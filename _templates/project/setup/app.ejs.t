---
to: src/app/app.tsx
---

import '../../global.css';
import { configure } from 'mobx';
import React from 'react';
import { StyleSheet } from 'react-native';
import { GestureHandlerRootView } from 'react-native-gesture-handler';
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

const App: React.FC = () => {
  return SHOW_STORYBOOK && __DEV__ ? (
    <StorybookUI />
  ) : (
    <StoreContext.Provider value={firstStore}>
      <GestureHandlerRootView style={styles.container}>
        <Navigator />
        <Toast />
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
