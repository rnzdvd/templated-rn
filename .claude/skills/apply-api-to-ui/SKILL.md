---
name: apply-api-to-ui
description: Wire a real API endpoint to an existing UI using Clean Architecture. Use for: "connect API", "fetch real data", "integrate backend", or "replace mocks".
---

# API Integration Skill

## 🛠️ Phase 1: Dependency Mapping & Generation

**Rule:** Never write files from scratch. Always generate via hygen CLI args — Claude runs these directly, not the user:

```bash
npx hygen usecase new --module <module> --usecase <name>
npx hygen gateway api --module <module> --gateway <name>
npx hygen gateway repo --module <module> --repository <name>
npx hygen controller new --module <module> --controller <name>
npx hygen presenter new --module <module> --presenter <name>
npx hygen store new --module <module> --store <module>
npx hygen entity new --module <module> --entity <name>
```

1.  **Identify Missing Layers:** Search `src/<module>/` for: `entity`, `store`, `controller`, `repository`, `gateway`, `presenter`, `usecase`.
2.  **Generate:** Run the required hygen commands above for any missing layer.
    - **Gateway rule:** Each module has its own gateway (`<module>.gateway.ts`) that extends `Api` directly — there is no shared `ApiGateway`. Generate with `npx hygen gateway api`.
    - **Store rule:** The store is **module-scoped**, not feature-scoped. It must be named after the module (e.g., `auth.store.ts` for the `auth` module), with class name `<Module>Store` (e.g., `AuthStore`). If `src/<module>/entities/<module>.store.ts` already exists, **do not generate a new one** — add new observables to the existing store instead.
    - **Store registration:** Register as `<module>: new <Module>Store()` in `src/app/store.ts` (e.g., `auth: new AuthStore()`).
    - **Observable naming:** Since one store serves multiple features, prefix observable names with the feature (e.g., `loginData` not `data`) to avoid collisions.
3.  **Read Base Classes:** To ensure correct inheritance, read:
    - `src/common/entities/base-api-mapped.entity.ts`
    - `src/common/api/api.ts`

## 📡 Phase 2: API Contract Definition

1.  **Define Models:** Add the response shape to `src/common/api/api-models.ts`.
2.  **Update Gateway:** Add the typed method to `ApiGateway` using `this.get`, `this.post`, etc.
    - _Pattern:_ `async methodName(): Promise<{ status_code: number; data: T }>`

## 🏗️ Phase 3: Layer Implementation

For each generated file, follow these project-specific logic rules:

- **Entity:** One entity per file — never combine multiple entities in a single file. All raw API interfaces (e.g. `ILesson`, `IExercise`) go in a sibling `interfaces.ts`, never inside an entity file. Each entity class must extend `BaseApiMappedEntity`, call `makeAutoObservable(this)` in the constructor, declare typed public properties with default values, and implement `setFromApiModel()` mapping `snake_case` (API) → `camelCase` (class).
- **Store:** Module-scoped (`<module>.store.ts`). Add feature-prefixed observables (e.g., `loginData`, `isLoading`, `error`). **Must** register in `src/app/store.ts` under the module key (e.g., `auth: new AuthStore()`). If the store already exists, add new observables to it — do not create a second store.
- **Repository:** Constructor accepts exactly one parameter: `store: IStore` (from `src/app/store.ts`) — never individual module stores. Access the module slice internally via `store.<moduleStore>.*`. All mutations must be wrapped in `runInAction(() => { ... })`. Create setter methods: `setX(data)`, `setIsLoading(bool)`, `setError(string)`, `clearError()`. Add getter methods (e.g. `getSelectedTopicId()`) when a UseCase needs to read data from this store — the UseCase must call the getter, never access the store directly.
- **UseCase:** Never inject or access a store directly — all store reads must go through a Repository getter method (e.g. `onboardingRepository.getSelectedTopicId()`). Wrap body in `try/catch`. On catch, call `this.repository.setError('Something went wrong')`. 1. Set `isLoading(true)`. 2. Call `gateway`. 3. Validate with `codeStatusChecker(response.status_code)` — **this is the only success check; never add `&& response.data.<field>`**. 4. If success: Map to Entity and call `repository.setX()`; set `repository.setIsSuccess(true)`; call `repository.clearError()`. 5. If fail: Call `repository.setError()`; set `repository.setIsSuccess(false)`. 6. Set `isLoading(false)`. **Never call `showToast` here** — toast notifications belong in the Container.
- **Controller:** Constructor accepts exactly one parameter: `store: IStore`. Instantiate Repository, Gateway, and UseCases internally. Expose action methods only — **never expose getters or return data**; all data reads belong in the Presenter. **Never call repository methods directly** — every action, including simple mutations, must go through a use case. If no use case exists for the action, create one.
- **Presenter:** Constructor accepts exactly one parameter: `store: IStore`. Create read-only getters accessing `store.<moduleStore>.*`.

