---
to: src/<%= module %>/interfaces/presenters/<%= h.changeCase.param(presenter) %>.presenter.ts
---

import { IStore } from '../../../app/store'

export default class <%= h.changeCase.pascal(presenter) %>Presenter {
  private readonly store: IStore

  constructor (store: IStore) {
    this.store = store
  }

  isLoading (): boolean {
    return false // this.store.<%= module %>.isLoading
  }

  isSuccess (): boolean {
    return false // this.store.<%= module %>.isSuccess
  }

  errorMessage (): string | null {
    return null // this.store.<%= module %>.error
  }
}
