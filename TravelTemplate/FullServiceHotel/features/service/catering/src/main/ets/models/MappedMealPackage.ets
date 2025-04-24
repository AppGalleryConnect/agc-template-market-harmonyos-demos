export interface MappedMealPackage {
  name: string;
  coverUrl: PixelMap | ResourceStr | DrawableDescriptor;
  originalPrice: number;
  promoPrice: number;
  monthlySales: number;
}

export interface MealPackage {
  name: string;
  coverUrl: PixelMap | ResourceStr | DrawableDescriptor;
  originalPrice: number;
  promoPrice: number;
  monthlySales: number;
  items: MealPackageItem[];
}

export interface MealPackageItem {
  type: string;
  foods: Food[];
}

export interface Food {
  name: string;
  description: string;
  price: number;
}
