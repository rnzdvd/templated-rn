module.exports = {
  prompt: ({ prompter, args }) => {
    if (args.projectType) {
      return Promise.resolve({ projectType: args.projectType });
    }
    return prompter.prompt({
      type: 'select',
      name: 'projectType',
      message: 'What type of React Native project is this?',
      choices: [
        { name: 'cli', message: 'CLI (React Native)' },
        { name: 'expo', message: 'Expo' },
      ],
    });
  },
}
