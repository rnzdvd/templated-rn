---
to: src/<%= module %>/screens/<%= h.changeCase.param(screen) %>.screen.tsx
---

import React from 'react'
import AppScreen, { IScreenContainer } from '../../common/ui/app.screen'

const <%= h.changeCase.pascal(screen) %>Screen: React.FC<IScreenContainer> = ({ navigation }) => {
  return (
    <AppScreen
      title='<%= h.changeCase.pascal(screen) %>'
      navigation={navigation}
    />
  )
}

export default <%= h.changeCase.pascal(screen) %>Screen
