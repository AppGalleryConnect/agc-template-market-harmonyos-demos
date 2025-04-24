import { cloudFunction } from '@kit.CloudFoundationKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { commonToast } from '../utils/Toast';


export class CloudFunction {
  /*
 * 调用云函数获取用户信息
 * */
  public static getUserInfo(authorizationCode: string): Promise<cloudFunction.FunctionResult> {
    return new Promise((resolve, reject) => {
      cloudFunction.call({
        name: 'govn-userinfo',
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
   * 更新头像
   * */
  public static updateAvatar(unionID: string, avatarUrl: string): Promise<cloudFunction.FunctionResult> {
    return new Promise((resolve, reject) => {

      cloudFunction.call({
        name: 'ifet-template',
        version: '$latest', //如果不传入版本号，默认为“$latest”。
        timeout: 60 * 1000, //单位为毫秒，默认为70*1000毫秒。
        data: {
          'operation': 'update-avatar',
          'idToken': unionID,
          'avatarUrl': avatarUrl,
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
 * 获取首页数据
 * */
  public static getHomeServiceList(loadModeType: cloudFunction.LoadMode): Promise<cloudFunction.FunctionResult> {
    return new Promise((resolve, reject) => {
      cloudFunction.call({
        name: 'home-service',
        version: '$latest', //如果不传入版本号，默认为“$latest”。
        loadMode: loadModeType,
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
* 资讯页数据
* */
  public static getInformaticaList(searchType?: number, refreshType?: string): Promise<cloudFunction.FunctionResult> {
    return new Promise((resolve, reject) => {
      cloudFunction.call({
        name: 'informations-service',
        version: '$latest', //如果不传入版本号，默认为“$latest”。
        timeout: 60 * 1000, //单位为毫秒，默认为70*1000毫秒。
        data: {
          'operation': 'query',
          'searchType': searchType ?? '',
          'refreshType': refreshType ?? '',
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
    * 服务页数据
    * serviceType:{
    *   service: 获取全部服务
    *   institutions：获取医保机构信息
    *   inquiry：获取医保机构药品信息
    * }
    * */
  public static getServiceList(serviceType: string): Promise<cloudFunction.FunctionResult> {
    commonToast.show({
      type: 'loading'
    })
    return new Promise((resolve, reject) => {
      cloudFunction.call({
        name: 'service-list',
        version: '$latest', //如果不传入版本号，默认为“$latest”。
        timeout: 60 * 1000, //单位为毫秒，默认为70*1000毫秒。
        data: {
          'operation': 'query',
          'serviceType': serviceType,
        },
      }).then((value: cloudFunction.FunctionResult) => {
        resolve(value)
        console.info(`Succeeded in call the function, result: ${value.result.toString()}`);
      }).catch((err: BusinessError) => {
        reject(err)
        console.error(`Failed to call the function, Code: ${err.code}, message: ${err.message}`);
      }).finally(() => {
        commonToast.hide()
      })
    })
  }
}


