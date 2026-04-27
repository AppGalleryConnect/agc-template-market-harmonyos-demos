import { PaymentMethod } from './Constant';

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

  public static getShippingMethodValue(key: number): string {
    switch (key) {
      case 1:
        return '网点自寄'
      case 2:
        return '自行联系快递员'
      case 3:
        return '每天固定时间'
      default:
        return '网点自寄'
    }
  }

  public static getPaymentMethodValue(key: PaymentMethod): string {
    switch (key) {
      case PaymentMethod.PAY_NOW:
        return '寄付现结'
      case PaymentMethod.PAY_ON_DELIVERY:
        return '到付'
      default:
        return '寄付现结'
    }
  }
}