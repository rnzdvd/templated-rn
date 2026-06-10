import React from 'react';
import { ActivityIndicator, Pressable, Text } from 'react-native';
import { Colors } from '../colors';

type AppButtonVariant = 'contained' | 'outlined' | 'text';

interface IAppButtonViewModel {
  label: string;
  onPress: () => void;
  variant?: AppButtonVariant;
  loading?: boolean;
  disabled?: boolean;
  className?: string;
}

const containerClasses: Record<AppButtonVariant, string> = {
  contained:
    'flex-row items-center justify-center bg-primary rounded-lg px-4 py-3',
  outlined:
    'flex-row items-center justify-center border border-primary bg-transparent rounded-lg px-4 py-3',
  text: 'flex-row items-center justify-center px-4 py-3',
};

const labelClasses: Record<AppButtonVariant, string> = {
  contained: 'text-white text-base font-semibold',
  outlined: 'text-primary text-base font-semibold',
  text: 'text-primary text-base font-semibold',
};

const AppButton: React.FC<IAppButtonViewModel> = props => {
  const variant = props.variant ?? 'contained';
  const inactive = props.disabled || props.loading;

  return (
    <Pressable
      className={`${containerClasses[variant]} ${
        inactive ? 'opacity-50' : 'active:opacity-80'
      } ${props.className ?? ''}`}
      onPress={props.onPress}
      disabled={inactive}
    >
      {props.loading && (
        <ActivityIndicator
          size="small"
          color={variant === 'contained' ? Colors.white : Colors.primary}
          className="mr-2"
        />
      )}
      <Text className={labelClasses[variant]}>{props.label}</Text>
    </Pressable>
  );
};

export default AppButton;
