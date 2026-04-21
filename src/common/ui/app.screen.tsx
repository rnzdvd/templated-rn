import { ParamListBase, RouteProp } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import React, { JSX } from 'react';
import { ColorValue, StatusBarStyle } from 'react-native';
import { Edges } from 'react-native-safe-area-context';
import Container from './container.view';

export interface IScreenContainer {
  navigation: NativeStackNavigationProp<ParamListBase, string>;
  route: RouteProp<ParamListBase>;
}

export interface IAppScreen {
  title?: string;
  children: JSX.Element;
  barStyle: StatusBarStyle;
  statusBarBg: ColorValue;
  navigation?: NativeStackNavigationProp<ParamListBase, string>;
  edges?: Edges;
}

const AppScreen: React.FC<IAppScreen> = props => {
  return (
    <Container
      barStyle={props.barStyle}
      statusBarBg={props.statusBarBg}
      edges={props.edges}
    >
      {props.children}
    </Container>
  );
};

export default AppScreen;
