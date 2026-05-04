---
to: src/<%= module %>/usecases/<%= h.changeCase.param(usecase) %>/<%= h.changeCase.param(usecase) %>.case.ts
---



import <%= h.changeCase.pascal(module) %>Gateway from '../../interfaces/gateways/<%= h.changeCase.param(module) %>.gateway'
import <%= h.changeCase.pascal(usecase) %>Repository from '../../interfaces/gateways/<%= h.changeCase.param(usecase) %>.repository'

export default class <%= h.changeCase.pascal(usecase) %>Case {
  constructor (
    private readonly gateway: <%= h.changeCase.pascal(module) %>Gateway,
    private readonly repository: <%= h.chpacangeCase.pascal(usecase) %>Repository,
  ) {}

  async execute (): Promise<void> {
    try {
      this.repository.setIsLoading(true)
      // const response = await this.gateway.method()
      // if (!codeStatusChecker(response.status_code)) {
      //   this.repository.setError(response.data)
      //   this.repository.setIsSuccess(false)
      //   return
      // }
      // this.repository.setX(response.data)
      this.repository.setIsSuccess(true)
      this.repository.clearError()
    } catch {
      this.repository.setError('Something went wrong')
      this.repository.setIsSuccess(false)
    } finally {
      this.repository.setIsLoading(false)
    }
  }
}
