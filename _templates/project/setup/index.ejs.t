---
to: "<%= projectType === 'expo' ? 'index.tsx' : 'index.js' %>"
---
<%_ if (projectType === 'expo') { _%>
import { registerRootComponent } from 'expo';
import 'react-native-gesture-handler';
import App from './src/app/app';

export default function Index() {
  return <App />;
}

registerRootComponent(Index);
<%_ } else { _%>
/**
 * @format
 */

import { AppRegistry } from 'react-native';
import { name as appName } from './app.json';
import App from './src/app/app';

AppRegistry.registerComponent(appName, () => App);
<%_ } _%>
