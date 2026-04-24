---
name: apply-api-to-ui
description: Wire a real API endpoint to an existing UI using Clean Architecture. Use for: "connect API", "fetch real data", "integrate backend", or "replace mocks".
---

# API Integration Skill

## 🛠️ Phase 1: Dependency Mapping & Generation

**Rule:** Never write files from scratch. Always generate via hygen CLI args — Claude runs these directly, not the user:

```bash
npx hygen usecase new --module <module> --usecase <name>
npx hygen gateway repo --module <module> --gateway <name>
npx hygen controller new --module <module> --controller <name>
npx hygen presenter new --module <module> --presenter <name>
npx hygen store new --module <module> --store <module>
npx hygen entity new --module <module> --entity <name>
```

1.  **Identify Missing Layers:** Search `src/<module>/` for: `entity`, `store`, `controller`, `repository`, `presenter`, `usecase`.
2.  **Generate:** Run the required hygen commands above for any missing layer.
    - **Store rule:** The store is **module-scoped**, not feature-scoped. It must be named after the module (e.g., `auth.store.ts` for the `auth` module), with class name `<Module>Store` (e.g., `AuthStore`). If `src/<module>/entities/<module>.store.ts` already exists, **do not generate a new one** — add new observables to the existing store instead.
    - **Store registration:** Register as `<module>: new <Module>Store()` in `src/app/store.ts` (e.g., `auth: new AuthStore()`).
    - **Observable naming:** Since one store serves multiple features, prefix observable names with the feature (e.g., `loginData` not `data`) to avoid collisions.
3.  **Read Base Classes:** To ensure correct inheritance, read:
    - `cat src/common/entities/base-api-mapped.entity.ts`
    - `cat src/common/gateways/api.gateway.ts`

## 📡 Phase 2: API Contract Definition

1.  **Define Models:** Add the response shape to `src/common/api/api-models.ts`.
2.  **Update Gateway:** Add the typed method to `ApiGateway` using `this.get`, `this.post`, etc.
    - _Pattern:_ `async methodName(): Promise<{ status_code: number; data: T }>`

## 🏗️ Phase 3: Layer Implementation

For each generated file, follow these project-specific logic rules:

- **Entity:** Implement `setFromApiModel`. Map `snake_case` (API) to `camelCase` (Class).
- **Store:** Module-scoped (`<module>.store.ts`). Add feature-prefixed observables (e.g., `loginData`, `isLoading`, `error`). **Must** register in `src/app/store.ts` under the module key (e.g., `auth: new AuthStore()`). If the store already exists, add new observables to it — do not create a second store.
- **Repository:** Create setter methods: `setX(data)`, `setIsLoading(bool)`, `setError(string)`. It can create getter methods also to get data for use case classes.
- **UseCase:** 1. Set `isLoading(true)`. 2. Call `apiGateway`. 3. Validate with `codeStatusChecker(response.status_code)`. 4. If success: Map to Entity and call `repository.setX()`. 5. If fail: Call `repository.setError()`. 6. Set `isLoading(false)`.
- **Controller:** Instantiate the Repository, Gateway, and UseCase. Expose an `execute` method.
- **Presenter:** Create read-only getters for store data.

## 🔗 Phase 4: UI Wiring

- **Container:** Use `useContext(StoreContext)`. Wrap the return in `<Observer>`. Internal handler functions must be defined **outside** the `Observer` render callback — above the return statement.
- **View:** Update `I<Name>ViewModel` to include `isLoading` and `error`. Render an `ActivityIndicator` if loading.

### Function naming convention

| Location | Prefix | Example |
|---|---|---|
| Passed as a prop to a child component | `on` | `onLogin`, `onDelete`, `onSubmit` |
| Internal handler (not a prop) | `handle` | `handleLogin`, `handleDelete` |

```tsx
// Container — correct
const handleLogin = (values: ILoginFormModel) => {
  controller.login(values);
};

return (
  <Observer>
    {() => (
      <LoginView
        onLogin={handleLogin}   // prop → "on" prefix
      />
    )}
  </Observer>
);
```

```tsx
// View — correct
interface ILoginViewModel {
  onLogin: (values: ILoginFormModel) => void;  // prop → "on" prefix
}
```

---

## Checklist for Claude

- [ ] Use `apisauce` methods only.
- [ ] No direct store access from View/Controller.
- [ ] All business logic stays in the UseCase.
- [ ] Ensure `makeObservable` is in the Entity constructor.
- [ ] Props callbacks use `on` prefix; internal handlers use `handle` prefix.
