import { Api } from '../http/Api';
import { AddressDTO } from '../models/AddressDTO';

export class AddressManageUtil{
  public static getDefaultAddress(): Promise<AddressDTO | undefined> {
    return Api.listAddresses().then((list) =>
    list.find((item) => item.isDefault),
    );
  }

  public static goToAddressListPage(navPathStack: NavPathStack, onAddressSelected?: Callback<AddressDTO>) {
    navPathStack.pushPathByName('AddressListPage', onAddressSelected);
  }
}



