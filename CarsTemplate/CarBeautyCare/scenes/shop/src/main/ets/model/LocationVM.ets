import { SHOP_DATA, ShopModel, SHOP_DEFAULT, SHOP_BEIJING, SHOP_NANJING} from './ShopModel'
import { ShopCardModel } from './ShopModel'
import { LocateUtil, CommonModel } from '@ohos_agcit/car_beauty_care_commonlib'

const BEI_JING = '北京'

@ObservedV2
// 根据所在城市得出的店铺信息以及处理逻辑
export class LocationVM {
  private static _instance: LocationVM;
  vm:CommonModel = CommonModel.instance;
  @Trace locationName: string | Resource = BEI_JING;
  @Trace shopCardList: ShopCardModel[] = [];          //根据所在城市得出的店铺列表
  @Trace nearByGoodShop: ShopCardModel = SHOP_BEIJING[0];
  @Trace selectShopData: ShopCardModel = SHOP_BEIJING[0];     //选中展示的店铺

  public static get instance() {
    if (!LocationVM._instance) {
      LocationVM._instance = new LocationVM();
      LocationVM._instance.handleChangeLocation()
    }
    return LocationVM._instance;
  }

  // 根据店铺城市地址调整某个城市的所有店铺信息
  public updataLocationName(locationName: string | Resource) {
    this.locationName = locationName;
    this.handleChangeLocation();
  }

  // 根据id从店铺列表更新选中的展示的店铺数据
  public updataSelectShop(id: string) {
      const allShop:ShopCardModel[] = [...SHOP_NANJING,... SHOP_BEIJING, ...SHOP_DEFAULT];
      const shopData:ShopCardModel[] =  allShop.filter((item: ShopCardModel) => item.id === id);
      if (shopData.length > 0) {
        this.selectShopData = shopData[0];
      }
      if (this.vm.allowGetPosition) {
        this.setDistance();
      }
  }

  //附近的店铺默认为当地城市店铺列表第一家
  private setGoodShop() {
    this.nearByGoodShop = this.shopCardList[0];
    this.updataSelectShop(this.nearByGoodShop.id)
  }

  // 根据店铺城市地址调整用哪个城市的所有店铺信息
  private handleChangeLocation():void {
    let cityData:ShopCardModel [] = SHOP_DEFAULT;
    const name = this.locationName || '';
    const hasCity = SHOP_DATA.some((item: ShopModel) => {
      return name.toString().indexOf(item.city) !== -1
    })
    if (hasCity) {
      cityData = SHOP_DATA.filter( (item: ShopModel) => {
        return name.toString().indexOf(item.city) !== -1
      })[0].shops
    }

    this.shopCardList = cityData;
    this.setGoodShop();
  }

  @Monitor('vm.allowGetPosition')
  onChange(monitor:IMonitor) {
    if (monitor.value()?.now) {
      if (LocateUtil.userLatitude === null) {
        LocateUtil.getLocationPosition(() => {
          this.setDistance();
        });
      } else {
        this.setDistance()
      }
    }
  }

  setDistance() {
    this.shopCardList.forEach((item:ShopCardModel) => {
      item.distance = this.calculateDistance(item.location[0], item.location[1])
    })
    this.nearByGoodShop.distance = this.calculateDistance(this.nearByGoodShop.location[0],
      this.nearByGoodShop.location[1]);
    this.selectShopData.distance = this.calculateDistance(this.selectShopData.location[0],
      this.selectShopData.location[1]);
  }

  calculateDistance(latitude:number,longitude:number) {
    const distance = LocateUtil.getDistance(latitude,longitude)
    return distance === null?'0':distance;
  }

}