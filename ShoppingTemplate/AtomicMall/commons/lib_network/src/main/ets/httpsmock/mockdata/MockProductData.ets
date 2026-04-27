import { PersistenceV2, Type } from '@kit.ArkUI';
import { MockImageData, MockImageMap } from './MockImageMap';
import { PriceType } from '../../types/EnumTypes';
import {
  ProductSku,
  ProductDetailInfo,
  ProductCardItem,
  BaseProductCard,
  ProductReviewItem,
  ReviewMediaItem,
  MovingPhotoUri,
} from '../../types/ProductTypes';

class MovingPhotoUriModel implements MovingPhotoUri{
  imageUri: string = '';
  videoUri: string = '';
}

class ProductReviewMediaItemModel implements ReviewMediaItem{
  type: number = 0;
  uri: ResourceStr = '';
  @Type(MovingPhotoUriModel)
  movingPhotoUri?: MovingPhotoUriModel | undefined;
}

class ProductReviewItemModel implements ProductReviewItem {
  productId: string = '';
  userAvatar: ResourceStr = '';
  userName: string = '';
  skuCode: string = '';
  skuDesc: string[] = [];
  rating: number = 0;
  date: number = 0;
  content: string = '';
  @Type(ProductReviewMediaItemModel)
  mediaList: ReviewMediaItem[] = [];
}

@ObservedV2
class ProductReviews {
  @Type(ProductReviewItemModel)
  @Trace reviewList: ProductReviewItemModel[] = [];
}

export class MockProductData {
  // ==================== SKU数据表 ====================

