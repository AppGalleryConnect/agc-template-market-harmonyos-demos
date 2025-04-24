import { BusinessError, pasteboard } from '@kit.BasicServicesKit';
import {
  CarGoodInfo,
  CouponResp,
  DishesType,
  GetGoodSpecResp,
  GetHelpMsgResp,
  GetMyCarResp,
  GetMyOrderResp,
  GetStoreInfoResp,
  GetTableInfoResp,
  GetUserInfoResp,
  Good,
  MyCouponResp,
  PackageSpec,
} from '../models/ResponseModel';
import * as HttpRequestApi from '../axiosHttpRequest/HttpRequestApi';
import { call } from '@kit.TelephonyKit';
import { AddDnOrderReq, GoodReq } from '../models/RequestModel';
import { promptAction } from '@kit.ArkUI';
import { paymentService } from '@kit.PaymentKit';
import { common } from '@kit.AbilityKit';
import { HttpCode, OrderTypeEnum } from '../constants/Common';

export function getCancelLoginUtil(): Promise<GetUserInfoResp> {
  return new Promise((resolve, reject) => {
    HttpRequestApi.getCloseLoginHm()
      .then((resp: GetUserInfoResp) => {
        if (resp) {
          console.info(`getCancelLoginUtil resp:${JSON.stringify(resp)}.`);
          resolve(resp)
        } else {
          console.error(`getCancelLoginUtil error: ${JSON.stringify(resp)}.`);
          reject(resp)
        }
      })
      .catch((e: BusinessError) => {
        console.error(`getCancelLoginUtil error: ${JSON.stringify(e)}.`);
        reject(e)
      })
  })
}

export function getStoreInfoUtil(storeId: string): Promise<GetStoreInfoResp> {
  return new Promise((resolve, reject) => {
    HttpRequestApi.getStoreInfo(storeId)
      .then((resp: GetStoreInfoResp) => {
        if (resp.store) {
          console.info(`getStoreInfo resp:${JSON.stringify(resp)}.`);
          resolve(resp)
        } else {
          console.error(`getStoreInfo error: ${JSON.stringify(resp)}.`);
          reject(resp)
        }
      })
      .catch((e: BusinessError) => {
        console.error(`getStoreInfo error: ${JSON.stringify(e)}.`);
        reject(e)
      })
  })
}

export function getTableInfoUtil(tableId: string): Promise<GetTableInfoResp> {
  return new Promise((resolve, reject) => {
    HttpRequestApi.getTableInfo(tableId)
      .then((resp: GetTableInfoResp) => {
        if (resp) {
          console.info(`getTableInfo resp：${JSON.stringify(resp)}.`);
          resolve(resp)
        } else {
          console.error(`getTableInfo error: ${JSON.stringify(resp)}.`);
          reject(resp)
        }
      })
      .catch((e: BusinessError) => {
        console.error(`getTableInfo error: ${JSON.stringify(e)}.`);
        reject(e)
      })
  })
}

export function getCouponListUtil(): Promise<Array<CouponResp>> {
  return new Promise((resolve, reject) => {
    HttpRequestApi.getCoupons().then((resp: Array<CouponResp>) => {
      if (resp.length) {
        console.info(`getCouponList resp:${JSON.stringify(resp)}.`);
        resolve(resp)
      } else {
        console.error(`getCouponList error: ${JSON.stringify(resp)}.`);
        reject(resp)
      }
    })
      .catch((e: BusinessError) => {
        console.error(`getCouponList error: ${JSON.stringify(e)}.`);
        reject(e)
      })
  })
}

export function getLqCouponsUtil(couponId: string): Promise<number> {
  return new Promise((resolve, reject) => {
    HttpRequestApi.getLqCoupons(couponId).then((resp: number) => {
      if (resp === HttpCode.SUCCESS) {
        console.info(`getLqCouponsUtil resp:${JSON.stringify(resp)}.`);
        resolve(resp)
      } else {
        console.error(`getLqCouponsUtil error: ${JSON.stringify(resp)}.`);
        reject(resp)
      }
    })
      .catch((e: BusinessError) => {
        console.error(`getLqCouponsUtil error: ${JSON.stringify(e)}.`);
        reject()
      })
  })
}

