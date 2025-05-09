import { CalenderUtil, DateModel, getMonthDate } from 'calendar';
import { RoomTypePrice } from 'type';
import { paymentService } from '@kit.PaymentKit';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { promptAction } from '@kit.ArkUI';

export function getRoomOrderAmount(priceList: RoomTypePrice[], startDate: DateModel, endDate: DateModel): number {
  let startDay = startDate.day;
  let endDay = endDate.day;
  let amount = 0;
  if (startDate.year === endDate.year && startDate.month === endDate.month) {
    for (let i = startDay; i < endDay; i++) {
      let priceItem = priceList.find((priceItem: RoomTypePrice) => priceItem.roomPriceDay ===
        `${startDate.year}-${CalenderUtil.formatDate(startDate.month)}-${CalenderUtil.formatDate(i)}`);
      amount += priceItem?.actualPrice ?? 0;
    }
  } else if ((startDate.year === endDate.year && startDate.month < endDate.month) || startDate.year < endDate.year) {
    let startMonthday = getMonthDate(startDate.year, startDate.month);
    for (let i = startDay; i < startMonthday.filter((item) => item !== 0).length; i++) {
      let priceItem = priceList.find((priceItem: RoomTypePrice) => priceItem.roomPriceDay ===
        `${startDate.year}-${CalenderUtil.formatDate(startDate.month)}-${CalenderUtil.formatDate(i)}`);
      amount += priceItem?.actualPrice ?? 0;
    }

    for (let i = 0; i < endDate.day; i++) {
      let priceItem = priceList.find((priceItem: RoomTypePrice) => priceItem.roomPriceDay ===
        `${startDate.year}-${CalenderUtil.formatDate(startDate.month)}-${CalenderUtil.formatDate(i)}`);
      amount += priceItem?.actualPrice ?? 0;
    }
  }

  return amount;
}

// 对接服务端接入华为支付调用
export async function pay(context: common.UIAbilityContext, data: string) {
  let payStr = '';
  paymentService.requestPayment(context, data).then(() => {
    payStr = '支付成功';
    //跳转到支付成功
  }).catch((error: BusinessError) => {
    if (error.code === 1001930000) {
      payStr = '取消支付';
    } else if (error.code === 1001930001) {
      payStr = '支付失败';
    } else if (error.code === 1001930011) {
      payStr = '网络链接异常';
    } else if (error.code === 1001930010) {
      payStr = '重复请求';
    }
    promptAction.showToast({
      message: payStr,
      duration: 1000,
    });
  });
}