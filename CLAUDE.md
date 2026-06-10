# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

> Project type: **React Native CLI**

---

## Package Manager

Always use **yarn** to install packages — never `npm install`.

```bash
yarn add <package>           # add a dependency
yarn add -D <package>        # add a dev dependency
yarn remove <package>        # remove a package
```

---

## Commands

```bash
# Development
yarn start            # react-native start
yarn android          # react-native run-android
yarn ios              # react-native run-ios

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
yarn gateway          # Creates <module>.gateway.ts (per-module API gateway)
yarn repo             # Creates repository.ts
yarn store            # Creates store.ts
yarn entity           # Creates entity.ts
yarn container        # Creates container.tsx only
yarn setup            # Regenerates all common infrastructure files via hygen
```

> Node >= 22.11.0 required.

---

## Project Overview

This is a React Native project enforcing **Clean Architecture** across all feature modules.

Every feature follows a strict layered structure: UI → Controller → UseCase → Gateway → Repository → Store → Presenter → UI. State is managed globally via **MobX**. HTTP calls go through **apisauce**. Navigation uses **React Navigation (native-stack)**. UI uses **React Native built-in components styled with NativeWind (Tailwind CSS)**, plus shared primitives in `src/common/ui/` (AppButton, AppTextInput, AppDialog). Forms use **React Hook Form + Zod**.

---

## Tech Stack

| Concern        | Library                              |
| -------------- | ------------------------------------ |
| Language       | TypeScript                           |
| State          | MobX + mobx-react-lite               |
| Navigation     | React Navigation (native-stack)      |
| HTTP           | apisauce (axios wrapper)             |
| Styling / UI   | NativeWind v4 (Tailwind CSS) + RN built-ins |
| Forms          | React Hook Form + Zod                |
| Animations     | react-native-reanimated              |
| Gestures       | react-native-gesture-handler         |
| Safe Area      | react-native-safe-area-context       |
| Toast          | react-native-toast-message           |
| Bottom Sheet   | @gorhom/bottom-sheet                 |
| Storage        | @react-native-async-storage/async-storage |
| Code Generator | hygen                                |
| Component Dev  | Storybook (react-native)             |

---

## Project Structure

