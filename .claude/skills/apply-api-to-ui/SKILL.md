---
name: apply-api-to-ui
description: Wire a real API endpoint to an existing UI using Clean Architecture. Use for: "connect API", "fetch real data", "integrate backend", or "replace mocks".
---

# API Integration Skill

## 🛠️ Phase 1: Dependency Mapping & Generation

**Rule:** Never write files from scratch. Check for missing layers and generate them.

1.  **Identify Missing Layers:** Search `src/<module>/` for: `entity`, `store`, `controller`, `repository`, `presenter`, `usecase`.
2.  **Generate:** List the required `yarn` commands (e.g., `yarn case`, `yarn repo`) for the user to run.
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
- **Store:** Add `data`, `isLoading`, and `error` observables. **Must** register in `src/app/store.ts`.
- **Repository:** Create setter methods: `setX(data)`, `setIsLoading(bool)`, `setError(string)`. It can create getter methods also to get data for use case classes.
- **UseCase:** 1. Set `isLoading(true)`. 2. Call `apiGateway`. 3. Validate with `codeStatusChecker(response.status_code)`. 4. If success: Map to Entity and call `repository.setX()`. 5. If fail: Call `repository.setError()`. 6. Set `isLoading(false)`.
- **Controller:** Instantiate the Repository, Gateway, and UseCase. Expose an `execute` method.
- **Presenter:** Create read-only getters for store data.

## 🔗 Phase 4: UI Wiring

- **Container:** Use `useContext(StoreContext)`. Trigger the controller in `useEffect`. Wrap the return in `<Observer>`.
- **View:** Update `I<Name>ViewModel` to include `isLoading` and `error`. Render an `ActivityIndicator` if loading.

---

## Checklist for Claude

- [ ] Use `apisauce` methods only.
- [ ] No direct store access from View/Controller.
- [ ] All business logic stays in the UseCase.
- [ ] Ensure `makeObservable` is in the Entity constructor.
