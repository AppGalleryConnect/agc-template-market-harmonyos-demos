import { AddressManagementOptions } from '../common/CustomTypes';

export function goToAddressListPage(navPathStack: NavPathStack, options?: AddressManagementOptions) {
  navPathStack.pushPathByName('AddressListPage', options);
}
