import { DinnerMenu, GetMealDetailResp, MealPackage, Restaurant, RestaurantInfo } from '../../types/responseTypes';
import { MockImageMap } from '../Constants';
import { getFormattedResp } from '../Utils';

const restaurantInfo1: RestaurantInfo = {
  shopId: 103,
  shopName: '千和大酒店·中餐厅',
  coordinate: '118.7553,31.9735',
  image: MockImageMap.IMG_HOTEL_COVER1,
  address: '江苏省南京市雨花客厅',
  restaurantTel: '025-12345678',
  morningBusinessHours: '11:00-13:30',
  afternoonBusinessHours: '17:00-20:30',
  banners: [MockImageMap.IMG_HOTEL_COVER1],
  sortNum: 1,
};

const restaurantInfo2: RestaurantInfo = {
  shopId: 104,
  shopName: '千和大酒店·西餐厅',
  coordinate: '118.7553,31.9735',
  image: MockImageMap.IMG_HOTEL_COVER1,
  address: '江苏省南京市雨花客厅',
  restaurantTel: '025-12345678',
  morningBusinessHours: '11:00-14:00',
  afternoonBusinessHours: '16:00-21:00',
  banners: [MockImageMap.IMG_HOTEL_COVER1],
  sortNum: 2,
};

const mealUsageRule: string =
  '有效期：购买后30天内有效\r\n除外日期 ·有效期内周末、法定节假日通用\r\n使用时间 ·营业时间内可用\r\n预约提醒·无需预约，消费高峰期可能需要等位\r\n堂食外带·堂食外带均可\r\n温馨提示 · 团购用户可以享受店内其他所有优惠\r\n酒水饮料等问题，请致电商家咨询，以商家反馈为准如部分菜品因时令或其他不可抗因素导致无法提供，商家会用等价菜品替换，具体事宜请与商家协商\r\n使用优惠券购买团单，有效期以优惠券规则为准\r\n发票信息·本单发票由商家提供，详情请咨询商家';

const meal1: MealPackage = {
  image: MockImageMap.IMG_MEAL5,
  monthlySell: 10,
  discountedPrice: 329,
  price: 199,
  packageName: '家常三人餐',
  id: 1101,
};
const meal2: MealPackage = {
  image: MockImageMap.IMG_MEAL3,
  monthlySell: 39,
  discountedPrice: 199,
  price: 291,
  packageName: '石锅酸汤鱼套餐2-3人餐',
  id: 1102,
};
const meal3: MealPackage = {
  image: MockImageMap.IMG_MEAL1,
  monthlySell: 7,
  discountedPrice: 98,
  price: 195,
  packageName: '新疆风味双人餐',
  id: 1103,
};
const meal4: MealPackage = {
  image: MockImageMap.IMG_MEAL6,
  monthlySell: 0,
  discountedPrice: 39,
  price: 59,
  packageName: '拉面单人餐',
  id: 1104,
};

const meal5: MealPackage = {
  image: MockImageMap.IMG_MEAL1,
  monthlySell: 83,
  discountedPrice: 157,
  price: 227,
  packageName: '巴西烤肉单人餐',
  id: 1105,
};
const meal6: MealPackage = {
  image: MockImageMap.IMG_MEAL2,
  monthlySell: 96,
  discountedPrice: 158,
  price: 245,
  packageName: '海鲜意面双人餐',
  id: 1106,
};

const dinnerMenus: DinnerMenu[] = [
  {
    dishCategoryName: '主菜',
    dishes: [
      { name: '宫保鸡丁', price: '89', showNumber: '1' },
      { name: '红烧肉', price: '95', showNumber: '1' },
    ],
  },
  {
    dishCategoryName: '配菜',
    dishes: [
      { name: '蒜蓉西兰花', price: '25', showNumber: '1' },
      { name: '清炒时蔬', price: '18', showNumber: '1' },
    ],
  },
  {
    dishCategoryName: '主食',
    dishes: [
      { name: '白米饭', price: '45', showNumber: '3' },
      { name: '蛋炒饭', price: '35', showNumber: '1' },
    ],
  },
  {
    dishCategoryName: '汤品',
    dishes: [{ name: '酸辣汤', price: '22', showNumber: '1' }],
  },
  {
    dishCategoryName: '水果',
    dishes: [{ name: '水果拼盘', price: '20', showNumber: '1' }],
  },
];


const restaurant1: Restaurant = {
  restaurantInfo: restaurantInfo1,
  packageInfo: {
    shopMonthlySell: 503,
    packages: [meal1, meal2, meal3, meal4],
  },
};

const restaurant2: Restaurant = {
  restaurantInfo: restaurantInfo2,
  packageInfo: {
    shopMonthlySell: 180,
    packages: [meal5, meal6],
  },
};

export class RestaurantDatasetMock {
  private static _restaurantList: Restaurant[] = [restaurant1, restaurant2];
  private static _mealList: MealPackage[] = [meal1, meal2, meal3, meal4, meal5, meal6];

  public static getRestaurantList() {
    const list: Restaurant[] = JSON.parse(JSON.stringify(RestaurantDatasetMock._restaurantList));
    return getFormattedResp(list);
  }

  public static getRestaurantDetail(shopId: number) {
    const item = RestaurantDatasetMock._restaurantList.find((item) => item.restaurantInfo.shopId === shopId)!;
    const restaurant: Restaurant = JSON.parse(JSON.stringify(item));
    return getFormattedResp(restaurant);
  }

  public static getMealDetail(packageId: number) {
    const restaurant = RestaurantDatasetMock._restaurantList.find((item) => {
      const packages = item.packageInfo.packages;
      if (packages.find((meal) => meal.id === packageId)) {
        return true;
      }
      return false;
    })!;
    const meal = RestaurantDatasetMock._mealList.find((item) => item.id === packageId)!;
    const detail: GetMealDetailResp = {
      shopId: restaurant.restaurantInfo.shopId,
      shopName: restaurant.restaurantInfo.shopName,
      monthlySells: meal.monthlySell,
      discountedPrice: meal.discountedPrice,
      price: meal.price,
      packageName: meal.packageName,
      images: meal.image,
      id: meal.id,
      usageRule:mealUsageRule,
      dinnerMenus,
    };
    return getFormattedResp(detail);

  }
}