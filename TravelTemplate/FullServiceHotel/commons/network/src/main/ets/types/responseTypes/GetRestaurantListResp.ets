export interface RestaurantInfo {
  shopName: string;
  coordinate: string;
  image: string;
  address: string;
  sortNum: number;
  restaurantTel: string;
  morningBusinessHours: string;
  afternoonBusinessHours: string;
  banners: string[];
  shopId: number;
}

export interface MealPackage {
  id: number;
  image: string;
  monthlySell: number;
  discountedPrice: number;
  price: number;
  packageName: string;
}

export interface MealPackageInfo {
  shopMonthlySell: number;
  packages: MealPackage[];
}

export interface Restaurant {
  restaurantInfo: RestaurantInfo;
  packageInfo: MealPackageInfo;
}

export type GetRestaurantListResp = Restaurant[];
