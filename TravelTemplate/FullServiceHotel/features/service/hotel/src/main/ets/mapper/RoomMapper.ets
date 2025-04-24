import { FormatUtil } from 'commonlib';
import { RoomItem, RoomRate } from 'network';
import { MappedRoom, MappedRoomRate } from '../models/MappedRoom';

export function mapRoomListResponse(roomList: RoomItem[]): MappedRoom[] {
  return roomList.map(
    (room) =>
      ({
        id: room.id && typeof room.id === 'number' ? room.id : -1,
        name: room.roomName ?? '',
        basePrice: room.minPrice && typeof room.minPrice === 'number' && room.minPrice > 0 ? room.minPrice : '---',
        cover: FormatUtil.getImgResource(room.imageUrl),
        tags: room.labelList ?? [],
        code: room.roomCode ?? '',
        mappedRoomRateList: convertRoomRateList(room.rmRateList),
      }) as MappedRoom,
  );
}

function convertRoomRateList(roomRateList: RoomRate[]): MappedRoomRate[] {
  if (!roomRateList) {
    return [];
  }
  let mappedRoomRateList: MappedRoomRate[] = [];
  for (let roomRate of roomRateList) {
    let mappedRoomRate: MappedRoomRate = {
      name: roomRate.rateName ?? '',
      rate: roomRate.rmRate && typeof roomRate.rmRate === 'number' && roomRate.rmRate > 0 ? roomRate.rmRate : '---',
      // remainingRooms: roomRate.roomNum && typeof roomRate.roomNum === 'number' ? roomRate.roomNum : 0,
      // currency: roomRate.currency ?? '',
      // isPrepaid: roomRate.isPrepaid ?? '',
      code: roomRate.rateCode ?? '',
    };
    mappedRoomRateList.push(mappedRoomRate);
  }
  return mappedRoomRateList;
}
