#!/usr/bin/env node

const { readFileSync } = require('fs');
const yaml = require('js-yaml');

function getYaml() {
  const yamlContent = readFileSync(0);
  return yaml.load(yamlContent) ?? {};
}

(async () => {
  const dockerComposeConfig = await getYaml();
  const volumes = dockerComposeConfig?.volumes;

  if (volumes) {
    console.log(Object.keys(volumes).join(' '));
  }
})();
