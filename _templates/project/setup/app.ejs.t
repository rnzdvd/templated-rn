---
to: src/app/app.tsx
---

import { configure } from 'mobx';
import React from 'react';
import { StyleSheet } from 'react-native';
import { GestureHandlerRootView } from 'react-native-gesture-handler';
import { DefaultTheme, PaperProvider } from 'react-native-paper';
import { ThemeProp } from 'react-native-paper/lib/typescript/types';
import { enableFreeze, enableScreens } from 'react-native-screens';
import Toast from 'react-native-toast-message';
import StorybookUI from '../../.rnstorybook';
import { SHOW_STORYBOOK } from '../common/config';
import Navigator from './navigator';
import getStore, { StoreContext } from './store';
enableScreens();
enableFreeze();

configure({
  enforceActions: 'always',
});

const firstStore = getStore();

const theme: ThemeProp = {
  ...DefaultTheme,
  colors: {
    ...DefaultTheme.colors,
    primary: '#007AFF',
    secondary: '#007AFF',
  },
};

const App: React.FC = () => {
  return SHOW_STORYBOOK && __DEV__ ? (
    <StorybookUI />
  ) : (
    <StoreContext.Provider value={firstStore}>
      <GestureHandlerRootView style={styles.container}>
        <PaperProvider theme={theme}>
          <Navigator />
          <Toast />
        </PaperProvider>
      </GestureHandlerRootView>
    </StoreContext.Provider>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
});

export default App;