  public static readonly PRODUCT_SKU_TABLE: ProductSku[] = [
    // 产品1 - 时尚轻商务系列针织打底纯羊毛内搭
    {
      skuCode: 'sku_100001',
      productId: 'product_10001',
      skuDesc: '粉色;160/80A',
      stock: 10,
      banner: MockImageData.getImageResource(MockImageMap.PRODUCT_10001_PINK),
      title: '时尚轻商务系列针织打底纯羊毛内搭',
      serviceDesc: '运费险｜7天无理由',
      price: 188,
      dashPrice: 200,
      priceType: PriceType.NORMAL,
    },
    {
      skuCode: 'sku_100002',
      productId: 'product_10001',
      skuDesc: '粉色;165/84A',
      stock: 10,
      banner: MockImageData.getImageResource(MockImageMap.PRODUCT_10001_PINK),
      title: '时尚轻商务系列针织打底纯羊毛内搭',
      serviceDesc: '运费险｜7天无理由',
      price: 188,
      dashPrice: 200,
      priceType: PriceType.NORMAL,
    },
    {
      skuCode: 'sku_100003',
      productId: 'product_10001',
      skuDesc: '粉色;170/88A',
      stock: 10,
      banner: MockImageData.getImageResource(MockImageMap.PRODUCT_10001_PINK),
      title: '时尚轻商务系列针织打底纯羊毛内搭',
      serviceDesc: '运费险｜7天无理由',
      price: 188,
      dashPrice: 200,
      priceType: PriceType.NORMAL,
    },
    {
      skuCode: 'sku_100004',
      productId: 'product_10001',
      skuDesc: '白色;160/80A',
      stock: 10,
      banner: MockImageData.getImageResource(MockImageMap.PRODUCT_10001_STRIPE),
      title: '时尚轻商务系列针织打底纯羊毛内搭',
      serviceDesc: '运费险｜7天无理由',
      price: 200,
      dashPrice: 200,
      priceType: PriceType.NORMAL,
    },
    {
      skuCode: 'sku_100005',
      productId: 'product_10001',
      skuDesc: '白色;165/84A',
      stock: 0,
      banner: MockImageData.getImageResource(MockImageMap.PRODUCT_10001_STRIPE),
      title: '时尚轻商务系列针织打底纯羊毛内搭',
      serviceDesc: '运费险｜7天无理由',
      price: 200,
      dashPrice: 200,
      priceType: PriceType.NORMAL,
    },
    {
      skuCode: 'sku_100006',
      productId: 'product_10001',
      skuDesc: '白色;170/88A',
      stock: 0,
      banner: MockImageData.getImageResource(MockImageMap.PRODUCT_10001_STRIPE),
      title: '时尚轻商务系列针织打底纯羊毛内搭',
      serviceDesc: '运费险｜7天无理由',
      price: 200,
      dashPrice: 200,
      priceType: PriceType.NORMAL,
    },
    {
      skuCode: 'sku_100007',
      productId: 'product_10001',
      skuDesc: '黄色;160/80A',
      stock: 0,
      banner: MockImageData.getImageResource(MockImageMap.PRODUCT_10001_YELLOW),
      title: '时尚轻商务系列针织打底纯羊毛内搭',
      serviceDesc: '运费险｜7天无理由',
      price: 200,
      dashPrice: 200,
      priceType: PriceType.NORMAL,
    },
    {
      skuCode: 'sku_100008',
      productId: 'product_10001',
      skuDesc: '黄色;165/84A',
      stock: 0,
      banner: MockImageData.getImageResource(MockImageMap.PRODUCT_10001_YELLOW),
      title: '时尚轻商务系列针织打底纯羊毛内搭',
      serviceDesc: '运费险｜7天无理由',
      price: 200,
      dashPrice: 200,
      priceType: PriceType.NORMAL,
    },
    {
      skuCode: 'sku_100009',
      productId: 'product_10001',
      skuDesc: '黄色;170/88A',
      stock: 0,
      banner: MockImageData.getImageResource(MockImageMap.PRODUCT_10001_YELLOW),
      title: '时尚轻商务系列针织打底纯羊毛内搭',
      serviceDesc: '运费险｜7天无理由',
      price: 200,
      dashPrice: 200,
      priceType: PriceType.NORMAL,
    },
    {
      skuCode: 'sku_100010',
      productId: 'product_10001',
      skuDesc: '绿色;160/80A',
      stock: 0,
      banner: MockImageData.getImageResource(MockImageMap.PRODUCT_10001_GREEN),
      title: '时尚轻商务系列针织打底纯羊毛内搭',
      serviceDesc: '运费险｜7天无理由',
      price: 200,
      dashPrice: 200,
      priceType: PriceType.NORMAL,
    },
    {
      skuCode: 'sku_100011',
      productId: 'product_10001',
      skuDesc: '绿色;165/84A',
      stock: 0,
      banner: MockImageData.getImageResource(MockImageMap.PRODUCT_10001_GREEN),
      title: '时尚轻商务系列针织打底纯羊毛内搭',
      serviceDesc: '运费险｜7天无理由',
      price: 200,
      dashPrice: 200,
      priceType: PriceType.NORMAL,
    },
    {
      skuCode: 'sku_100012',
      productId: 'product_10001',
      skuDesc: '绿色;170/88A',
      stock: 0,
      banner: MockImageData.getImageResource(MockImageMap.PRODUCT_10001_GREEN),
      title: '时尚轻商务系列针织打底纯羊毛内搭',
      serviceDesc: '运费险｜7天无理由',
      price: 200,
      dashPrice: 200,
      priceType: PriceType.NORMAL,
    },

    // 产品2 - 休闲简约经典商务衬衫T恤日系风高级感
    {
      skuCode: 'sku_200001',
      productId: 'product_20001',
      skuDesc: '黑色;S',
      stock: 10,
      banner: MockImageData.getImageResource(MockImageMap.PRODUCT_20001_BLACK),
      title: '休闲简约经典商务衬衫T恤日系风高级感',
      serviceDesc: '运费险｜7天无理由',
      price: 98,
      dashPrice: 128,
      priceType: PriceType.NORMAL,
    },
    {
      skuCode: 'sku_200002',
      productId: 'product_20001',
      skuDesc: '黑色;M',
      stock: 10,
      banner: MockImageData.getImageResource(MockImageMap.PRODUCT_20001_BLACK),
      title: '休闲简约经典商务衬衫T恤日系风高级感',
      serviceDesc: '运费险｜7天无理由',
      price: 98,
      dashPrice: 128,
      priceType: PriceType.NORMAL,
    },
    {
      skuCode: 'sku_200003',
      productId: 'product_20001',
      skuDesc: '黑色;L',
      stock: 10,
      banner: MockImageData.getImageResource(MockImageMap.PRODUCT_20001_BLACK),
      title: '休闲简约经典商务衬衫T恤日系风高级感',
      serviceDesc: '运费险｜7天无理由',
      price: 98,
      dashPrice: 128,
      priceType: PriceType.NORMAL,
    },
    {
      skuCode: 'sku_200004',
      productId: 'product_20001',
      skuDesc: '白色;S',
      stock: 10,
      banner: MockImageData.getImageResource(MockImageMap.PRODUCT_20001_WHITE),
      title: '休闲简约经典商务衬衫T恤日系风高级感',
      serviceDesc: '运费险｜7天无理由',
      price: 108.8,
      dashPrice: 128,
      priceType: PriceType.NORMAL,
    },
    {
      skuCode: 'sku_200005',
      productId: 'product_20001',
      skuDesc: '白色;M',
      stock: 0,
      banner: MockImageData.getImageResource(MockImageMap.PRODUCT_20001_WHITE),
      title: '休闲简约经典商务衬衫T恤日系风高级感',
      serviceDesc: '运费险｜7天无理由',
      price: 128,
      dashPrice: 128,
      priceType: PriceType.NORMAL,
    },
    {
      skuCode: 'sku_200006',
      productId: 'product_20001',
      skuDesc: '白色;L',
      stock: 0,
      banner: MockImageData.getImageResource(MockImageMap.PRODUCT_20001_WHITE),
      title: '休闲简约经典商务衬衫T恤日系风高级感',
      serviceDesc: '运费险｜7天无理由',
      price: 128,
      dashPrice: 128,
      priceType: PriceType.NORMAL,
    },
    {
      skuCode: 'sku_200007',
      productId: 'product_20001',
      skuDesc: '浅蓝色长袖;S',
      stock: 0,
      banner: MockImageData.getImageResource(MockImageMap.PRODUCT_20001_BLACK),
      title: '休闲简约经典商务衬衫T恤日系风高级感',
      serviceDesc: '运费险｜7天无理由',
      price: 128,
      dashPrice: 128,
      priceType: PriceType.NORMAL,
    },
    {
      skuCode: 'sku_200008',
      productId: 'product_20001',
      skuDesc: '浅蓝色长袖;M',
      stock: 10,
      banner: MockImageData.getImageResource(MockImageMap.PRODUCT_20001_BLACK),
      title: '休闲简约经典商务衬衫T恤日系风高级感',
      serviceDesc: '运费险｜7天无理由',
      price: 128,
      dashPrice: 128,
      priceType: PriceType.NORMAL,
    },
    {
      skuCode: 'sku_200009',
      productId: 'product_20001',
      skuDesc: '浅蓝色长袖;L',
      stock: 0,
      banner: MockImageData.getImageResource(MockImageMap.PRODUCT_20001_BLACK),
      title: '休闲简约经典商务衬衫T恤日系风高级感',
      serviceDesc: '运费险｜7天无理由',
      price: 128,
      dashPrice: 128,
      priceType: PriceType.NORMAL,
    },
    {
      skuCode: 'sku_200010',
      productId: 'product_20001',
      skuDesc: '深蓝色长袖;S',
      stock: 0,
      banner: MockImageData.getImageResource(MockImageMap.PRODUCT_20001_SHIRT),
      title: '休闲简约经典商务衬衫T恤日系风高级感',
      serviceDesc: '运费险｜7天无理由',
      price: 128,
      dashPrice: 128,
      priceType: PriceType.NORMAL,
    },
    {
      skuCode: 'sku_200011',
      productId: 'product_20001',
      skuDesc: '深蓝色长袖;M',
      stock: 0,
      banner: MockImageData.getImageResource(MockImageMap.PRODUCT_20001_SHIRT),
      title: '休闲简约经典商务衬衫T恤日系风高级感',
      serviceDesc: '运费险｜7天无理由',
      price: 128,
      dashPrice: 128,
      priceType: PriceType.NORMAL,
    },
    {
      skuCode: 'sku_200012',
      productId: 'product_20001',
      skuDesc: '深蓝色长袖;L',
      stock: 0,
      banner: MockImageData.getImageResource(MockImageMap.PRODUCT_20001_SHIRT),
      title: '休闲简约经典商务衬衫T恤日系风高级感',
      serviceDesc: '运费险｜7天无理由',
      price: 128,
      dashPrice: 128,
      priceType: PriceType.NORMAL,
    },
    {
      skuCode: 'sku_300001',
      productId: 'product_30001',
      skuDesc: '黄色;均码',
      stock: 10,
      banner: MockImageData.getImageResource(MockImageMap.PRODUCT_30001),
      title: '冬季打底纯羊毛毛衣',
      serviceDesc: '运费险｜7天无理由',
      price: 128,
      dashPrice: 288,
      priceType: PriceType.SECKILL,
    },
    {
      skuCode: 'sku_300002',
      productId: 'product_30002',
      skuDesc: '浅蓝色/浅黄色',
      stock: 10,
      banner: MockImageData.getImageResource(MockImageMap.PRODUCT_30002),
      title: '莫兰迪水杯马克杯',
      serviceDesc: '运费险｜7天无理由',
      price: 10.8,
      dashPrice: 58.8,
      priceType: PriceType.SECKILL,
    },
    {
      skuCode: 'sku_300003',
      productId: 'product_30003',
      skuDesc: '1条',
      stock: 10,
      banner: MockImageData.getImageResource(MockImageMap.PRODUCT_30003),
      title: '吸水毛巾可擦车可洗澡',
      serviceDesc: '运费险｜7天无理由',
      price: 8.8,
      dashPrice: 48,
      priceType: PriceType.SECKILL,
    },
    {
      skuCode: 'sku_300004',
      productId: 'product_30004',
      skuDesc: '1对',
      stock: 10,
      banner: MockImageData.getImageResource(MockImageMap.PRODUCT_30004),
      title: '玻璃高脚杯红酒杯水晶杯',
      serviceDesc: '运费险｜7天无理由',
      price: 10.8,
      dashPrice: 58,
      priceType: PriceType.SECKILL,
    },
    {
      skuCode: 'sku_300005',
      productId: 'product_30005',
      skuDesc: '1只',
      stock: 10,
      banner: MockImageData.getImageResource(MockImageMap.PRODUCT_30005),
      title: '咖啡杯简约',
      serviceDesc: '运费险｜7天无理由',
      price: 8.8,
      dashPrice: 28,
      priceType: PriceType.SECKILL,
    },
  ];
  // ==================== 商品卡片列表 ====================

