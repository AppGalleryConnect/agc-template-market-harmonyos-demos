import { IAddrInfo } from 'module_base';
import { Api } from '../http/Api';

export async function getDefaultAddress(): Promise<IAddrInfo | undefined> {
  return Api.listAddresses().then(list => list.find(item => item.isDefault));
}
