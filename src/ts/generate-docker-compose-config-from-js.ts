#!/usr/bin/env node

import { writeFile } from 'fs/promises';
import * as yaml from 'js-yaml';

const [ source ] = process.argv.slice(2);

(async () => {
  const dockerComposeConfig = require(source);
  const yamlConfig = yaml.dump(dockerComposeConfig);
  await writeFile(`${source}.yml`, yamlConfig);
})();
