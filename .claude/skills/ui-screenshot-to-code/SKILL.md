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

- Screen renders `<AppScreen barStyle=... statusBarBg={Colors.background}>` wrapping the Container. Never render the Container directly as the screen root. Always import `AppScreen` from `src/common/ui/app.screen.tsx` and `Colors` from `src/common/colors.ts`.
- **All navigation calls belong in the screen.** Define `navigateTo<Destination>` functions in the screen and pass them as typed callback props to the container. Containers must never hold a `navigation` prop or call `navigation.*` directly.
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
- Container is the `Observer` wrapper — owns store wiring and passes typed props to View. **Never access the store directly in a Container** — all state reads must go through the Presenter (e.g. `presenter.isLoading()`, never `store.module.isLoading`). If a Presenter method is missing, add it to the Presenter first.
- **Exactly one controller and one presenter per Container.** If API wiring is added later (see `apply-api-to-ui`), instantiate a single `controller` and single `presenter` — never declare a second controller or presenter in the same Container.
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
- Use `Controller` from `react-hook-form` to wrap `AppTextInput` (from `src/common/ui/text-input.view.tsx`); pass `errors.<field>?.message` from `formState.errors` to its `error` prop for inline validation.
- Container stays a plain Observer wrapper — no form logic in the container.
- **UI first rule:** when the task is "create UI" or "create form", build the View with `handleSubmit(() => {})` as a no-op. Do NOT wire controller calls, usecases, or API calls until the user explicitly asks to connect the API.

## Phase 4: Output Requirements

In this order:

1. Run `npx hygen screen new --module <module> --screen <name>` and `npx hygen component new --module <module> --component <name>` using the same `<name>` for both.
2. Fill in the generated scaffold files — screen renders container, container wires store + passes props, view is pure UI.
3. Styles via NativeWind `className` with semantic color classes (`bg-primary`, `text-primary`) from `tailwind.config.js` (palette in `src/common/palette.js`, exposed as `Colors` via `src/common/colors.ts` for non-className props like `statusBarBg`). No `StyleSheet.create()` in new views. No arbitrary hex in classNames (`bg-[#007AFF]` is forbidden — add the color to the palette instead).


## UI Component Reference

| Visual Element | Component                                                           |
| :------------- | :------------------------------------------------------------------ |
| Headings       | RN `<Text className="text-2xl font-bold">`                           |
| Body text      | RN `<Text className="text-base">`                                    |
| Buttons        | `<AppButton variant="contained">` (`src/common/ui/button.view.tsx`)  |
| Inputs         | `<AppTextInput label="..." error={...}>` (`src/common/ui/text-input.view.tsx`) |
| Tab toggle     | Row of `Pressable`s styled with `className`                          |
| Dialog         | `<AppDialog>` (`src/common/ui/dialog.view.tsx`)                      |
| Screen wrapper | `AppScreen`                                                          |
