---
to: src/<%= module %>/ui/<%= h.changeCase.param(component) %>/<%= h.changeCase.param(component) %>.view.tsx
---

import React from 'react'
import { Text, View } from 'react-native'

interface I<%= h.changeCase.pascal(component) %>ViewModel {
  optional?: any
}

const <%= h.changeCase.pascal(component) %>View: React.FC<I<%= h.changeCase.pascal(component) %>ViewModel> = (props) => (
  <View className="flex-1">
    <Text className="text-base text-black"><%= h.changeCase.param(component) %></Text>
  </View>
)

export default <%= h.changeCase.pascal(component) %>View
