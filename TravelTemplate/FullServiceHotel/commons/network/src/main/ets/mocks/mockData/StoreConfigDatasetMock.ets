import { GetServiceBannerRequest } from '../../types/AxiosRequestParam';
import { BaseResponse } from '../../types/BaseResponse';
import {
  EquityItem,
  GetGradeListResp,
  GetNoticeDetailResp,
  GetNoticeListResp,
  GetServiceBannerResp,
  GetTenantConfigResp,
  GetTenantInfoResp,
  GetTrafficDetailResp,
  NoticeItem,
  StructureDetailItem,
} from '../../types/responseTypes';
import { MockImageMap } from '../Constants';
import { getFormattedResp } from '../Utils';

const bannerMock: StructureDetailItem = {
  templateStructureType: 1,
  info: '[{"image":"img_banner1.png?token=c335c660-e957-4ff7-8ac6-2b90167eb768"},{"image":"img_banner2.png?token=56df743a-35cc-4a88-a550-1ca2708ce3e5"}]',
};

const twoPicsServiceMock: StructureDetailItem = {
  templateStructureType: 2,
  info: '[{"link":"orderoom","image":"img_service_hotel.png?token=442d57c5-17c8-4b34-a19c-6079464c9576","title":"酒店预订"},{"link":"orderfood","image":"img_service_catering.png?token=edf184b9-d4a7-4ea1-8021-7464cd6a1005","title":"餐饮预订"}]',
};

const threePicsServiceMock: StructureDetailItem = {
  templateStructureType: 3,
  info: '[{"image":"img_service_banquet.png?token=23482143-0002-4d03-b88f-6b960af08fd2","link":"shop","title":"宴会厅查询"},{"image":"img_service_order.png?token=8acc439f-9596-4912-bc28-8c019a8d6f7a","link":"myorder","title":"订单查询"},{"image":"img_service_contact.png?token=f336d17c-446d-4394-b042-9ca58225c5f6","link":"phone","title":"致电客服"}]',
};

const otherServiceMock: StructureDetailItem = {
  templateStructureType: 4,
  info: '[{"image":"mockImage://ic_restaurant","link":"orderfood","title":"美食餐饮"},{"image":"mockImage://ic_hotel","link":"hotel","title":"酒店介绍"},{"image":"mockImage://ic_location","link":"traffic","title":"酒店位置"},{"image":"mockImage://ic_comment","link":"comment","title":"客人说"}]',
};

const productAdMock: StructureDetailItem = {
  templateStructureType: 5,
  info: '{"image":"img_product_ad.png?token=28e278c3-c63d-4e52-bfa1-0f01417f72e3","title":"","link":""}',
};

const productListMock: StructureDetailItem = {
  templateStructureType: 6,
  info: '[{"image":"img_meal6.png?token=0412a5a8-9022-4d4b-a352-5d21eba4b7aa","link":"","text":"巴西烤肉单人餐","price":"157","oldPrice":"227","id":"1105","bigImageUrl":"","detailImageUrl":"","storeName":"千和大酒店·西餐厅"},{"image":"img_meal2.png?token=4ecb6cb6-f144-42fb-be9d-577c7fd5d0b4","link":"","text":"海鲜意面双人餐","price":"158","oldPrice":"245","id":"1106","bigImageUrl":"","detailImageUrl":"","storeName":"千和大酒店·西餐厅"},{"image":"img_meal3.png?token=13736cc6-3bc4-480d-b0c4-65c0d56284d8","link":"","text":"石锅酸汤鱼套餐2-3人餐","price":"199","oldPrice":"291","id":"1102","bigImageUrl":"","detailImageUrl":"","storeName":"千和大酒店·中餐厅"},{"image":"img_meal1.png?token=a16847c2-0ff9-4d0b-9f09-f5cb20bc3826","link":"","text":"新疆风味双人餐","price":"98","oldPrice":"185","id":"1103","bigImageUrl":"","detailImageUrl":"","storeName":"千和大酒店·中餐厅"}]',
};

