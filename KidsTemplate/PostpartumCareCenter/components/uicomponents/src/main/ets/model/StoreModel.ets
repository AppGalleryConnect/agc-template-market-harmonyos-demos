import { Logger, LocateUtil } from '@ohos_agcit/postpartum_care_center_utils';

const TAG: string = '[LocateUtil]';

@ObservedV2
export class StoreModel {
  // 门店编号
  id: number;
  // 门店名称
  name: string;
  // 门店地址
  address: string;
  // 门店联系电话
  telephone: string;
  // 门店图片资源
  image: Resource;
  // 门店所在城市
  city: string;

  storeLatitude: number;

  storeLongitude: number;

  @Trace distance: number | null = null;

  @Trace translateX: number = 0; // X轴偏移量

  @Trace translateY: number = 0; // Y轴偏移量

  constructor(id: number, name: string, address: string, telephone: string, image: Resource, city: string,
    storeLatitude: number, storeLongitude: number) {
    this.id = id;
    this.name = name;
    this.address = address;
    this.telephone = telephone;
    this.image = image;
    this.city = city;
    this.storeLatitude = storeLatitude;
    this.storeLongitude = storeLongitude;
  }

  getStoreDistance() {
    this.distance = LocateUtil.getDistance(this.storeLatitude, this.storeLongitude);
    if (this.distance) {
      this.distance = parseFloat((this.distance).toFixed(1));
      Logger.debug(TAG, `getStoreDistance distance: ${this.distance}`);
    }
    Logger.debug(TAG, `getStoreDistance distance null`);
  }
}