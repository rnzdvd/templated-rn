#!/usr/bin/env node
// Usage (from any new project root — works on Windows, macOS, Linux):
//   npx github:rnzdvd/react-native-scaffold
// then: yarn setup

const { spawnSync } = require('child_process');

const REPO = 'rnzdvd/templated-rn';

const folders = [
  { src: `${REPO}/_templates`, dest: '_templates' },
  { src: `${REPO}/.claude/skills`, dest: '.claude/skills' },
  { src: `${REPO}/scripts`, dest: 'scripts' },
];

console.log('\nPulling TemplatedRN tooling...\n');

for (const { src, dest } of folders) {
  console.log(`  → ${dest}`);
  const result = spawnSync('npx', ['degit', src, dest, '--force'], {
    stdio: 'inherit',
    shell: true,
  });
  if (result.status !== 0) {
    console.error(`\nFailed to pull ${dest}. Make sure the repo is public and degit is available.`);
    process.exit(result.status ?? 1);
  }
}

console.log('\nDone! Run `node scripts/setup.js` to initialize the project.\n');
