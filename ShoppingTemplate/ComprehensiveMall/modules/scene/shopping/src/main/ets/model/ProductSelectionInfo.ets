

export interface ProductSelectionInfo {
  defaultBanner: string;     // 默认封面, 在尚未选择规格或选择的规格不包含图片时显示
  defaultPrice: string;      // 默认价格, 在尚未选择出明确 sku 时显示
  defaultDashPrice: string;  // 默认划线价格, 在尚未选择出明确 sku 时显示
  priceRemark: string;       // 价格备注, 如: 实付、共实付、卷后、X件卷后等
  services: string[];        // 服务详情, 如: 运费险｜7天无理由、48小时内发货等
  skuItems: SkuItem[];       // SKU 列表
  specOptions: SpecOption[];                       // 规格选项列表
  specOptionWithImage: SpecOptionWithImage | null; // 带有图片的规格选项
}

export interface SkuItem {
  skuCode: string;               // 库存保持单元编码 (唯一)
  specs: Record<string, string>; // 规格组合 (key to uuid)
  stock: number;                 // 库存
  price: string;                 // 价格
}

export interface SpecValue {
  id: string;  // UUID
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

