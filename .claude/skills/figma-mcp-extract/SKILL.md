---
name: figma-mcp-extract
description: Extract and convert Figma design data into React Native-ready properties using the Figma MCP tool. Trigger this skill whenever a Figma URL is provided alongside any code generation task (screen, component, modal, etc.). Used as a shared base by ui-screenshot-to-code and ui-to-code-no-screen skills.
---

# Figma MCP Extract

## Phase 1: Validate Input

- Confirm URL contains `figma.com/file/` or `figma.com/design/`.
- If a specific node/frame is needed, ask the user to share the node link (right-click frame → Copy link in Figma).
- If no URL is provided, skip this skill entirely.

## Phase 2: Fetch via Figma MCP

Use the Figma MCP tool to fetch the target frame or component. Extract:

| Figma Property                             | Extract As                                                                  |
| ------------------------------------------ | --------------------------------------------------------------------------- |
| Layer / component name                     | File name, component name, prop name                                        |
| Auto layout direction                      | `flexDirection: 'row'` or `'column'`                                        |
| Item spacing (gap)                         | `gap: N`                                                                    |
| Padding                                    | `padding` / `paddingHorizontal` / `paddingVertical`                         |
| Corner radius                              | `borderRadius: N`                                                           |
| Fill color                                 | Map to `Colors` from `src/common/colors.ts`                                 |
| Stroke                                     | `borderWidth` + `borderColor`                                               |
| Opacity                                    | `opacity: N`                                                                |
| Drop shadow                                | `shadowColor`, `shadowOffset`, `shadowOpacity`, `shadowRadius`, `elevation` |
| Font size                                  | `fontSize: N`                                                               |
| Font weight (Regular/Medium/SemiBold/Bold) | `400` / `500` / `600` / `700`                                               |
| Line height                                | `lineHeight: N`                                                             |
| Frame width — fixed                        | `width: N`                                                                  |
| Frame width — fill container               | `flex: 1` or `alignSelf: 'stretch'`                                         |
| Frame width — hug contents                 | No explicit size                                                            |
| Component variants                         | Map to component props / `activeTab` state                                  |

> **Spacing:** Figma `px` maps 1:1 to React Native `dp`. No conversion needed.

## Phase 3: Color Matching

- Match every extracted fill to the nearest value in `src/common/colors.ts`.
- If no match exists → **flag it to the user** and ask before proceeding. Never use raw hex codes.

## Phase 4: Output a Design Summary

Before handing off to the screen or component skill, output a brief summary:

```
Frame: <name>
Layout: <flexDirection>, gap: N, padding: N
Colors: { background: Colors.X, text: Colors.Y, ... }
Typography: { fontSize: N, fontWeight: 'N', lineHeight: N }
Border: borderRadius: N
Components detected: [list of Figma component instances]
Variants: [list if any]
Unmatched colors: [hex values to review]
```

This summary becomes the input spec for the next skill (ui-screenshot-to-code or ui-to-code-no-screen).
