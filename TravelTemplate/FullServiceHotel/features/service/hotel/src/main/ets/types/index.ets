import { PrepayRoomGuestItem } from 'network';

export interface PrepayRoomInfo {
  roomId: number;
  roomCode: string;
  roomName: string;
  currency: string;
  isPrepaid: string;
  rmRate: string;
  rateCode: string;
  rateName: string;
}

export interface PrepayHotelInfo {
  orgUnitName: string;
  orgUnitNo: string;
  hotelId: number;
}

export interface PrepayCustomerInfo {
  booker: string;
  bookTel: string;
  cardNo: string;
  userId: number;
}

export interface PrepayCheckInData {
  arrDate: string;
  depDate: string;
  rmQty: number;
  nights: number;
  remark: string;
  guest: PrepayRoomGuestItem;
  totalOrderPrice: string;
  actualPaidPrice: string;
}
