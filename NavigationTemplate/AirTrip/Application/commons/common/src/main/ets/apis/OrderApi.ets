import { cloudFunction } from '@kit.CloudFoundationKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { OrderInfo } from '../model/ApiResponse';

export class OrderApi {
  /*
   * 查询订单列表
   */
  public static getOrderList(status: string = ''): Promise<cloudFunction.FunctionResult> {
    return new Promise((resolve, reject) => {
      cloudFunction.call({
        name: 'air-trip-service',
        version: '$latest', // 如果不传入版本号，默认为“$latest”。
        timeout: 50 * 1000, // 单位为毫秒，默认为70*1000毫秒。
        data: {
          'operation': 'queryOrderList',
          'status': status,
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
   * 新增或修改订单
   */
  public static addOrUpdateOrder(data: OrderInfo): Promise<cloudFunction.FunctionResult> {
    return new Promise((resolve, reject) => {
      cloudFunction.call({
        name: 'air-trip-service',
        version: '$latest', // 如果不传入版本号，默认为“$latest”。
        timeout: 50 * 1000, // 单位为毫秒，默认为70*1000毫秒。
        data: {
          'operation': 'upsertOrder',
          'orderData': data,
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
   * 查询订单详情
   */
  public static getOrderDetail(orderNo: string): Promise<cloudFunction.FunctionResult> {
    return new Promise((resolve, reject) => {
      cloudFunction.call({
        name: 'air-trip-service',
        version: '$latest', // 如果不传入版本号，默认为“$latest”。
        timeout: 50 * 1000, // 单位为毫秒，默认为70*1000毫秒。
        data: {
          'operation': 'queryOrderDetail',
          'orderNo': orderNo,
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
   * 取消订单
   */
  public static cancelOrder(data: OrderInfo): Promise<cloudFunction.FunctionResult> {
    return new Promise((resolve, reject) => {
      cloudFunction.call({
        name: 'air-trip-service',
        version: '$latest', // 如果不传入版本号，默认为“$latest”。
        timeout: 50 * 1000, // 单位为毫秒，默认为70*1000毫秒。
        data: {
          'operation': 'cancelOrder',
          'orderData': data,
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
   * 支付订单
   */
  public static payOrder(data: OrderInfo): Promise<cloudFunction.FunctionResult> {
    return new Promise((resolve, reject) => {
      cloudFunction.call({
        name: 'air-trip-service',
        version: '$latest', // 如果不传入版本号，默认为“$latest”。
        timeout: 50 * 1000, // 单位为毫秒，默认为70*1000毫秒。
        data: {
          'operation': 'upsertOrder',
          'orderData': data,
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

  // 删除订单
  public static deleteOrder(orderData: OrderInfo): Promise<cloudFunction.FunctionResult> {
    return new Promise((resolve, reject) => {
      cloudFunction.call({
        name: 'air-trip-service',
        version: '$latest', // 如果不传入版本号，默认为“$latest”。
        timeout: 50 * 1000, // 单位为毫秒，默认为70*1000毫秒。
        data: {
          'operation': 'deleteOrder',
          'orderData': orderData,
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