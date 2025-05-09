import { ProductSelectionInfo } from './ProductSelectionInfo';

export interface ProductInfo {
  id: string;                      // 商品id
  banners: string[];               // 商品封面列表
  price: string;                   // 商品价格
  dashPrice: string;               // 商品划线价格
  sales: string;                   // 商品销量
  title: string;                   // 商品标题
  tags: string[];                  // 商品标签列表
  logistics: ProductServiceItem[]; // 物流服务信息
  service: ProductServiceItem[];   // 服务信息
  pictures: string[];              // 商品详情区图片列表
  selectionInfo: ProductSelectionInfo; // 商品规格选择信息
}

export interface ProductServiceItem {
  icon: string;
  content: string;
}
