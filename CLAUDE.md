# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

## Commands

```bash
# Development
yarn start            # Start Metro bundler
yarn android          # Run on Android
yarn ios              # Run on iOS

# Quality
yarn lint             # ESLint
yarn test             # Jest (all tests)
yarn test --testPathPattern=<path>  # Run a single test file

# Code generation (always use these — never write feature files manually)
yarn component        # Creates container.tsx + view.tsx
yarn screen           # Creates screen.tsx
yarn case             # Creates usecase.ts + test.ts
yarn controller       # Creates controller.ts
yarn presenter        # Creates presenter.ts
yarn repo             # Creates repository.ts
yarn store            # Creates store.ts
yarn entity           # Creates entity.ts
yarn container        # Creates container.tsx only
yarn setup            # (Re)generates all common infrastructure files via hygen
```

> Node >= 22.11.0 required.

---

## Project Overview

**TemplatedRN** is a React Native CLI template that enforces **Clean Architecture** across all feature modules.

Every feature follows a strict layered structure: UI → Controller → UseCase → Gateway → Repository → Store → Presenter → UI. State is managed globally via **MobX**. HTTP calls go through **apisauce**. Navigation uses **React Navigation (native-stack)**. UI components use **React Native Paper**. Forms use **Formik + Zod**.

---

## Tech Stack

| Concern        | Library                              |
| -------------- | ------------------------------------ |
| Language       | TypeScript                           |
| State          | MobX + mobx-react-lite               |
| Navigation     | React Navigation (native-stack)      |
| HTTP           | apisauce (axios wrapper)             |
| UI Components  | React Native Paper                   |
| Forms          | Formik + Zod                         |
| Animations     | react-native-reanimated              |
| Gestures       | react-native-gesture-handler         |
| Safe Area      | react-native-safe-area-context       |
| Toast          | react-native-toast-message           |
| Bottom Sheet   | @gorhom/bottom-sheet                 |
| Storage        | @react-native-async-storage/async-storage |
| Code Generator | hygen                                |
| Component Dev  | Storybook (react-native)             |

> All packages are installed at **latest** version — no pinned versions.

---

## Project Structure

```
src/
├── app/
│   ├── app.tsx             # Root: StoreContext.Provider → GestureHandlerRootView → PaperProvider → Navigator
│   ├── navigator.tsx       # NavigationContainer; register stacks here
│   ├── screen-registry.ts  # ScreenNames constants object (add new screen names here)
│   └── store.ts            # getStore() — add module stores here; IStore type is its return type
├── common/                 # Shared infrastructure only — no feature code
│   ├── api/
│   │   ├── api.ts          # Base Api class: wraps apisauce, adds { status_code, data } envelope via interceptor
│   │   ├── api-config.ts   # ApiConfig + DEFAULT_API_CONFIG (reads BASE_URL from config.ts)
│   │   ├── api-models.ts   # API response interfaces (e.g. ILoginResponseModel)
│   │   └── api-utils.ts    # codeStatusChecker(status) utility
│   ├── entities/            # Note: folder is spelled "entities" (typo in codebase)
│   │   ├── base.entity.ts            # IBaseEntity interface
│   │   └── base-api-mapped.entity.ts # BaseApiMappedEntity: fromApiModel, fromManyApiModels, mock
│   ├── gateways/
│   │   └── api.gateway.ts  # ApiGateway extends Api — add all API endpoint methods here
│   ├── ui/
│   │   ├── app.screen.tsx        # AppScreen wrapper (IScreenContainer, IAppScreen props)
│   │   ├── container.view.tsx    # SafeArea + KeyboardAvoid root container
│   │   └── custom-status-bar.view.tsx
│   ├── colors.ts           # All color constants
│   ├── config.ts           # BASE_URL, SHOW_STORYBOOK flag
│   ├── form-models.ts      # Form/request interfaces (e.g. ILoginFormModel)
│   └── utils.ts            # Shared utilities
└── <module>/               # One folder per feature (e.g. auth, profile)
    ├── entities/
    │   ├── <n>.entity.ts   # Extends BaseApiMappedEntity; implements setFromApiModel()
    │   └── <n>.store.ts    # MobX store: makeAutoObservable in constructor
    ├── interfaces/
    │   ├── controllers/<n>.controller.ts   # Receives IStore; orchestrates use cases
    │   ├── gateways/<n>.repository.ts      # Receives IStore; reads/writes store state
    │   └── presenters/<n>.presenter.ts     # Receives IStore; read-only store projections
    ├── screens/<n>.screen.tsx              # Uses AppScreen; receives IScreenContainer props
    ├── ui/<component>/
    │   ├── <component>.container.tsx       # Observer; wires controller + presenter to View
    │   └── <component>.view.tsx            # Pure UI — no store access, props only
    └── usecases/<n>/
        ├── <n>.case.ts     # Business logic; async execute()
        └── <n>.test.ts     # Jest unit test
```

---

## Clean Architecture Data Flow

```
View (pure UI, props only)
  ↑ props
Container (Observer, StoreContext, wires controller + presenter)
  ↓ calls                          ↑ reads
Controller (orchestrates usecases)   Presenter (reads store, read-only)
  ↓ calls                               ↑ reads
UseCase (business logic)             Store (MobX observable state)
  ↓ calls               ↓ calls          ↑ writes
ApiGateway (HTTP)    Repository (writes to store)
```

No layer skips another. Data flows down through calls and up through MobX observables.

---

## Key Conventions

**API responses** are always shaped as `{ status_code: number; data: T }`. The interceptor in `api.ts` normalises both success and error responses into this envelope — use `codeStatusChecker` from `api-utils.ts` to interpret the status code.

**MobX** is configured with `enforceActions: 'never'` (see `app.tsx`), so direct mutations on observables are allowed without wrapping in `action`.

**Storybook** is toggled by `SHOW_STORYBOOK` in `src/common/config.ts`. When `true` in `__DEV__`, the app renders `StorybookUI` instead of Navigator. Set to `false` to run the normal app.

**Registration checklist** when adding a new screen/module:
1. Add screen name constant to `src/app/screen-registry.ts`
2. Register the screen in the stack inside `src/app/navigator.tsx`
3. Add the module's store instance to `getStore()` in `src/app/store.ts`

**Storybook stories** live alongside components in `.rnstorybook/`; run `yarn storybook-generate` after adding new stories.

**Context7** — always use Context7 MCP to fetch current library/API documentation instead of relying on training data. This applies to setup questions, code generation, API references, and anything involving specific packages.
