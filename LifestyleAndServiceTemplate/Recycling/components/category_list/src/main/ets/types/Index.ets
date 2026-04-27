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

export interface ModelItemContentInfo {
  // 标题
  title: string;
  // 内容数组
  content: string[];
  // 描述
  description?: string;
}

export interface ModelItemInfo {
  // 标签
  label: string;
  // 内容数组
  content: ModelItemContentInfo[];
}