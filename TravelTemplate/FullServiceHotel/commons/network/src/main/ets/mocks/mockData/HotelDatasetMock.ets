import { SubmitCommentRequest } from '../../types/AxiosRequestParam';
import { BaseResponse } from '../../types/BaseResponse';
import {
  CommentItem,
  GetCommentListResp,
  GetRoomDetailResp,
  GetRoomListResp,
  HotelItem,
  RoomItem,
  ShopItem,
} from '../../types/responseTypes';
import { MockImageMap, MockStorageMap } from '../Constants';
import { getFormattedResp } from '../Utils';

const hotel1: HotelItem = {
  id: 101,
  name: '千和大酒店(1店)',
  orgUnitNo: '101',
  address: '江苏省南京市雨花客厅',
  minPrice: 388,
  imageUrl: MockImageMap.IMG_HOTEL_COVER1,
  tel: '025-12345678',
  labelList: ['免费wifi', '停车场', '健身房'],
  coordinate: '118.7553,31.9735',
  sortNum: 1,
};

const hotel2: HotelItem = {
  id: 102,
  name: '千和大酒店(2店)',
  orgUnitNo: '102',
  address: '江苏省南京市雨花客厅',
  minPrice: 388,
  imageUrl: MockImageMap.IMG_HOTEL_COVER1,
  tel: '025-12345678',
  labelList: ['停车场', '宴会厅', '游泳池'],
  coordinate: '118.7553,31.9735',
  sortNum: 2,
};

const room1: RoomItem = {
  id: 107733,
  roomName: '海景大床房',
  roomCode: '1ba191c90a8e2e1cea3f8b789a28bb46',
  imageUrl: MockImageMap.IMG_HOTEL_ROOM1,
  labelList: ['35m²', '2-5', '特大床,', '有窗'],
  roomNum: 0,
  minPrice: 388,
  rmRateList: [
    {
      rmRate: 388,
      rateCode: 'VAB1',
      rateName: '贵宾卡（无早餐）',
    },
    {
      rmRate: 458,
      rateCode: 'VAB1',
      rateName: '贵宾卡（双早餐）',
    },
  ],
};

const room2: RoomItem = {
  id: 107732,
  roomName: '豪华海景大床房',
  roomCode: '0ac455b293da637aa4ec902eecad9d56',
  imageUrl: MockImageMap.IMG_HOTEL_ROOM2,
  labelList: ['40m²', '4-7', '单人床,', '有窗'],
  roomNum: 0,
  minPrice: 532,
  rmRateList: [
    {
      rmRate: 532,
      rateCode: 'VAB1',
      rateName: '贵宾卡（单早餐）',
    },
    {
      rmRate: 608,
      rateCode: 'VAB1',
      rateName: '贵宾卡（双早餐）',
    },
  ],
};

const room3: RoomItem = {
  id: 107735,
  roomName: '海景双床房',
  roomCode: 'fdd085f3fd8959c552e23348c3684f05',
  imageUrl: MockImageMap.IMG_HOTEL_ROOM3,
  labelList: ['35m²', '2-7', '单人床,', '有窗'],
  roomNum: 0,
  minPrice: 388,
  rmRateList: [
    {
      rmRate: 388,
      rateCode: 'VAB1',
      rateName: '贵宾卡（无早餐）',
    },
  ],
};

