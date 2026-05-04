---
to: src/<%= module %>/interfaces/gateways/<%= h.changeCase.param(gateway) %>.gateway.ts
---

import { IStore } from '../../../app/store'
import { Api } from '../../../common/api/api'

export default class <%= h.changeCase.pascal(gateway) %>Gateway extends Api {
  constructor (store: IStore) {
    super(store)
  }

  // Add <%= h.changeCase.param(gateway) %>-specific API methods here
}
