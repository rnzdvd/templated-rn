---
name: ui-to-code-no-screen
description: Build modals, bottom sheets, dialogs, or inline components (Container + View only) from screenshots or Figma designs. Trigger on: "create a modal", "build a bottom sheet", "make a popup", "add a dialog", Figma URL provided, or when UI is an overlay/partial screen.
---

# UI to Code — No Screen

## Phase 0: Input Source

- **Screenshot** → analyze image visually, proceed to Phase 1.
- **Figma URL** → run `figma-mcp-extract` skill first, use its design summary as the spec, then proceed to Phase 1.
- **Both** → Figma is source of truth; screenshot is visual reference only.
- **Neither** → ask the user for one before continuing.

## Phase 1: Alignment

Never create files manually. Always generate via hygen CLI args — Claude runs this, not the user:

```bash
npx hygen component new --module <module> --component <name>
```

**Naming rule:** the component name should match the feature name exactly — no suffixes like `-form` or `-modal`. If the feature is `login`, the component is `login`.

Never use `yarn screen` or interactive `yarn component` prompts for this skill. After generation, fill in the scaffolded container and view files.

**Container → View rule:**

- Container is the `Observer` wrapper — owns `visible`/`onDismiss` state and store wiring. **Never access the store directly in a Container** — all state reads must go through the Presenter (e.g. `presenter.isLoading()`, never `store.module.isLoading`). If a Presenter method is missing, add it to the Presenter first.
- Handler functions that do **not** read observables must be defined **outside** the `Observer` render callback — at module level or above the component return — so they are not recreated on every render.
- **Function naming:** props callbacks use `on` prefix (`onLogin`, `onDelete`); internal handlers use `handle` prefix (`handleLogin`, `handleDelete`).
- View is pure UI — no store access, all data via its `IXxxViewModel` interface.
- Always use `const` arrow functions instead of `function` declarations. This applies to `validate`, event handlers, and all module-level helpers in component files.

## Phase 2: Form Detection

**Has form inputs?** → always use `useForm<IXxxFormModel>({ resolver: zodResolver(XxxSchema) })` **in the View file**. Never use plain `useState` for form fields. Never use Formik.

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
- **UI first rule:** set `handleSubmit(() => {})` as a no-op placeholder. Do NOT wire controller calls or API calls until the user explicitly asks to connect the API.

## Phase 4: Pattern Selection

**Standard Modal / Bottom Sheet** — use RN `Modal`.

- Dialog → `animationType="fade"`
- Bottom Sheet → `animationType="slide"` + `Pressable` backdrop
- Style: `rounded-2xl p-6` via `className`

**Dialog** — use `AppDialog` from `src/common/ui/dialog.view.tsx` (RN `Modal` based — no Portal needed).

- Pass `title`, content as `children`, and `actions` as a row of `AppButton`s.
- Parent Container owns `visible` / `onDismiss`.

**Inline UI (Tabs/Toggles)** — compose a row of `Pressable`s styled with `className` (e.g. `flex-row bg-black/5 rounded-lg p-1`, selected segment `bg-white`).

- Manage `activeTab` state in the parent Container.

## Phase 5: Implementation Rules

- **Presenter-only store access** — Containers must never read from the store directly. Always use the Presenter. If a getter is missing, add it to the Presenter file before wiring the Container.
- **View** — no store access; data via typed ViewModel interface only.
- **Assets** — import from `assets/` via `require()`. Never store in `src/`.
- **Styles** — NativeWind `className` with semantic color classes (`bg-primary`, `text-primary`) from `tailwind.config.js` (palette in `src/common/palette.js`, exposed as `Colors` via `src/common/colors.ts` for non-className props). No `StyleSheet.create()` in new views. No arbitrary hex in classNames (`bg-[#007AFF]` is forbidden — add the color to the palette instead).
- **State** — parent Container controls `visible` prop.

## Output Checklist

- [ ] `yarn component` command provided first.
- [ ] Container has `visible` and `onDismiss` props.
- [ ] View uses NativeWind `className` with semantic color classes only — no `StyleSheet`, no arbitrary hex.
- [ ] Parent screen usage snippet included.
