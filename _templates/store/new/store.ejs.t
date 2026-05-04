---
to: src/<%= module %>/entities/<%= h.changeCase.param(store) %>.store.ts
---

import { makeAutoObservable } from 'mobx'

export default class <%= h.changeCase.pascal(store) %>Store {
  isLoading = false
  isSuccess = false
  error: string | null = null

  constructor () {
    makeAutoObservable(this)
  }
}
