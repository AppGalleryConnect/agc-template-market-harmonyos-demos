import { JSON } from '@kit.ArkTS';
import { formatDate, getDateByIncrement, getFormatDate, getRealTimeDate } from 'calendar';
import {
  CarouselImage,
  Commodity,
  HotelInfo,
  Instructions,
  Order,
  Passenger,
  PersonalInfo,
  ScenicHomestaySurrounds,
} from 'type';
import { AddOrModifyPassengerRequest, CreateOrderRequest, UpdateOrderRequest } from '../types/AxiosRequestParam';
import {
  BaseResponse,
  CommodityCarouselImagesResp,
  CommodityListResp,
  CommodityResp,
  HomeDetailResp,
  HomeResp,
  RoomTypeResp,
  TenantResp,
  TravelNoteResp,
} from '../types/ResponceTypes';

export class Mock {
  static TENANTINFO: TenantResp =
    {
      code: 200,
      data: {
        id: 0,
        appName: '原舍望山民宿(湖州莫干山店)',
        labelList: ['双十一特惠', '度假'],
        banner: $r('app.media.brand'),
        phone: '12345678901',
        address: '莫干山镇南路村孙家岭清境原舍',
        position: '119.89,30.56',
        introduction: '位于莫干山南路村，坐拥竹山，背靠茶园，独享一片清幽的江南山色。田地平旷，屋舍俨然，有良田美池桑竹之属。望山有斑驳老墙，也有新研房舍。老木为梁，老物为潢，质朴少堆彻。在山坳之间，青砖黛瓦的小屋仿若带我们回到了童年，在群山环抱的林问谷地，我们还原了乡村最为本质的生活状态，最淳朴的民风民俗，让忙碌于城市中的人们在这找到心灵休憩短暂停留的地方。',
      },
    };
  static HOME: HomeResp = {
    data: {
      recommendGoodsList: [new Commodity(3, 126, '126', '神牛高原牧场4.0g高蛋白低脂青少年成人早餐奶',
        $r('app.media.recommend5'), [$r('app.media.recommend5')], [$r('app.media.detail_combile')],
        '200ml*6盒,200ml*12盒,200ml*12盒【送牛奶杯】',
        [158, 316, 320],
        [128, 256, 260], '', '', 1), new Commodity(3, 126, '126', '神牛高原牧场4.0g高蛋白低脂青少年成人早餐奶',
        $r('app.media.recommend3'), [$r('app.media.recommend3')], [$r('app.media.detail_combile')],
        '200ml*6盒,200ml*12盒,200ml*12盒【送牛奶杯】',
        [158, 316, 320],
        [128, 256, 260], '', '', 1)],
      hotScenicSpotCategoryList: [{
        id: 0,
        name: '公路',
        categoryName: '',
        categoryBanner: $r('app.media.post1'),
        categoryDetailImagesJson: '',
        categoryDetailImageList: [],
        labelList: ['宝山', '德宏'],
        isHot: 1,
      },
        {
          id: 1,
          name: '动物世界',
          categoryName: '',
          categoryBanner: $r('app.media.post2'),
          categoryDetailImagesJson: '',
          categoryDetailImageList: [],
          labelList: ['哈尔滨'],
          isHot: 1,
        },
        {
          id: 2,
          name: '都市',
          categoryName: '',
          categoryBanner: $r('app.media.post3'),
          categoryDetailImagesJson: '',
          categoryDetailImageList: [],
          labelList: ['北京', '南京'],
          isHot: 1,
        },
        {
          id: 3,
          name: '悬崖',
          categoryName: '',
          categoryBanner: $r('app.media.post4'),
          categoryDetailImagesJson: '',
          categoryDetailImageList: [],
          labelList: ['青岛', '大连'],
          isHot: 1,
        },
        {
          id: 4,
          name: '湖泊',
          categoryName: '',
          categoryBanner: $r('app.media.post5'),
          categoryDetailImagesJson: '',
          categoryDetailImageList: [],
          labelList: ['长白山'],
          isHot: 1,
        },
      ],
      carouselImageList: [{
        id: 0,
        image: $r('app.media.swiper'),
      }],
    },
    code: 200,
  };
  static INSTRUCTIONS: Instructions = {
    'foundations': [
      {
        'tag': '基础',
        'subTags': [
          '公共音响系统',
          '地暖',
          '中央空调',
          '酒吧',
          '咖啡',
          '中餐厅',
          '烧烤BBQ',
          '野餐区',
          '篮球场',
          '派对',
          '会议厅',
          '篝火',
          'wifi',
        ],
      },
      {
        'tag': '基础',
        'subTags': [
          '免费停车场',
        ],
      },
      {
        'tag': '前台',
        'subTags': [
          '叫车服务',
          '行李寄存',
        ],
      },
    ],
    'reservation': [
      {
        'tag': '入离',
        'subTags': [
          '14:00 办理入住',
          '12:00 办理退房',
        ],
      },
    ],
    'checkOut': [
      {
        'tag': '宠物',
        'subTags': [
          '不可携带宠物',
        ],
      },
      {
        'tag': '年龄',
        'subTags': [
          '不允许18岁以下单独办理',
        ],
      },
      {
        'tag': '早餐',
        'subTags': [
          '含双早（中式早餐）',
        ],
      },
    ],
  };
  static CAROUSEL_IMAGE_LIST: CarouselImage[] = [{
    id: 0,
    image: $r('app.media.detail_banner'),
  }];
  static ROOM_TYPE: RoomTypeResp[] = [
    {
      id: 0,
      roomTypeName: '山景大床房',
      roomTypeBanner: $r('app.media.room1'),
      roomTypeDetailImageList: [$r('app.media.room1')],
      labelList: ['清静优雅', '田园风'],
      occupancyLimit: 2,
      introduction: '该房型不提供加床、不提供加婴儿床',
      roomTypeBedList: [
        {
          id: 3,
          bedTypeCode: 'ONE_EIGHT_METER',
          bedTypeName: '1.8米床',
          bedCount: 1,
          roomTypeId: 1,
          isDelete: 0,
          appId: '',
          remark: '',
          createBy: '',
          createTime: '2024-11-04T16:47:40',
          updateBy: '',
          updateTime: '2024-11-08T16:13:07',
        },
      ],
      isRecommended: true,
      instructions: {
        'foundations': [
          {
            'tag': '基础',
            'subTags': [
              '公共音响系统',
              '地暖',
              '中央空调',
              'wifi',
            ],
          },
          {
            'tag': '前台',
            'subTags': [
              '叫车服务',
              '行李寄存',
            ],
          },
        ],
        'reservation': [
          {
            'tag': '入离',
            'subTags': [
              '14:00 办理入住',
              '12:00 办理退房',
            ],
          },
        ],
        'checkOut': [
          {
            'tag': '宠物',
            'subTags': [
              '不可携带宠物',
            ],
          },
          {
            'tag': '年龄',
            'subTags': [
              '不允许18岁以下单独办理',
            ],
          },
          {
            'tag': '早餐',
            'subTags': [
              '含双早（中式早餐）',
            ],
          },
        ],
      },
      roomTypePriceList: [{
        'id': 8,
        'roomTypeId': 1,
        'originalPrice': 140,
        'discount': 0.73,
        'actualPrice': 140,
        'roomPriceDay': `${getRealTimeDate().year}-${formatDate(getRealTimeDate().month)}-${formatDate(getRealTimeDate()
          .day)}`,
        'remainingRooms': '5',
        'breakfastQuantity': 0,
        'sortOrder': 1,
        'isDelete': 0,
        'appId': '',
        'remark': '',
        'createBy': '',
        'createTime': '2024-11-05T14:01:15',
        'updateBy': '',
        'updateTime': '2024-11-12T13:40:25',
      },
        {
          'id': 11,
          'roomTypeId': 1,
          'originalPrice': 120,
          'discount': 0.73,
          'actualPrice': 120,
          'roomPriceDay': getDateByIncrement(1),
          'remainingRooms': '5',
          'breakfastQuantity': 0,
          'sortOrder': 1,
          'isDelete': 0,
          'appId': '',
          'remark': '',
          'createBy': '',
          'createTime': '2024-11-05T14:01:15',
          'updateBy': '',
          'updateTime': '2024-11-12T13:40:25',
        },
        {
          'id': 11,
          'roomTypeId': 1,
          'originalPrice': 100,
          'discount': 0.73,
          'actualPrice': 100,
          'roomPriceDay': getDateByIncrement(2),
          'remainingRooms': '5',
          'breakfastQuantity': 0,
          'sortOrder': 1,
          'isDelete': 0,
          'appId': '',
          'remark': '',
          'createBy': '',
          'createTime': '2024-11-05T14:01:15',
          'updateBy': '',
          'updateTime': '2024-11-12T13:40:25',
        },
      ],
    },
    {
      id: 1,
      roomTypeName: '山景双床房',
      roomTypeBanner: $r('app.media.room2'),
      roomTypeDetailImageList: [$r('app.media.room2')],
      labelList: ['清静优雅', '田园风'],
      occupancyLimit: 4,
      introduction: '该房型不提供加床、不提供加婴儿床',
      roomTypeBedList: [
        {
          'id': 4,
          'bedTypeCode': 'ONE_EIGHT_METER',
          'bedTypeName': '1.5米床',
          'bedCount': 2,
          'roomTypeId': 1,
          'isDelete': 0,
          'appId': '',
          'remark': '',
          'createBy': '',
          'createTime': '2024-11-04T16:47:40',
          'updateBy': '',
          'updateTime': '2024-11-08T16:13:07',
        },
      ],
      isRecommended: true,
      instructions: {
        'foundations': [
          {
            'tag': '基础',
            'subTags': [
              '公共音响系统',
              '地暖',
              '中央空调',
              'wifi',
            ],
          },
          {
            'tag': '前台',
            'subTags': [
              '叫车服务',
              '行李寄存',
            ],
          },
        ],
        'reservation': [
          {
            'tag': '入离',
            'subTags': [
              '14:00 办理入住',
              '12:00 办理退房',
            ],
          },
        ],
        'checkOut': [
          {
            'tag': '宠物',
            'subTags': [
              '不可携带宠物',
            ],
          },
          {
            'tag': '年龄',
            'subTags': [
              '不允许18岁以下单独办理',
            ],
          },
          {
            'tag': '早餐',
            'subTags': [
              '含双早（中式早餐）',
            ],
          },
        ],
      },
      roomTypePriceList: [{
        'id': 8,
        'roomTypeId': 1,
        'originalPrice': 200,
        'discount': 0.73,
        'actualPrice': 200,
        'roomPriceDay': `${getRealTimeDate().year}-${formatDate(getRealTimeDate().month)}-${formatDate(getRealTimeDate()
          .day)}`,
        'remainingRooms': '5',
        'breakfastQuantity': 0,
        'sortOrder': 1,
        'isDelete': 0,
        'appId': '',
        'remark': '',
        'createBy': '',
        'createTime': '2024-11-05T14:01:15',
        'updateBy': '',
        'updateTime': '2024-11-12T13:40:25',
      },
        {
          'id': 11,
          'roomTypeId': 1,
          'originalPrice': 180,
          'discount': 0.73,
          'actualPrice': 180,
          'roomPriceDay': getDateByIncrement(1),
          'remainingRooms': '5',
          'breakfastQuantity': 0,
          'sortOrder': 1,
          'isDelete': 0,
          'appId': '',
          'remark': '',
          'createBy': '',
          'createTime': '2024-11-05T14:01:15',
          'updateBy': '',
          'updateTime': '2024-11-12T13:40:25',
        },
        {
          'id': 11,
          'roomTypeId': 1,
          'originalPrice': 160,
          'discount': 0.73,
          'actualPrice': 160,
          'roomPriceDay': getDateByIncrement(2),
          'remainingRooms': '5',
          'breakfastQuantity': 0,
          'sortOrder': 1,
          'isDelete': 0,
          'appId': '',
          'remark': '',
          'createBy': '',
          'createTime': '2024-11-05T14:01:15',
          'updateBy': '',
          'updateTime': '2024-11-12T13:40:25',
        },
      ],
    },
    {
      id: 2,
      roomTypeName: ' 山景露台大床房',
      roomTypeBanner: $r('app.media.room3'),
      roomTypeDetailImageList: [$r('app.media.room3')],
      labelList: ['清静优雅', '田园风'],
      occupancyLimit: 4,
      instructions: {
        'foundations': [
          {
            'tag': '基础',
            'subTags': [
              '公共音响系统',
              '地暖',
              '中央空调',
              'wifi',
            ],
          },
          {
            'tag': '前台',
            'subTags': [
              '叫车服务',
              '行李寄存',
            ],
          },
        ],
        'reservation': [
          {
            'tag': '入离',
            'subTags': [
              '14:00 办理入住',
              '12:00 办理退房',
            ],
          },
        ],
        'checkOut': [
          {
            'tag': '宠物',
            'subTags': [
              '不可携带宠物',
            ],
          },
          {
            'tag': '年龄',
            'subTags': [
              '不允许18岁以下单独办理',
            ],
          },
          {
            'tag': '早餐',
            'subTags': [
              '含双早（中式早餐）',
            ],
          },
        ],
      },
      introduction: '该房型不提供加床、不提供加婴儿床',
      roomTypeBedList: [
        {
          'id': 4,
          'bedTypeCode': 'ONE_EIGHT_METER',
          'bedTypeName': '1.5米床',
          'bedCount': 2,
          'roomTypeId': 1,
          'isDelete': 0,
          'appId': '',
          'remark': '',
          'createBy': '',
          'createTime': '2024-11-04T16:47:40',
          'updateBy': '',
          'updateTime': '2024-11-08T16:13:07',
        },
      ],
      isRecommended: true,
      roomTypePriceList: [{
        'id': 8,
        'roomTypeId': 1,
        'originalPrice': 200,
        'discount': 0.73,
        'actualPrice': 200,
        'roomPriceDay': `${getRealTimeDate().year}-${formatDate(getRealTimeDate().month)}-${formatDate(getRealTimeDate()
          .day)}`,
        'remainingRooms': '5',
        'breakfastQuantity': 0,
        'sortOrder': 1,
        'isDelete': 0,
        'appId': '',
        'remark': '',
        'createBy': '',
        'createTime': '2024-11-05T14:01:15',
        'updateBy': '',
        'updateTime': '2024-11-12T13:40:25',
      },
        {
          'id': 11,
          'roomTypeId': 1,
          'originalPrice': 180,
          'discount': 0.73,
          'actualPrice': 180,
          'roomPriceDay': getDateByIncrement(1),
          'remainingRooms': '5',
          'breakfastQuantity': 0,
          'sortOrder': 1,
          'isDelete': 0,
          'appId': '',
          'remark': '',
          'createBy': '',
          'createTime': '2024-11-05T14:01:15',
          'updateBy': '',
          'updateTime': '2024-11-12T13:40:25',
        },
        {
          'id': 11,
          'roomTypeId': 1,
          'originalPrice': 160,
          'discount': 0.73,
          'actualPrice': 160,
          'roomPriceDay': getDateByIncrement(2),
          'remainingRooms': '5',
          'breakfastQuantity': 0,
          'sortOrder': 1,
          'isDelete': 0,
          'appId': '',
          'remark': '',
          'createBy': '',
          'createTime': '2024-11-05T14:01:15',
          'updateBy': '',
          'updateTime': '2024-11-12T13:40:25',
        },
      ],
    },
    {
      id: 3,
      roomTypeName: '山景小院',
      roomTypeBanner: $r('app.media.room4'),
      roomTypeDetailImageList: [$r('app.media.room4')],
      labelList: ['清静优雅', '田园风'],
      occupancyLimit: 4,
      introduction: '该房型不提供加床、不提供加婴儿床',
      instructions: {
        'foundations': [
          {
            'tag': '基础',
            'subTags': [
              '公共音响系统',
              '地暖',
              '中央空调',
              'wifi',
            ],
          },
          {
            'tag': '前台',
            'subTags': [
              '叫车服务',
              '行李寄存',
            ],
          },
        ],
        'reservation': [
          {
            'tag': '入离',
            'subTags': [
              '14:00 办理入住',
              '12:00 办理退房',
            ],
          },
        ],
        'checkOut': [
          {
            'tag': '宠物',
            'subTags': [
              '不可携带宠物',
            ],
          },
          {
            'tag': '年龄',
            'subTags': [
              '不允许18岁以下单独办理',
            ],
          },
          {
            'tag': '早餐',
            'subTags': [
              '含双早（中式早餐）',
            ],
          },
        ],
      },
      roomTypeBedList: [
        {
          'id': 4,
          'bedTypeCode': 'ONE_EIGHT_METER',
          'bedTypeName': '1.5米床',
          'bedCount': 2,
          'roomTypeId': 1,
          'isDelete': 0,
          'appId': '',
          'remark': '',
          'createBy': '',
          'createTime': '2024-11-04T16:47:40',
          'updateBy': '',
          'updateTime': '2024-11-08T16:13:07',
        },
      ],
      isRecommended: true,
      roomTypePriceList: [{
        'id': 8,
        'roomTypeId': 1,
        'originalPrice': 200,
        'discount': 0.73,
        'actualPrice': 200,
        'roomPriceDay': `${getRealTimeDate().year}-${formatDate(getRealTimeDate().month)}-${formatDate(getRealTimeDate()
          .day)}`,
        'remainingRooms': '5',
        'breakfastQuantity': 0,
        'sortOrder': 1,
        'isDelete': 0,
        'appId': '',
        'remark': '',
        'createBy': '',
        'createTime': '2024-11-05T14:01:15',
        'updateBy': '',
        'updateTime': '2024-11-12T13:40:25',
      },
        {
          'id': 11,
          'roomTypeId': 1,
          'originalPrice': 180,
          'discount': 0.73,
          'actualPrice': 180,
          'roomPriceDay': getDateByIncrement(1),
          'remainingRooms': '5',
          'breakfastQuantity': 0,
          'sortOrder': 1,
          'isDelete': 0,
          'appId': '',
          'remark': '',
          'createBy': '',
          'createTime': '2024-11-05T14:01:15',
          'updateBy': '',
          'updateTime': '2024-11-12T13:40:25',
        },
        {
          'id': 11,
          'roomTypeId': 1,
          'originalPrice': 160,
          'discount': 0.73,
          'actualPrice': 160,
          'roomPriceDay': getDateByIncrement(2),
          'remainingRooms': '5',
          'breakfastQuantity': 0,
          'sortOrder': 1,
          'isDelete': 0,
          'appId': '',
          'remark': '',
          'createBy': '',
          'createTime': '2024-11-05T14:01:15',
          'updateBy': '',
          'updateTime': '2024-11-12T13:40:25',
        },
      ],
    },
  ];
  static SCENIC_HOMESTAY_SURROUNDS: ScenicHomestaySurrounds [] = [{
    id: 0,
    name: '莫干山风景区',
    position: '472m',
    detailsImg: $r('app.media.surround'),
  },
  ];
  static ADD_PSG: BaseResponse = {
    code: 200,
    data: undefined,
  };
  static HOME_DETAIL: HomeDetailResp = {
    code: 200,
    data: new HotelInfo({
      id: 0,
      appName: '原舍望山民宿(湖州莫干山店)',
      labelList: ['双十一特惠', '度假'],
      banner: $r('app.media.detail_banner'),
      phone: '12345678901',
      address: '莫干山镇南路村孙家岭清境原舍',
      introduction: '位于莫干山南路村，坐拥竹山，背靠茶园，独享一片清幽的江南山色。田地平旷，屋舍俨然，有良田美池桑竹之属。\n' +
        '望山有斑驳老墙，也有新研房舍。老木为梁，老物为潢，质朴少堆彻。在山坳之间，青砖黛瓦的小屋仿若带我们回到了童年，在群山环抱的林问谷地，我们还原了乡村最为本质的生活状态，最淳朴的民风民俗，让忙碌于城市中的人们在这找到心灵休憩短暂停留的地方。',
      instructions: this.INSTRUCTIONS,
    }, this.CAROUSEL_IMAGE_LIST, [], this.ROOM_TYPE, this.SCENIC_HOMESTAY_SURROUNDS),
  };
  static TRAVEL_NOTE: TravelNoteResp = {
    code: 200,
    data: [{
      id: 0,
      banner: $r('app.media.post3'),
      imageList: [$r('app.media.post3')],
      title: '原舍望山民宿 位于莫干山南路村，坐拥竹山',
      notes: '位于莫干山南路村，坐拥竹山，背靠茶园，独享一片清幽的江南山色。田地平旷，屋舍俨然，有良田美池桑竹之属。\n' +
        '望山有斑驳老墙，也有新研房舍。老木为梁，老物为潢，质朴少堆彻。在山坳之间，青砖黛瓦的小屋仿若带我们回到了童年，在群山环抱的林问谷地，我们还原了乡村最为本质的生活状态，最淳朴的民风民俗，让忙碌于城市中的人们在这找到心灵休憩短暂停留的地方。',
      createTime: '2022-11-18 18:20',
    },
      {
        id: 1,
        banner: $r('app.media.post4'),
        imageList: [$r('app.media.post4')],
        title: '雨后乡野小镇的清晨',
        notes: '雨后乡野小镇的清晨，是一个宁静而美丽的时刻。当夜幕渐渐散去，第一缕阳光穿过云层，洒在这片被雨水滋润过的土地上，给人一种清新的感觉。',
        createTime: '2022-11-18 18:20',
      },
      {
        id: 2,
        banner: $r('app.media.post5'),
        imageList: [$r('app.media.post5')],
        title: '今日海景房~~~~~~~',
        notes: '壮丽的海景，让您尽情享受大自然的美丽。无论是躺在舒适的床上，还是坐在阳台上，您都可以欣赏到无敌海景，尽情感受海风的拂面。',
        createTime: '2022-11-18 18:20',
      },
      {
        id: 3,
        banner: $r('app.media.post1'),
        imageList: [$r('app.media.post1')],
        title: '追风山野，FUN肆美好，第一季业主春日行',
        notes: '春光无限好，正是户外时。脱下冬日的厚重大衣，换上轻便的运动装，来一场说走就走的春日踏青之旅吧！4月9日，金地·追风山野，FUN肆美好业主春日行第一季活动，约你一起嗨！',
        createTime: '2022-11-18 18:20',
      },
      {
        id: 4,
        banner: $r('app.media.post2'),
        imageList: [$r('app.media.post2')],
        title: '骏马与大海',
        notes: '大海风景不仅仅是一种视觉享受，更是一种心灵的洗礼。站在海边，你可以感受到海风的轻拂，听到海浪的潮起潮落，沉浸在大自然的怀抱中，忘却一切烦恼与压力。大海给人带来的宁静与宽广，让人心旷神怡，仿佛与世隔绝，与自然融为一体。',
        createTime: '2022-11-18 18:20',
      },
    ],
  };
  static commodityList: CommodityListResp[] = [
    {
      id: 3,
      shopId: 126,
      goodsSn: '126',
      goodsName: '神牛高原牧场4.0g高蛋白低脂青少年成人早餐奶',
      banner: $r('app.media.recommend5'),
      detailImages: [$r('app.media.recommend5')],
      imageList: [$r('app.media.detail_combile')],
      specification: '200ml*6盒,200ml*12盒,200ml*12盒【送牛奶杯】',
      counterPrice: [158, 316, 320],
      retailPrice: [128, 256, 260],
      detail: '',
      saleRule: '',
      count: 1,
    },
    {
      id: 4,
      shopId: 123,
      goodsSn: '123',
      goodsName: '吐鲁番葡萄顺丰冷链包邮',
      banner: $r('app.media.recommend1'),
      detailImages: [$r('app.media.recommend1')],
      imageList: [$r('app.media.detail_combile')],
      specification: '1kg,5kg,10kg',
      counterPrice: [49.9, 249.5, 499],
      retailPrice: [35.8, 175, 350],
      detail: '',
      saleRule: '',
      count: 1,
    },
    {
      id: 5,
      shopId: 124,
      goodsSn: '124',
      goodsName: '京都抹茶世家',
      banner: $r('app.media.recommend3'),
      detailImages: [$r('app.media.recommend3')],
      imageList: [$r('app.media.detail_combile')],
      specification: '1盒,2盒,5盒',
      counterPrice: [49.9, 99, 190],
      retailPrice: [35.8, 70, 175],
      detail: '',
      saleRule: '',
      count: 1,
    },
    {
      id: 6,
      shopId: 125,
      goodsSn: '125',
      goodsName: '奥地利进口橄榄油',
      banner: $r('app.media.recommend2'),
      detailImages: [$r('app.media.recommend2')],
      imageList: [$r('app.media.detail_combile')],
      specification: '1瓶,5瓶,1箱',
      counterPrice: [80, 400, 520],
      retailPrice: [72, 360, 480],
      detail: '',
      saleRule: '',
      count: 1,
    },
    {
      id: 7,
      shopId: 126,
      goodsSn: '126',
      goodsName: '神牛高原牧场4.0g高蛋白低脂青少年成人早餐奶',
      banner: $r('app.media.recommend5'),
      detailImages: [$r('app.media.recommend5')],
      imageList: [$r('app.media.detail_combile')],
      specification: '200ml*6盒,200ml*12盒,200ml*12盒【送牛奶杯】',
      counterPrice: [158, 316, 320],
      retailPrice: [128, 256, 260],
      detail: '',
      saleRule: '',
      count: 1,
    },
    {
      id: 8,
      shopId: 127,
      goodsSn: '127',
      goodsName: '斯里兰卡猫屎咖啡',
      banner: $r('app.media.recommend6'),
      detailImages: [$r('app.media.recommend6')],
      imageList: [$r('app.media.detail_combile')],
      specification: '1盒,5盒,10盒【送咖啡杯】',
      counterPrice: [9.9, 45, 90],
      retailPrice: [9, 40, 80],
      detail: '',
      saleRule: '',
      count: 1,
    },
    {
      id: 9,
      shopId: 128,
      goodsSn: '128',
      goodsName: '有机胡萝卜',
      banner: $r('app.media.recommend7'),
      detailImages: [$r('app.media.recommend7')],
      imageList: [$r('app.media.detail_combile')],
      specification: '1斤,5斤,1袋【送香葱】',
      counterPrice: [5, 25, 40],
      retailPrice: [4, 20, 35],
      detail: '',
      saleRule: '',
      count: 1,
    },
  ];
  static COMMODITY: CommodityResp = {
    code: 200,
    data: {
      records: getCommodityList(this.commodityList),
    },
  };
  static COMMODITY_CAROUSEL_IMAGES: CommodityCarouselImagesResp = {
    code: 200,
    data: [{
      id: 0,
      image: $r('app.media.swiper1'),
      type: 'SHOP',
    }],
  };

