export interface  ProductCard {
  coverImg: Resource;
  productContent: string;     //产品内容描述
  soldQuantity: number;       //已售数量
  introduction: string;       //产品简介
  price: number;              //产品价格
  classifieds?: string;       //产品分类
  id: string;                 //产品标识
  shopId: string;             //店铺标识
}

// 产品分类
export enum PRODUCT_CLASSIFICATION {
  BEAUTY = '美容',
  TIRE = '轮胎',
  MAINTENANCE = '保养'
}

// 美容类产品分类
export enum BEAUTY {
  WAXING = '打蜡',
  POLISHED = '抛光',
  INTERIOR_CLEANING = '内饰清洗',
  INTERIOR_REPLACEMENT = '内饰换新',
}

// 美容类产品数组
export const BEAUTY_DATA:ProductCard[] = [
  {
    coverImg:$r('app.media.banner1'),
    productContent: '全车打蜡（小轿车）',
    soldQuantity: 8,
    introduction:  '洗完车打蜡，让爱车光彩熠熠',
    price: 188,
    classifieds: BEAUTY.WAXING,
    id:'P0001',
    shopId:'0001'
  },
  {
    coverImg:$r('app.media.banner1'),
    productContent: '漆面抛光（小轿车）',
    soldQuantity: 11,
    introduction:  '机器抛光，让爱车光彩熠熠',
    price: 620,
    classifieds: BEAUTY.POLISHED,
    id:'P0002',
    shopId:'0001'
  },
  {
    coverImg:$r('app.media.banner1'),
    productContent: '漆面去污（小轿车）',
    soldQuantity: 22,
    introduction:  '让爱车光彩熠熠',
    price: 120,
    classifieds: BEAUTY.INTERIOR_CLEANING,
    id:'P0003',
    shopId:'0001'
  },
  {
    coverImg:$r('app.media.banner1'),
    productContent: '深度去污（小轿车）',
    soldQuantity: 11,
    introduction:  '让爱车光彩熠熠',
    price: 120,
    classifieds: BEAUTY.INTERIOR_CLEANING,
    id:'P0004',
    shopId:'0001'
  },
  {
    coverImg:$r('app.media.banner1'),
    productContent: '去除油膜（小轿车）',
    soldQuantity: 90,
    introduction:  '机器抛光，让爱车光彩熠熠',
    price: 220,
    classifieds: BEAUTY.INTERIOR_CLEANING,
    id:'P0005',
    shopId:'0001'
  },
  {
    coverImg:$r('app.media.banner1'),
    productContent: '皮具护理（小轿车）',
    soldQuantity: 60,
    introduction:  '让爱车光彩熠熠',
    price: 20,
    classifieds: BEAUTY.INTERIOR_REPLACEMENT,
    id:'P0006',
    shopId:'0001'
  },
  {
    coverImg:$r('app.media.banner1'),
    productContent: '座椅清洗（小轿车）',
    soldQuantity: 50,
    introduction:  '机器抛光，让爱车光彩熠熠',
    price: 120,
    classifieds: BEAUTY.INTERIOR_REPLACEMENT,
    id:'P0007',
    shopId:'0001'
  },
]

// 轮胎类产品分类
export enum TIRE {
  FILM_TIRE_REPAIR = '胶片补胎',
  FOUR_WHEEL_ALIGNMENT = '四轮定位',
  CHANGE_TIRE = '换轮胎',
  WHEEL_HUB_CLEANING = '轮毂清洗'
}

