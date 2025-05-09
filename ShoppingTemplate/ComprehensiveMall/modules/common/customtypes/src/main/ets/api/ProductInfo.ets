

export interface ProductInfo {
  id: string;
  banners: string[];
  price: string;
  dashPrice: string;
  sales: string;
  title: string;
  tags: string[];
  logistics: ProductServiceItem[];
  service: ProductServiceItem[];
  pictures: string[];
  selectionInfo: ProductSelectionInfo;
}

export interface ProductServiceItem {
  icon: string;
  content: string;
}

export interface ProductSelectionInfo {
  defaultBanner: string;
  basicPrice: string;
  priceRange: string;
  priceRemark: string;
  totalPriceRemark: string;
  services: string[];
  skuItems: SkuItem[];
  specOptions: SpecOption[];
  specOptionWithImage: SpecOptionWithImage | null;
}

export interface SkuItem {
  skuCode: string;               // 库存保持单元编码 (唯一)
  specs: Record<string, string>; // 规格组合 (key to uuid)
  stock: number;
  price: number;
  dashPrice: number;
}

export interface SpecValue {
  id: string;
  text: string;
  image?: string;
}

export interface SpecOption {
  key: string;
  values: SpecValue[];
}

export interface SpecOptionWithImage {
  key: string;
  values: SpecValue[];
}