const noticeItemMock: NoticeItem = {
  noticeId: 1,
  publishTime: '2023-12-01 14:10:26',
  noticeTitle: '千和客房礼遇您了解吗',
  noticeType: '1',
};

const noticeDetailMock: GetNoticeDetailResp = {
  noticeId: 3,
  publishTime: '2024-12-01 14:10:26',
  noticeTitle: '千和会员客房礼遇您了解吗',
  noticeType: '2',
  contentList: [
    {
      title: '',
      content: `尊敬的各位宾客：

您好！为了感谢您一直以来对千和酒店的支持与厚爱，我们特此推出千和会员客房礼遇，让您的每一次入住都更加尊贵与舒适。作为千和酒店的会员，您将享受到一系列专属福利，提升您的住宿体验。

会员专享客房优惠
优先入住与延迟退房：会员可享受优先办理入住和延迟退房服务，让您无需担忧时间上的压力，随时根据自己的行程安排更灵活的入住与退房。

专属房价优惠：会员可在每次预定时，享受最高**15%**的房价折扣，让您的每次住宿都能得到更高性价比的回报。

房型升级：根据房态，会员可在入住时免费享受房型升级，尽情体验更加宽敞舒适的客房环境。

专属礼遇与增值服务
每日欢迎饮品：入住期间，会员将获得免费的每日欢迎饮品，轻松开启一天的愉快旅程。

定制化服务：会员将享受个性化定制服务，如提前安排特别需求（如枕头、浴室用品等），确保您的舒适体验。

积分奖励：每次入住时，会员将根据消费金额积累积分，积分可以兑换房晚、餐饮、SPA等多种礼遇，享受更多实惠。

如何成为千和会员
成为千和酒店会员非常简单！只需通过我们的官网或前台登记，便可立即加入。无论是短期旅行还是长期住宿，您都将成为千和会员的一员，享受来自我们全方位的贴心服务。

小贴士：
会员卡的所有优惠不可与其他优惠活动同时使用。
房型升级、优先入住等服务需视房态与酒店实际情况而定。
感谢您对千和酒店的信任与支持，您的每次到来都让我们更加努力为您提供更优质的服务。我们期待着您的光临，帮助您打造完美的住宿体验！

千和酒店全体员工敬上
2024年12月`,
      image: '',
    },
  ],
};

const serviceBannerMock1: GetServiceBannerResp = {
  image: MockImageMap.IMG_HOTEL_LIST_BANNER,
};

const serviceBannerMock2: GetServiceBannerResp = {
  image: MockImageMap.IMG_BANNER1,
};

const equityItemMock1: EquityItem = {
  id: 1,
  equityName: '房价9折',
  equityIcon: 'mockImage://ic_vip_benefit1',
  equityIntro: '当日基准房价9折',
};

const equityItemMock2: EquityItem = {
  id: 11,
  equityName: '房价8折',
  equityIcon: 'mockImage://ic_vip_benefit1',
  equityIntro: '当日基准房价8折',
};

const equityItemMock3: EquityItem = {
  id: 2,
  equityName: '延时退房',
  equityIcon: 'mockImage://ic_vip_benefit2',
  equityIntro: '免费延迟退房至14:00点',
};

const equityItemMock4: EquityItem = {
  id: 3,
  equityName: '积分返利',
  equityIcon: 'mockImage://ic_vip_benefit3',
  equityIntro: '客房按消费金额3%返积分；餐饮按消费金额6%返积分',
};

const equityItemMock5: EquityItem = {
  id: 4,
  equityName: '积分兑换',
  equityIcon: 'mockImage://ic_vip_benefit4',
  equityIntro: '',
};

const equityItemMock6: EquityItem = {
  id: 5,
  equityName: '增值服务',
  equityIcon: 'mockImage://ic_vip_benefit5',
  equityIntro: '可部分享受会员增值服务',
};

