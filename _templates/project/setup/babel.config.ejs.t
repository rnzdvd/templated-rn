---
to: babel.config.js
---
module.exports = {
<%_ if (projectType === 'expo') { _%>
  presets: [
    ['babel-preset-expo', { jsxImportSource: 'nativewind' }],
    'nativewind/babel',
  ],
  plugins: [
    'react-native-reanimated/plugin', // ← MUST be last
  ],
<%_ } else { _%>
  presets: ['module:@react-native/babel-preset', 'nativewind/babel'],
  plugins: [
    ['module:react-native-dotenv', {
      moduleName: '@env',
      path: '.env',
      safe: false,
      allowUndefined: true,
    }],
    'react-native-reanimated/plugin', // ← MUST be last
  ],
<%_ } _%>
};
