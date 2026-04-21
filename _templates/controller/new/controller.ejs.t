---
to: src/<%= module %>/interfaces/controllers/<%= h.changeCase.param(controller) %>.controller.ts
---

import { IStore } from '../../../app/store'

export default class <%= h.changeCase.pascal(controller) %>Controller {
  private readonly store: IStore

  constructor (store: IStore) {
    this.store = store
  }
}
