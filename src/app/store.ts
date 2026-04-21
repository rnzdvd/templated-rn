import React from 'react';

export type IStore = ReturnType<typeof getStore>;

export default function getStore() {
  return {};
}

export const StoreContext = React.createContext({} as IStore);
