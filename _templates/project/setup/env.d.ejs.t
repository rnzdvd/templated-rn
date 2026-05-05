---
to: types/env.d.ts
---
<%_ if (projectType === 'expo') { _%>
declare global {
  namespace NodeJS {
    interface ProcessEnv {
      EXPO_PUBLIC_BASE_URL: string;
      EXPO_PUBLIC_SHOW_STORYBOOK: string;
    }
  }
}
export {};
<%_ } else { _%>
declare module '@env' {
  export const BASE_URL: string;
  export const SHOW_STORYBOOK: string;
}
<%_ } _%>
