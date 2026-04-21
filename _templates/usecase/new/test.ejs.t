---
to: src/<%= module %>/usecases/<%= h.changeCase.param(usecase) %>/<%= h.changeCase.param(usecase) %>.test.ts
---

import getStore from '../../../app/store'
import <%= h.changeCase.pascal(usecase) %>Case from './<%= h.changeCase.param(usecase) %>.case'

describe('<%= h.changeCase.sentence(usecase) %>', () => {
  let useCase: <%= h.changeCase.pascal(usecase) %>Case

  const store = getStore()

  beforeEach(() => {
    useCase = new <%= h.changeCase.pascal(usecase) %>Case()
  })

  test('execute', async () => {
    await useCase.execute()
    expect(null).toBeTruthy()
  })
})
