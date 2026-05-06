const readline = require('readline');
const { spawnSync } = require('child_process');
const fs = require('fs');
const path = require('path');

const CHOICES = [
  { label: 'CLI (React Native)', value: 'cli' },
  { label: 'Expo', value: 'expo' },
];

const SHARED_SCRIPTS = {
  lint: 'eslint .',
  format: 'prettier --write "**/*.{js,jsx,ts,tsx,json,md}"',
  'format:check': 'prettier --check "**/*.{js,jsx,ts,tsx,json,md}"',
  test: 'jest',
  component: 'hygen component new && yarn prestorybook',
  case: 'hygen usecase new',
  controller: 'hygen controller new',
  presenter: 'hygen presenter new',
  screen: 'hygen screen new',
  container: 'hygen container new',
  entity: 'hygen entity new',
  gateway: 'hygen gateway api',
  repo: 'hygen gateway repo',
  store: 'hygen store new',
  setup: 'node scripts/setup.js',
  storybook: 'npm create storybook@latest',
  'storybook-generate': 'sb-rn-get-stories',
};

const CLI_SCRIPTS = {
  start: 'react-native start',
  android: 'react-native run-android',
  ios: 'react-native run-ios',
  ...SHARED_SCRIPTS,
  apk: 'cd android && ./gradlew assembleRelease',
  aab: 'cd android && ./gradlew bundleRelease',
};

const EXPO_SCRIPTS = {
  start: 'expo start',
  android: 'expo run:android',
  ios: 'expo run:ios',
  prebuild: 'expo prebuild --clean',
  ...SHARED_SCRIPTS,
  apk: 'eas build -p android --profile preview --clear-cache',
  aab: 'eas build -p android --profile production --clear-cache',
  ipa: 'eas build -p ios --profile preview --clear-cache',
  playstore: 'eas build -p android --profile production --auto-submit',
  testflight: 'eas build -p ios --profile production --auto-submit',
  creds: 'eas credentials',
  'apk-local': 'cd android && ./gradlew assembleRelease',
  'aab-local': 'cd android && ./gradlew bundleRelease',
};

const rl = readline.createInterface({ input: process.stdin, output: process.stdout });

console.log('\nWhat type of React Native project is this?\n');
CHOICES.forEach((c, i) => console.log(`  ${i + 1}) ${c.label}`));
console.log('');

rl.question('Enter choice [1]: ', (answer) => {
  rl.close();

  const index = answer.trim() === '' ? 0 : parseInt(answer, 10) - 1;

  if (isNaN(index) || index < 0 || index >= CHOICES.length) {
    console.error('\nInvalid choice. Run yarn setup again.');
    process.exit(1);
  }

  const { value: projectType, label } = CHOICES[index];
  console.log(`\nScaffolding for ${label}...\n`);

  const root = path.join(__dirname, '..');

  if (projectType === 'cli') {
    const toDelete = ['App.tsx', 'babel.config.js', 'index.js'];
    for (const rel of toDelete) {
      const target = path.join(root, rel);
      if (fs.existsSync(target)) {
        fs.rmSync(target, { force: true });
        console.log(`Deleted: ${rel}`);
      }
    }
  }

  const result = spawnSync(
    'npx',
    ['hygen', 'project', 'setup', '--projectType', projectType],
    { stdio: 'inherit', shell: true },
  );

  if (result.status !== 0) {
    process.exit(result.status ?? 1);
  }

  const pkgPath = path.join(__dirname, '..', 'package.json');
  const pkg = JSON.parse(fs.readFileSync(pkgPath, 'utf8'));
  pkg.scripts = projectType === 'expo' ? EXPO_SCRIPTS : CLI_SCRIPTS;
  if (projectType === 'expo') {
    pkg.main = 'index.tsx';
  } else {
    delete pkg.main;
  }
  fs.writeFileSync(pkgPath, JSON.stringify(pkg, null, 2) + '\n');

  console.log(`\npackage.json scripts updated for ${label}.`);

  if (projectType === 'expo') {
    const toDelete = ['app', 'components', 'hooks', 'constants', 'scripts/reset-project.js'];
    for (const rel of toDelete) {
      const target = path.join(root, rel);
      if (fs.existsSync(target)) {
        fs.rmSync(target, { recursive: true, force: true });
        console.log(`Deleted: ${rel}`);
      }
    }
  }
});
