import { cloudFunction } from '@kit.CloudFoundationKit';
import { BusinessError } from '@kit.BasicServicesKit';

export class AppResourceApi {

  public static getResourceData(loadMode: cloudFunction.LoadMode): Promise<cloudFunction.FunctionResult> {
    return new Promise((resolve, reject) => {
      cloudFunction.call({
        name: 'app-resource-service',
        version: '$latest', // 如果不传入版本号，默认为“$latest”。
        loadMode: loadMode,  // 获取缓存数据必须设置为PRELOAD
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