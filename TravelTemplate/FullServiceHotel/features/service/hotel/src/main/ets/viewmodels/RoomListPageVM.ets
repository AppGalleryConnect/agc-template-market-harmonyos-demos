import { AccountUtil, AppStorageMap, FormatUtil, RouterMap, RouterModule, UserInfoModel } from 'commonlib';
import { https } from 'network';
import { mapRoomListResponse } from '../mapper/RoomMapper';
import { MappedHotel } from '../models/MappedHotel';
import { MappedRoom } from '../models/MappedRoom';
import { DatePickerPanelVM } from './DatePickerPanelVM';

@ObservedV2
export class RoomListPageVM {
  @Trace hotel: MappedHotel | undefined = undefined;

  @Trace topBannerList: ResourceStr[] = [];

  @Trace roomList: MappedRoom[] = [];

  private readonly datePickerVM: DatePickerPanelVM = DatePickerPanelVM.instance;

  private readonly userInfo: UserInfoModel = AccountUtil.getUserInfo();

  private static _instance: RoomListPageVM;

  public static get instance() {
    if (!RoomListPageVM._instance) {
      RoomListPageVM._instance = new RoomListPageVM();
    }
    return RoomListPageVM._instance;
  }

  public async initData() {
    this.hotel = RouterModule.getNavParam<MappedHotel>({ url: RouterMap.HOTEL_ROOM_LIST });
    this.getRoomList();
  }

  public async getRoomList() {
    if (!this.hotel) {
      return;
    }
    const res = await https.getRoomList({
      arrDate: FormatUtil.dateAsISO(this.datePickerVM.checkInDate),
      depDate: FormatUtil.dateAsISO(this.datePickerVM.checkOutDate),
      memberLevel: '01',
      orgUnitNo: this.hotel!.orgUnitNo,
      roomNum: this.datePickerVM.roomCount,
      userId: this.userInfo.id,
      tenantId: AppStorage.get(AppStorageMap.TENANT_ID) ?? -1,
    });
    if (res.code === 0) {
      this.topBannerList = res.data.bannerList.map((item) => FormatUtil.getImgResource(item));
      this.roomList = mapRoomListResponse(res.data.roomList);
    }
  }
}
