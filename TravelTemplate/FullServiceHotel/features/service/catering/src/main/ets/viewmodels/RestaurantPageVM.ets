import { LocationStatus, LocationUtil, RouterMap, RouterModule, TelUtil } from 'commonlib';
import { https } from 'network';
import { mapRestaurantListResponse } from '../mapper/RestaurantMapper';
import { MappedRestaurant } from '../models/MappedRestaurant';
import { mapCommon } from '@kit.MapKit';

@ObservedV2
export class RestaurantPageVM {
  @Trace shopId: number | undefined = undefined;
  @Trace restaurant: MappedRestaurant | undefined = undefined;
  @Trace gcj02LatLng: mapCommon.LatLng | undefined = undefined;
  private static _instance: RestaurantPageVM;

  public static get instance() {
    if (!RestaurantPageVM._instance) {
      RestaurantPageVM._instance = new RestaurantPageVM();
    }
    return RestaurantPageVM._instance;
  }

  public initData() {
    const params: number | undefined = RouterModule.getNavParam({ url: RouterMap.RESTAURANT_INFO });
    if (params) {
      this.shopId = params;
      this.getRestaurant();
    }
  }

  public async getRestaurant() {
    this.restaurant = undefined;
    const res = await https.getRestaurantDetail(this.shopId ?? -1);
    if (res.code === 0) {
      const locationRes = await LocationUtil.getCachedGCJ02Location();
      if (locationRes.result === LocationStatus.SUCCESS) {
        this.gcj02LatLng = locationRes.gcj02LatLng;
      }

      this.restaurant = mapRestaurantListResponse([res.data], this.gcj02LatLng)[0];
    }
  }

  public makeCall() {
    TelUtil.makeCall(this.restaurant?.phoneNumber);
  }

  public jumpToFoodInfoPage(mealId: number) {
    RouterModule.push({ url: RouterMap.RESTAURANT_FOOD_INFO, param: mealId });
  }
}
