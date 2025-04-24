export interface BanquetRoomItem {
  banquetName: string;
  hotelId: number;
  id: number;
  hotelName: string;
  labelList: string[];
  banner: string;
  introduce: string;
  profile: string;
}

export type GetBanquetRoomListResp = BanquetRoomItem[];