  static createOrder(data: CreateOrderRequest): BaseResponse {
    let orderList: string = '';
    let list: string | undefined = AppStorage.get('orderList');
    let order: Order = new Order();
    order.id = data.id;
    order.orderType = data.orderType;
    order.orderSn = data.orderSn;
    order.passengerId = data.passengerId ?? 0;
    order.orderStatus = data.orderStatus;
    order.orderRemark = data.orderRemark;
    order.planCheckInDate = data.planCheckInDate;
    order.planCheckOutDate = data.planCheckOutDate;
    order.dayCount = data.dayCount;
    order.openId = data.openId;
    order.orderSn = data.orderSn;
    order.createTime = data.createTime;
    order.amount = data.amount;
    order.count = data.count;
    order.goodsCount = data.goodsCount ?? 0;
    order.goodsBanner = data.goodsBanner;
    order.commodityId = data.commodityId;
    order.sfc = data.sfc;

    if (AppStorage.has('orderList') && list?.length !== 0) {
      let orders: Order[] = JSON.parse(AppStorage.get('orderList')) as Order[];
      orders.unshift(order);
      AppStorage.setOrCreate('orderList', JSON.stringify(orders));
    } else {
      orderList = JSON.stringify([order]);
      AppStorage.setOrCreate('orderList', orderList);
    }
    return {
      code: 200,
      data: AppStorage.get('orderList'),
    };
  }

