import util from '@ohos.util';
import { CommonConstants } from '../common/Constants';
import { AddressDTO } from '../models/AddressDTO';

export class Api {
  private static addressListMock: AddressDTO[] = [
    {
      id: util.generateRandomUUID(false),
      name: '张三',
      phone: '12345678901',
      countryCode: 'CN',
      country: '中国',
      province: '江苏省',
      city: '南京市',
      district: '雨花台区',
      street: '铁心桥街道',
      detail: '软件大道101号',
      isDefault: true,
      createdAt: new Date().getTime(),
      updatedAt: new Date().getTime(),
      latitude: CommonConstants.DEFAULT_LATITUDE,
      longitude: CommonConstants.DEFAULT_LONGITUDE,
    },
  ];

  private static withDelay<T>(callback: () => T | Promise<T>, delay = 300): Promise<T> {
    return new Promise((resolve, reject) => {
      setTimeout(async () => {
        try {
          const result: T = await callback();
          resolve(result);
        } catch (error) {
          reject(error);
        }
      }, delay);
    });
  }

  public static async listAddresses(): Promise<AddressDTO[]> {
    return Api.withDelay(() => {
      const list: AddressDTO[] = JSON.parse(
        JSON.stringify(Api.addressListMock),
      );
      list.sort((a, b) => {
        if (a.isDefault && !b.isDefault) {
          return -1;
        }
        if (!a.isDefault && b.isDefault) {
          return 1;
        }
        return b.updatedAt - a.updatedAt;
      });
      return list;
    });
  }

  public static async createAddress(address: AddressDTO): Promise<void> {
    return Api.withDelay(() => {
      const time: number = new Date().getTime();
      address.createdAt = time;
      address.updatedAt = time;
      address.id = util.generateRandomUUID(false);
      if (address.isDefault) {
        Api.addressListMock.forEach((item) => (item.isDefault = false));
      }
      Api.addressListMock.push(address);
    });
  }

  public static async updateAddress(address: AddressDTO): Promise<void> {
    return Api.withDelay(() => {
      address.updatedAt = new Date().getTime();
      const index = Api.addressListMock.findIndex(
        (item) => item.id === address.id,
      );
      if (index === -1) {
        throw new Error('该地址不存在');
      }
      if (address.isDefault) {
        Api.addressListMock.forEach((item) => (item.isDefault = false));
      }
      Api.addressListMock[index] = address;
    });
  }

  public static async deleteAddress(id: string): Promise<void> {
    return Api.withDelay(() => {
      const index = Api.addressListMock.findIndex((item) => item.id === id);
      if (index === -1) {
        throw new Error('该地址不存在');
      }
      Api.addressListMock.splice(index, 1);
    });
  }
}
