import { CarouselImage } from './CarouselImage';
import { Instructions } from './Index';
import { RoomType } from './RoomType';
import { ScenicHomestaySurrounds } from './ScenicHomestaySurrounds';

export class HotelInfo {
  appInfo: AppInfo;
  carouselImageList: CarouselImage[];
  navigationAreaList: string[];
  roomTypeList: RoomType[];
  scenicHomestaySurrounds: ScenicHomestaySurrounds[]

  constructor(
    appInfo: AppInfo = {
      id: 0,
      appName: '',
      labelList: [],
      banner: '',
      phone: '',
      address: '',
      introduction: '',
      instructions: {
        foundations: [],
        reservation: [],
        checkOut: []
      }
    },
    carouselImageList: CarouselImage[] = [],

    navigationAreaList: string[] = [],

    roomTypeList: RoomType[] = [],

    scenicHomestaySurrounds: ScenicHomestaySurrounds[] = []
  ) {
    this.appInfo = appInfo;
    this.carouselImageList = carouselImageList;
    this.navigationAreaList = navigationAreaList;
    this.roomTypeList = roomTypeList;
    this.scenicHomestaySurrounds = scenicHomestaySurrounds;
  }
}

export interface AppInfo {
  /*主键ID */
  id: number;
  appName: string;

  /*标签列表 */
  labelList: string[];
  banner: string | Resource;

  /*联系电话 */
  phone: string;

  /*地址 */
  address: string;
  introduction: string;
  instructions: Instructions;
}