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

- **Form inputs present?** → use Formik + Zod pattern (see Phase 3).
- **Tabs inside the screen?** → `useState` in Container to toggle views; no screen wrapper needed for tab content.
- **List of items?** → use `FlatList` in the View; pass `data` and `renderItem` as props.
- **Modal / bottom sheet / dialog?** → Container owns `visible` + `onDismiss`; choose the right overlay pattern (see Phase 4).
- **Mixed (e.g. list + form)?** → combine patterns, Formik still lives in the View.

## Phase 3: Implementation Patterns

### Screen → Container → View (full screen)

- **Screen** — renders `<AppScreen barStyle=... statusBarBg=...>` wrapping the Container. Receives `IScreenContainer` props. Register in `screen-registry.ts` and `navigator.tsx` after creation.
- **Container** — plain `<Observer>` wrapper. No Formik logic. No store wiring until the user asks to connect the API.
- **View** — pure UI. All data via its `IXxxViewModel` interface. No store access.

### Container → View (component / modal)

- **Container** — plain `<Observer>` wrapper. Owns `visible` / `onDismiss` if it is an overlay.
- **View** — pure UI. All data via its `IXxxViewModel` interface. No store access.

### Handler placement rule

Handler functions that do **not** read observables must be defined **outside** the `Observer` render callback — at module level or above the component return — so they are not recreated on every render.

### Function naming convention

- **Props callbacks** (passed to a child) → `on` prefix: `onLogin`, `onDelete`, `onSubmit`
- **Internal handlers** (not passed as props) → `handle` prefix: `handleLogin`, `handleDelete`

```tsx
// correct
const handleLogin = (values: IFormModel) => { ... };  // internal — "handle"

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

### Data Entry (Formik + Zod)

Always use `<Formik>` JSX component with render props **in the View file**. Never use `useFormik` hook. Never use plain `useState` for form fields.

- Define the Zod schema at the top of the View file with `z.object(...)`.
- **Zod v4 format validators are top-level** — use `z.email()`, `z.url()`, `z.uuid()` directly, not `z.string().email()` / `z.string().url()` etc. (those are deprecated in v4). For string length/regex constraints, `z.string().min()` / `.max()` / `.regex()` are still valid.
- `validate` calls `schema.safeParse()` and maps `flatten().fieldErrors` to Formik's errors shape:
  ```ts
  const validate = (values: IXxxFormModel) => {
    const result = schema.safeParse(values);
    if (result.success) return {};
    const errors = result.error.flatten().fieldErrors;
    return Object.fromEntries(
      Object.entries(errors).map(([k, v]) => [k, v?.[0] ?? '']),
    );
  };
  ```
- Use `<HelperText type="error">` from RN Paper for inline validation messages.
- Define the form data shape as an interface in `src/common/form-models.ts` and type `<Formik<IXxxFormModel>>`.
- Container stays a plain Observer wrapper — no Formik logic in the container.
- **UI first rule:** `onSubmit={() => {}}` is always a no-op placeholder. Do NOT wire controller calls, usecases, or API calls until the user explicitly asks to connect the API.

## Phase 4: Overlay Patterns (component scope only)

**Standard Modal:**
- Dialog → `animationType="fade"`
- Bottom Sheet → `animationType="slide"` + `TouchableOpacity` backdrop
- Style: `borderRadius: 16`, `padding: 24`

**Material Dialog (RN Paper):**
- Use `<Dialog>` wrapped in `<Portal>`.
- Structure: `Dialog.Title` + `Dialog.Content` + `Dialog.Actions`

**Inline Tabs / Toggles:**
- Use `<SegmentedButtons>` from RN Paper.
- Manage `activeTab` in the Container.

## Phase 5: Rules

- **Styles** — `StyleSheet.create()` + `Colors` from `src/common/colors.ts`. No inline hex codes.
- **Assets** — import from `assets/` via `require()`. Never store in `src/`.
- **New screen** — after creating, register the screen name in `src/app/screen-registry.ts` and add the `Stack.Screen` entry to `src/app/navigator.tsx`.

## UI Component Reference

| Visual Element        | Paper Component                   |
| :-------------------- | :-------------------------------- |
| Headings              | `<Text variant="headlineMedium">` |
| Body text             | `<Text variant="bodyMedium">`     |
| Contained button      | `<Button mode="contained">`       |
| Outlined button       | `<Button mode="outlined">`        |
| Text inputs           | `<TextInput label="..." mode="outlined">` |
| Inline error          | `<HelperText type="error">`       |
| Screen wrapper        | `<AppScreen>`                     |
| Tab toggle            | `<SegmentedButtons>`              |
| Dialog                | `<Dialog>` inside `<Portal>`      |
