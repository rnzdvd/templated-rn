---
name: ui-screenshot-to-code
description: Convert UI screenshots OR Figma designs into full React Native screens using Clean Architecture. Trigger on "build this screen", "convert this image", "use this Figma", or when a screenshot is uploaded or a Figma URL is provided.
---

# UI Screenshot to Code

## Phase 0: Input Source

- **Screenshot** → analyze image visually, proceed to Phase 1.
- **Figma URL** → run `figma-mcp-extract` skill first, use its design summary as the spec, then proceed to Phase 1.
- **Both** → Figma is source of truth; screenshot is visual reference only.
- **Neither** → ask the user for one before continuing.

## Phase 1: Environment Alignment

Never create files manually. Always generate via hygen CLI args — never use interactive prompts:

```bash
npx hygen screen new --module <module> --screen <name>
npx hygen component new --module <module> --component <name>
```

**Naming rule:** screen and component must share the same base name. If the screen is `login`, the component is also `login` — not `login-form` or `login-screen`.

Example — login screen in the `auth` module:

```bash
npx hygen screen new --module auth --screen login
npx hygen component new --module auth --component login
```

Run these commands directly. Do not tell the user to run them — Claude runs them. After generation, fill in the scaffolded files with the actual implementation.

Ask for the target module (e.g. `auth`, `profile`) if not already provided.

## Phase 2: UI Analysis

Identify from screenshot or Figma summary:

- **Bottom tab bar?** → use Bottom Tab pattern.
- **Tabs inside screen?** → use Inner-Screen Tab pattern.
- **Form inputs?** → use React Hook Form + Zod pattern.

## Phase 3: Implementation Patterns

**Screen → Container → View rule (always enforced):**

- Screen renders Container (never the View directly).
- Container is the `Observer` wrapper — owns store wiring and passes typed props to View. **Never access the store directly in a Container** — all state reads must go through the Presenter (e.g. `presenter.isLoading()`, never `store.module.isLoading`). If a Presenter method is missing, add it to the Presenter first.
- Handler functions that do **not** read observables must be defined **outside** the `Observer` render callback — at module level or above the component return — so they are not recreated on every render.
- **Function naming:** props callbacks use `on` prefix (`onLogin`, `onDelete`); internal handlers use `handle` prefix (`handleLogin`, `handleDelete`); navigation functions defined in a Screen use `navigateTo<Destination>` prefix (`navigateToHome`, `navigateToProfile`) — never `handleNavigation` or `handleSuccess`.
- View is pure UI — no store access, props only via its `IXxxViewModel` interface.
- Always use `const` arrow functions instead of `function` declarations. This applies to `validate`, event handlers, and all module-level helpers in component files.

**Bottom Navigation Tabs** — every tab needs `Screen → Container → View`.

- Check `src/app/navigator.tsx` for existing `Tab.Navigator`.
- Icons from `assets/icons/` via `require()`.
- Figma: use frame/layer names as route names.

**Inner-Screen Tabs** — `Container → View` only, no screen wrapper.

- `useState` in Container to toggle views.
- Figma: map active/inactive variants to `activeTab` state.

**Data Entry (React Hook Form + Zod)** — always use `useForm<IXxxFormModel>({ resolver: zodResolver(XxxSchema) })` **in the View file**. Never use plain `useState` for form fields. Never use Formik.

- Zod schema lives in `src/common/form-schemas.ts` — never inline it in the View file:
  ```ts
  // src/common/form-schemas.ts
  import { z } from 'zod';

  export const LoginSchema = z.object({ ... });
  ```
- Import the schema in the View file and use `z.infer<typeof LoginSchema>` directly — no type alias needed. `useForm` call and `Controller` components live in the View body.
- **Zod v4 format validators are top-level** — use `z.email()`, `z.url()`, `z.uuid()` directly, not `z.string().email()` / `z.string().url()` etc. (those are deprecated in v4). For length/regex constraints, `z.string().min()` / `.max()` / `.regex()` are still valid.
- Use `Controller` from `react-hook-form` to wrap RN Paper inputs; expose errors via `formState.errors`.
- Use `<HelperText type="error">` from RN Paper for inline validation messages.
- Container stays a plain Observer wrapper — no form logic in the container.
- **UI first rule:** when the task is "create UI" or "create form", build the View with `handleSubmit(() => {})` as a no-op. Do NOT wire controller calls, usecases, or API calls until the user explicitly asks to connect the API.

## Phase 4: Output Requirements

In this order:

1. Run `npx hygen screen new --module <module> --screen <name>` and `npx hygen component new --module <module> --component <name>` using the same `<name>` for both.
2. Fill in the generated scaffold files — screen renders container, container wires store + passes props, view is pure UI.
3. Styles via `StyleSheet.create` + `Colors` from `src/common/colors.ts`. No inline hex codes.


## UI Component Reference

| Visual Element | Paper Component                   |
| :------------- | :-------------------------------- |
| Headings       | `<Text variant="headlineMedium">` |
| Buttons        | `<Button mode="contained">`       |
| Inputs         | `<TextInput label="...">`         |
| Screen wrapper | `AppScreen`                       |
