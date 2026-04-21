import { BASE_URL as ENV_BASE_URL, SHOW_STORYBOOK as ENV_SHOW_STORYBOOK } from '@env';

export const BASE_URL = ENV_BASE_URL ?? '';
export const SHOW_STORYBOOK = ENV_SHOW_STORYBOOK === 'true';