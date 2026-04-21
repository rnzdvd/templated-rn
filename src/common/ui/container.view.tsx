import React, { JSX } from 'react';
import {
  ColorValue,
  KeyboardAvoidingView,
  StatusBarStyle,
  StyleSheet,
  View,
} from 'react-native';
import {
  Edges,
  SafeAreaProvider,
  SafeAreaView,
} from 'react-native-safe-area-context';
import CustomStatusBarView from './custom-status-bar.view';

interface IContainerViewModel {
  children: JSX.Element;
  barStyle: StatusBarStyle;
  statusBarBg: ColorValue;
  enableAvoidingView?: boolean;
  edges?: Edges;
}

const Container: React.FC<IContainerViewModel> = props => (
  <View style={styles.container}>
    <CustomStatusBarView
      barStyle={props.barStyle}
      backgroundColor={props.statusBarBg}
    />

    <SafeAreaProvider>
      <SafeAreaView
        edges={props.edges ?? []}
        style={[
          styles.container,
          {
            backgroundColor: props.statusBarBg,
          },
        ]}
      >
        <KeyboardAvoidingView
          style={styles.container}
          behavior="padding"
          keyboardVerticalOffset={0}
        >
          {props.children}
        </KeyboardAvoidingView>
      </SafeAreaView>
    </SafeAreaProvider>
  </View>
);

export default Container;

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
});
