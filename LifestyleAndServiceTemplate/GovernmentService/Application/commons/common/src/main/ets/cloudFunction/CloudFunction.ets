import { cloudFunction } from '@kit.CloudFoundationKit';
import { BusinessError } from '@kit.BasicServicesKit';


export class CloudFunction {
  /*
 * 调用云函数获取用户信息
 * */
  public static getUserInfo(authorizationCode: string): Promise<cloudFunction.FunctionResult> {
    return new Promise((resolve, reject) => {
      cloudFunction.call({
        name: 'govn-template-userinfo',
        version: '$latest', //如果不传入版本号，默认为“$latest”。
        timeout: 60 * 1000, //单位为毫秒，默认为70*1000毫秒。
        data: {
          'operation': 'query',
          'authorizationCode': authorizationCode,
        },
      }).then((value: cloudFunction.FunctionResult) => {
        resolve(value)
        console.info(`Succeeded in call the function, result: ${value.result.toString()}`);
      }).catch((err: BusinessError) => {
        reject(err)
        console.error(`Failed to call the function, Code: ${err.code}, message: ${err.message}`);
      })
    })
  }
  /*
   * 调用云函数进行推送服务
   * */
  public static pushMessage(pushToken: string): Promise<cloudFunction.FunctionResult> {
    return new Promise((resolve, reject) => {
      cloudFunction.call({
        name: 'govn-template-push',
        version: '$latest', //如果不传入版本号，默认为“$latest”。
        timeout: 60 * 1000, //单位为毫秒，默认为70*1000毫秒。
        data: {
          'operation': 'query',
          'pushToken': pushToken,
        },
      }).then((value: cloudFunction.FunctionResult) => {
        resolve(value)
        console.info(`Succeeded in call the function, result: ${value.result.toString()}`);
      }).catch((err: BusinessError) => {
        reject(err)
        console.error(`Failed to call the function, Code: ${err.code}, message: ${err.message}`);
      })
    })
  }
}