  public static readonly PRODUCT_CARD_LIST: ProductCardItem[] = [
    {
      productId: 'product_10001',
      categoryId: '1001_10001',
      price: 188,
      dashPrice: 200,
      title: '时尚轻商务系列针织打底纯羊毛内搭',
      banner: MockImageData.getImageResource(MockImageMap.PRODUCT_10001_PINK),
      promotion: ['VIP会员另享9.0折'],
      label: [
        { preset: 0,
data: '上新折扣' },
        { preset: 1,
data: '热销爆款' },
      ],
      summary: {
        size: ['xs', 's', 'm', 'l', 'xl'],
        minPrice: 188,
        maxPrice: 200,
        place: '中国',
      },
      sales: 3000,
    },
    {
      productId: 'product_10002',
      categoryId: '1001_10002',
      price: 188,
      dashPrice: 200,
      title: '时尚轻商务系列针织打底纯羊毛内搭',
      banner: MockImageData.getImageResource(MockImageMap.PRODUCT_10001_STRIPE),
      promotion: ['VIP会员另享9.0折'],
      label: [],
      summary: {
        size: ['xs', 's', 'm', 'l', 'xl'],
        minPrice: 188,
        maxPrice: 200,
        place: '中国',
      },
      sales: 800,
    },
    {
      productId: 'product_10003',
      categoryId: '1001_10003',
      price: 188,
      dashPrice: 200,
      title: '时尚轻商务系列针织打底纯羊毛内搭',
      banner: MockImageData.getImageResource(MockImageMap.PRODUCT_10001_YELLOW),
      promotion: ['VIP会员另享9.0折'],
      label: [],
      summary: {
        size: ['xs', 's', 'm', 'l', 'xl'],
        minPrice: 188,
        maxPrice: 200,
        place: '中国',
      },
      sales: 1500,
    },
    {
      productId: 'product_10004',
      categoryId: '1001_10004',
      price: 188,
      dashPrice: 200,
      title: '时尚轻商务系列针织打底纯羊毛内搭',
      banner: MockImageData.getImageResource(MockImageMap.PRODUCT_10001_GREEN),
      promotion: ['VIP会员另享9.0折'],
      label: [],
      summary: {
        size: ['xs', 's', 'm', 'l', 'xl'],
        minPrice: 188,
        maxPrice: 200,
        place: '中国',
      },
      sales: 600,
    },
    {
      productId: 'product_10005',
      categoryId: '1001_10001',
      price: 188,
      dashPrice: 200,
      title: '时尚轻商务系列针织打底纯羊毛内搭',
      banner: MockImageData.getImageResource(MockImageMap.PRODUCT_10001_PINK),
      promotion: ['VIP会员另享9.0折'],
      label: [
        { preset: 0,
data: '上新折扣' },
        { preset: 1,
data: '热销爆款' },
      ],
      summary: {
        size: ['xs', 's', 'm', 'l', 'xl'],
        minPrice: 188,
        maxPrice: 200,
        place: '中国',
      },
      sales: 3200,
    },
    {
      productId: 'product_10006',
      categoryId: '1001_10002',
      price: 188,
      dashPrice: 200,
      title: '时尚轻商务系列针织打底纯羊毛内搭',
      banner: MockImageData.getImageResource(MockImageMap.PRODUCT_10001_STRIPE),
      promotion: ['VIP会员另享9.0折'],
      label: [],
      summary: {
        size: ['xs', 's', 'm', 'l', 'xl'],
        minPrice: 188,
        maxPrice: 200,
        place: '中国',
      },
      sales: 700,
    },
    {
      productId: 'product_10007',
      categoryId: '1001_10003',
      price: 188,
      dashPrice: 200,
      title: '时尚轻商务系列针织打底纯羊毛内搭',
      banner: MockImageData.getImageResource(MockImageMap.PRODUCT_10001_YELLOW),
      promotion: ['VIP会员另享9.0折'],
      label: [],
      summary: {
        size: ['xs', 's', 'm', 'l', 'xl'],
        minPrice: 188,
        maxPrice: 200,
        place: '中国',
      },
      sales: 1300,
    },
    {
      productId: 'product_10008',
      categoryId: '1001_10004',
      price: 188,
      dashPrice: 200,
      title: '时尚轻商务系列针织打底纯羊毛内搭',
      banner: MockImageData.getImageResource(MockImageMap.PRODUCT_10001_GREEN),
      promotion: ['VIP会员另享9.0折'],
      label: [],
      summary: {
        size: ['xs', 's', 'm', 'l', 'xl'],
        minPrice: 188,
        maxPrice: 200,
        place: '中国',
      },
      sales: 500,
    },
    {
      productId: 'product_20001',
      categoryId: '1002_20001',
      price: 98,
      dashPrice: 128,
      title: '休闲简约经典商务衬衫T恤日系风高级感',
      banner: MockImageData.getImageResource(MockImageMap.PRODUCT_20001_BLACK),
      promotion: ['VIP会员另享9.0折'],
      label: [
        { preset: 1,
data: '热销爆款' },
      ],
      summary: {
        size: ['s', 'm', 'l'],
        minPrice: 98,
        maxPrice: 128,
        place: '中国',
      },
      sales: 2500,
    },
    {
      productId: 'product_20002',
      categoryId: '1002_20002',
      price: 98,
      dashPrice: 128,
      title: '休闲简约经典商务衬衫T恤日系风高级感',
      banner: MockImageData.getImageResource(MockImageMap.PRODUCT_20001_BLACK),
      promotion: ['VIP会员另享9.0折'],
      label: [
        { preset: 1,
data: '热销爆款' },
      ],
      summary: {
        size: ['s', 'm', 'l'],
        minPrice: 98,
        maxPrice: 128,
        place: '中国',
      },
      sales: 2200,
    },
    {
      productId: 'product_20003',
      categoryId: '1002_20003',
      price: 98,
      dashPrice: 128,
      title: '休闲简约经典商务衬衫T恤日系风高级感',
      banner: MockImageData.getImageResource(MockImageMap.PRODUCT_20001_SHIRT),
      promotion: ['VIP会员另享9.0折'],
      label: [],
      summary: {
        size: ['s', 'm', 'l'],
        minPrice: 98,
        maxPrice: 128,
        place: '中国',
      },
      sales: 1800,
    },
    {
      productId: 'product_20004',
      categoryId: '1002_20004',
      price: 98,
      dashPrice: 128,
      title: '休闲简约经典商务衬衫T恤日系风高级感',
      banner: MockImageData.getImageResource(MockImageMap.PRODUCT_20001_WHITE),
      promotion: ['VIP会员另享9.0折'],
      label: [],
      summary: {
        size: ['s', 'm', 'l'],
        minPrice: 98,
        maxPrice: 128,
        place: '中国',
      },
      sales: 1500,
    },
    {
      productId: 'product_20005',
      categoryId: '1002_20005',
      price: 98,
      dashPrice: 128,
      title: '休闲简约经典商务衬衫T恤日系风高级感',
      banner: MockImageData.getImageResource(MockImageMap.PRODUCT_20001_BLACK),
      promotion: ['VIP会员另享9.0折'],
      label: [
        { preset: 1,
data: '热销爆款' },
      ],
      summary: {
        size: ['s', 'm', 'l'],
        minPrice: 98,
        maxPrice: 128,
        place: '中国',
      },
      sales: 2800,
    },
    {
      productId: 'product_20006',
      categoryId: '1002_20006',
      price: 98,
      dashPrice: 128,
      title: '休闲简约经典商务衬衫T恤日系风高级感',
      banner: MockImageData.getImageResource(MockImageMap.PRODUCT_20001_BLUE),
      promotion: ['VIP会员另享9.0折'],
      label: [
        { preset: 1,
data: '热销爆款' },
      ],
      summary: {
        size: ['s', 'm', 'l'],
        minPrice: 98,
        maxPrice: 128,
        place: '中国',
      },
      sales: 2400,
    },
    {
      productId: 'product_20007',
      categoryId: '1002_20007',
      price: 98,
      dashPrice: 128,
      title: '休闲简约经典商务衬衫T恤日系风高级感',
      banner: MockImageData.getImageResource(MockImageMap.PRODUCT_20001_SHIRT),
      promotion: ['VIP会员另享9.0折'],
      label: [],
      summary: {
        size: ['s', 'm', 'l'],
        minPrice: 98,
        maxPrice: 128,
        place: '中国',
      },
      sales: 1600,
    },
    {
      productId: 'product_20008',
      categoryId: '1002_20008',
      price: 98,
      dashPrice: 128,
      title: '休闲简约经典商务衬衫T恤日系风高级感',
      banner: MockImageData.getImageResource(MockImageMap.PRODUCT_20001_WHITE),
      promotion: ['VIP会员另享9.0折'],
      label: [],
      summary: {
        size: ['s', 'm', 'l'],
        minPrice: 98,
        maxPrice: 128,
        place: '中国',
      },
      sales: 1200,
    },
    {
      productId: 'product_30001',
      categoryId: '3000_30001',
      price: 128,
      dashPrice: 288,
      title: '冬季打底纯羊毛毛衣',
      banner: MockImageData.getImageResource(MockImageMap.PRODUCT_30001),
      promotion: ['限时特惠'],
      label: [],
      summary: {
        size: ['均码'],
        minPrice: 128,
        maxPrice: 288,
        place: '浙江',
      },
      sales: 204,
    },
    {
      productId: 'product_30002',
      categoryId: '3000_30002',
      price: 10.8,
      dashPrice: 58.8,
      title: '莫兰迪水杯马克杯',
      banner: MockImageData.getImageResource(MockImageMap.PRODUCT_30002),
      promotion: ['限时特惠'],
      label: [],
      summary: {
        size: ['浅蓝色', '浅黄色'],
        minPrice: 10.8,
        maxPrice: 58.8,
        place: '广东',
      },
      sales: 100,
    },
    {
      productId: 'product_30003',
      categoryId: '3000_30003',
      price: 8.8,
      dashPrice: 48,
      title: '吸水毛巾可擦车可洗澡',
      banner: MockImageData.getImageResource(MockImageMap.PRODUCT_30003),
      promotion: ['限时特惠'],
      label: [],
      summary: {
        size: ['1条装'],
        minPrice: 8.8,
        maxPrice: 48,
        place: '河北',
      },
      sales: 500,
    },
    {
      productId: 'product_30004',
      categoryId: '3000_30004',
      price: 10.8,
      dashPrice: 58,
      title: '玻璃高脚杯红酒杯水晶杯',
      banner: MockImageData.getImageResource(MockImageMap.PRODUCT_30004),
      promotion: ['限时特惠'],
      label: [],
      summary: {
        size: ['1对装'],
        minPrice: 10.8,
        maxPrice: 58,
        place: '山西',
      },
      sales: 20,
    },
    {
      productId: 'product_30005',
      categoryId: '3000_30005',
      price: 8.8,
      dashPrice: 28,
      title: '咖啡杯简约',
      banner: MockImageData.getImageResource(MockImageMap.PRODUCT_30005),
      promotion: ['限时秒杀'],
      label: [],
      summary: {
        size: ['1只装'],
        minPrice: 8.8,
        maxPrice: 28,
        place: '广东',
      },
      sales: 88,
    },
  ];
  // ==================== 商品详情数据 ====================

