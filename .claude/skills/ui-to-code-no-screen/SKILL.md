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

Never create files manually. Read templates first:

- `cat _templates/component/new/container.tsx.t`
- `cat _templates/component/new/view.tsx.t`

Instruct user to run `yarn component`. Never use `yarn screen` for this skill.

## Phase 2: Pattern Selection

**Standard Modal / Bottom Sheet** — use RN `Modal`.

- Dialog → `animationType="fade"`
- Bottom Sheet → `animationType="slide"` + `TouchableOpacity` backdrop
- Style: `borderRadius: 16`, `padding: 24`

**Material Dialog (RN Paper)** — use `<Dialog>` wrapped in `<Portal>`.

- Structure: `Dialog.Title` + `Dialog.Content` + `Dialog.Actions`

**Inline UI (Tabs/Toggles)** — use `SegmentedButtons` from RN Paper.

- Manage `activeTab` state in the parent Container.

## Phase 3: Implementation Rules

- **View** — no store access; data via typed ViewModel interface only.
- **Assets** — import from `assets/` via `require()`. Never store in `src/`.
- **Styles** — `StyleSheet.create()` + `Colors` from `src/common/colors.ts`. No hex codes.
- **State** — parent Container controls `visible` prop.

## Output Checklist

- [ ] `yarn component` command provided first.
- [ ] Container has `visible` and `onDismiss` props.
- [ ] View uses `StyleSheet` and `Colors` only.
- [ ] Parent screen usage snippet included.
