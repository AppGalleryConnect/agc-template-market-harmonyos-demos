import { FormatUtil, RouterMap, RouterModule } from 'commonlib';
import { https } from 'network';
import { mapRoomInfoResponse } from '../mapper/RoomInfoMapper';
import { MappedHotel } from '../models/MappedHotel';
import { MappedRoom, MappedRoomRate } from '../models/MappedRoom';
import { MappedRoomDetail } from '../models/MappedRoomInfo';
import { DatePickerPanelVM } from './DatePickerPanelVM';

@ObservedV2
export class RoomInfoPageVM {
  @Trace hotel: MappedHotel | undefined = undefined;
  @Trace room: MappedRoom | undefined = undefined;
  @Trace roomRate: MappedRoomRate | undefined = undefined;
  @Trace roomDetail: MappedRoomDetail | undefined = undefined;
  private readonly datePickerVM: DatePickerPanelVM = DatePickerPanelVM.instance;
  private static _instance: RoomInfoPageVM;

  public static get instance() {
    if (!RoomInfoPageVM._instance) {
      RoomInfoPageVM._instance = new RoomInfoPageVM();
    }
    return RoomInfoPageVM._instance;
  }

  public async initData() {
    const params = RouterModule.getNavParam<[MappedHotel, MappedRoom, MappedRoomRate]>({
      url: RouterMap.HOTEL_ROOM_DETAIL,
    });
    this.hotel = params?.[0];
    this.room = params?.[1];
    this.roomRate = params?.[2];
    this.getRoomInfo();
  }

  public clearData() {
    this.hotel = undefined;
    this.room = undefined;
    this.roomRate = undefined;
  }

  public async getRoomInfo() {
    if (!this.hotel || !this.room) {
      return;
    }
    const res = await https.getRoomDetail({
      orgUnitNo: this.hotel.orgUnitNo,
      roomCode: this.room.code,
    });
    if (res.code === 0) {
      this.roomDetail = mapRoomInfoResponse(res.data);
    }
  }

  public jumpToHotelOrder() {
    RouterModule.push({
      url: RouterMap.HOTEL_ROOM_ORDER,
      param: this.roomRate,
    });
  }
}
