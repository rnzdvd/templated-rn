---
to: src/common/config.ts
---
<%_ if (projectType === 'expo') { _%>
export const BASE_URL = process.env.EXPO_PUBLIC_BASE_URL ?? '';
export const SHOW_STORYBOOK = process.env.EXPO_PUBLIC_SHOW_STORYBOOK === 'true';
<%_ } else { _%>
import { BASE_URL as ENV_BASE_URL, SHOW_STORYBOOK as ENV_SHOW_STORYBOOK } from '@env';

export const BASE_URL = ENV_BASE_URL ?? '';
export const SHOW_STORYBOOK = ENV_SHOW_STORYBOOK === 'true';
<%_ } _%>