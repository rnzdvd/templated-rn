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

Never generate code before reading templates:

- `cat _templates/component/new/container.tsx.t`
- `cat _templates/component/new/view.tsx.t`
- `cat _templates/screen/new/screen.tsx.t`

Ask for the target module (e.g. `auth`, `profile`), then instruct user to run `yarn screen` or `yarn component`.

## Phase 2: UI Analysis

Identify from screenshot or Figma summary:

- **Bottom tab bar?** → use Bottom Tab pattern.
- **Tabs inside screen?** → use Inner-Screen Tab pattern.
- **Form inputs?** → use Formik + Yup pattern.

## Phase 3: Implementation Patterns

**Bottom Navigation Tabs** — every tab needs `Screen → Container → View`.

- Check `src/app/navigator.tsx` for existing `Tab.Navigator`.
- Icons from `assets/icons/` via `require()`.
- Figma: use frame/layer names as route names.

**Inner-Screen Tabs** — `Container → View` only, no screen wrapper.

- `useState` in Container to toggle views.
- Figma: map active/inactive variants to `activeTab` state.

**Data Entry (Formik + Yup)** — `validationSchema` + `initialValues` in View.

- Define data shape in `form-models.ts`.
- Figma: use field labels and placeholder text directly as props.

## Phase 4: Output Requirements

Provide in this order:

1. Hygen commands (`yarn screen` / `yarn component`).
2. Boilerplate code matching the `cat` template output from Phase 1.
3. Styles via `StyleSheet.create` + `Colors` from `src/common/colors.ts`. No hex codes.

## UI Component Reference

| Visual Element | Paper Component                   |
| :------------- | :-------------------------------- |
| Headings       | `<Text variant="headlineMedium">` |
| Buttons        | `<Button mode="contained">`       |
| Inputs         | `<TextInput label="...">`         |
| Screen wrapper | `AppScreen`                       |
