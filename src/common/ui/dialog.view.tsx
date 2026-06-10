import React from 'react';
import { Modal, Pressable, Text, View } from 'react-native';

interface IAppDialogViewModel {
  visible: boolean;
  onDismiss: () => void;
  title?: string;
  children: React.ReactNode;
  actions?: React.ReactNode;
}

const AppDialog: React.FC<IAppDialogViewModel> = props => (
  <Modal
    visible={props.visible}
    transparent
    animationType="fade"
    onRequestClose={props.onDismiss}
  >
    <Pressable
      className="flex-1 bg-black/50 justify-center px-6"
      onPress={props.onDismiss}
    >
      <View
        className="bg-white rounded-2xl p-6"
        onStartShouldSetResponder={() => true}
      >
        {!!props.title && (
          <Text className="text-lg font-bold mb-3">{props.title}</Text>
        )}
        {props.children}
        {!!props.actions && (
          <View className="flex-row justify-end gap-2 mt-4">
            {props.actions}
          </View>
        )}
      </View>
    </Pressable>
  </Modal>
);

export default AppDialog;
