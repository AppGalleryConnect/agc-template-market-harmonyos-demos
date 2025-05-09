import { cloudFunction } from '@kit.CloudFoundationKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Trip } from '../model/ApiResponse';

export class ItineraryApi {
  /*
   * 获取行程列表数据
   */
  public static getTripList(): Promise<cloudFunction.FunctionResult> {
    return new Promise((resolve, reject) => {
      cloudFunction.call({
        name: 'air-trip-service',
        version: '$latest', // 如果不传入版本号，默认为“$latest”。
        timeout: 60 * 1000, // 单位为毫秒
        data: {
          'operation': 'queryTripList',
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
   * 新增行程
   */
  public static addTrip(data: Trip): Promise<cloudFunction.FunctionResult> {
    return new Promise((resolve, reject) => {
      cloudFunction.call({
        name: 'air-trip-service',
        version: '$latest', // 如果不传入版本号，默认为“$latest”。
        timeout: 50 * 1000, // 单位为毫秒，默认为70*1000毫秒。
        data: {
          'operation': 'upsertTrip',
          'tripData': data,
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
   * 查询行程详情
   */
  public static getTripDetail(id: string): Promise<cloudFunction.FunctionResult> {
    return new Promise((resolve, reject) => {
      cloudFunction.call({
        name: 'air-trip-service',
        version: '$latest', // 如果不传入版本号，默认为“$latest”。
        timeout: 50 * 1000, // 单位为毫秒，默认为70*1000毫秒。
        data: {
          'operation': 'queryTripDetail',
          'tripId': id,
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