## 🔗 Phase 4: UI Wiring

- **Container:** Use `useContext(StoreContext)`. Wrap the return in `<Observer>`. Internal handler functions must be defined **outside** the `Observer` render callback — above the return statement. After `await controller.x()`, read outcome via `presenter.isSuccess()` / `presenter.getErrorMessage()` and call `showToast` here — not in the UseCase. **Never read from the store directly in a Container** — always go through the Presenter (e.g. `presenter.isLoading()`, not `store.auth.isLoading`). **Exactly one controller and one presenter per Container** — instantiate each once (e.g. `const controller = new LoginController(store)`, `const presenter = new LoginPresenter(store)`). If the Container needs actions/data from another feature, add the methods to the existing controller/presenter instead of instantiating a second one; never declare two controllers or two presenters in the same Container.
- **View:** Update `I<Name>ViewModel` to include `isLoading` and `error`. Render an `ActivityIndicator` if loading.

## 🧹 Phase 5: Mock Data Cleanup

**Rule:** Only perform this phase after the real API call has been verified end-to-end — gateway wired, use case executing, data flowing through Repository → Store → Presenter → View, and the screen renders live data successfully. If wiring fails, is untested, or the endpoint isn't reachable yet, **leave the mock data in place** and do not proceed with this phase.

Once wiring is confirmed successful:

1.  **Locate mock sources** tied to this specific API/feature:
    - Hardcoded mock arrays/objects in the View or Container (e.g. `const mockLessons = [...]`).
    - `.mock` / `mock()` static helpers or fixtures on the entity (e.g. `<Entity>.mock`) that were only used to fake this data before the API existed.
    - Mock imports (e.g. `import { mockX } from './mock-data'`) and now-unused mock data files, if nothing else references them.
    - Any `isLoading`/data fallback logic that exists only to display mock data.
2.  **Remove only what's replaced:** Delete mock data/usages exclusively for the feature just wired. Never remove mocks still used by other unwired features, Storybook stories, or tests.
3.  **Verify no dangling references:** After removal, search the module for the mock identifier/file to confirm nothing else imports it before deleting the file itself.
4.  **Do not delete test fixtures** — `*.test.ts` files may legitimately use mock entities/data for unit testing; this phase only targets mocks used to fake real UI data.

### Function naming convention

| Location                              | Prefix                    | Example                               |
| ------------------------------------- | ------------------------- | ------------------------------------- |
| Passed as a prop to a child component | `on`                      | `onLogin`, `onDelete`, `onSubmit`     |
| Internal handler (not a prop)         | `handle`                  | `handleLogin`, `handleDelete`         |
| Navigation function in a Screen       | `navigateTo<Destination>` | `navigateToHome`, `navigateToProfile` |

> **Screen navigation handlers** must describe the destination, not the triggering action. Use `navigateToHome`, not `handleDeleteSuccess` or `handleNavigation`.

```tsx
// Container — correct
const handleLogin = (values: ILoginFormModel) => {
  controller.login(values);
};

return (
  <Observer>
    {() => (
      <LoginView
        onLogin={handleLogin} // prop → "on" prefix
      />
    )}
  </Observer>
);
```

```tsx
// View — correct
interface ILoginViewModel {
  onLogin: (values: ILoginFormModel) => void; // prop → "on" prefix
}
```

---

## Checklist for Claude

- [ ] Use `apisauce` methods only.
- [ ] No direct store access from View, Controller, or Container — all state reads go through the Presenter.
- [ ] All business logic stays in the UseCase.
- [ ] UseCase success check uses `codeStatusChecker(response.status_code)` only — no `&& response.data.<field>` checks.
- [ ] UseCase never calls `showToast` — toast notifications go in the Container.
- [ ] Controller methods return `void` — never return data from a controller.
- [ ] Container reads outcome via `presenter.isSuccess()` / `presenter.getErrorMessage()` after awaiting the controller.
- [ ] Each entity is in its own file; API interfaces live in `interfaces.ts`, not inside entity files.
- [ ] Ensure `makeAutoObservable` is in the Entity constructor.
- [ ] Repository, Controller, and Presenter each take exactly one constructor parameter: `store: IStore`.
- [ ] UseCase never injects a store directly — reads go through Repository getter methods.
- [ ] Controller never calls repository methods directly — every mutation routes through a use case.
- [ ] Controller exposes no getters and returns no data — data reads belong in the Presenter.
- [ ] Props callbacks use `on` prefix; internal handlers use `handle` prefix.
- [ ] Navigation functions in Screens use `navigateTo<Destination>` prefix (e.g. `navigateToHome`, not `handleDeleteSuccess`).
- [ ] Container declares exactly one controller instance and one presenter instance — no duplicate controller/presenter instantiations.
- [ ] Mock data for this feature removed **only if** the API call was verified working and wired to the UI — left in place otherwise; other features' mocks and test fixtures are untouched.
