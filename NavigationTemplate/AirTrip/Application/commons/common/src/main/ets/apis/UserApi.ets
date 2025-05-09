import { cloudFunction } from '@kit.CloudFoundationKit';
import { BusinessError } from '@kit.BasicServicesKit';

export class UserApi {
  // 授权关联登录
  public static userLogin(authorizationCode: string): Promise<cloudFunction.FunctionResult> {
    return new Promise((resolve, reject) => {
      cloudFunction.call({
        name: 'air-trip-service',
        version: '$latest', //如果不传入版本号，默认为“$latest”。
        timeout: 60 * 1000, //单位为毫秒，默认为70*1000毫秒。
        data: {
          'operation': 'userLogin',
          'authorizationCode': authorizationCode,
        },
      }).then((value: cloudFunction.FunctionResult) => {
        resolve(value)
        console.info(`Succeeded in call the function, result: ${JSON.stringify(value.result)}`);
      }).catch((err: BusinessError) => {
        reject(err)
        console.error(`Failed to call the function, Code: ${err.code}, message: ${err.message}`);
      })
    })
  }

  /*
   * 更新用户信息
   * */
  public static updateUserInfo(userData: Record<string, string>): Promise<cloudFunction.FunctionResult> {
    return new Promise((resolve, reject) => {
      cloudFunction.call({
        name: 'air-trip-service',
        version: '$latest', //如果不传入版本号，默认为“$latest”。
        timeout: 60 * 1000, //单位为毫秒，默认为70*1000毫秒。
        data: {
          'operation': 'upsertUserInfo',
          'userData': userData,
        },
      }).then((value: cloudFunction.FunctionResult) => {
        resolve(value)
        console.info(`Succeeded in call the function, result: ${JSON.stringify(value.result)}`);
      }).catch((err: BusinessError) => {
        reject(err)
        console.error(`Failed to call the function, Code: ${err.code}, message: ${err.message}`);
      })
    })
  }
}
