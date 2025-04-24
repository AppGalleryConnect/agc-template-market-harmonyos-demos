import {
  doRandBySync,
  getFormatDate,
  getFormatTime,
  getValidEndTime,
  LazyDataSource,
  Logger,
  TouristUtil,
  verifyCardNo,
  verifyPhoneNo,
} from 'common';
import { CreateTicketOrderRequest, GetOrderDetailRequest, https, TouristRequest } from 'network';
import { TouristInfo, TouristList } from 'types';
import { mapperTicketList } from '../mapper/Index';
import { TicketInfo, TicketType } from '../model/TicketInfo';
import { promptAction } from '@kit.ArkUI';

@ObservedV2
export class TicketVM {
  @Trace pathStack: NavPathStack = new NavPathStack();
  @Trace initDates: Date[] = [];
  @Trace selectedIndex: number = 0;
  @Trace selectedDate: Date = new Date();
  @Trace touristList: TouristList = TouristUtil.getTouristList();
  @Trace selectedTourists: TouristInfo[] = [new TouristInfo(doRandBySync(2))];
  @Trace selectTouristCount: number = 1;
  @Trace ticketList: LazyDataSource<TicketInfo> = new LazyDataSource();
  public static _instance: TicketVM;

  public static get instance() {
    if (!TicketVM._instance) {
      TicketVM._instance = new TicketVM();
    }
    return TicketVM._instance;
  }

  public constructor() {
    this.getTicketList();
  }

  getTouristIds() {
    let touristIds: string[] = [];
    this.selectedTourists.forEach(item => {
      touristIds.push(item.id);
    });
    return touristIds;
  }

  validate() {
    if (!verifyPhoneNo(this.selectedTourists[0].phone)) {
      promptAction.showToast({ message: '请正确填写游客手机号码', duration: 1000 });
      return false;
    } else if (this.selectedTourists.some((item) => !verifyCardNo(item.cardNo))) {
      promptAction.showToast({ message: '请正确填写游客身份证号', duration: 1000 });
      return false;
    } else if (this.selectedTourists.some((item) => (!item.name.length || !item.cardNo.length)) ||
      (!this.selectedTourists[0].name.length || !this.selectedTourists[0].cardNo.length)) {
      promptAction.showToast({ message: '请填写完整游客信息', duration: 1000 });
      return false;
    }
    return true;
  }

  createOrder(ticketType: TicketType | null) {
    let ticketRequest: CreateTicketOrderRequest = {
      orderNo: doRandBySync(6),
      orderTime: getFormatTime(new Date()),
      orderStatus: 1,
      couponId: 0,
      count: this.selectTouristCount,
      touristId: this.getTouristIds(),
      // 首个游客id
      contactId: this.selectedTourists[0].id,
      productName: ticketType?.ticketTypeName ?? '',
      productPrice: ticketType?.originalPrice ?? 0,
      startTime: getFormatDate(this.selectedDate),
      endTime: getValidEndTime(this.selectedDate),
    };
    this.selectedTourists.forEach((item) => {
      let params: TouristRequest = {
        id: item.id,
        name: item.name,
        phone: item.phone,
        cardType: item.cardType,
        cardNo: item.cardNo,
        isChecked: item.isChecked,
      };
      https.createTourist(params).then((res) => {
        if (res.code === 0) {
          Logger.info('create tourist success');
        }
      });
    });

    https.createTicketOrder(ticketRequest).then((res) => {
      if (res.code === 0) {
        this.pathStack.pushPathByName('TicketOrderDetail', {
          category: 0,
          orderNo: ticketRequest.orderNo,
        } as GetOrderDetailRequest);
      }
    });
  }

  getTicketList() {
    https.getTicketList().then((res) => {
      this.ticketList.pushArrayData(mapperTicketList(res.data));
    });
  }

  getAmount(price: number) {
    return price * this.selectTouristCount;
  }

  deleteTourist(index: number) {
    if (this.touristList.length > 1) {
      index === 0 ? this.touristList.splice(index + 1, 1) : this.touristList.splice(index, 1);
    } else {
      promptAction.showToast({ message: '请填写至少一位游客信息', duration: 1000 });
    }
  }

  changeTourist(value: number) {
    if (this.selectTouristCount > value) {
      this.selectTouristCount--;
      this.selectedTourists.pop();
    } else if (this.selectTouristCount < value) {
      this.selectTouristCount++;
      this.selectedTourists.push(new TouristInfo(doRandBySync(2)));
    } else {
      Logger.info('tourist count no change');
    }
  }
}