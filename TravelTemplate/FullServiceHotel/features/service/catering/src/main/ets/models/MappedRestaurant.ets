export interface MappedRestaurant {
  name: string; // 餐厅名称
  address: string; // 餐厅地址
  distanceInMeters: string; // 距离 (单位: 米)
  monthlyTotalSales: string; // 月销量 (所有套餐月销的总和)
  phoneNumber: string; // 联系方式
  notice: string; // 公告
  shopId: number;
  mappedMealPackageList: MappedMealPackage[];
  cover: PixelMap | ResourceStr | DrawableDescriptor;
  banners: (PixelMap | ResourceStr | DrawableDescriptor)[];
}

export interface MappedMealPackage {
  id: number;
  name: string;
  coverUrl: PixelMap | ResourceStr | DrawableDescriptor;
  originalPrice: number | string;
  promoPrice: number | string;
  monthlySales: string;
}
