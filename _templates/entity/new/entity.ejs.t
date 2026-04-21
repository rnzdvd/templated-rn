---
to: src/<%= module %>/entities/<%= h.changeCase.param(entity) %>.entity.ts
---

import { makeAutoObservable } from 'mobx'

export default class <%= h.changeCase.pascal(entity) %>Entity {
  constructor () {
    makeAutoObservable(this)
  }
}