  public static readonly PRODUCT_ITEM1: ProductDetailInfo = {
    productId: 'product_10001',
    title: '时尚轻商务系列针织打底纯羊毛内搭',
    banner: MockImageData.getImageResource(MockImageMap.PRODUCT_10001_PINK),
    price: 188,
    dashPrice: 200,
    sales: 0,
    tags: ['VIP会员另享9.0折', '退货包邮费最高减￥5'],
    banners: [
      MockImageData.getImageResource(MockImageMap.PRODUCT_10001_PINK),
      MockImageData.getImageResource(MockImageMap.PRODUCT_10001_STRIPE),
      MockImageData.getImageResource(MockImageMap.PRODUCT_10001_YELLOW),
    ],
    logistics: [
      {
        icon: $r('app.media.ic_truck'),
        content: '48小时内发货 | 免运费',
      },
    ],
    service: [
      { icon: $r('app.media.ic_heart'),
content: '运费险｜7天无理由' },
    ],
    pictures: [
      MockImageData.getImageResource(MockImageMap.PRODUCT_10001_PINK),
      MockImageData.getImageResource(MockImageMap.PRODUCT_10001_STRIPE),
      MockImageData.getImageResource(MockImageMap.PRODUCT_10001_YELLOW),
      MockImageData.getImageResource(MockImageMap.PRODUCT_10001_GREEN),
    ],
    selectionInfo: {
      defaultBanner: MockImageData.getImageResource(MockImageMap.PRODUCT_10001_PINK),
      basicPrice: 188,
      priceRange: '188-200',
      priceRemark: '实付',
      totalPriceRemark: '共实付',
      services: ['运费险｜7天无理由', '48小时内发货'],
      skuItems: [
        {
          skuCode: 'sku_100001',
          specs: { 'size': 'uuid_160_80A',
'color': 'uuid_pink' },
          stock: 10,
          price: 188,
          dashPrice: 200,
        },
        {
          skuCode: 'sku_100002',
          specs: { 'size': 'uuid_165_84A',
'color': 'uuid_pink' },
          stock: 10,
          price: 188,
          dashPrice: 200,
        },
        {
          skuCode: 'sku_100003',
          specs: { 'size': 'uuid_170_88A',
'color': 'uuid_pink' },
          stock: 10,
          price: 188,
          dashPrice: 200,
        },
        {
          skuCode: 'sku_100004',
          specs: { 'size': 'uuid_160_80A',
'color': 'uuid_white' },
          stock: 10,
          price: 200,
          dashPrice: 200,
        },
        {
          skuCode: 'sku_100005',
          specs: { 'size': 'uuid_165_84A',
'color': 'uuid_white' },
          stock: 0,
          price: 200,
          dashPrice: 200,
        },
        {
          skuCode: 'sku_100006',
          specs: { 'size': 'uuid_170_88A',
'color': 'uuid_white' },
          stock: 0,
          price: 200,
          dashPrice: 200,
        },
        {
          skuCode: 'sku_100007',
          specs: { 'size': 'uuid_160_80A',
'color': 'uuid_stripe' },
          stock: 0,
          price: 200,
          dashPrice: 200,
        },
        {
          skuCode: 'sku_100008',
          specs: { 'size': 'uuid_165_84A',
'color': 'uuid_stripe' },
          stock: 0,
          price: 200,
          dashPrice: 200,
        },
        {
          skuCode: 'sku_100009',
          specs: { 'size': 'uuid_170_88A',
'color': 'uuid_stripe' },
          stock: 0,
          price: 200,
          dashPrice: 200,
        },
        {
          skuCode: 'sku_100010',
          specs: { 'size': 'uuid_160_80A',
'color': 'uuid_green' },
          stock: 0,
          price: 200,
          dashPrice: 200,
        },
        {
          skuCode: 'sku_100011',
          specs: { 'size': 'uuid_165_84A',
'color': 'uuid_green' },
          stock: 0,
          price: 200,
          dashPrice: 200,
        },
        {
          skuCode: 'sku_100012',
          specs: { 'size': 'uuid_170_88A',
'color': 'uuid_green' },
          stock: 0,
          price: 200,
          dashPrice: 200,
        },
      ],
      specOptions: [
        {
          key: 'size',
          label: '尺码',
          values: [
            { id: 'uuid_160_80A',
text: '160/80A' },
            { id: 'uuid_165_84A',
text: '165/84A' },
            { id: 'uuid_170_88A',
text: '170/88A' },
          ],
        },
      ],
      specOptionWithImage: {
        key: 'color',
        label: '颜色',
        values: [
          {
            id: 'uuid_pink',
            text: '粉色',
            image: MockImageData.getImageResource(MockImageMap.PRODUCT_10001_PINK),
          },
          {
            id: 'uuid_white',
            text: '白色',
            image: MockImageData.getImageResource(MockImageMap.PRODUCT_10001_STRIPE),
          },
          {
            id: 'uuid_stripe',
            text: '黄色',
            image: MockImageData.getImageResource(MockImageMap.PRODUCT_10001_YELLOW),
          },
          {
            id: 'uuid_green',
            text: '绿色',
            image: MockImageData.getImageResource(MockImageMap.PRODUCT_10001_GREEN),
          },
        ],
      },
    },
  };
  public static readonly PRODUCT_ITEM2: ProductDetailInfo = {
    productId: 'product_20001',
    title: '休闲简约经典商务衬衫T恤日系风高级感',
    banner: MockImageData.getImageResource(MockImageMap.PRODUCT_20001_WHITE),
    price: 98,
    dashPrice: 128,
    sales: 0,
    tags: ['VIP会员另享9.0折', '7天无理由'],
    banners: [
      MockImageData.getImageResource(MockImageMap.PRODUCT_20001_WHITE),
      MockImageData.getImageResource(MockImageMap.PRODUCT_20001_SHIRT),
      MockImageData.getImageResource(MockImageMap.PRODUCT_20001_BLACK),
      MockImageData.getImageResource(MockImageMap.PRODUCT_20001_BLACK),
    ],
    logistics: [
      { icon: $r('app.media.ic_truck'),
content: '24小时发货' },
    ],
    service: [
      { icon: $r('app.media.ic_heart'),
content: '运费险｜7天无理由' },
    ],
    pictures: [
      MockImageData.getImageResource(MockImageMap.PRODUCT_20001_WHITE),
      MockImageData.getImageResource(MockImageMap.PRODUCT_20001_SHIRT),
      MockImageData.getImageResource(MockImageMap.PRODUCT_20001_BLACK),
      MockImageData.getImageResource(MockImageMap.PRODUCT_20001_BLACK),
    ],
    selectionInfo: {
      defaultBanner: MockImageData.getImageResource(MockImageMap.PRODUCT_20001_WHITE),
      basicPrice: 98,
      priceRange: '98-128',
      priceRemark: '实付',
      totalPriceRemark: '共实付',
      services: ['运费险｜7天无理由', '48小时内发货'],
      skuItems: [
        {
          skuCode: 'sku_200001',
          specs: { 'size': 'S',
'color': 'uuid_black' },
          stock: 10,
          price: 98,
          dashPrice: 128,
        },
        {
          skuCode: 'sku_200002',
          specs: { 'size': 'M',
'color': 'uuid_black' },
          stock: 10,
          price: 98,
          dashPrice: 128,
        },
        {
          skuCode: 'sku_200003',
          specs: { 'size': 'L',
'color': 'uuid_black' },
          stock: 10,
          price: 98,
          dashPrice: 128,
        },
        {
          skuCode: 'sku_200004',
          specs: { 'size': 'S',
'color': 'uuid_white' },
          stock: 10,
          price: 108.8,
          dashPrice: 128,
        },
        {
          skuCode: 'sku_200005',
          specs: { 'size': 'M',
'color': 'uuid_white' },
          stock: 0,
          price: 128,
          dashPrice: 128,
        },
        {
          skuCode: 'sku_200006',
          specs: { 'size': 'L',
'color': 'uuid_white' },
          stock: 0,
          price: 128,
          dashPrice: 128,
        },
        {
          skuCode: 'sku_200007',
          specs: { 'size': 'S',
'color': 'uuid_blue' },
          stock: 0,
          price: 128,
          dashPrice: 128,
        },
        {
          skuCode: 'sku_200008',
          specs: { 'size': 'M',
'color': 'uuid_blue' },
          stock: 10,
          price: 128,
          dashPrice: 128,
        },
        {
          skuCode: 'sku_200009',
          specs: { 'size': 'L',
'color': 'uuid_blue' },
          stock: 0,
          price: 128,
          dashPrice: 128,
        },
        {
          skuCode: 'sku_200010',
          specs: { 'size': 'S',
'color': 'uuid_shirt' },
          stock: 0,
          price: 128,
          dashPrice: 128,
        },
        {
          skuCode: 'sku_200011',
          specs: { 'size': 'M',
'color': 'uuid_shirt' },
          stock: 0,
          price: 128,
          dashPrice: 128,
        },
        {
          skuCode: 'sku_200012',
          specs: { 'size': 'L',
'color': 'uuid_shirt' },
          stock: 0,
          price: 128,
          dashPrice: 128,
        },
      ],
      specOptions: [
        {
          key: 'size',
          label: '尺码',
          values: [
            { id: 'S',
text: 'S' },
            { id: 'M',
text: 'M' },
            { id: 'L',
text: 'L' },
          ],
        },
      ],
      specOptionWithImage: {
        key: 'color',
        label: '颜色',
        values: [
          {
            id: 'uuid_black',
            text: '黑色',
            image: MockImageData.getImageResource(MockImageMap.PRODUCT_20001_BLACK),
          },
          {
            id: 'uuid_white',
            text: '白色',
            image: MockImageData.getImageResource(MockImageMap.PRODUCT_20001_WHITE),
          },
          {
            id: 'uuid_blue',
            text: '浅蓝色长袖',
            image: MockImageData.getImageResource(MockImageMap.PRODUCT_20001_BLACK),
          },
          {
            id: 'uuid_shirt',
            text: '深蓝色长袖',
            image: MockImageData.getImageResource(MockImageMap.PRODUCT_20001_SHIRT),
          },
        ],
      },
    },
  };
  public static readonly PRODUCT_30001: ProductDetailInfo = {
    productId: 'product_30001',
    title: '冬季打底纯羊毛毛衣',
    banner: MockImageData.getImageResource(MockImageMap.PRODUCT_30001),
    price: 128,
    dashPrice: 288,
    sales: 0,
    tags: [],
    banners: [
      MockImageData.getImageResource(MockImageMap.PRODUCT_30001),
    ],
    logistics: [
      { icon: $r('app.media.ic_truck'),
content: '24小时发货' },
    ],
    service: [
      { icon: $r('app.media.ic_heart'),
content: '免运费' },
    ],
    pictures: [
      MockImageData.getImageResource(MockImageMap.PRODUCT_30001),
    ],
    selectionInfo: {
      defaultBanner: MockImageData.getImageResource(MockImageMap.PRODUCT_30001),
      basicPrice: 128,
      priceRange: '128-288',
      priceRemark: '实付',
      totalPriceRemark: '共实付',
      services: ['运费险｜7天无理由', '48小时内发货'],
      skuItems: [
        {
          skuCode: 'sku_300001',
          specs: { 'size': 'uuid_normal' },
          stock: 10,
          price: 128,
          dashPrice: 288,
        },
      ],
      specOptions: [{
        key: 'size',
        label: '尺码',
        values: [
          {
            id: 'uuid_normal',
            text: '均码',
          },
        ],
      }],
    },
  };
  public static readonly PRODUCT_30002: ProductDetailInfo = {
    productId: 'product_30002',
    title: '莫兰迪水杯马克杯',
    banner: MockImageData.getImageResource(MockImageMap.PRODUCT_30002),
    price: 10.8,
    dashPrice: 58.8,
    sales: 100,
    tags: [],
    banners: [
      MockImageData.getImageResource(MockImageMap.PRODUCT_30002),
    ],
    logistics: [
      { icon: $r('app.media.ic_truck'),
content: '24小时发货' },
    ],
    service: [
      { icon: $r('app.media.ic_heart'),
content: '免运费' },
    ],
    pictures: [
      MockImageData.getImageResource(MockImageMap.PRODUCT_30002),
    ],
    selectionInfo: {
      defaultBanner: MockImageData.getImageResource(MockImageMap.PRODUCT_30002),
      basicPrice: 10.8,
      priceRange: '10.8-58.8',
      priceRemark: '实付',
      totalPriceRemark: '共实付',
      services: ['运费险｜7天无理由', '破损包赔'],
      skuItems: [
        {
          skuCode: 'sku_300002',
          specs: { 'color': 'uuid_blue_yellow' },
          stock: 10,
          price: 10.8,
          dashPrice: 58.8,
        },
      ],
      specOptions: [{
        key: 'color',
        label: '颜色',
        values: [
          {
            id: 'uuid_blue_yellow',
            text: '浅蓝色/浅黄色',
          },
        ],
      }],
    },
  };
  public static readonly PRODUCT_30003: ProductDetailInfo = {
    productId: 'product_30003',
    title: '吸水毛巾可擦车可洗澡',
    banner: MockImageData.getImageResource(MockImageMap.PRODUCT_30003), // 修正了原数据可能指向30001的问题
    price: 8.8,
    dashPrice: 48,
    sales: 500,
    tags: [],
    banners: [
      MockImageData.getImageResource(MockImageMap.PRODUCT_30003),
    ],
    logistics: [
      { icon: $r('app.media.ic_truck'),
content: '48小时发货' },
    ],
    service: [
      { icon: $r('app.media.ic_heart'),
content: '免运费' },
    ],
    pictures: [
      MockImageData.getImageResource(MockImageMap.PRODUCT_30003),
    ],
    selectionInfo: {
      defaultBanner: MockImageData.getImageResource(MockImageMap.PRODUCT_30003),
      basicPrice: 8.8,
      priceRange: '8.8-48',
      priceRemark: '实付',
      totalPriceRemark: '共实付',
      services: ['运费险｜7天无理由'],
      skuItems: [
        {
          skuCode: 'sku_300003',
          specs: { 'spec': 'uuid_one_piece' },
          stock: 10,
          price: 8.8,
          dashPrice: 48,
        },
      ],
      specOptions: [{
        key: 'spec',
        label: '规格',
        values: [
          {
            id: 'uuid_one_piece',
            text: '1条装',
          },
        ],
      }],
    },
  };
  public static readonly PRODUCT_30004: ProductDetailInfo = {
    productId: 'product_30004',
    title: '玻璃高脚杯红酒杯水晶杯',
    banner: MockImageData.getImageResource(MockImageMap.PRODUCT_30004),
    price: 10.8,
    dashPrice: 58,
    sales: 20,
    tags: [],
    banners: [
      MockImageData.getImageResource(MockImageMap.PRODUCT_30004),
    ],
    logistics: [
      { icon: $r('app.media.ic_truck'),
content: '24小时发货' },
    ],
    service: [
      { icon: $r('app.media.ic_heart'),
content: '免运费' },
    ],
    pictures: [
      MockImageData.getImageResource(MockImageMap.PRODUCT_30004),
    ],
    selectionInfo: {
      defaultBanner: MockImageData.getImageResource(MockImageMap.PRODUCT_30004),
      basicPrice: 10.8,
      priceRange: '10.8-58',
      priceRemark: '实付',
      totalPriceRemark: '共实付',
      services: ['运费险｜7天无理由', '破损补寄'],
      skuItems: [
        {
          skuCode: 'sku_300004',
          specs: { 'spec': 'uuid_pair' },
          stock: 10,
          price: 10.8,
          dashPrice: 58,
        },
      ],
      specOptions: [{
        key: 'spec',
        label: '规格',
        values: [
          {
            id: 'uuid_pair',
            text: '1对装',
          },
        ],
      }],
    },
  };
  public static readonly PRODUCT_30005: ProductDetailInfo = {
    productId: 'product_30005',
    title: '咖啡杯简约',
    banner: MockImageData.getImageResource(MockImageMap.PRODUCT_30005),
    price: 8.8,
    dashPrice: 28,
    sales: 88,
    tags: [],
    banners: [
      MockImageData.getImageResource(MockImageMap.PRODUCT_30005),
    ],
    logistics: [
      { icon: $r('app.media.ic_truck'),
content: '24小时发货' },
    ],
    service: [
      { icon: $r('app.media.ic_heart'),
content: '免运费' },
    ],
    pictures: [
      MockImageData.getImageResource(MockImageMap.PRODUCT_30005),
    ],
    selectionInfo: {
      defaultBanner: MockImageData.getImageResource(MockImageMap.PRODUCT_30005),
      basicPrice: 8.8,
      priceRange: '8.8-28',
      priceRemark: '实付',
      totalPriceRemark: '共实付',
      services: ['运费险｜7天无理由'],
      skuItems: [
        {
          skuCode: 'sku_300005',
          specs: { 'spec': 'uuid_single' },
          stock: 10,
          price: 8.8,
          dashPrice: 28,
        },
      ],
      specOptions: [{
        key: 'spec',
        label: '规格',
        values: [
          {
            id: 'uuid_single',
            text: '1只',
          },
        ],
      }],
    },
  };
  // ==================== 商品列表生成函数 ====================
  private static _productListMock: ProductDetailInfo[] = [];

