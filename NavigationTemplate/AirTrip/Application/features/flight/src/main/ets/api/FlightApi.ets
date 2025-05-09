import { cloudFunction } from '@kit.CloudFoundationKit';
import { BusinessError } from '@kit.BasicServicesKit';

export class FlightApi {
  /*
   * 航班动态列表
   */
  public static getFlightSearchList(flightParamData: Record<string, string>): Promise<cloudFunction.FunctionResult> {
    return new Promise((resolve, reject) => {
      cloudFunction.call({
        name: 'air-trip-service',
        version: '$latest', // 如果不传入版本号，默认为“$latest”。
        timeout: 50 * 1000, // 单位为毫秒，默认为70*1000毫秒。
        data: {
          'operation': 'queryFlightList',
          'flightParamData': flightParamData,
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
   * 航班动态详情
   */
  public static getFlightDetail(flightNo: string): Promise<cloudFunction.FunctionResult> {
    return new Promise((resolve, reject) => {
      cloudFunction.call({
        name: 'air-trip-service',
        version: '$latest', // 如果不传入版本号，默认为“$latest”。
        timeout: 50 * 1000, // 单位为毫秒，默认为70*1000毫秒。
        data: {
          'operation': 'queryFlightDetail',
          'flightNo': flightNo,
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