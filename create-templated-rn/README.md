# react-native-scaffold

Pulls the TemplatedRN tooling into any React Native project in one command.

## Usage

Run this from your **new project root** (works on Windows, macOS, Linux):

```bash
npx github:rnzdvd/react-native-scaffold
```

Then initialize the project:

```bash
node scripts/setup.js
```

`scripts/setup.js` will ask:

```
What type of React Native project is this?
  1) CLI (React Native)
  2) Expo
```

Pick your target and it will generate all the boilerplate and update your `package.json` scripts automatically.

## What gets pulled

| Folder | Purpose |
| ------ | ------- |
| `_templates/` | hygen code generators (component, screen, usecase, etc.) |
| `.claude/skills/` | Claude Code AI skills for UI generation |
| `scripts/` | setup script |

## Requirements

- Node >= 22.11.0
- yarn
