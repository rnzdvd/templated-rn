---
to: src/<%= module %>/ui/<%= h.changeCase.param(component) %>/<%= h.changeCase.param(component) %>.container.tsx
---

import React from 'react'
import <%= h.changeCase.pascal(component) %>View from './<%= h.changeCase.param(component) %>.view'
import { Observer } from 'mobx-react-lite'

const <%= h.changeCase.pascal(component) %>Container: React.FC = () => (
  <Observer>
    {() => {
      return (
        <<%= h.changeCase.pascal(component) %>View />
      )
    }}
  </Observer>
)

export default <%= h.changeCase.pascal(component) %>Container
