import { ColorValue, StatusBar, StatusBarStyle, View } from 'react-native';

const CustomStatusBarView: React.FC<{
  backgroundColor: ColorValue;
  barStyle: StatusBarStyle;
}> = props => {
  return (
    <View style={{ backgroundColor: props.backgroundColor }}>
      <StatusBar {...props} translucent />
    </View>
  );
};

export default CustomStatusBarView;