  static updateOrder(data: UpdateOrderRequest): BaseResponse {
    let res: Order[] = JSON.parse(AppStorage.get('orderList')) as Order[];
    let list = res.filter(item => item.orderSn !== data.orderSn);
    let order = res.filter(item => item.orderSn === data.orderSn);
    order[0].orderStatus = data.orderStatus;
    list.unshift(order[0]);
    AppStorage.setOrCreate('orderList', JSON.stringify(list));
    return {
      code: 200,
      data: undefined,
    };
  }

  static getPersonalInfo(): BaseResponse {
    let hasUserInfo: boolean = AppStorage.has('userInfo');
    let userInfo: string | undefined = '';
    if (hasUserInfo) {
      userInfo = AppStorage.get('userInfo');
    } else {
      userInfo = JSON.stringify({
        id: 0,
        openId: '',
        nickName: '',
        gender: 0,
        birthday: getFormatDate(new Date()),
        phone: '',
        avatar: '',
        appId: '',
      });
      AppStorage.setOrCreate('userInfo', userInfo);
    }

    return {
      code: 200,
      data: JSON.parse(userInfo),
    };
  }

  static modifyPsg(data: AddOrModifyPassengerRequest): BaseResponse {
    let passenger: Passenger = {
      passengerId: data.passengerId,
      openId: '',
      passengerName: data.passengerName,
      passengerPhone: data.passengerPhone,
      passengerCardType: data.passengerCardType,
      passengerCardId: data.passengerCardId,
      appId: '',
    };

    let psgList = JSON.parse(AppStorage.get('psgList')) as Passenger[];
    let index = psgList.findIndex((item) => item.passengerId === data.passengerId);
    psgList.splice(index, 1, passenger);
    AppStorage.setOrCreate('psgList', JSON.stringify(psgList));

    return {
      code: 200,
      data: undefined,
    };
  }