export function getMyCouponsUtil(): Promise<Array<MyCouponResp>> {
  return new Promise((resolve, reject) => {
    HttpRequestApi.getMyCoupons().then((resp: Array<MyCouponResp>) => {
      if (resp) {
        console.info(`getMyCouponsUtil resp:${JSON.stringify(resp)}.`);
        resolve(resp)
      } else {
        console.error(`getMyCouponsUtil error: ${JSON.stringify(resp)}.`);
        reject(resp)
      }
    })
      .catch((e: BusinessError) => {
        console.error(`getMyCouponsUtil error: ${JSON.stringify(e)}.`);
        reject(e)
      })
  })
}

export function getGoodInfoUtil(goodId: string = ''): Promise<Good> {
  return new Promise((resolve, reject) => {
    if (!goodId) {
      console.error(`getGoodInfo error. GoodId is empty: ${JSON.stringify(goodId)}.`);
      reject(`getGoodInfo error. GoodId is empty: ${JSON.stringify(goodId)}.`)
      return
    }
    HttpRequestApi.getGoodInfo(goodId).then((resp: Good) => {
      if (resp) {
        resolve(resp)
        console.info(`getGoodInfo resp:${JSON.stringify(resp)}.`);
      } else {
        console.error(`getGoodInfo error: ${JSON.stringify(resp)}.`);
        reject(resp)
      }
    })
      .catch((e: BusinessError) => {
        console.error(`getGoodSpec error: ${JSON.stringify(e)}.`);
        reject(e)
      })
  })
}

export function getMyCarUtil(): Promise<GetMyCarResp> {
  return new Promise((resolve, reject) => {
    HttpRequestApi.getMyCar().then((resp: GetMyCarResp) => {
      if (resp) {
        console.info(`getMyCar resp:${JSON.stringify(resp)}.`);
        AppStorage.setOrCreate('myCar', resp)
        resolve(resp)
      } else {
        console.error(`getMyCar error: ${JSON.stringify(resp)}.`);
        reject(resp)
      }
    })
      .catch((e: BusinessError) => {
        console.error(`getMyCar error: ${JSON.stringify(e)}.`);
        reject(e)
      })
  })
}

export function addCarUtil(good: Good, num: number = 1): Promise<number> {
  return new Promise((resolve, reject) => {
    HttpRequestApi.addCar(good, num).then((resp: number) => {
      if (resp) {
        console.info(`addCar resp:${JSON.stringify(resp)}.`);
        getMyCarUtil()
        resolve(resp)
      } else {
        console.error(`addCar error: ${JSON.stringify(resp)}.`);
        reject(resp)
      }
    })
      .catch((e: BusinessError) => {
        console.error(`addCar error: ${JSON.stringify(e)}.`);
        reject(e)
      })
  })
}

export function addCarSpecUtil(selectSpecInfo: GetGoodSpecResp, goodId: string | undefined,
  num: number = 1): Promise<number> {
  return new Promise((resolve, reject) => {
    if (!goodId) {
      console.error(`addCarSpecUtil error.goodId is empty.`);
      reject(`addCarSpecUtil error.goodId is empty.`)
      return
    }
    HttpRequestApi.addCarBySpec(goodId, selectSpecInfo, num).then((resp: number) => {
      if (resp) {
        console.info(`addCarSpecUtil resp:${JSON.stringify(resp)}.`);
        getMyCarUtil()
        resolve(resp)
      } else {
        console.error(`addCarSpecUtil error: ${JSON.stringify(resp)}.`);
        reject(resp)
      }
    })
      .catch((e: BusinessError) => {
        console.error(`addCarSpecUtil error: ${JSON.stringify(e)}.`);
        reject(e)
      })
  })
}

export function updateMyCarUtil(carId: string, num: number): Promise<number> {
  return new Promise((resolve, reject) => {
    HttpRequestApi.updateMyCar(carId, num).then((resp: number) => {
      if (resp) {
        console.info(`updateMyCarUtil resp:${JSON.stringify(resp)}.`);
        getMyCarUtil()
        resolve(resp)
      } else {
        console.error(`updateMyCarUtil error: ${JSON.stringify(resp)}.`);
        reject(resp)
      }
    })
      .catch((e: BusinessError) => {
        console.error(`updateMyCarUtil error: ${JSON.stringify(e)}.`);
        reject(e)
      })
  })
}

