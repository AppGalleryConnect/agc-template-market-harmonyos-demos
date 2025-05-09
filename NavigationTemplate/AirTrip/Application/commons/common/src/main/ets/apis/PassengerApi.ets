import { cloudFunction } from '@kit.CloudFoundationKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { PassengerInfo } from '../model/ApiResponse';

export class PassengerApi {
  /*
   * 获取乘机人列表数据
   */
  public static getPassengerList(): Promise<cloudFunction.FunctionResult> {
    return new Promise((resolve, reject) => {
      cloudFunction.call({
        name: 'air-trip-service',
        version: '$latest', // 如果不传入版本号，默认为“$latest”。
        timeout: 60 * 1000, // 单位为毫秒，默认为70*1000毫秒。
        data: {
          'operation': 'queryPassengerList',
        },
      }).then((res: cloudFunction.FunctionResult) => {
        resolve(res)
        console.info(`Succeeded in call the function, result: ${JSON.stringify(res)}`);
      }).catch((err: BusinessError) => {
        reject(err)
        console.error(`Failed to call the function, Code: ${err.code}, message: ${err.message}`);
      })
    })
  }

  /*
   * 添加或编辑乘机人
   */
  public static addOrEditPassenger(data: PassengerInfo): Promise<cloudFunction.FunctionResult> {
    return new Promise((resolve, reject) => {
      cloudFunction.call({
        name: 'air-trip-service',
        version: '$latest', // 如果不传入版本号，默认为“$latest”。
        timeout: 60 * 1000, // 单位为毫秒，默认为70*1000毫秒。
        data: {
          'operation': 'upsertPassenger',
          'passengerData': data,
        },
      }).then((res: cloudFunction.FunctionResult) => {
        resolve(res)
        console.info(`Succeeded in call the function, result: ${JSON.stringify(res)}`);
      }).catch((err: BusinessError) => {
        reject(err)
        console.error(`Failed to call the function, Code: ${err.code}, message: ${err.message}`);
      })
    })
  }
  /*
   * 删除乘机人
   */
  public static deletePassenger(data: PassengerInfo): Promise<cloudFunction.FunctionResult> {
    return new Promise((resolve, reject) => {
      cloudFunction.call({
        name: 'air-trip-service',
        version: '$latest', // 如果不传入版本号，默认为“$latest”。
        timeout: 60 * 1000, // 单位为毫秒，默认为70*1000毫秒。
        data: {
          'operation': 'deletePassenger',
          'passengerData': data,
        },
      }).then((res: cloudFunction.FunctionResult) => {
        resolve(res)
        console.info(`Succeeded in call the function, result: ${JSON.stringify(res)}`);
      }).catch((err: BusinessError) => {
        reject(err)
        console.error(`Failed to call the function, Code: ${err.code}, message: ${err.message}`);
      })
    })
  }
}
