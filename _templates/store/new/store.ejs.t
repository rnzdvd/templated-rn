---
to: src/<%= module %>/entities/<%= h.changeCase.param(store) %>.store.ts
---

import { makeAutoObservable } from 'mobx'

export default class <%= h.changeCase.pascal(store) %>store {
  constructor () {
    makeAutoObservable(this)
  }
}
