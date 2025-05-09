import { CarouselImage, Commodity, HotelInfo, HotScenicSpot, TravelNote } from 'type';

export interface BaseResponse<T = ESObject> {
  code: number;
  msg?: string;
  data: T;
}

export interface TenantResp {
  data: TenantInfoResp;
  code: number;
}

export interface TenantInfoResp {
  id: number;
  appName: string;
  labelList: string[];
  banner: string | Resource;
  phone: string;
  address: string;
  position: string;
  introduction: string;
}

export interface Home {
  recommendGoodsList: Commodity[],
  hotScenicSpotCategoryList: HotScenicSpot[],
  carouselImageList: CarouselImage[],
}

export interface HomeResp {
  data: Home;
  code: number;
}

export interface HomeDetailResp {
  data: HotelInfo;
  code: number;
}

export interface TravelNoteResp {
  data: TravelNote[],
  code: number
}

export interface Records {
  records: Commodity[];
}

export interface CommodityResp {
  data: Records,
  code: number
}

export interface CommodityCarouselImagesResp {
  data: CarouselImagesResp[],
  code: number
}

export interface CarouselImagesResp {
  id: number,
  image: ResourceStr,
  type: string,
}

export interface RoomTypeBedResp {
  id: number,
  bedTypeCode: string,
  bedTypeName: string,
  bedCount: number,
  roomTypeId: number,
  isDelete: number,
  appId: string,
  remark: string,
  createBy: string,
  createTime: string,
  updateBy: string,
  updateTime: string,
}

export interface RoomTypePriceListResp {
  id: number,
  roomTypeId: number,
  originalPrice: number,
  discount: number,
  actualPrice: number,
  roomPriceDay: string,
  remainingRooms: string,
  breakfastQuantity: number,
  sortOrder: number,
  isDelete: number,
  appId: string,
  remark: string,
  createBy: string,
  createTime: string,
  updateBy: string,
  updateTime: string,
}

export interface InstructionsResp {
  foundations: Tag[],
  reservation: Tag[],
  checkOut: Tag[],
}

export interface Tag {
  tag: string,
  subTags: string[]
}

export interface RoomTypeResp {
  /*主键ID */
  id: number,

  /*房型名称 */
  roomTypeName: string,

  /*房型banner图地址 */
  roomTypeBanner: string | Resource,

  /*房型详细图片列表 */
  roomTypeDetailImageList: string[] | Resource[],

  /*标签列表 */
  labelList: string[],

  /*入住人数限制 */
  occupancyLimit: number,

  /*房型介绍 */
  introduction: string,

  /*房型床信息列表 */
  roomTypeBedList: RoomTypeBedResp[],

  /*房型价格列表 */
  roomTypePriceList: RoomTypePriceListResp[],

  /*是否推荐房型 */
  isRecommended: boolean,

  /*房型设施服务 */
  instructions: InstructionsResp
}

export interface CommodityListResp {
  id: number,
  shopId: number,
  goodsSn: string,
  goodsName: string,
  banner: ResourceStr,
  detailImages: ResourceStr[],
  imageList: ResourceStr[],
  specification: string,
  counterPrice: Array<number>,
  retailPrice: Array<number>,
  detail: string,
  saleRule: string,
  count: number,
}