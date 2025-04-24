import { MappedHotel } from '../models/MappedHotel';
import { mapCommon } from '@kit.MapKit';
import { HotelItem, https } from 'network';
import { AppStorageMap, FormatUtil, LocationStatus, LocationUtil, RouterMap, RouterModule } from 'commonlib';
import { promptAction } from '@kit.ArkUI';
import { mapHotelInfoListResponse } from '../mapper/HotelMapper';
import { DatePickerPanelVM } from './DatePickerPanelVM';
import { HotelBookingVM } from './HotelBookingVM';

@ObservedV2
export class HotelListPageVM {
  initList: HotelItem[] = [];

  @Trace hotelList: MappedHotel[] = [];

  @Trace topBanner: ResourceStr = '';

  @Trace gcj02LatLng: mapCommon.LatLng | undefined = undefined;

  datePickerVM: DatePickerPanelVM = DatePickerPanelVM.instance;

  private static _instance: HotelListPageVM;

  public static get instance() {
    if (!HotelListPageVM._instance) {
      HotelListPageVM._instance = new HotelListPageVM();
    }
    return HotelListPageVM._instance;
  }

  public async initData() {
    this.getTopBanner();
    await this.getHotelList();

  }

  public resetRoomCount(){
    this.datePickerVM.resetRoomCount()
  }

  public async getTopBanner() {
    const res = await https.getServiceBanner(2);
    if (res.code === 0) {
      this.topBanner = FormatUtil.getImgResource(res.data.image);
    }
  }

  public async getHotelList() {
    const res = await https.getHotelList({
      arrDate: FormatUtil.dateAsISO(this.datePickerVM.checkInDate),
      depDate: FormatUtil.dateAsISO(this.datePickerVM.checkOutDate),
      memberLevel: '01',
      roomNum: this.datePickerVM.roomCount,
      tenantId: AppStorage.get(AppStorageMap.TENANT_ID) ?? -1,
    });
    if (res.code === 0) {
      this.initList = res.data;
      this.getMapHotelList(this.initList);
    }
  }

  public async getMapHotelList(list: HotelItem[]) {
    const res = await LocationUtil.getCachedGCJ02Location();
    if (res.result === LocationStatus.SUCCESS) {
      this.gcj02LatLng = res.gcj02LatLng;
      if (this.gcj02LatLng && list) {
        this.hotelList = mapHotelInfoListResponse(list, this.gcj02LatLng);
      }
      return;
    } else if (res.result === LocationStatus.PERMISSION_DENIED) {
      this.hotelList = mapHotelInfoListResponse(list);
      promptAction.showToast({ message: '定位权限未开启，如需开启请前往系统设置' });
    } else {
      this.hotelList = mapHotelInfoListResponse(list);
      promptAction.showToast({ message: '未知错误，请稍后重试' });
    }
  }

  public jumpToRoomList(hotel: MappedHotel) {
    HotelBookingVM.instance.setHotelInfo(hotel);
    RouterModule.push({ url: RouterMap.HOTEL_ROOM_LIST, param: hotel });
  }
}
