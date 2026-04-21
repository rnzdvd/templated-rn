---
to: src/<%= module %>/interfaces/gateways/<%= h.changeCase.param(repository) %>.repository.ts
---

import { IStore } from '../../../app/store'

export default class <%= h.changeCase.pascal(repository) %>Repository {
  private readonly store: IStore

  constructor (store: IStore) {
    this.store = store
  }

}
