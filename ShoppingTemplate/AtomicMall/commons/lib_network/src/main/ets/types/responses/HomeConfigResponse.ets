import { BaseResponse } from './BaseResponse';

export interface HomeConfigResp extends BaseResponse {
  categoryList: CategoryItem[];
  searchList: string[];
  bannerList: string[];
}

export interface CategoryProductListResp extends BaseResponse {
  productList: ProductSummaryItem[];
}

export interface CategoryItem {
  id: string;
  label: string;
  iconUrl: string;
  subCategory?: SubCategoryItem[];
}

export interface SubCategoryItem {
  id: string;
  label: string;
}

export interface ProductSummaryItem {
  banner: string;
  title: string;
  subCategoryId: string;
  id: string;
}
