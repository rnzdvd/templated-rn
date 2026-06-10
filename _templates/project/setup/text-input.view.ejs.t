---
to: src/common/ui/text-input.view.tsx
---
import React from 'react';
import { Text, TextInput, TextInputProps, View } from 'react-native';

interface IAppTextInputViewModel extends TextInputProps {
  label?: string;
  error?: string;
}

const AppTextInput: React.FC<IAppTextInputViewModel> = ({
  label,
  error,
  ...inputProps
}) => (
  <View className="w-full">
    {!!label && <Text className="text-sm text-black mb-1">{label}</Text>}
    <TextInput
      className={`border rounded-lg px-3 py-2 text-base text-black ${
        error ? 'border-red-500' : 'border-black/20'
      }`}
      {...inputProps}
    />
    {!!error && <Text className="text-red-500 text-xs mt-1">{error}</Text>}
  </View>
);

export default AppTextInput;
