import { IntroType } from '../common/Constant';
import {
  IBaseStore,
  IGoodList,
  IGroupInfo,
  ISingleVisitCard,
  IStoreInfo,
  IUserInfo,
  LoginWithHuaweiIDResp,
} from '../model/IResponse';

export class MockData {
  static initialAppointId: number = 20;
  static USER_ID: number = 9876543210;
  static LOGIN_RESP: LoginWithHuaweiIDResp = {
    token: 'qwertyuiop',
    userId: MockData.USER_ID.toString(),
  };
  static USER_INFO_UNBIND: IUserInfo = {
    userId: MockData.USER_ID,
    mobile: '',
  };
  static USER_INFO_FULL: IUserInfo = {
    userId: MockData.USER_ID,
    mobile: '11100001111',
    nickName: '华为用户',
  };
  static STORE_INFO: IStoreInfo = {
    id: 1,
    brandId: 1,
    storeName: '柚子瑞颜美甲四季花城店',
    storeProfile: '',
    mobile: '11100001111',
    logoUrl: 'mockImage://example_store_logo',
    coords: '114.30795419058587,22.592429967609824',
    region: '',
    address: '柚子瑞颜美甲四季花城东门17-22号门',
    certName: '',
    storeBanner: 'mockImage://example_store_banner',
    businessLicense: 'mockImage://example_store_business',
    score: '5.0',
    businessStatus: 0,
    businessTimes: '8:00-21:00',
  };
  static STORE_LIST: IBaseStore[] = [
    {
      id: 1,
      storeName: '柚子瑞颜美甲陶跃居店',
      mobile: '11100001111',
      coords: '114.30795419058587,22.592429967609824',
      address: '柚子瑞颜美甲四季花城东门17-22号门',
    },
    {
      id: 2,
      storeName: '柚子瑞颜美甲青青世界店',
      mobile: '11100001111',
      coords: '114.30795419058587,22.592429967609824',
      address: '柚子瑞颜美甲四季花城东门17-22号门',
    },
    {
      id: 3,
      storeName: '柚子瑞颜美甲世纪花园店',
      mobile: '11100001111',
      coords: '114.30795419058587,22.592429967609824',
      address: '柚子瑞颜美甲四季花城东门17-22号门',
    },
    {
      id: 4,
      storeName: '柚子瑞颜美甲平安小区店',
      mobile: '11100001111',
      coords: '114.30795419058587,22.592429967609824',
      address: '柚子瑞颜美甲四季花城东门17-22号门',
    },
    {
      id: 5,
      storeName: '柚子瑞颜美甲龙园店',
      mobile: '11100001111',
      coords: '114.30795419058587,22.592429967609824',
      address: '柚子瑞颜美甲四季花城东门17-22号门',
    },
    {
      id: 6,
      storeName: '柚子瑞颜美甲龙湖店',
      mobile: '11100001111',
      coords: '114.30795419058587,22.592429967609824',
      address: '柚子瑞颜美甲四季花城东门17-22号门',
    },
    {
      id: 7,
      storeName: '柚子瑞颜美甲梅花店',
      mobile: '11100001111',
      coords: '114.30795419058587,22.592429967609824',
      address: '柚子瑞颜美甲四季花城东门17-22号门',
    },
    {
      id: 8,
      storeName: '柚子瑞颜美甲芙蓉大道店',
      mobile: '11100001111',
      coords: '114.30795419058587,22.592429967609824',
      address: '柚子瑞颜美甲四季花城东门17-22号门',
    },
    {
      id: 9,
      storeName: '柚子瑞颜美甲九龙湖店',
      mobile: '11100001111',
      coords: '114.30795419058587,22.592429967609824',
      address: '柚子瑞颜美甲四季花城东门17-22号门',
    },
    {
      id: 10,
      storeName: '柚子瑞颜美甲百家湖店',
      mobile: '11100001111',
      coords: '114.30795419058587,22.592429967609824',
      address: '柚子瑞颜美甲四季花城东门17-22号门',
    },
    {
      id: 11,
      storeName: '柚子瑞颜美甲太湖店',
      mobile: '11100001111',
      coords: '114.30795419058587,22.592429967609824',
      address: '柚子瑞颜美甲四季花城东门17-22号门',
    },
    {
      id: 12,
      storeName: '柚子瑞颜美甲青海店',
      mobile: '11100001111',
      coords: '114.30795419058587,22.592429967609824',
      address: '柚子瑞颜美甲四季花城东门17-22号门',
    },
    {
      id: 13,
      storeName: '柚子瑞颜美甲洞庭湖店',
      mobile: '11100001111',
      coords: '114.30795419058587,22.592429967609824',
      address: '柚子瑞颜美甲四季花城东门17-22号门',
    },
    {
      id: 14,
      storeName: '柚子瑞颜美甲呼伦店',
      mobile: '11100001111',
      coords: '114.30795419058587,22.592429967609824',
      address: '柚子瑞颜美甲四季花城东门17-22号门',
    },
    {
      id: 15,
      storeName: '柚子瑞颜美甲洪泽店',
      mobile: '11100001111',
      coords: '114.30795419058587,22.592429967609824',
      address: '柚子瑞颜美甲四季花城东门17-22号门',
    },
    {
      id: 16,
      storeName: '柚子瑞颜美甲洱海店',
      mobile: '11100001111',
      coords: '114.30795419058587,22.592429967609824',
      address: '柚子瑞颜美甲四季花城东门17-22号门',
    },
    {
      id: 17,
      storeName: '柚子瑞颜美甲纳木错店',
      mobile: '11100001111',
      coords: '114.30795419058587,22.592429967609824',
      address: '柚子瑞颜美甲四季花城东门17-22号门',
    },
    {
      id: 18,
      storeName: '柚子瑞颜美甲山西店',
      mobile: '11100001111',
      coords: '114.30795419058587,22.592429967609824',
      address: '柚子瑞颜美甲四季花城东门17-22号门',
    },
    {
      id: 19,
      storeName: '柚子瑞颜美甲黄山店',
      mobile: '11100001111',
      coords: '114.30795419058587,22.592429967609824',
      address: '柚子瑞颜美甲四季花城东门17-22号门',
    },
    {
      id: 20,
      storeName: '柚子瑞颜美甲长隆店',
      mobile: '11100001111',
      coords: '114.30795419058587,22.592429967609824',
      address: '柚子瑞颜美甲四季花城东门17-22号门',
    },
    {
      id: 21,
      storeName: '柚子瑞颜美甲梁溪店',
      mobile: '11100001111',
      coords: '114.30795419058587,22.592429967609824',
      address: '柚子瑞颜美甲四季花城东门17-22号门',
    },
  ];
  static GOOD_LIST: IGoodList[] = [
    {
      id: 1111,
      title: '专业美甲',
      goods: [
        {
          id: 1,
          title: '黑色琥珀猫眼美甲/送建构送卸甲',
          classId: 1111,
          images: [
            'mockImage://example_good_1',
            'mockImage://example_good_2',
          ],
          intro: [
            {
              type: IntroType.IMAGE,
              value: 'mockImage://example_good_intro_1',
            },
          ],
          price: 149,
          vipPrice: 59,
        },
        {
          id: 2,
          title: '贵气祖母绿日式美甲',
          classId: 1111,
          images: [
            'mockImage://example_good_2',
          ],
          intro: [
            {
              type: IntroType.IMAGE,
              value: 'mockImage://example_good_intro_2',
            },
          ],
          price: 299,
          vipPrice: 159,
        },
        {
          id: 3,
          title: '法式小清新美甲/送建构送卸甲',
          classId: 1111,
          images: [
            'mockImage://example_good_3',
          ],
          intro: [],
          price: 428,
          vipPrice: 125,
        },
        {
          id: 4,
          title: '法式镶钻美甲/送建构送卸甲',
          classId: 1111,
          images: [
            'mockImage://example_good_4',
          ],
          intro: [],
          price: 455,
          vipPrice: 193,
        },
      ],
    },
  ];
  // 首页团购列表
  static GROUP_LIST: IGroupInfo[] = [
    {
      id: 1,
      title: '新春特定/轻奢风美甲任选/含构建送跳色',
      images: ['mockImage://example_group_1', 'mockImage://example_group_2'],
      soldNum: 800,
      projectNum: 1,
      groupContent: {
        location: '手部',
        including: '美甲类型：纯色，含2跳色\u000A封层：亮面/磨砂',
        present: '下次到店免费卸甲',
        detail: [
          {
            title: 'ins款式美甲',
            numbers: 1,
            price: 380,
          },
          {
            title: '一次性用品',
            numbers: 1,
            price: 28,
          },
          {
            title: '送钻',
            numbers: 1,
            price: 68,
          },
          {
            title: '免费卸甲',
            numbers: 1,
            price: 38,
          },
          {
            title: '手部护理',
            numbers: 1,
            price: 28,
          },
        ],
      },
      intro: [
        {
          type: IntroType.IMAGE,
          value: 'mockImage://example_group_intro_1',
        },
      ],
      price: 299,
      vipPrice: 159,
      availablePeriod: -1,
    },
    {
      id: 2,
      title: 'ins款式简约大气/送钻/不含构建（全国门288家店通用）',
      images: ['mockImage://example_group_2'],
      soldNum: 1000,
      projectNum: 1,
      groupContent: {
        location: '手部',
        including: '美甲类型：纯色，含2跳色\u000A封层：亮面/磨砂',
        present: '下次到店免费卸甲',
        detail: [
          {
            title: 'ins款式美甲',
            numbers: 1,
            price: 380,
          },
          {
            title: '一次性用品',
            numbers: 1,
            price: 28,
          },
          {
            title: '送钻',
            numbers: 1,
            price: 68,
          },
          {
            title: '免费卸甲',
            numbers: 1,
            price: 38,
          },
          {
            title: '手部护理',
            numbers: 1,
            price: 28,
          },
        ],
      },
      intro: [],
      price: 149,
      vipPrice: 59,
      availablePeriod: -1,
    },
  ];
  // 首页次卡列表
  static SINGLE_CARD_LIST: ISingleVisitCard[] = [
    {
      id: 1,
      title: '贴片延长美甲卡',
      image: 'mockImage://example_good_1',
      sales: 800,
      availableNum: 3,
      projectNum: 1,
      price: 299,
      vipPrice: 159,
      availablePeriod: -1,
      intro: [
        {
          type: IntroType.IMAGE,
          value: 'mockImage://example_single_intro_1',
        },
        {
          type: IntroType.TEXT,
          value: '贴片延长美甲，会使您的短甲焕发新的光彩。',
        },
      ],
    },
    {
      id: 2,
      title: '建构美甲卡',
      image: 'mockImage://example_good_2',
      sales: 800,
      availableNum: 3,
      projectNum: 1,
      price: 146,
      vipPrice: 58,
      availablePeriod: new Date('2025-8-8').getTime(),
      intro: [],
    },
  ];
}