import { shippingAddress } from '@kit.AccountKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { IAddrInfo, Logger } from 'module_base';

/**
 * 通用Utils
 */
export class CommonUtils {
  static assign(target: Object, ...source: Object[]) {
    for (let s of source) {
      for (let key of Object.keys(s)) {
        const value = Reflect.get(s, key) as Object;
        Reflect.set(target, key, value)
      }
    }
  }

  public static async chooseAddress(context: Context): Promise<IAddrInfo | null> {
    try {
      const data: shippingAddress.AddressInfo = await shippingAddress.chooseAddress(context)
      if (data) {
        const address: IAddrInfo = {
          id: '0',
          name: data.userName,
          phone: data.mobileNumber,
          countryCode: data.countryCode,
          country: '',
          province: data.provinceName,
          city: data.cityName,
          district: data.districtName,
          street: data.streetName,
          detail: data.detailedAddress,
          isDefault: false,
          updatedAt: 0,
          createdAt: 0,
        }
        return address
      }
      return null
    } catch (error) {
      CommonUtils._dealAllError(error);
    }
    return null
  }

  private static _dealAllError(error: BusinessError): void {
    Logger.error(`Failed to login, errorCode: ${error.code}, errorMsg: ${error.message}`);
  }
}