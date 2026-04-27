import { AddressListPageRouterContext } from '../common/CustomTypes';

export function goToAddressListPage(navPathStack: NavPathStack, routerCtx?: AddressListPageRouterContext) {
  navPathStack.pushPathByName('AddressListPage', routerCtx);
}