  static deletePsg(passengerId: number): BaseResponse {
    let psgList = JSON.parse(AppStorage.get('psgList')) as Passenger[];
    let index = psgList.findIndex((item) => item.passengerId === passengerId);
    psgList.splice(index, 1);
    AppStorage.setOrCreate('psgList', JSON.stringify(psgList));

    return {
      code: 200,
      data: undefined,
    };
  }

  static createPsg(data: AddOrModifyPassengerRequest): BaseResponse {
    let psgList: string = '';
    let list: string | undefined = AppStorage.get('psgList');
    let passenger = new Passenger();
    passenger.passengerId = data.passengerId;
    passenger.passengerName = data.passengerName;
    passenger.passengerPhone = data.passengerPhone;
    passenger.passengerCardType = data.passengerCardType;
    passenger.passengerCardId = data.passengerCardId;
    if (AppStorage.has('psgList') && list?.length !== 0) {
      let passengers: Passenger[] = JSON.parse(AppStorage.get('psgList')) as Passenger[];
      // 已存在直接返回
      if (passengers.find(item => item.passengerId === data.passengerId)) {
        return {
          code: 200,
          data: undefined,
        };
      }
      passengers.push(passenger);
      AppStorage.setOrCreate('psgList', JSON.stringify(passengers));
    } else {
      psgList = JSON.stringify([passenger]);
      AppStorage.setOrCreate('psgList', psgList);
    }

    return {
      code: 200,
      data: undefined,
    };
  }

