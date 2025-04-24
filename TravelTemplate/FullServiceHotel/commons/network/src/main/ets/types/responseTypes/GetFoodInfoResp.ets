export interface DishItem {
  price: string;

  showNumber: string;

  name: string;
}

export interface DinnerMenu {
  dishCategoryName: string;
  dishes: DishItem[];
}

export interface GetMealDetailResp {
  shopId: number;
  shopName: string;
  monthlySells: number;
  discountedPrice: number;
  price: number;
  packageName: string;
  images: string;
  dinnerMenus: DinnerMenu[];
  id: number;
  usageRule?: string;
}
