---
to: src/common/entities/base.entity.ts
---

export interface IBaseEntity {
  setFromApiModel: (model: any) => void;
}
