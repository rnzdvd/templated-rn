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

Never use `yarn screen` or interactive `yarn component` prompts for this skill. After generation, fill in the scaffolded container and view files.

**Container → View rule:**
- Container is the `Observer` wrapper — owns `visible`/`onDismiss` state and any handler callbacks.
- View is pure UI — no store access, all data via its `IXxxViewModel` interface.

## Phase 2: Form Detection

**Has form inputs?** → always use Formik + Zod, even if it's UI-only with no API wired yet. Never use plain `useState` for form fields.

- Wrap the View's JSX in a `<Formik<IXxxFormModel>>` component with render props.
- Define the Zod schema at the top of the View file with `z.object(...)`.
- Pass a `validate` prop that calls `schema.safeParse()` and maps `flatten().fieldErrors` to Formik's errors shape.
- Use `<HelperText type="error">` from RN Paper for inline validation messages.
- Define the form data shape as an interface in `src/common/form-models.ts`.

## Phase 4: Pattern Selection

**Standard Modal / Bottom Sheet** — use RN `Modal`.

- Dialog → `animationType="fade"`
- Bottom Sheet → `animationType="slide"` + `TouchableOpacity` backdrop
- Style: `borderRadius: 16`, `padding: 24`

**Material Dialog (RN Paper)** — use `<Dialog>` wrapped in `<Portal>`.

- Structure: `Dialog.Title` + `Dialog.Content` + `Dialog.Actions`

**Inline UI (Tabs/Toggles)** — use `SegmentedButtons` from RN Paper.

- Manage `activeTab` state in the parent Container.

## Phase 5: Implementation Rules

- **View** — no store access; data via typed ViewModel interface only.
- **Assets** — import from `assets/` via `require()`. Never store in `src/`.
- **Styles** — `StyleSheet.create()` + `Colors` from `src/common/colors.ts`. No hex codes.
- **State** — parent Container controls `visible` prop.

## Output Checklist

- [ ] `yarn component` command provided first.
- [ ] Container has `visible` and `onDismiss` props.
- [ ] View uses `StyleSheet` and `Colors` only.
- [ ] Parent screen usage snippet included.
