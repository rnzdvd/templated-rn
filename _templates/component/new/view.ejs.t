---
to: src/<%= module %>/ui/<%= h.changeCase.param(component) %>/<%= h.changeCase.param(component) %>.view.tsx
---

import React from 'react'
import { StyleSheet, View } from 'react-native'
import { Text } from "react-native-paper";

interface I<%= h.changeCase.pascal(component) %>ViewModel {
  optional?: any
}

const <%= h.changeCase.pascal(component) %>View: React.FC<I<%= h.changeCase.pascal(component) %>ViewModel> = (props) => (
  <View style={styles.container}>
    <Text><%= h.changeCase.param(component) %></Text>
  </View>
)

export default <%= h.changeCase.pascal(component) %>View

const styles = StyleSheet.create({
  container: {
  }
})