  /**
   * 获取商品详情列表（用于详情页展示）
   */
  public static getProductListMock(): ProductDetailInfo[] {
    if (MockProductData._productListMock.length) {
      return MockProductData._productListMock;
    }
    let arr: ProductDetailInfo[] = [];

    // 生成8个产品1的变体
    for (let index = 0; index < 8; index++) {
      const element = JSON.parse(JSON.stringify(MockProductData.PRODUCT_ITEM1)) as ProductDetailInfo;
      element.productId = `product_1000${index + 1}`;
      const productItem = MockProductData.PRODUCT_CARD_LIST.find((item) => item.productId === element.productId);
      if (productItem) {
        element.sales = productItem.sales;
      }
      const bannerList: string[] = [
        MockImageData.getImageResource(MockImageMap.PRODUCT_10001_PINK),
        MockImageData.getImageResource(MockImageMap.PRODUCT_10001_STRIPE),
        MockImageData.getImageResource(MockImageMap.PRODUCT_10001_YELLOW),
        MockImageData.getImageResource(MockImageMap.PRODUCT_10001_GREEN),
      ];
      const first = bannerList.splice(index % 4, 1);
      bannerList.unshift(...first);
      element.banners = bannerList;
      element.banner = bannerList[0];

      arr.push(element);
    }

    // 生成8个产品2的变体
    for (let index = 0; index < 8; index++) {
      const element = JSON.parse(JSON.stringify(MockProductData.PRODUCT_ITEM2)) as ProductDetailInfo;
      element.productId = `product_2000${index + 1}`;
      const productItem = MockProductData.PRODUCT_CARD_LIST.find((item) => item.productId === element.productId);
      if (productItem) {
        element.sales = productItem.sales;
      }
      const bannerList: string[] = [
        MockImageData.getImageResource(MockImageMap.PRODUCT_20001_BLACK),
        MockImageData.getImageResource(MockImageMap.PRODUCT_20001_BLACK),
        MockImageData.getImageResource(MockImageMap.PRODUCT_20001_SHIRT),
        MockImageData.getImageResource(MockImageMap.PRODUCT_20001_WHITE),
      ];
      const first = bannerList.splice(index % 4, 1);
      bannerList.unshift(...first);
      element.banners = bannerList;
      element.banner = bannerList[0];

      arr.push(element);
    }

    // 获取秒杀商品详情
    arr.push(
      MockProductData.PRODUCT_30001,
      MockProductData.PRODUCT_30002,
      MockProductData.PRODUCT_30003,
      MockProductData.PRODUCT_30004,
      MockProductData.PRODUCT_30005,
    );
    MockProductData._productListMock = arr;
    return MockProductData._productListMock;
  }

