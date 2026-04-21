import { IStore } from '../../app/store';
import { Api } from '../api/api';

export default class ApiGateway extends Api {
  private readonly store: IStore;

  constructor(store: IStore) {
    super(store);
    this.store = store;
  }

  // Example API call
  // async login(data: ILoginFormModel): Promise<{
  //   status_code: number;
  //   data: {
  //     user: ILoginResponseModel;
  //   };
  // }> {
  //   return await this.post('api/login', {
  //     username: data.username,
  //     password: data.password,
  //   });
  // }
}
