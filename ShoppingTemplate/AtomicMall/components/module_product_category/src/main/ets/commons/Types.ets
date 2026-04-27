export interface CategoryItem {
  id: string;
  label: string;
  iconUrl: ResourceStr;
  subCategory?: SubCategoryItem[];
}

export interface SubCategoryItem {
  id: string;
  label: string;
}

export interface ProductSummaryItem {
  banner: ResourceStr;
  title: string;
  subCategoryId: string;
  id: string;
}