  /**
   * 获取商品卡片列表（用于首页展示）
   */
  public static getProductCardListMock(): BaseProductCard[] {
    const products = MockProductData.getProductListMock();
    return products.map(p => ({
      productId: p.productId,
      title: p.title,
      banner: p.banner,
      price: p.price,
      dashPrice: p.dashPrice,
    } as BaseProductCard));
  }

  // ==================== 商品评价数据 ====================

  public static readonly REVIEW_ITEM_MOCK1: ProductReviewItem = {
    productId: 'product_10001',
    userAvatar: '',
    userName: '张**',
    skuCode: 'sku_100012',
    skuDesc: ['170/88A', '绿色'],
    rating: 5,
    date: 1704220800000, // 2024-01-03 00:00:00
    content: '这款针织打底衫质量非常棒，纯羊毛材质，穿着舒适，保暖性很好。适合商务场合，搭配西装外套也很合适。',
    mediaList: [
      { type: 0,
uri: MockImageData.getImageResource(MockImageMap.PRODUCT_10001_PINK) },
      { type: 0,
uri: MockImageData.getImageResource(MockImageMap.PRODUCT_10001_STRIPE) },
      { type: 0,
uri: MockImageData.getImageResource(MockImageMap.PRODUCT_10001_GREEN) },
    ],
  };
  public static readonly REVIEW_ITEM_MOCK2: ProductReviewItem = {
    productId: 'product_10001',
    userAvatar: '',
    userName: '李**',
    skuCode: 'sku_100005',
    skuDesc: ['165/84A', '白色'],
    rating: 4,
    date: 1703616000000, // 2023-12-27 00:00:00
    content: '颜色很百搭，颜色看起来很高级。版型修身，穿上显得很精神。不过稍微有点紧身，建议选大一码。',
    mediaList: [],
  };
  public static readonly REVIEW_ITEM_MOCK3: ProductReviewItem = {
    productId: 'product_10001',
    userAvatar: '',
    userName: '小**',
    skuCode: 'sku_100004',
    skuDesc: ['160/80A', '白色'],
    rating: 5,
    date: 1704393600000, // 2024-01-05 00:00:00
    content: '深蓝色非常显气质，适合秋冬季节。羊毛材质柔软，洗涤后不易起球，质量上乘。',
    mediaList: [],
  };