const equityItemMock7: EquityItem = {
  id: 6,
  equityName: '免费宵夜',
  equityIcon: 'mockImage://ic_vip_benefit6',
  equityIntro: '每年可免费享受4次宵夜',
};

const equityItemMock8: EquityItem = {
  id: 7,
  equityName: '免费升级券',
  equityIcon: 'mockImage://ic_vip_benefit7',
  equityIntro: '每年可免费享受4次客房升级',
};

const grandListMock: GetGradeListResp = [
  {
    gradeName: '大众会员特权',
    gradeNum: 1,
    gradeCover: MockImageMap.IMG_GRADE_LEVEL1,
    introTitle: '会员服务说明',
    introText:
    '“千和会”是千和酒店集团为每一位会员提供的一项专属礼遇，在获得专享服务同时彰显尊贵身份。根据“千和会”会籍等级享受各类会员待遇，主要包括专享特价、畅享积分、尊享礼遇。凡持有“千和会”会员卡，可在任何一家舜和旗下酒店消费，为会员提供方便之余，并可根据酒店消费轻松赚取丰厚积分，畅享舜和酒店线上商城自主购物，实现酒店产品及其他物品的积分兑换，让每一位会员的旅途充满奖赏和惊喜。',
    equityList: [equityItemMock1, equityItemMock3, equityItemMock4, equityItemMock5, equityItemMock6],
  },
  {
    gradeName: '黄金会员特权',
    gradeNum: 2,
    gradeCover: MockImageMap.IMG_GRADE_LEVEL2,
    introTitle: '会员服务说明',
    introText:
    '“千和会”是千和酒店集团为每一位会员提供的一项专属礼遇，在获得专享服务同时彰显尊贵身份。根据“千和会”会籍等级享受各类会员待遇，主要包括专享特价、畅享积分、尊享礼遇。凡持有“千和会”会员卡，可在任何一家舜和旗下酒店消费，为会员提供方便之余，并可根据酒店消费轻松赚取丰厚积分，畅享舜和酒店线上商城自主购物，实现酒店产品及其他物品的积分兑换，让每一位会员的旅途充满奖赏和惊喜。',
    equityList: [equityItemMock2, equityItemMock3, equityItemMock4, equityItemMock5, equityItemMock6, equityItemMock7,
      equityItemMock8],
  },
];


export class StoreConfigDatasetMock {
  static hotelName: string = '千和大酒店';
  static tenantId: number = 1001;

  public static getTenantInfo() {
    const data: GetTenantInfoResp = {
      tenantId: StoreConfigDatasetMock.tenantId,
      tenantName: StoreConfigDatasetMock.hotelName,
    };
    return getFormattedResp(data);
  }

  public static getTenantConfig() {
    const data: GetTenantConfigResp = [
      bannerMock, twoPicsServiceMock, threePicsServiceMock, otherServiceMock, productAdMock, productListMock,
    ];
    return getFormattedResp(data);
  }

  public static getNoticeList() {
    const data: GetNoticeListResp = [noticeItemMock, noticeItemMock];
    return getFormattedResp(data);
  }

  public static getNoticeDetail() {
    const data: GetNoticeDetailResp = noticeDetailMock;
    return getFormattedResp(data);
  }

  public static getTrafficDetail() {
    const data: GetTrafficDetailResp = {
      hotelId: StoreConfigDatasetMock.tenantId,
      name: StoreConfigDatasetMock.hotelName,
      coordinate: '118.7553,31.9735',
    };
    return getFormattedResp(data);
  }

  public static getServiceBanner(data: GetServiceBannerRequest) {
    if (data.pageType === 2) {
      return getFormattedResp(serviceBannerMock1);
    } else {
      return getFormattedResp(serviceBannerMock2);
    }
  }

  public static getGrandList() {
    const grandCopy:GetGradeListResp = JSON.parse(JSON.stringify(grandListMock))
    return getFormattedResp(grandCopy);
  }

}