  static getOrderList(): BaseResponse {
    let hasList: Boolean = AppStorage.has('orderList');
    let list: string | undefined = AppStorage.get('orderList');
    return {
      code: 200,
      data: hasList && list?.length !== 0 ? JSON.parse(list) : [],
    };
  }

  static getPassengerList(): BaseResponse {
    let hasList: Boolean = AppStorage.has('psgList');
    let list: string | undefined = AppStorage.get('psgList');
    return {
      code: 200,
      data: hasList && list?.length !== 0 ? JSON.parse(AppStorage.get('psgList')) : [],
    };
  }

  static setUserInfo(data: PersonalInfo): BaseResponse<undefined> {
    AppStorage.setOrCreate('userInfo', JSON.stringify(data));
    return {
      code: 200,
      data: undefined,
    };
  }
}

function getCommodityList(list: CommodityListResp[]) {
  let result: Commodity[] = [];
  list.forEach((item: CommodityListResp) => {
    let commodity = new Commodity();
    commodity.id = item.id;
    commodity.shopId = item.shopId;
    commodity.goodsSn = item.goodsSn;
    commodity.goodsName = item.goodsName;
    commodity.banner = item.banner;
    commodity.detailImages = item.detailImages;
    commodity.imageList = item.imageList;
    commodity.specification = item.specification;
    commodity.counterPrice = item.counterPrice;
    commodity.retailPrice = item.retailPrice;
    commodity.detail = item.detail;
    commodity.saleRule = item.saleRule;
    commodity.count = item.count;

    result.push(commodity);
  });
  return result;
}