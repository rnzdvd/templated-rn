# React Native Clean Architecture Scaffold

  A React Native project template enforcing strict Clean Architecture across all feature modules.

  **Stack:** TypeScript · MobX · React Navigation · apisauce · React Native Paper · React Hook Form + Zod · hygen

  ---

  ## Using this as a scaffold

  Run this from your **new project root:**

  ```bash
  npx github:rnzdvd/react-native-scaffold

  Then run the setup script:

  node scripts/setup.js

  You'll be prompted to pick your project type:

  What type of React Native project is this?
    1) CLI (React Native)
    2) Expo

  The setup script scaffolds all boilerplate and wires up your package.json scripts automatically.

  ---
  What the scaffold copies into your project

  ┌─────────────────┬────────────────────────────────────────────────────────────────────────────────────────────────────┐
  │      Path       │                                              Purpose                                               │
  ├─────────────────┼────────────────────────────────────────────────────────────────────────────────────────────────────┤
  │ _templates/     │ hygen generators — component, screen, usecase, controller, presenter, gateway, repo, store, entity │
  ├─────────────────┼────────────────────────────────────────────────────────────────────────────────────────────────────┤
  │ CLAUDE.md       │ Claude Code architecture guide                                                                     │
  ├─────────────────┼────────────────────────────────────────────────────────────────────────────────────────────────────┤
  │ .claude/skills/ │ Claude Code skill definitions for UI generation and API wiring                                     │
  ├─────────────────┼────────────────────────────────────────────────────────────────────────────────────────────────────┤
  │ scripts/        │ Setup script                                                                                       │
  └─────────────────┴────────────────────────────────────────────────────────────────────────────────────────────────────┘

  ---
  After scaffolding

  # 1. Install dependencies
  yarn

  # 2. Start the app
  yarn start    # Metro bundler
  yarn android  # run on Android
  yarn ios      # run on iOS

  ---
  Architecture

  View (pure UI, props only)
    ↑ props
  Container (Observer, wires controller + presenter)
    ↓ calls                          ↑ reads
  Controller (orchestrates usecases)   Presenter (reads store, read-only)
    ↓ calls                               ↑ reads
  UseCase (business logic)             Store (MobX observable state)
    ↓ calls               ↓ calls          ↑ runInAction
  ApiGateway (HTTP)    Repository (writes to store)

  Every feature is scaffolded with hygen generators — never write boilerplate by hand.

  yarn component    # Creates container.tsx + view.tsx
  yarn screen       # Creates screen.tsx
  yarn case         # Creates usecase.ts + test.ts
  yarn controller   # Creates controller.ts
  yarn presenter    # Creates presenter.ts
  yarn gateway      # Creates <module>.gateway.ts
  yarn repo         # Creates repository.ts
  yarn store        # Creates store.ts
  yarn entity       # Creates entity.ts
  yarn container    # Creates container.tsx only

  ▎ See CLAUDE.md for the full convention guide.

  Requirements

  - Node >= 22.11.0
  - yarn