import { FormatUtil, LocationUtil } from 'commonlib';
import { mapCommon } from '@kit.MapKit';
import { MappedMealPackage, MappedRestaurant } from '../models/MappedRestaurant';
import { GetRestaurantListResp, MealPackage } from 'network';

export function mapRestaurantListResponse(
  restaurantList: GetRestaurantListResp,
  gcj02LatLng?: mapCommon.LatLng,
): MappedRestaurant[] {
  return restaurantList
    .sort((a, b) => {
      const sortA = a.restaurantInfo.sortNum ?? Infinity;
      const sortB = b.restaurantInfo.sortNum ?? Infinity;
      return sortA - sortB;
    })
    .map(
      (restaurant) =>
        ({
          name: restaurant.restaurantInfo.shopName ?? '',
          address: restaurant.restaurantInfo.address ?? '',
          distanceInMeters: convertDistanceDisplay(gcj02LatLng, restaurant.restaurantInfo.coordinate),
          phoneNumber: restaurant.restaurantInfo.restaurantTel ?? '',
          notice: generateNoticeByBusinessHours(
            restaurant.restaurantInfo.morningBusinessHours,
            restaurant.restaurantInfo.afternoonBusinessHours,
          ),
          monthlyTotalSales: FormatUtil.salesDisplay(restaurant.packageInfo.shopMonthlySell ?? 0),
          cover: FormatUtil.getImgResource(restaurant.restaurantInfo.image),
          mappedMealPackageList: mapMealPackageListResponse(restaurant.packageInfo.packages ?? []),
          banners: convertBanners(restaurant.restaurantInfo.banners),
          shopId: restaurant.restaurantInfo.shopId ?? -1,
        }) as MappedRestaurant,
    );
}

function convertBanners(data: string[] | null | undefined) {
  if (!data) {
    return [''];
  }
  let banners: ResourceStr[] = [];
  for (let banner of data) {
    banners.push(FormatUtil.getImgResource(banner));
  }
  return banners;
}

function mapMealPackageListResponse(mealPackageList: MealPackage[]): MappedMealPackage[] {
  return mealPackageList.map(
    (mealPackage) =>
      ({
        name: mealPackage.packageName ?? '',
        coverUrl: FormatUtil.getImgResource(mealPackage.image),
        originalPrice: mealPackage.price ?? '',
        promoPrice: mealPackage.discountedPrice ?? '---',
        monthlySales: FormatUtil.salesDisplay(mealPackage.monthlySell),
        id: mealPackage.id,
      }) as MappedMealPackage,
  );
}

function generateNoticeByBusinessHours(
  morning: string | null | undefined,
  afternoon: string | null | undefined,
): string {
  if (!morning || !afternoon) {
    return '营业时间: 未获取到具体数据';
  }
  return `营业时间: ${morning}  ${afternoon}`;
}

function convertDistanceDisplay(
  fromLatLng: mapCommon.LatLng | null | undefined,
  coordinate: string | null | undefined,
): string {
  if (!fromLatLng) {
    return '--km';
  }
  const toLatLng: mapCommon.LatLng | null = coordinate ? LocationUtil.parseLatLng(coordinate) : null;
  if (!toLatLng) {
    return '--km';
  }
  const distanceInMeters: number = LocationUtil.calculateDistance(fromLatLng, toLatLng);
  return FormatUtil.distanceDisplay(distanceInMeters);
}
