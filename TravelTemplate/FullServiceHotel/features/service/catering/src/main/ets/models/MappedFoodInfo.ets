export interface MappedFoodInfo {
  mealPackageName: string;
  originalPrice: number | string;
  promoPrice: number | string;
  monthlySales: number | string;
  items: MappedFoodInfoItem[];
  coverUrl: PixelMap | ResourceStr | DrawableDescriptor;
  usageRule?: string;
}

export interface MappedFoodInfoItem {
  type: string;
  foods: MappedFood[];
}

export interface MappedFood {
  name: string;
  description: string;
  price: string;
}
