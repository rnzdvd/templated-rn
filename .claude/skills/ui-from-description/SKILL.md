---
name: ui-from-description
description: Build React Native screens or components from a text description — no screenshot or Figma URL required. Trigger on "create a screen", "create a form", "create a component", "build a UI", or any UI request that has no image or Figma link attached.
---

# UI from Description

## Phase 0: Clarify Intent

Before generating any files, confirm these two things if not already clear from the user's message:

1. **Module** — which feature folder does this belong to? (e.g. `auth`, `profile`, `dashboard`). Ask if not stated.
2. **Scope** — is this a full screen or a component/modal/overlay?
   - Full screen → uses `Screen → Container → View` pattern.
   - Component / modal / bottom sheet / inline UI → uses `Container → View` pattern only.

Do not generate files until both are known.

## Phase 1: Scaffold via Hygen

Never create files manually. Always generate via hygen CLI args — Claude runs these directly, not the user:

**Naming rule:** screen and component must share the same base name. If the screen is `login`, the component is also `login` — not `login-form` or `login-screen`.

**Full screen:**

```bash
npx hygen screen new --module <module> --screen <name>
npx hygen component new --module <module> --component <name>
```

Example — login screen in the `auth` module:

```bash
npx hygen screen new --module auth --screen login
npx hygen component new --module auth --component login
```

**Component / modal only:**

```bash
npx hygen component new --module <module> --component <name>
```

Run the commands. After generation, fill in the scaffolded files with the actual implementation.

## Phase 2: Layout Detection

Read the user's description and identify the layout pattern:

- **Form inputs present?** → use React Hook Form + Zod pattern (see Phase 3).
- **Tabs inside the screen?** → `useState` in Container to toggle views; no screen wrapper needed for tab content.
- **List of items?** → use `FlatList` in the View; pass `data` and `renderItem` as props.
- **Modal / bottom sheet / dialog?** → Container owns `visible` + `onDismiss`; choose the right overlay pattern (see Phase 4).
- **Mixed (e.g. list + form)?** → combine patterns, React Hook Form still lives in the View.

## Phase 3: Implementation Patterns

### Screen → Container → View (full screen)

- **Screen** — renders `<AppScreen barStyle=... statusBarBg=...>` wrapping the Container. Receives `IScreenContainer` props. **All navigation calls live here** — define `navigateTo<Destination>` functions and pass them as typed callback props to the container. Never pass the `navigation` object into a container. Register in `screen-registry.ts` and `navigator.tsx` after creation.
- **Container** — plain `<Observer>` wrapper. No form logic. No store wiring until the user asks to connect the API. **Never access the store directly** — all state reads must go through the Presenter (e.g. `presenter.isLoading()`, never `store.auth.isLoading`). **Exactly one controller and one presenter per Container** — when API wiring is added later (see `apply-api-to-ui`), never declare a second controller or presenter in the same Container.
- **View** — pure UI. All data via its `IXxxViewModel` interface. No store access.

### Container → View (component / modal)

- **Container** — plain `<Observer>` wrapper. Owns `visible` / `onDismiss` if it is an overlay. **Never access the store directly** — all state reads must go through the Presenter. **Exactly one controller and one presenter per Container** — never declare a second controller or presenter in the same Container.
- **View** — pure UI. All data via its `IXxxViewModel` interface. No store access.

### Handler placement rule

Handler functions that do **not** read observables must be defined **outside** the `Observer` render callback — at module level or above the component return — so they are not recreated on every render.

### Function naming convention

- **Props callbacks** (passed to a child) → `on` prefix: `onLogin`, `onDelete`, `onSubmit`
- **Internal handlers** (not passed as props) → `handle` prefix: `handleLogin`, `handleDelete`
- **Navigation functions in a Screen** → `navigateTo<Destination>` prefix: `navigateToHome`, `navigateToProfile` — never `handleSuccess` or `handleNavigation`

```tsx
// correct
const handleLogin = (values: IFormModel) => { ... };  // internal — "handle"
const navigateToHome = () => { navigation.navigate(...) };  // screen navigation — "navigateTo"

<ChildView onLogin={handleLogin} />                    // prop — "on"
```

### `const` over `function` rule

Always use `const` arrow functions instead of `function` declarations in component files. This applies to helpers like `validate`, event handlers, and any other module-level or in-component functions:

```ts
// correct
const validate = (values: IXxxFormModel) => { ... };

// wrong
function validate(values: IXxxFormModel) { ... }
```

### Data Entry (React Hook Form + Zod)