  /**
   * 获取商品评价列表
   */
  public static getProductReviewListMock(productId: string): ProductReviewItem[] {
    const data = PersistenceV2.connect(
      ProductReviews,
      'product_review',
      () => new ProductReviews(),
    )!;
    if (!data.reviewList.length) {
      MockProductData.setProductReviewListMock([
        MockProductData.REVIEW_ITEM_MOCK1,
        MockProductData.REVIEW_ITEM_MOCK2,
        MockProductData.REVIEW_ITEM_MOCK3]);
    }

    return data.reviewList.filter(
      review => review.productId === productId,
    );
  }

  public static setProductReviewListMock(data: ProductReviewItem[]) {
    const list = PersistenceV2.connect(
      ProductReviews,
      'product_review',
      () => new ProductReviews(),
    )!;
    data.forEach((item) => {
      const model = new ProductReviewItemModel();
      model.productId = item.productId;
      model.userAvatar = item.userAvatar;
      model.userName = item.userName;
      model.skuCode = item.skuCode;
      model.skuDesc = item.skuDesc;
      model.rating = item.rating;
      model.date = item.date;
      model.content = item.content;
      model.mediaList = item.mediaList;
      list.reviewList.unshift(model);
    });
  }

  // ==================== 工具函数 ====================

  /**
   * 根据SKU Code获取SKU信息
   */
  public static getSkuByCode(skuCode: string): ProductSku | undefined {
    return MockProductData.PRODUCT_SKU_TABLE.find(sku => sku.skuCode === skuCode);
  }

