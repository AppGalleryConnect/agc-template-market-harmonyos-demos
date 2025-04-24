export interface RoomInfoLabel {
  resourceName: string;
  resourceUrl: string;
}

export interface GetRoomDetailResp {
  roomName: string;
  roomCode: string;
  roomLabel: string;
  amenities: string;
  beds: string;
  mediaTech: string;
  foodDrink: string;
  toiletries: string;
  bath: string;
  other: string;
  bannerList: string[];
  labelList: RoomInfoLabel[];
}
