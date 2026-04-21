import {
  NavigationContainer,
  NavigationContainerRef,
} from '@react-navigation/native';
// import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { Observer } from 'mobx-react-lite';
import React from 'react';

// const Stack = createNativeStackNavigator();

const Navigator: React.FC = () => {
  const navigationRef =
    React.useRef<NavigationContainerRef<ReactNavigation.RootParamList> | null>(
      null,
    );

  return (
    <NavigationContainer ref={navigationRef}>
      <Observer>
        {() => {
          // TODO: Add your Main stack navigator here, Also you can wrap your providers here.
          return <></>;
        }}
      </Observer>
    </NavigationContainer>
  );
};

// Ex. of stack navigator, you can add more stacks as you like.
// const BaseStack: React.FC = () => (
//   <Stack.Navigator
//     id={undefined}
//     initialRouteName={ScreenNames.LoginScreen}
//     screenOptions={{ headerShown: false }}
//   >
//     {/* <Stack.Screen name={ScreenNames.LoginScreen} component={LoginScreen} /> */}
//   </Stack.Navigator>
// );

export default Navigator;
