---
to: src/<%= module %>/interfaces/gateways/<%= h.changeCase.param(repository) %>.repository.ts
---

import { runInAction } from 'mobx'
import { IStore } from '../../../app/store'

export default class <%= h.changeCase.pascal(repository) %>Repository {
  private readonly store: IStore

  constructor (store: IStore) {
    this.store = store
  }

  setIsLoading (value: boolean): void {
    runInAction(() => {
      // this.store.<%= module %>.isLoading = value
    })
  }

  setIsSuccess (value: boolean): void {
    runInAction(() => {
      // this.store.<%= module %>.isSuccess = value
    })
  }

  setError (message: string): void {
    runInAction(() => {
      // this.store.<%= module %>.error = message
    })
  }

  clearError (): void {
    runInAction(() => {
      // this.store.<%= module %>.error = null
    })
  }

}
