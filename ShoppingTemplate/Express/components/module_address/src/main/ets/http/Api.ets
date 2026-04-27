import util from '@ohos.util';
import { address1, address2, IAddrInfo } from 'module_base';

export class Api {
  private static addressListMock: IAddrInfo[] = [address1, address2];

  private static withDelay<T>(callback: () => T, delay = 300): Promise<T> {
    return new Promise((resolve) => {
      setTimeout(() => {
        resolve(callback());
      }, delay);
    });
  }

  public static listAddressesOne(): Promise<IAddrInfo[]> {
    const list: IAddrInfo[] = JSON.parse(
      JSON.stringify(Api.addressListMock),
    );
    return new Promise((resolve) => {
      resolve(list);
    });
  }

  public static async listAddresses(): Promise<IAddrInfo[]> {
    return Api.withDelay(() => {
      const list: IAddrInfo[] = JSON.parse(
        JSON.stringify(Api.addressListMock),
      );
      return list;
    });
  }

  public static async createAddress(address: IAddrInfo): Promise<boolean> {
    return Api.withDelay(() => {
      const time: number = new Date().getTime();
      address.createdAt = time;
      address.updatedAt = time;
      address.id = util.generateRandomUUID(false);
      if (address.isDefault) {
        Api.addressListMock.forEach((item) => (item.isDefault = false));
      }
      Api.addressListMock.push(address);
      return true;
    });
  }

  public static async updateAddress(address: IAddrInfo): Promise<boolean> {
    return Api.withDelay(() => {
      address.updatedAt = new Date().getTime();
      const index = Api.addressListMock.findIndex(
        (item) => item.id === address.id,
      );
      if (index === -1) {
        return false;
      }
      if (address.isDefault) {
        Api.addressListMock.forEach((item) => (item.isDefault = false));
      }
      Api.addressListMock[index] = address;
      return true;
    });
  }

  public static async updateDefaultAddress(address: IAddrInfo): Promise<boolean> {
    return Api.withDelay(() => {
      address.updatedAt = new Date().getTime();
      const index = Api.addressListMock.findIndex(
        (item) => item.id === address.id,
      );
      if (index === -1) {
        return false;
      }
      if (address.isDefault) {
        Api.addressListMock.forEach((item) => (item.isDefault = false));
      }
      Api.addressListMock[index] = address;
      return true;
    });
  }

  public static async deleteAddress(id: string): Promise<boolean> {
    return Api.withDelay(() => {
      const index = Api.addressListMock.findIndex((item) => item.id === id);
      if (index === -1) {
        return false;
      }
      Api.addressListMock.splice(index, 1);
      return true;
    });
  }
}