// 多个轮胎类产品数据（轮胎产品数组）
export const TIRE_DATA: ProductCard[] = [
  {
    coverImg:$r('app.media.banner1'),
    productContent: '17寸以下贴片补胎',
    soldQuantity: 10,
    introduction:  '',
    price: 40,
    classifieds: TIRE.FILM_TIRE_REPAIR,
    id:'P0008',
    shopId:'0001'
  },
  {
    coverImg:$r('app.media.banner1'),
    productContent: '防爆胎、静音胎贴片补胎',
    soldQuantity: 10,
    introduction:  '',
    price: 50,
    classifieds: TIRE.FILM_TIRE_REPAIR,
    id:'P0009',
    shopId:'0001'
  },
  {
    coverImg:$r('app.media.banner1'),
    productContent: 'A级紧凑型',
    soldQuantity: 10,
    introduction:  '',
    price: 100,
    classifieds: TIRE.FOUR_WHEEL_ALIGNMENT,
    id:'P0010',
    shopId:'0001'
  },
  {
    coverImg:$r('app.media.banner1'),
    productContent: 'B级中型轿车SUV',
    soldQuantity: 10,
    introduction:  '',
    price: 150,
    classifieds: TIRE.FOUR_WHEEL_ALIGNMENT,
    id:'P0011',
    shopId:'0001'
  },
  {
    coverImg:$r('app.media.banner1'),
    productContent: 'C级中大型轿车SUV',
    soldQuantity: 10,
    introduction:  '',
    price: 200,
    classifieds: TIRE.FOUR_WHEEL_ALIGNMENT,
    id:'P0012',
    shopId:'0001'
  },
  {
    coverImg:$r('app.media.banner1'),
    productContent: '标准换胎',
    soldQuantity: 10,
    introduction:  '工时费，不含材料',
    price: 40,
    classifieds: TIRE.CHANGE_TIRE,
    id:'P0013',
    shopId:'0001'
  },
  {
    coverImg:$r('app.media.banner1'),
    productContent: '更换气门嘴',
    soldQuantity: 5,
    introduction:  '工时费，不含材料',
    price: 40,
    classifieds: TIRE.CHANGE_TIRE,
    id:'P0014',
    shopId:'0001'
  },
  {
    coverImg:$r('app.media.banner1'),
    productContent: '更换轮毂',
    soldQuantity: 10,
    introduction:  '工时费，不含材料',
    price: 40,
    classifieds: TIRE.CHANGE_TIRE,
    id:'P0015',
    shopId:'0001'
  },
  {
    coverImg:$r('app.media.banner1'),
    productContent: '轮毂清洗',
    soldQuantity: 10,
    introduction:  '',
    price: 100,
    classifieds: TIRE.WHEEL_HUB_CLEANING,
    id:'P0016',
    shopId:'0001'
  },
  {
    coverImg:$r('app.media.banner1'),
    productContent: '轮毂深度清洗',
    soldQuantity: 100,
    introduction:  '工时费，不含材料',
    price: 200,
    classifieds: TIRE.WHEEL_HUB_CLEANING,
    id:'P0017',
    shopId:'0001'
  },
]

// 保养类产品分类
export enum MAINTENANCE {
  GLASS_WATER = '玻璃水',
  OILS = '机油',
  SECURITY_CHECK = '安全检查',
}

// 保养类产品数组
export const MAINTENANCE_DATA: ProductCard[] = [
  {
    coverImg:$r('app.media.banner1'),
    productContent: '添加玻璃水',
    soldQuantity: 100,
    introduction:  '含材料',
    price: 20,
    classifieds: MAINTENANCE.GLASS_WATER,
    id:'P0018',
    shopId:'0001'
  },
  {
    coverImg:$r('app.media.banner1'),
    productContent: '更换机油',
    soldQuantity: 100,
    introduction:  '工时费，不含材料',
    price: 50,
    classifieds: MAINTENANCE.OILS,
    id:'P0019',
    shopId:'0001'
  },
  {
    coverImg:$r('app.media.banner1'),
    productContent: '全车检测',
    soldQuantity: 100,
    introduction:  '工时费，不含材料',
    price: 50,
    classifieds: MAINTENANCE.SECURITY_CHECK,
    id:'P0020',
    shopId:'0001'
  },
]