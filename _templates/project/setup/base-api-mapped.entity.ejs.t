---
to: src/common/entities/base-api-mapped.entity.ts
---


/* eslint-disable @typescript-eslint/no-unused-vars */
import { IBaseEntity } from './base.entity';

type Constructor<T> = new () => T;

export default class BaseApiMappedEntity implements IBaseEntity {
  setFromApiModel(data: any): void {
    throw new Error('Set From API Model not implemented');
  }

  static fromApiModel<T>(this: Constructor<T>, apiModel: any): T {
    const me = new this();
    // @ts-expect-error setFromApiModel is not implemented on Constructor<T>
    me.setFromApiModel(apiModel);
    return me;
  }

  static fromManyApiModels<T>(this: Constructor<T>, apiModels: any[]): T[] {
    const entities: T[] = [];
    apiModels.forEach(model => {
      const entity = new this();
      // @ts-expect-error setFromApiModel is not implemented on Constructor<T>
      entity.setFromApiModel(model);
      entities.push(entity);
    });
    return entities;
  }

  static mock<T>(this: Constructor<T>): any {
    return new this();
  }
}
