import { HomeDetailResp, HomeResp, https } from 'network';
import { NavigationConfig } from '../model/Index';
import { CarouselImage, Commodity, HotelInfo, HotScenicSpot, RoomType, RoomTypePrice, Tag, TenantInfo } from 'type';
import { mapHotelInfoResponse } from '../mapper/HotelInfoMapper';
import { LazyDataSource } from 'util'
import { CalenderUtil, DateModel, Price } from 'calendar';

@ObservedV2
export class HomePageVM {
  @Trace recCommodityList: Commodity[] = [];
  @Trace hotSpotList: HotScenicSpot[] = [];
  @Trace navigationAreaList: NavigationConfig[] = [];
  @Trace carouselImageList: CarouselImage[] = [];
  @Trace swiperData: LazyDataSource<CarouselImage> = new LazyDataSource();
  @Trace hotelInfo: HotelInfo = new HotelInfo();
  @Trace roomData: LazyDataSource<RoomType> = new LazyDataSource();
  @Trace tenantInfo: TenantInfo | undefined = AppStorage.get('tenantInfo');
  private static _instance: HomePageVM;

  private constructor() {
    this.getHomeRollupInfo();
    this.getHotelInfo();
  }

  getPriceList(roomTypePriceList: RoomTypePrice[]) {
    //每次展示清空价格列表
    let priceList: Price[] = [];
    roomTypePriceList.forEach((item: RoomTypePrice) => {
      let priceItem: Price = {
        date: item.roomPriceDay,
        price: item.actualPrice,
      };
      priceList.push(priceItem);
    });
    return priceList;
  }

  getTags(tagsObj: Tag[], key: string): string[] {
    const tags: string[] = [];
    tagsObj.forEach((item: Tag) => {
      if (item.tag === key) {
        tags.push(...item.subTags);
      }
    });
    return tags;
  }

  getPriceByDate(priceList: RoomTypePrice[], date: DateModel, type: number): number {
    let priceItem =
      priceList.find((priceItem: RoomTypePrice) => priceItem.roomPriceDay ===
        `${date.year}-${CalenderUtil.formatDate(date.month)}-${CalenderUtil.formatDate(date.day)}`);
    return type === 0 ? priceItem?.actualPrice ?? 0 : priceItem?.originalPrice ?? 0;
  }

  async getHotelInfo() {
    const res: HomeDetailResp = await https.getHotelDetail() as HomeDetailResp;

    if (res.code === 200) {
      this.hotelInfo = mapHotelInfoResponse(res);
      this.roomData.pushArrayData(this.hotelInfo.roomTypeList);
    }
  }

  public static get instance() {
    if (!HomePageVM._instance) {
      HomePageVM._instance = new HomePageVM();
    }
    return HomePageVM._instance;
  }

  public async getHomeRollupInfo() {
    const res: HomeResp = await https.getHomeRollupInfo() as HomeResp;

    if (res.code === 200) {
      this.getCarouselImageList(res.data.carouselImageList);
    }
  }

  getCarouselImageList(carouselImageList: CarouselImage[]) {
    this.carouselImageList = [];

    carouselImageList.forEach((item: CarouselImage) => {
      const carouselImageItem: CarouselImage = {
        id: item.id,
        image: item.image,
      };
      this.carouselImageList.push(carouselImageItem);
    });
    this.swiperData.pushArrayData(this.carouselImageList);
  }
}