  /**
   * 根据产品ID获取所有SKU
   */
  public static getSkusByProductId(productId: string): ProductSku[] {
    return MockProductData.PRODUCT_SKU_TABLE.filter(sku => sku.productId === productId);
  }

  /**
   * 根据产品ID获取商品卡片
   */
  public static getProductCardById(productId: string): ProductCardItem | undefined {
    return MockProductData.PRODUCT_CARD_LIST.find(card => card.productId === productId);
  }

  /**
   * 根据分类ID获取商品列表
   */
  public static getProductCardsByCategoryId(categoryId: string): ProductCardItem[] {
    return MockProductData.PRODUCT_CARD_LIST.filter(card => card.categoryId === categoryId);
  }

  /**
   * 根据产品ID获取商品详情
   */
  public static getProductDetailById(productId: string): ProductDetailInfo | undefined {
    const products = MockProductData.getProductListMock();
    return products.find(p => p.productId === productId);
  }

  /**
   * 获取热销商品列表（按销量排序）
   */
  public static getHotProductCards(limit: number = 10): ProductCardItem[] {
    return [...MockProductData.PRODUCT_CARD_LIST]
      .sort((a, b) => b.sales - a.sales)
      .slice(0, limit);
  }

  /**
   * 获取折扣商品列表
   */
  public static getDiscountProductCards(): ProductCardItem[] {
    return MockProductData.PRODUCT_CARD_LIST.filter(card =>
    card.label.some(l => l.preset === 0),
    );
  }

  /**
   * 搜索商品
   */
  public static searchProducts(keyword: string): ProductCardItem[] {
    const lowerKeyword = keyword.toLowerCase();
    return MockProductData.PRODUCT_CARD_LIST.filter(card =>
    card.title.toLowerCase().includes(lowerKeyword),
    );
  }
}