export function addDnOrderUtil(list: Array<CarGoodInfo>, params: AddDnOrderReq): Promise<number> {
  return new Promise((resolve, reject) => {
    let sz = list?.map((carGood: CarGoodInfo) => {
      return {
        id: carGood.goodId,
        img: carGood.logo,
        money: carGood.money,
        name: carGood.name,
        num: carGood.num,
        spec: carGood.spec,
        combination: carGood.combination,
      } as GoodReq
    }) as Array<GoodReq>
    let req = {
      tableId: AppStorage.get('tableId') as string,
      userId: AppStorage.get('userId') as string,
      storeId: AppStorage.get('storeId') as string,
      money: params.money,
      reductionMoney: params.reductionMoney,
      discount: '0',
      mjMoney: params.mjMoney,
      xyhMoney: params.xyhMoney,
      note: params.note,
      type: 2,
      formId: 1,
      formId2: 1,
      payType: 0,
      sz: JSON.stringify(sz),
      tableware: AppStorage.get('dinerNum') as number,
      yhqMoney: params.yhqMoney ?? '0',
      couponId: params.couponId,
      orderType: params.orderType,
      boxMoney: params.orderType === OrderTypeEnum.STORE_DINING ? 0 : params.boxMoney, // orderType为0堂食，无打包费；为4外带，有打包费
    } as AddDnOrderReq
    HttpRequestApi.addDnOrder(req).then((resp: number) => {
      if (resp) {
        console.info(`AddDnOrderUtil resp:${JSON.stringify(resp)}.`);
        getMyCarUtil()
        resolve(resp)
      } else {
        console.error(`AddDnOrderUtil error: ${JSON.stringify(resp)}.`);
        reject(resp)
      }
    })
      .catch((e: BusinessError) => {
        console.error(`AddDnOrderUtil error: ${JSON.stringify(e)}.`);
        reject(e)
      })
  })
}

export function clearCarUtil(): Promise<number> {
  return new Promise((resolve, reject) => {
    HttpRequestApi.clearMyCar()
      .then((resp: number) => {
        if (resp) {
          console.info(`clearCarUtil resp:${JSON.stringify(resp)}.`);
          getMyCarUtil()
          resolve(resp)
        } else {
          console.error(`clearCarUtil error: ${JSON.stringify(resp)}.`);
          reject(resp)
        }
      })
      .catch((e: BusinessError) => {
        console.error(`clearCarUtil error: ${JSON.stringify(e)}.`);
        reject(e)
      })
  })
}


export function getDishesListUtil(): Promise<Array<DishesType>> {
  return new Promise((resolve, reject) => {
    let storeId: string = AppStorage.get('storeId') as string
    if (!storeId) {
      console.error('storeId is empty!');
      reject('storeId is empty!')
      return
    }
    HttpRequestApi.getDishesList(storeId)
      .then((resp: Array<DishesType>) => {
        if (resp.length) {
          console.info(`getDishesList resp:${JSON.stringify(resp)}.`);
          resolve(resp)
        } else {
          console.error(`getDishesList error: ${JSON.stringify(resp)}.`);
        }
      })
      .catch((e: BusinessError) => {
        console.error(`getDishesList error: ${JSON.stringify(e)}.`);
      })
  })
}

export function getGoodSpecUtil(goodId: string = '', selectSpecArr: PackageSpec[]): Promise<GetGoodSpecResp> {
  return new Promise((resolve, reject) => {
    if (!goodId || !selectSpecArr) {
      console.error(' GoodId or selectSpecArr is empty!');
      reject(' GoodId or selectSpecArr is empty!')
      return
    }
    HttpRequestApi.getGoodSpec(goodId, selectSpecArr).then((resp: GetGoodSpecResp) => {
      if (resp) {
        console.info(`getGoodSpec resp:${JSON.stringify(resp)}.`);
        resolve(resp)
      } else {
        console.error(`getGoodSpec error: ${JSON.stringify(resp)}.`);
        reject(resp)
      }
    })
      .catch((e: BusinessError) => {
        console.error(`getGoodSpec error: ${JSON.stringify(e)}.`);
        reject(e)
      })
  })
}

