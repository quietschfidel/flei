#!/usr/bin/env node

import { readFile, writeFile, readdir, rm, mkdtemp } from 'fs/promises';
import { move } from 'fs-extra';
import { tmpdir } from 'os';
import * as NodeGit from 'nodegit';
import * as yaml from 'js-yaml';
import * as crypto from 'crypto';
import * as path from 'path';
import * as  dotenv from 'dotenv';

const baseDirectory = process.env.FLEI_BASE_DIRECTORY;
const installedPluginsPath = path.join(baseDirectory, '.flei', 'installed-plugins.yaml');
const pluginsPath = path.join(baseDirectory, '.flei', 'plugins');
const pluginLocksPath = path.join(baseDirectory, 'plugins-lock.yaml')

function getConfigPath(configPath: string): string {
  const relativePath = configPath.replace(/^\//, '');
  return path.join(baseDirectory, relativePath);
}

async function getTempDirectory() {
  const tmpDir = path.join(tmpdir(), `flei-`);
  return await mkdtemp(tmpDir);
}

async function getYaml(src) {
  const yamlContent = await readFile(src).catch(() => {
    return '';
  });
  return yaml.load(yamlContent) ?? {};
}

async function getEnvFile(src) {
  const envContent = await readFile(src).catch(() => {
    return '';
  });

  return dotenv.parse(envContent);
}

async function saveYaml(target, data) {
  const yamlContent = yaml.dump(data);
  return await writeFile(target, yamlContent);
}

function getAuthConfig(authConfig) {
  if (authConfig.type === 'basic') {
    const config = {
      userVariableName: 'FLEI_PLUGIN_GIT_USERNAME',
      passwordVariableName: 'FLEI_PLUGIN_GIT_PASSWORD',
      envFile: 'config/local/.env.flei-plugins',
      ...authConfig
    };
    const envFilePath = getConfigPath(config.envFile);
    const credentials = getEnvFile(envFilePath);

    return NodeGit.Cred.userpassPlaintextNew(
      credentials[config.userVariableName],
      credentials[config.passwordVariableName]
    );
  }

  if (authConfig.type === 'ssh') {
    const config = {
      username: 'git',
      publicKey: 'config/local/id_ed25519.pub',
      privateKey: 'config/local/id_ed25519',
      passphrase: '',
      ...authConfig
    };

    return NodeGit.Cred.sshKeyNew(
      config.username,
      getConfigPath(config.publicKey),
      getConfigPath(config.privateKey),
      config.passphrase
    );
  }

  return {};
}

function getCloneOptions(authConfig) {
  if(authConfig !== undefined) {
    return {
        fetchOpts: {
          callbacks: {
            credentials: function () {
              return getAuthConfig(authConfig);
            }
          }
        }
      }
  }

  return {};
}

async function gitTypeHandler(config, lock) {
  const tempDir = await getTempDirectory();

  const repo = await NodeGit.Clone(config.src, tempDir, getCloneOptions(config.auth));

  const hash = await ((async () => {
    if (config.hash) {
      return config.hash;
    }

    if (lock) {
      return lock;
    }

    const commit = await repo.getHeadCommit();
    return commit.sha();
  })());

  /**
   * todo: ensure that the sha is a valid commit hash
   */
  const commit = await repo.getCommit(hash);
  await NodeGit.Reset(repo, commit, NodeGit.Reset.TYPE.HARD);

  // remove git, that we won't confuse IDE or tools in our project work space
  await rm(path.join(tempDir, '.git'), {
    recursive: true
  });

  const pluginConfig = await getYaml(path.join(tempDir, 'flei.yaml'));
  const name = pluginConfig.name ?? config.name;
  if (!name) {
    /**
     * todo: we need clean failures, so we shouldn't modify anything on filesystem
     *       until we know that such stuff worked
     */

    await rm(tempDir, {
      recursive: true
    });

    console.error(`Plugin installation failed.`);
    console.error(`${config.src} does not contain a valid flei.yaml config.`);
    process.exit(1);
  }

  await removePlugin(name);
  await move(tempDir, path.join(pluginsPath, name));

  return {
    name: name,
    lock: hash
  };
}

function getHash(config) {
  const stringified = JSON.stringify(config);
  return crypto.createHash('md5').update(stringified).digest('hex');
}

async function removePlugin(pluginName) {
  await rm(path.join(pluginsPath, pluginName), {
    recursive: true
  }).catch(() => null);
}

(async () => {
  const config = await getYaml(path.join(baseDirectory, 'flei.yaml'));
  const installedPlugins = await getYaml(installedPluginsPath);
  const pluginLocks = await getYaml(pluginLocksPath);
  const pluginConfigs = config?.plugins ?? [];

  const pluginTypeHandlers = {
    git: gitTypeHandler
  }

  const newInstalledPlugins = {};
  const newLocks = {};

  for (const pluginConfig of pluginConfigs) {
    const type = pluginConfig.type ?? null;
    if (!type) {
      console.error(`Flei plugin installation failed.`);
      console.error(`There is no plugin type defined.`);
      process.exit(1);
    }

    const handler = pluginTypeHandlers[type];

    if (!handler) {
      console.error(`Flei plugin installation failed.`);
      console.error(`Invalid plugin type: ${type}.`);
      process.exit(1);
    }

    const hashedConfig = getHash(pluginConfig);
    const pluginLock = pluginLocks[hashedConfig];
    const pluginHash = getHash([pluginConfig, pluginLock]);
    const existingInstallation = installedPlugins[pluginHash];

    if (existingInstallation) {
      newInstalledPlugins[pluginHash] = existingInstallation;
      newLocks[hashedConfig] = pluginLock;
      continue;
    }

    const { lock, name } = await handler(pluginConfig, pluginLock);
    newInstalledPlugins[pluginHash] = name;
    newLocks[hashedConfig] = lock;
  }

  const existingPluginDirectories = await readdir(pluginsPath);

  const pluginsToDelete = Object.values(existingPluginDirectories).filter((name) => {
    if (name === 'flei') {
      return false;
    }

    if (Object.values(newInstalledPlugins).includes(name)) {
      return false;
    }

    return true;
  });

  for (const pluginName of pluginsToDelete) {
    await removePlugin(pluginName);
  }

  await saveYaml(installedPluginsPath, newInstalledPlugins);
  await saveYaml(pluginLocksPath, newLocks);
})();
