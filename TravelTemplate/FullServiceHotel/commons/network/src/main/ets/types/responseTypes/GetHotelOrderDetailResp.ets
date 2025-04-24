export interface CheckInItem {
  checkInName: string;
  checkInTel: string;
}

export interface RoomInfo {
  pmsResourceInfoList: PmsResourceInfoItem[];
}

export interface PmsResourceInfoItem {
  resourceUrl: string;
}

export interface GetHotelOrderDetailResp {
  orderNo: string;
  orderStatus: string;
  createTime: string;
  payMethod: string;
  prepayResult: string;
  remark: string;
  actualPaidPrice: string;
  payTime: string;
  payExpireTime: string;
  arrDate: string;
  depDate: string;
  hotelId: number;
  hotelName: string;
  roomId: number;
  roomName: string;
  nights: number;
  rmQty: number;
  checkInList: CheckInItem[];
  cover: string;
}
