import { shippingAddress } from '@kit.AccountKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Context } from '@ohos.abilityAccessCtrl';
import { default as Logger } from '../Logger';

export function getSystemAddress(context: Context) {
  return new Promise<shippingAddress.AddressInfo>((resolve, reject) => {
    try {
      shippingAddress.chooseAddress(context).then((data: shippingAddress.AddressInfo) => {
        Logger.info(0x0000, 'testTag', 'Succeeded in choosing address.');
        resolve(data)
      }).catch((error: BusinessError) => {
        reject(error)
      })
    } catch (error) {
      reject(error)
    }
  })
}