/*
 * 订单列表页
 */
export function getMyOrderUtil(page: number = 0, tab: number): Promise<Array<GetMyOrderResp>> {
  return new Promise((resolve, reject) => {
    HttpRequestApi.getMyOrder(page, tab).then((resp: Array<GetMyOrderResp>) => {
      if (resp) {
        console.info(`getMyOrder resp:${JSON.stringify(resp)}.`);
        resolve(resp)
      } else {
        console.error(`getMyOrder error: ${JSON.stringify(resp)}.`);
        reject(resp)
      }
    }).catch((e: BusinessError) => {
      console.error(`getMyOrder error: ${JSON.stringify(e)}.`);
      reject(e)
    })
  })
}

export function cancelOrderUtil(orderId: string): Promise<number> {
  return new Promise((resolve, reject) => {
    HttpRequestApi.cancelOrder(orderId)
      .then((resp: number) => {
        if (resp) {
          console.info(`cancelOrder resp：${JSON.stringify(resp)}.`);
          resolve(resp)
        } else {
          console.error(`cancelOrder error: ${JSON.stringify(resp)}.`);
          reject(resp)
        }
      })
      .catch((e: BusinessError) => {
        console.error(`cancelOrder error: ${JSON.stringify(e)}.`);
        reject(e)
      })
  })
}

/*
 * 个人中心页
 * */
export function getHelpMsgUtil(): Promise<Array<GetHelpMsgResp>> {
  return new Promise((resolve, reject) => {
    HttpRequestApi.getHelpMsg().then((resp: Array<GetHelpMsgResp>) => {
      if (resp) {
        console.info(`getHelpMsg resp:${JSON.stringify(resp)}.`);
        resolve(resp)
      } else {
        console.error(`getHelpMsg error: ${JSON.stringify(resp)}.`);
        reject(resp)
      }
    }).catch((e: BusinessError) => {
      console.error(`getHelpMsg error: ${JSON.stringify(e)}.`);
      reject(e)
    })
  })
}

export function purchaseUtil(context: common.UIAbilityContext): Promise<boolean> {
  return new Promise((resolve, reject) => {
    const orderStr =
      '{"app_id":"***","merc_no":"***","prepay_id":"xxx","timestamp":"1680259863114","noncestr":"1487b8a60ed9f9ecc0ba759fbec23f4f","sign":"****","auth_id":"***"}';
    paymentService.requestPayment(context, orderStr).then(() => {
      console.info('fzp  pay succeed');
      resolve(true)
      promptAction.showToast({
        message: $r('app.string.pay_success'),
        duration: 1000,
      })

    }).catch((error: BusinessError) => {
      console.error('fzp  pay failed.error:' + error.code);
      let payStr = $r('app.string.request_failed')
      if (error.code === HttpCode.CANCEL_PAY) {
        payStr = $r('app.string.cancel_pay')
      } else if (error.code === HttpCode.PAY_FAILED) {
        payStr = $r('app.string.pay_failed')
      } else if (error.code === HttpCode.NETWORK_ERROR) {
        payStr = $r('app.string.network_error')
      } else if (error.code === HttpCode.DUPLICATE_REQUEST) {
        payStr = $r('app.string.duplicate_request')
      }
      promptAction.showToast({
        message: payStr,
        duration: 1000,
      })
      reject(error.code)
    })
  })
}

export function copyString(param: string) {
  let pasteData: pasteboard.PasteData =
    pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, param)
  let systemPasteboard: pasteboard.SystemPasteboard = pasteboard.getSystemPasteboard();
  systemPasteboard.setData(pasteData)
    .then(() => {
      console.info('succeeded in setting PasteData. ')
      promptAction.showToast({
        message: $r('app.string.copy_success'),
        duration: 2000,
      });
    })
    .catch((err: BusinessError) => {
      console.error(`faild to set PasteData, ${JSON.stringify(err)}`)
    })
}

export function callPhone(phoneNumber: string) {
  call.makeCall(phoneNumber).then(() => {
    console.info(`Succeeded to makeCall`)
  })
    .catch((err: BusinessError) => {
      console.error(`Failed to makeCall , ${JSON.stringify(err)}}`)
    })
}
