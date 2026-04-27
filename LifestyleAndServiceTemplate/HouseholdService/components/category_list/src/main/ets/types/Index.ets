export interface CategoryItem {
  id: string;
  label: string;
  iconUrl?: ResourceStr;
  subCategoryId?: string[];
}

export interface SubCategoryItem {
  id: string;
  label: string;
  itemList: ItemInfo[];
}

export interface ItemInfo {
  id: string;
  title: string;
  imgSrc?: ResourceStr;
  description?: string;
}