const roomDetail: GetRoomDetailResp = {
  roomName: '海景大床房',
  roomCode: '1ba191c90a8e2e1cea3f8b789a28bb46',
  roomLabel: '35m²|2-5|特大床,|有窗',
  amenities: '220V电压插座、110V电压插座、电吹风、空调、电热水壶、迷你酒吧、针线包、电子秤、阳台、无线WIFI',
  beds: '',
  mediaTech: '电视（卫星）频道',
  foodDrink: '瓶装水',
  toiletries: '毛巾、浴巾、拖鞋、沐浴露、洗发水、牙膏、一次性拖鞋、牙刷',
  bath: '浴衣/浴袍、24小时热水、卫生间、有浴室',
  other: '',
  bannerList: [MockImageMap.IMG_HOTEL_ROOM_BANNER1, MockImageMap.IMG_HOTEL_ROOM_BANNER2],
  labelList: [
    {
      resourceName: '特大床',
      resourceUrl: 'mockImage://ic_hotel_room_label1',
    },
    {
      resourceName: '免费WiFi',
      resourceUrl: 'mockImage://ic_hotel_room_label2',
    },
    {
      resourceName: '2-5层',
      resourceUrl: 'mockImage://ic_hotel_room_label3',
    },
    {
      resourceName: '有窗',
      resourceUrl: 'mockImage://ic_hotel_room_label4',
    },
    {
      resourceName: '35m²',
      resourceUrl: 'mockImage://ic_hotel_room_label5',
    },
  ],
};

const commentMock1: CommentItem = {
  commentMakerIcon: '',
  commentMakerName: '',
  comment: '房间挺好阳台打大靠海，前台小姐姐服务很好，满意不错',
  score: 5,
  commentTime: '2024-11-29 14:16:51',
  hotelName: '千和大酒店(1店)',
};

const commentMock2: CommentItem = {
  commentMakerIcon: '',
  commentMakerName: '',
  comment:
  '小区和酒店同享一片海，天气冷了不适合下海，无边泳池也玩不了了，酒店环境不错，除设施老点其他都好，服务也不错，海边骑车最远走到这里，还不错的酒店',
  score: 5,
  commentTime: '2024-11-29 14:16:51',
  hotelName: '千和大酒店(2店)',
};

const shopItemMock1: ShopItem = {
  id: 101,
  name: '千和大酒店(1店)',
  type: 'HOTEL',
};

const shopItemMock2: ShopItem = {
  id: 102,
  name: '千和大酒店(2店)',
  type: 'HOTEL',
};

const shopItemMock3: ShopItem = {
  id: 103,
  name: '千和大酒店·中餐厅',
  type: 'RESTAURANT',
};

const shopItemMock4: ShopItem = {
  id: 104,
  name: '千和大酒店·西餐厅',
  type: 'RESTAURANT',
};

export class HotelDatasetMock {
  public static getHotelList() {
    const hotelList: HotelItem[] = [hotel1, hotel2];
    return getFormattedResp(hotelList);
  }

  public static getRoomList() {
    const roomListResp: GetRoomListResp = {
      roomList: [room1, room2, room3],
      bannerList: [MockImageMap.IMG_HOTEL_COVER1],
    };
    return getFormattedResp(roomListResp);
  }

  public static getRoomDetail() {
    return getFormattedResp(roomDetail);
  }

  public static getShopListForComment() {
    const list: ShopItem[] = [shopItemMock1, shopItemMock2, shopItemMock3, shopItemMock4];
    return getFormattedResp(list)
  }

  public static getCommentList() {
    let storageList = AppStorage.get<GetCommentListResp>(MockStorageMap.COMMENT_LIST);
    if (!storageList) {
      storageList = [commentMock1, commentMock2];
      AppStorage.setOrCreate(MockStorageMap.COMMENT_LIST, storageList);
    }
    return getFormattedResp(storageList);
  }

  public static submitComment(data: SubmitCommentRequest) {
    const storageList = AppStorage.get<GetCommentListResp>(MockStorageMap.COMMENT_LIST);
    if (!storageList) {
      HotelDatasetMock.getCommentList();
    }
    const newComment: CommentItem = {
      commentMakerIcon: '',
      commentMakerName: '',
      comment: data.comment,
      score: data.overallScore,
      commentTime: data.commentTime ?? '',
      hotelName: data.hotelName ?? '',
    };
    storageList!.push(newComment);
    AppStorage.set(MockStorageMap.COMMENT_LIST, storageList);
    return getFormattedResp(undefined);
  }
}