import { AddressDTO } from '../models/AddressDTO';

export function goToAddressListPage(navPathStack: NavPathStack, onAddressSelected?: Callback<AddressDTO>) {
  navPathStack.pushPathByName('AddressListPage', onAddressSelected);
}