```
src/
├── app/
│   ├── app.tsx             # Root: imports global.css; StoreContext.Provider → GestureHandlerRootView → Navigator
│   ├── navigator.tsx       # NavigationContainer; register stacks here
│   ├── screen-registry.ts  # ScreenNames constants object (add new screen names here)
│   └── store.ts            # getStore() — add module stores here; IStore type is its return type
├── common/                 # Shared infrastructure only — no feature code
│   ├── api/
│   │   ├── api.ts          # Base Api class: wraps apisauce, adds { status_code, data } envelope via interceptor
│   │   ├── api-config.ts   # ApiConfig + DEFAULT_API_CONFIG (reads BASE_URL from config.ts)
│   │   ├── api-models.ts   # API response interfaces (e.g. ILoginResponseModel)
│   │   └── api-utils.ts    # codeStatusChecker(status) utility
│   ├── entities/
│   │   ├── base.entity.ts            # IBaseEntity interface
│   │   └── base-api-mapped.entity.ts # BaseApiMappedEntity: fromApiModel, fromManyApiModels, mock
│   ├── ui/
│   │   ├── app.screen.tsx        # AppScreen wrapper (IScreenContainer, IAppScreen props)
│   │   ├── container.view.tsx    # SafeArea + KeyboardAvoid root container
│   │   ├── custom-status-bar.view.tsx
│   │   ├── button.view.tsx           # AppButton (contained/outlined/text, loading, disabled)
│   │   ├── text-input.view.tsx       # AppTextInput (label + inline error; Controller-friendly)
│   │   └── dialog.view.tsx           # AppDialog (RN Modal-based; title/children/actions)
│   ├── palette.js          # CJS color palette — single source of truth (consumed by tailwind.config.js)
│   ├── colors.ts           # Re-exports palette as Colors for non-className props (StatusBar, nav)
│   ├── config.ts           # BASE_URL, SHOW_STORYBOOK flag
│   ├── form-schemas.ts     # Zod schemas + inferred types (e.g. LoginSchema, ILoginFormModel)
│   └── utils.ts            # Shared utilities
└── <module>/               # One folder per feature (e.g. auth, profile)
    ├── entities/
    │   ├── <n>.entity.ts   # Extends BaseApiMappedEntity; implements setFromApiModel()
    │   └── <n>.store.ts    # MobX store: makeAutoObservable in constructor
    ├── interfaces/
    │   ├── controllers/<n>.controller.ts   # Receives IStore; orchestrates use cases
    │   ├── gateways/<n>.gateway.ts         # Extends Api; module-specific HTTP endpoints
    │   ├── gateways/<n>.repository.ts      # Receives IStore; all mutations via runInAction
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

**File creation rule** — always use the hygen generators listed in the Commands section (`yarn component`, `yarn screen`, `yarn case`, `yarn controller`, `yarn presenter`, `yarn gateway`, `yarn repo`, `yarn store`, `yarn entity`, `yarn container`) to scaffold any new feature file. Never hand-write a container, view, screen, use case, controller, presenter, gateway, repository, store, or entity file from scratch — run the generator first, then edit the generated output. This keeps boilerplate, imports, and naming consistent across modules.

**API responses** are always shaped as `{ status_code: number; data: T }`. The interceptor in `api.ts` normalises both success and error responses into this envelope — use `codeStatusChecker` from `api-utils.ts` to interpret the status code.

**MobX** is configured with `enforceActions: 'always'` (see `app.tsx`). All store mutations must go through the Repository layer and be wrapped in `runInAction(() => { ... })`. Never mutate store state outside a Repository.

**Storybook** is toggled by `SHOW_STORYBOOK` in `src/common/config.ts`. When `true` in `__DEV__`, the app renders `StorybookUI` instead of Navigator. Set to `false` to run the normal app.

**Registration checklist** when adding a new screen/module:
1. Add screen name constant to `src/app/screen-registry.ts`
2. Register the screen in the stack inside `src/app/navigator.tsx`
3. Add the module's store instance to `getStore()` in `src/app/store.ts`

**Store split rule** — one store per module by default. Split into a second store when either condition is true: (1) the store exceeds ~10 observables, or (2) two distinct feature domains exist in the same module (e.g. `auth` handling both login and user profile). Name split stores after the feature: `login.store.ts`, `profile.store.ts`.

**Entity file split rule** — never put multiple entities in one file. Each entity gets its own file (e.g. `exercise.entity.ts`, `lesson.entity.ts`). All raw API interfaces (`IExercise`, `ILesson`, etc.) live in a single `interfaces.ts` alongside the entities — never inside an entity class file. Each entity class must extend `BaseApiMappedEntity`, call `makeAutoObservable(this)` in its constructor, declare typed public properties with default values, and implement `setFromApiModel()`.

**UseCase store access rule** — use cases must never inject or access a store directly. If a use case needs to read data from a store (including another module's store), it must do so through a Repository method. Add a getter method to the relevant Repository (e.g. `getSelectedTopicId()`) and inject that Repository into the use case instead of the store.

**Single IStore parameter rule** — controllers, presenters, and repositories must each accept exactly one parameter: the global `IStore` from `src/app/store.ts`. Never pass individual module stores (e.g. `HomeStore`, `LessonStore`) as separate constructor arguments. Internally, access the needed slice via `store.homeStore`, `store.lessonStore`, etc. Containers instantiate these classes with just `store` (from `useContext(StoreContext)`).

**Controller-to-UseCase rule** — controllers must never call repository methods directly. Every store mutation, no matter how simple, must be routed through a use case: `Controller → UseCase → Repository → Store`. If no use case exists for an action, create one.

**Controller getter rule** — controllers must never expose getter methods or return data. Controllers only orchestrate use cases (actions/mutations). All data reads for the UI belong in the Presenter.

**UseCase execute void rule** — `execute()` must always return `void`. Use cases must never return data to their caller. If the result of an execution needs to be observed (e.g. success/failure, completion status), write it to the store via the Repository and expose it through the Presenter.

**UseCase injection rule** — never pass a use case as a constructor argument to another use case. Use case execution always happens in the controller. If two use cases must run in sequence, the controller calls them one after the other; each case guards itself via store state (e.g. `getIsComplete()`) to determine whether it should run.

**Screen AppScreen rule** — every screen component must wrap its container with `AppScreen` from `src/common/ui/app.screen.tsx`. Never render a container directly as the screen root. Always pass `barStyle` and `statusBarBg` (from `Colors`) to `AppScreen`.

**Screen navigation rule** — all `navigation.navigate`, `navigation.replace`, and `navigation.goBack` calls must live in the screen component. Define `navigateTo<Destination>` functions in the screen and pass them as callbacks to the container. Containers must never import or call `navigation` directly — they receive typed callback props instead.

```tsx
const FooScreen: React.FC<IScreenContainer> = ({ navigation }) => {
  const navigateToBar = () => navigation.navigate(ScreenNames.BarScreen);
  const navigateBack = () => navigation.goBack();

  return (
    <AppScreen barStyle="dark-content" statusBarBg={Colors.background}>
      <FooContainer onNavigateToBar={navigateToBar} onBack={navigateBack} />
    </AppScreen>
  );
};
```

**NativeWind styling rule** — feature views are styled exclusively with NativeWind `className` and semantic color utilities (`bg-primary`, `text-primary`). The palette lives in `src/common/palette.js` (consumed by `tailwind.config.js` and re-exported as `Colors` from `src/common/colors.ts` for non-className props like `statusBarBg` and navigation themes). Never use `StyleSheet.create()` in new views; never use arbitrary hex values in classNames (`bg-[#007AFF]` is forbidden — add the color to `palette.js` instead). Prefer the shared primitives (`AppButton`, `AppTextInput`, `AppDialog` in `src/common/ui/`) over hand-rolled buttons/inputs/dialogs.

**Storybook stories** live alongside components in `.rnstorybook/`; run `yarn storybook-generate` after adding new stories.

**Context7** — always use Context7 MCP to fetch current library/API documentation instead of relying on training data. This applies to setup questions, code generation, API references, and anything involving specific packages.
