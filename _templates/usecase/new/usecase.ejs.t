---
to: src/<%= module %>/usecases/<%= h.changeCase.param(usecase) %>/<%= h.changeCase.param(usecase) %>.case.ts
---



export default class <%= h.changeCase.pascal(usecase) %>Case {
  constructor (
  ) {
    console.log('init')
  }

  async execute (): Promise<void> {
    return Promise.resolve()
  }
}
