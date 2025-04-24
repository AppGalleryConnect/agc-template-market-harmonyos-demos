import { mapCommon } from '@kit.MapKit';
import { FormatUtil, LocationStatus, LocationUtil, RouterMap, RouterModule } from 'commonlib';
import { https, Restaurant } from 'network';
import { mapRestaurantListResponse } from '../mapper/RestaurantMapper';
import { MappedRestaurant } from '../models/MappedRestaurant';
import { promptAction } from '@kit.ArkUI';

@ObservedV2
export class RestaurantListPageVM {
  initList: Restaurant[] = [];

  @Trace restaurantList: MappedRestaurant[] = [];

  @Trace topBanner: ResourceStr = '';

  @Trace gcj02LatLng: mapCommon.LatLng | undefined = undefined;

  private static _instance: RestaurantListPageVM;

  public static get instance() {
    if (!RestaurantListPageVM._instance) {
      RestaurantListPageVM._instance = new RestaurantListPageVM();
    }
    return RestaurantListPageVM._instance;
  }

  public async initData() {
    this.getTopBanner();
    await this.getRestaurantList();
    this.getGCJ02Location();
  }

  public async getTopBanner() {
    const res = await https.getServiceBanner(3);
    if (res.code === 0) {
      this.topBanner = FormatUtil.getImgResource(res.data.image);
    }
  }

  public async getRestaurantList() {
    const res = await https.getRestaurantList();
    if (res.code === 0) {
      this.initList = res.data;
      this.restaurantList = mapRestaurantListResponse(this.initList);
    }
  }

  public async getGCJ02Location() {
    const res = await LocationUtil.getCachedGCJ02Location();
    if (res.result === LocationStatus.SUCCESS) {
      this.gcj02LatLng = res.gcj02LatLng;
      if (this.gcj02LatLng && this.initList) {
        this.restaurantList = mapRestaurantListResponse(this.initList, this.gcj02LatLng);
      }
      return;
    } else if (res.result === LocationStatus.PERMISSION_DENIED) {
      promptAction.showToast({ message: '定位权限未开启，如需开启请前往系统设置' });
    } else {
      promptAction.showToast({ message: '未知错误，请稍后重试' });
    }
  }

  public jumpToRestaurantPage(shopId: number) {
    RouterModule.push({ url: RouterMap.RESTAURANT_INFO, param: shopId });
  }

  public jumpToFoodInfoPage(mealId: number) {
    RouterModule.push({ url: RouterMap.RESTAURANT_FOOD_INFO, param: mealId });
  }
}
