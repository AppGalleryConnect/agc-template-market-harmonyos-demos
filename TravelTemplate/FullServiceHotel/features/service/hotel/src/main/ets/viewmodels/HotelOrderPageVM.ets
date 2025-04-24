import { GetOrderDetailRequest, https, PrepayRoomRequest } from 'network';
import { paymentService } from '@kit.PaymentKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';
import { HotelBookingVM } from './HotelBookingVM';
import { promptAction } from '@kit.ArkUI';
import { FormatUtil, Logger, RouterMap, RouterModule } from 'commonlib';
import { CheckInData } from '../models/CheckInData';
import { DatePickerPanelVM } from './DatePickerPanelVM';

@ObservedV2
export class HotelOrderPageVM {
  context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
  @Trace pageTitle: string = '';
  @Trace checkInData: CheckInData = new CheckInData();
  public readonly REMAIN_ROOM_NUMBER: number = 99;
  private readonly datePickerVM: DatePickerPanelVM = DatePickerPanelVM.instance;
  private readonly hotelBookingVM: HotelBookingVM = HotelBookingVM.instance;
  private static _instance: HotelOrderPageVM;

  public static get instance() {
    if (!HotelOrderPageVM._instance) {
      HotelOrderPageVM._instance = new HotelOrderPageVM();
    }
    return HotelOrderPageVM._instance;
  }

  public async initData() {
    this.pageTitle = this.hotelBookingVM.hotelInfo.orgUnitName;
    const checkInDate = this.datePickerVM.checkInDate;
    this.checkInData.checkInDateLabel = this.datePickerVM.getDateLabel(checkInDate);
    this.checkInData.checkInDateDescription = this.datePickerVM.getDateDescription(checkInDate);

    const checkOutDate = this.datePickerVM.checkOutDate;
    this.checkInData.checkOutDateLabel = this.datePickerVM.getDateLabel(checkOutDate);
    this.checkInData.checkOutDateDescription = this.datePickerVM.getDateDescription(checkOutDate);

    this.checkInData.totalDays = this.datePickerVM.totalDays;
    this.checkInData.roomCount = this.datePickerVM.roomCount;
    const roomInfo = this.hotelBookingVM.roomInfo;
    this.checkInData.roomTag = [roomInfo.roomName, roomInfo.rateName];
    this.updateRoomCount(0);
  }

  public updateRoomCount(num: number) {
    const newCount = this.checkInData.roomCount + num;
    if (newCount > 0 && newCount <= this.REMAIN_ROOM_NUMBER) {
      this.checkInData.roomCount = newCount;
      this.datePickerVM.roomCount = newCount;
      let rate: number = parseFloat(this.hotelBookingVM.roomInfo.rmRate);
      let total: number = rate * newCount * this.checkInData.totalDays;
      this.checkInData.actualPaidPrice = isNaN(total) ? '--' : total.toString();
    }
  }

  public async prepayRoom() {
    this.hotelBookingVM.setCheckInData({
      arrDate: FormatUtil.dateAsISO(this.datePickerVM.checkInDate),
      depDate: FormatUtil.dateAsISO(this.datePickerVM.checkOutDate),
      rmQty: this.checkInData.roomCount,
      nights: this.checkInData.totalDays,
      remark: this.checkInData.remark,
      guest: {
        name: this.checkInData.guestName,
        tel: this.checkInData.guestPhone,
      },
      totalOrderPrice: this.checkInData.actualPaidPrice,
      actualPaidPrice: this.checkInData.actualPaidPrice,
    });
    const data: PrepayRoomRequest | void = this.hotelBookingVM.getPrepayRequestParam();
    if (!data) {
      return;
    }
    const res = await https.prepayHotel(data);
    if (res.code === 500) {
      promptAction.showToast({ message: res.msg });
    }
    if (res.code === 0) {
      paymentService
        .requestPayment(this.context, res.data.orderStr)
        .then(() => {
          Logger.info('succeeded in paying');
        })
        .catch((error: BusinessError) => {
          promptAction.showToast({ message: '支付失败！' });
          const timer = setTimeout(() => {
            RouterModule.push({
              url: RouterMap.ORDER_DETAIL,
              param: {
                orderNo: res.data.mercOrderNo,
                orderType: 1,
                userId: data.userId,
              } as GetOrderDetailRequest,
            });
            clearTimeout(timer);
          }, 1000);
          Logger.error(`failed to pay, error.code: ${error.code}, error.message: ${error.message}`);
        });
    }
  }
}
