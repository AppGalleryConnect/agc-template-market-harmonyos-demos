export interface RoomItem {
  id: number;
  roomName: string;
  minPrice: number;
  imageUrl: string;
  labelList: string[];
  roomCode: string;
  rmRateList: RoomRate[];
  roomNum: number;
}

export interface RoomRate {
  rmRate: number;
  rateName: string;
  rateCode: string;
}

export interface GetRoomListResp {
  bannerList: string[];
  roomList: RoomItem[];
}