Always use `useForm<IXxxFormModel>` with `resolver: zodResolver(XxxSchema)` **in the View file**. Never use plain `useState` for form fields. Never use Formik.

- Define the Zod schema in `src/common/form-schemas.ts` — never inline it in the View file:
  ```ts
  // src/common/form-schemas.ts
  import { z } from 'zod';

  export const LoginSchema = z.object({
    email: z.email(),
    password: z.string().min(6),
  });
  ```
- Import the schema in the View file and use `z.infer<typeof LoginSchema>` directly — no type alias needed:
  ```ts
  import { LoginSchema } from '../../common/form-schemas';

  const { control, handleSubmit, formState: { errors } } = useForm<z.infer<typeof LoginSchema>>({
    resolver: zodResolver(LoginSchema),
  });
  ```
- **Zod v4 format validators are top-level** — use `z.email()`, `z.url()`, `z.uuid()` directly, not `z.string().email()` / `z.string().url()` etc. (those are deprecated in v4). For string length/regex constraints, `z.string().min()` / `.max()` / `.regex()` are still valid.
- Use `Controller` from `react-hook-form` to wrap `AppTextInput` (from `src/common/ui/text-input.view.tsx`):
  ```tsx
  const { control, handleSubmit, formState: { errors } } = useForm<ILoginFormModel>({
    resolver: zodResolver(LoginSchema),
  });

  <Controller
    control={control}
    name="email"
    render={({ field: { onChange, onBlur, value } }) => (
      <AppTextInput
        label="Email"
        onBlur={onBlur}
        onChangeText={onChange}
        value={value}
        error={errors.email?.message}
      />
    )}
  />
  ```
- Inline validation messages come from `AppTextInput`'s `error` prop — pass `errors.<field>?.message`; no separate helper-text component.
- Container stays a plain Observer wrapper — no form logic in the container.
- **UI first rule:** `onSubmit={() => {}}` is always a no-op placeholder. Do NOT wire controller calls, usecases, or API calls until the user explicitly asks to connect the API.

## Phase 4: Overlay Patterns (component scope only)

**Standard Modal:**

- Dialog → `animationType="fade"`
- Bottom Sheet → RN `Modal` with `animationType="slide"` + `Pressable` backdrop
- Style: `rounded-2xl p-6` via `className`

**Dialog:**

- Use `AppDialog` from `src/common/ui/dialog.view.tsx` — RN `Modal` based, no Portal needed.
- Pass `title`, content as `children`, and `actions` as a row of `AppButton`s.
- The parent Container owns `visible` / `onDismiss`.

**Inline Tabs / Toggles:**

- Compose a row of `Pressable`s styled with `className` (e.g. `flex-row bg-black/5 rounded-lg p-1`, selected segment `bg-white`).
- Manage `activeTab` in the Container.

## Phase 5: Rules

- **Presenter-only store access** — Containers must never read from the store directly. Always use the Presenter (e.g. `presenter.isLoading()`, not `store.module.isLoading`). If a Presenter method is missing, add it to the Presenter first.
- **Styles** — NativeWind `className` with semantic color classes (`bg-primary`, `text-primary`) defined in `tailwind.config.js` (palette lives in `src/common/palette.js`, exposed to TS as `Colors` via `src/common/colors.ts`). No `StyleSheet.create()` in new views. No arbitrary hex in classNames (`bg-[#007AFF]` is forbidden — add the color to the palette instead). `Colors` is still used for non-className props (`statusBarBg`, navigation theme).
- **Assets** — import from `assets/` via `require()`. Never store in `src/`.
- **New screen** — after creating, register the screen name in `src/app/screen-registry.ts` and add the `Stack.Screen` entry to `src/app/navigator.tsx`.

## UI Component Reference

| Visual Element   | Component                                                            |
| :--------------- | :------------------------------------------------------------------- |
| Headings         | RN `<Text className="text-2xl font-bold">`                            |
| Body text        | RN `<Text className="text-base">`                                     |
| Contained button | `<AppButton variant="contained">` (`src/common/ui/button.view.tsx`)   |
| Outlined button  | `<AppButton variant="outlined">`                                      |
| Text inputs      | `<AppTextInput label="...">` (`src/common/ui/text-input.view.tsx`)    |
| Inline error     | `error` prop on `<AppTextInput>`                                      |
| Screen wrapper   | `<AppScreen>`                                                         |
| Tab toggle       | Row of `Pressable`s styled with `className`                           |
| Dialog           | `<AppDialog>` (`src/common/ui/dialog.view.tsx`) — no Portal needed    |
