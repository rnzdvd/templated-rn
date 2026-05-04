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

- **Entity:** Implement `setFromApiModel`. Map `snake_case` (API) to `camelCase` (Class).
- **Store:** Module-scoped (`<module>.store.ts`). Add feature-prefixed observables (e.g., `loginData`, `isLoading`, `error`). **Must** register in `src/app/store.ts` under the module key (e.g., `auth: new AuthStore()`). If the store already exists, add new observables to it — do not create a second store.
- **Repository:** All mutations must be wrapped in `runInAction(() => { ... })` — never mutate store state outside `runInAction`. Create setter methods: `setX(data)`, `setIsLoading(bool)`, `setError(string)`, `clearError()`. It can create getter methods also to get data for use case classes.
- **UseCase:** Wrap body in `try/catch`. On catch, call `this.repository.setError('Something went wrong')`. 1. Set `isLoading(true)`. 2. Call `gateway`. 3. Validate with `codeStatusChecker(response.status_code)` — **this is the only success check; never add `&& response.data.<field>`**. 4. If success: Map to Entity and call `repository.setX()`; set `repository.setIsSuccess(true)`; call `repository.clearError()`. 5. If fail: Call `repository.setError()`; set `repository.setIsSuccess(false)`. 6. Set `isLoading(false)`. **Never call `showToast` here** — toast notifications belong in the Container.
- **Controller:** Instantiate the Repository, Gateway, and UseCase. Expose an `execute` method. Returns `void` — never return data; callers read state via the Presenter.
- **Presenter:** Create read-only getters for store data.

## 🔗 Phase 4: UI Wiring

- **Container:** Use `useContext(StoreContext)`. Wrap the return in `<Observer>`. Internal handler functions must be defined **outside** the `Observer` render callback — above the return statement. After `await controller.x()`, read outcome via `presenter.isSuccess()` / `presenter.getErrorMessage()` and call `showToast` here — not in the UseCase. **Never read from the store directly in a Container** — always go through the Presenter (e.g. `presenter.isLoading()`, not `store.auth.isLoading`).
- **View:** Update `I<Name>ViewModel` to include `isLoading` and `error`. Render an `ActivityIndicator` if loading.

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
- [ ] Ensure `makeObservable` is in the Entity constructor.
- [ ] Props callbacks use `on` prefix; internal handlers use `handle` prefix.
- [ ] Navigation functions in Screens use `navigateTo<Destination>` prefix (e.g. `navigateToHome`, not `handleDeleteSuccess`).
