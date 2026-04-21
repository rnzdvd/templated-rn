---
to: src/common/api/api.ts
---

import { ApiResponse, ApisauceInstance, create } from 'apisauce';
import { AxiosRequestConfig, AxiosResponse } from 'axios';
import { IStore } from '../../app/store';
import { ApiConfig, DEFAULT_API_CONFIG } from './api-config';

export interface IApi {
  apiSauce: ApisauceInstance;
  config: ApiConfig;
}

export class Api implements IApi {
  apiSauce: ApisauceInstance;
  config: ApiConfig;

  constructor(_: IStore) {
    this.config = DEFAULT_API_CONFIG;

    this.apiSauce = create({
      baseURL: this.config.url,
      timeout: this.config.timeout,
      headers: this.config.headers,
    });

    this.apiSauce.axiosInstance.interceptors.response.use(
      function (response: AxiosResponse<any, any>) {
        // Ensure the response data exists
        if (!response.data) {
          response.data = {};
        }

        // Preserve the response structure and add status_code
        response.data = {
          status_code: response.status,
          data: response.data,
        };

        return response;
      },
      function (error) {
        return {
          data: {
            status_code: error.response?.status ?? 500,
            data: error.response?.data ?? {},
          },
        };
      },
    );

    // Adding access token to the request header if it exists
    // this.apiSauce.axiosInstance.interceptors.request.use(
    //   async config => {
    //     const user = this.authRepo.getAuthUser();
    //     config.headers.Authorization = `Bearer ${user.accessToken}`;
    //     return config;
    //   },
    //   error => {
    //     return Promise.reject(error);
    //   },
    // );
  }

  protected handleAPIResult<TApiResponseModel>(
    response: ApiResponse<unknown, unknown>,
  ): TApiResponseModel {
    return response.data as TApiResponseModel;
  }

  protected parseAPIResultIntoModel<TApiResponseModel>(
    response: ApiResponse<unknown, unknown>,
  ): TApiResponseModel {
    return this.handleAPIResult<TApiResponseModel>(response);
  }

  protected async delete<TApiResponseModel>(
    apiPath: string,
    params?: any,
  ): Promise<TApiResponseModel> {
    const result = await this.apiSauce.delete(apiPath, params);
    return this.parseAPIResultIntoModel<TApiResponseModel>(result);
  }

  protected async get<TApiResponseModel>(
    apiPath: string,
    params?: any,
    axiosConfig?: AxiosRequestConfig,
  ): Promise<TApiResponseModel> {
    const result = await this.apiSauce.get(apiPath, params, axiosConfig);
    return this.parseAPIResultIntoModel<TApiResponseModel>(result);
  }

  protected async post<TApiResponseModel>(
    apiPath: string,
    params?: any,
    axiosConfig?: AxiosRequestConfig,
  ): Promise<TApiResponseModel> {
    const result = await this.apiSauce.post(apiPath, params, axiosConfig);
    return this.parseAPIResultIntoModel<TApiResponseModel>(result);
  }

  protected async put<TApiResponseModel>(
    apiPath: string,
    params?: any,
  ): Promise<TApiResponseModel> {
    const result = await this.apiSauce.put(apiPath, params);
    return this.parseAPIResultIntoModel<TApiResponseModel>(result);
  }

  protected async patch<TApiResponseModel>(
    apiPath: string,
    params?: any,
  ): Promise<TApiResponseModel> {
    const result = await this.apiSauce.patch(apiPath, params);
    return this.parseAPIResultIntoModel<TApiResponseModel>(result);
  }
}
