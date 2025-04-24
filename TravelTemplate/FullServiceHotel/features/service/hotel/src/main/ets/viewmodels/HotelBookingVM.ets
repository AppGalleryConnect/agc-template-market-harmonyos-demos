import { PrepayRoomRequest } from 'network';
import { PrepayCheckInData, PrepayCustomerInfo, PrepayHotelInfo, PrepayRoomInfo } from '../types';
import { MappedHotel } from '../models/MappedHotel';
import { MappedRoom, MappedRoomRate } from '../models/MappedRoom';
import { promptAction } from '@kit.ArkUI';
import { AccountUtil, RouterMap, RouterModule, UserInfo } from 'commonlib';

@ObservedV2
export class HotelBookingVM {
  public hotelInfo: PrepayHotelInfo = {
    hotelId: -1,
    orgUnitName: '',
    orgUnitNo: '',
  };

  public roomInfo: PrepayRoomInfo = {
    roomCode: '',
    roomId: -1,
    roomName: '',
    currency: '',
    isPrepaid: '',
    rmRate: '',
    rateCode: '',
    rateName: '',
  };

  public checkInData: PrepayCheckInData = {
    arrDate: '',
    depDate: '',
    rmQty: -1,
    nights: -1,
    remark: '',
    guest: {
      name: '',
      tel: '',
    },
    totalOrderPrice: '',
    actualPaidPrice: '',
  };
  public customerInfo: PrepayCustomerInfo = {
    booker: '',
    bookTel: '',
    cardNo: '',
    userId: -1,
  };
  private static _instance: HotelBookingVM;

  public static get instance() {
    if (!HotelBookingVM._instance) {
      HotelBookingVM._instance = new HotelBookingVM();
    }
    return HotelBookingVM._instance;
  }

  public initUserInfo() {
    const userInfo: UserInfo = AccountUtil.getUserInfo();
    this.customerInfo.booker = userInfo.name ?? '';
    this.customerInfo.bookTel = userInfo.cellphone ?? '';
    this.customerInfo.cardNo = userInfo.memberInfo?.memberCardNo ?? '';
    this.customerInfo.userId = userInfo.id;
  }

  public setHotelInfo(hotel: MappedHotel | undefined) {
    if (!hotel) {
      return;
    }
    this.hotelInfo.orgUnitName = hotel.name;
    this.hotelInfo.orgUnitNo = hotel.orgUnitNo;
    this.hotelInfo.hotelId = hotel.id;
  }

  public setRoomInfo(room: MappedRoom | undefined, roomRate: MappedRoomRate | undefined) {
    if (!room || !roomRate) {
      return;
    }
    this.roomInfo.roomId = room.id;
    this.roomInfo.roomName = room.name;
    this.roomInfo.roomCode = room.code;
    this.roomInfo.rateCode = roomRate.code;
    this.roomInfo.rateName = roomRate.name;
    this.roomInfo.rmRate = roomRate.rate.toString();
  }

  public setCheckInData(checkInData: PrepayCheckInData): void {
    this.checkInData = checkInData;
  }

  public isPrepayRequestValid(): boolean {
    // 用户信息未更新
    if (!this.customerInfo.booker || !this.customerInfo.bookTel) {
      promptAction.showToast({ message: '请先更新用户信息！' });
      const timer = setTimeout(() => {
        RouterModule.push({
          url: RouterMap.MINE_PROFILE_EDIT,
        });
        clearTimeout(timer);
      }, 1000);
      return false;
    }
    // 预订人未填写
    if (!this.checkInData.guest.name) {
      promptAction.showToast({ message: '请填写入住人！' });
      return false;
    }
    // 手机号未填写
    if (!this.checkInData.guest.tel) {
      promptAction.showToast({ message: '请填写手机号！' });
      return false;
    }
    // 手机号格式不正确
    const reg = /^[1][3,4,5,6,7,8,9][0-9]{9}$/;
    if (!reg.test(this.checkInData.guest.tel)) {
      promptAction.showToast({ message: '手机号格式不正确！' });
      return false;
    }
    return true;
  }

  public getPrepayRequestParam(): PrepayRoomRequest | void {
    this.initUserInfo();
    if (!this.isPrepayRequestValid()) {
      return undefined;
    }
    const data: PrepayRoomRequest = {
      /*
       * --------  酒店信息  --------
       */
      hotelId: this.hotelInfo.hotelId,
      orgUnitName: this.hotelInfo.orgUnitName,
      orgUnitNo: this.hotelInfo.orgUnitNo,
      /*
       * --------  房间信息  --------
       */
      isPrepaid: this.roomInfo.isPrepaid,
      rmRate: this.roomInfo.rmRate,
      rateCode: this.roomInfo.rateCode,
      rateName: this.roomInfo.rateName,
      roomCode: this.roomInfo.roomCode,
      roomId: this.roomInfo.roomId,
      roomName: this.roomInfo.roomName,
      /*
       * --------  用户信息  --------
       */
      booker: this.customerInfo.booker,
      bookTel: this.customerInfo.bookTel,
      cardNo: this.customerInfo.cardNo,
      userId: this.customerInfo.userId,
      /*
       * --------  入住信息  --------
       */
      arrDate: this.checkInData.arrDate,
      depDate: this.checkInData.depDate,
      rmQty: this.checkInData.rmQty,
      nights: this.checkInData.nights,
      remark: this.checkInData.remark,
      guest: this.checkInData.guest,
      totalOrderPrice: this.checkInData.totalOrderPrice,
      actualPaidPrice: this.checkInData.actualPaidPrice,
    };
    return data;
  }
}
