import { MockImageMap } from './MockImageMap';
import {
  CategoryItem,
  ProductSummaryItem,
  SubCategoryItem,
} from '../../types/responses/HomeConfigResponse';

const subCategoryMock: SubCategoryItem[] = [
  {
    id: '1001',
    label: '女士经典',
  },
  {
    id: '1002',
    label: '男士经典',
  },
  {
    id: '1003',
    label: '儿童',
  },
];


export class MockHomeConfig {
  static readonly categoryBarList: CategoryItem[] = [
    {
      id: '1',
      label: '精选',
      iconUrl: MockImageMap.HOME_CATEGORY_1,
      subCategory: subCategoryMock,
    },
    {
      id: '2',
      label: '清洁用品',
      iconUrl: MockImageMap.HOME_CATEGORY_2,
      subCategory: subCategoryMock,
    },
    {
      id: '3',
      label: '全棉用品',
      iconUrl: MockImageMap.HOME_CATEGORY_3,
      subCategory: subCategoryMock,
    },
    {
      id: '4',
      label: '安睡香氛',
      iconUrl: MockImageMap.HOME_CATEGORY_4,
    },
    {
      id: '6',
      label: '运动休闲',
      iconUrl: MockImageMap.HOME_CATEGORY_6,
    },
    {
      id: '7',
      label: '成人服装',
      iconUrl: MockImageMap.HOME_CATEGORY_7,
    },
    {
      id: '8',
      label: '折扣商品',
      iconUrl: MockImageMap.HOME_CATEGORY_8,
    },
    {
      id: '9',
      label: '美妆彩妆',
      iconUrl: MockImageMap.HOME_CATEGORY_9,
    },
    {
      id: '10',
      label: '饰品首饰',
      iconUrl: MockImageMap.HOME_CATEGORY_10,
    },
  ];
  static readonly categoryDataList: ProductSummaryItem[] = [
    {
      banner: MockImageMap.PRODUCT_20001_BLACK,
      title: '经典休闲短袖',
      id: '1002_001',
      subCategoryId: '1002',
    },
    {
      banner: MockImageMap.PRODUCT_20001_BLUE,
      title: '经典舒适短袖',
      id: '1002_002',
      subCategoryId: '1002',
    },
    {
      banner: MockImageMap.PRODUCT_20001_SHIRT,
      title: '经典休闲衬衫',
      subCategoryId: '1002',
      id: '1002_003',
    },
    {
      banner: MockImageMap.PRODUCT_20001_WHITE,
      title: '经典商务衬衫',
      subCategoryId: '1002',
      id: '1002_004',
    },
    {
      banner: MockImageMap.PRODUCT_20001_BLACK,
      title: '经典休闲短袖',
      subCategoryId: '1002',
      id: '1002_005',
    },
    {
      banner: MockImageMap.PRODUCT_20001_BLUE,
      title: '经典舒适短袖',
      subCategoryId: '1002',
      id: '1002_006',
    },
    {
      banner: MockImageMap.PRODUCT_10001_GREEN,
      title: '经典针织打底',
      id: '1001_001',
      subCategoryId: '1001',
    },
    {
      banner: MockImageMap.PRODUCT_10001_PINK,
      title: '时尚针织打底',
      id: '1001_002',
      subCategoryId: '1001',
    },
    {
      banner: MockImageMap.PRODUCT_10001_STRIPE,
      title: '纯羊毛内搭',
      subCategoryId: '1001',
      id: '1001_003',
    },
    {
      banner: MockImageMap.PRODUCT_10001_YELLOW,
      title: '轻商务系列',
      subCategoryId: '1001',
      id: '1001_004',
    },
    {
      banner: MockImageMap.PRODUCT_10001_GREEN,
      title: '经典针织打底',
      id: '1001_001',
      subCategoryId: '1001',
    },
    {
      banner: MockImageMap.PRODUCT_10001_PINK,
      title: '时尚针织打底',
      id: '1001_002',
      subCategoryId: '1001',
    },
    {
      banner: MockImageMap.PRODUCT_10001_STRIPE,
      title: '纯羊毛内搭',
      subCategoryId: '1001',
      id: '1001_003',
    },
    {
      banner: MockImageMap.PRODUCT_10001_YELLOW,
      title: '轻商务系列',
      subCategoryId: '1001',
      id: '1001_004',
    },
  ];
  static readonly searchList: string[] = [
    '时尚轻商务系列',
    '秋季穿搭',
    '针织',
    '衬衫',
  ];
  static readonly bannerList:string[] = [
    MockImageMap.HOME_BANNER_1,
    MockImageMap.HOME_BANNER_2,
  ];
}
