// Use this import if you want to use "env.js" file
// const { API_URL } = require("../../config/env")
// Or just specify it directly like this:
import { AxiosHeaders, RawAxiosRequestHeaders } from 'axios';
import { BASE_URL } from '../config';

/**
 * The options used to configure the API.
 */
export interface ApiConfig {
  url?: string;
  timeout: number;
  headers: RawAxiosRequestHeaders | AxiosHeaders;
}

export const DEFAULT_API_CONFIG: ApiConfig = {
  url: BASE_URL,
  timeout: 120000,
  headers: {
    Accept: 'application/json',
    'Content-Type': 'application/json',
  },
};
