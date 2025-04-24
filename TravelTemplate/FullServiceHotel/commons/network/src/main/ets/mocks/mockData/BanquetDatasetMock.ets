import { BaseResponse } from '../../types/BaseResponse';
import { BanquetHotelItem, BanquetRoomItem, GetBanquetRoomDetailResp } from '../../types/responseTypes';
import { MockImageMap } from '../Constants';
import { getFormattedResp } from '../Utils';

const banquetHotelMock1: BanquetHotelItem = {
  id: 101,
  hotelName: '千和大酒店(1店)',
  hotelAddress: '江苏省南京市雨花客厅',
  longitude: '118.7553',
  latitude: '31.9735',
  displayImg: MockImageMap.IMG_HOTEL_COVER1,
  maxArea: '200㎡',
  maxCapacity: '1000人',
};

const banquetHotelMock2: BanquetHotelItem = {
  id: 102,
  hotelName: '千和大酒店(2店)',
  hotelAddress: '江苏省南京市雨花客厅',
  longitude: '118.7553',
  latitude: '31.9735',
  displayImg: MockImageMap.IMG_HOTEL_COVER2,
  maxArea: '450㎡',
  maxCapacity: '500人',
};

const banquetRoomMock1: BanquetRoomItem = {
  id: 25,
  banquetName: '维多利亚厅',
  hotelId: 101,
  hotelName: '千和大酒店(1店)',
  labelList: ['可容纳500人', '大型宴会'],
  introduce:
  '位于酒店3楼，厅正无柱子，歌剧院式尖顶设计，规模宏大，气势非凡，透气明亮，配备先进视听设备，灵活布局，满足不同规模会议，宴请需求',
  banner: MockImageMap.IMG_BANQUET_COVER1,
  profile: '歌剧院式尖顶设计，规模宏大，气势非凡',
};

const banquetRoomMock2: BanquetRoomItem = {
  id: 26,
  banquetName: '顶楼户外大厅',
  hotelId: 101,
  hotelName: '千和大酒店(1店)',
  labelList: ['可容纳60人', '办公会议'],
  introduce: '透气明亮，配有投影幕布、LED大屏、单独音响与调音台',
  banner: MockImageMap.IMG_BANQUET_COVER2,
  profile: '窗外海景，透气明亮',
};

const banquetRoomDetailMock:GetBanquetRoomDetailResp = {
  id: 25,
  banquetName: '维多利亚厅',
  banquetTel: '86-631-7577777',
  labelList: ['可容纳500人', '大型宴会'],
  introduce:
  '位于酒店3楼，厅正无柱子，歌剧院式尖顶设计，规模宏大，气势非凡，透气明亮，配备先进视听设备，灵活布局，满足不同规模会议，宴请需求',
  bannerList: [MockImageMap.IMG_BANQUET_COVER1],
  profile: '歌剧院式尖顶设计，规模宏大，气势非凡',
  siteInformation: [
    {
      content: '450',
      id: 5,
      siteName: '面积',
    },
    {
      content: '6',
      id: 6,
      siteName: '层高',
    },
    {
      content: '3',
      id: 7,
      siteName: '楼层',
    },
    {
      content: '无柱',
      id: 8,
      siteName: '特点',
    },
  ],
  layoutMethod: [
    {
      icon: 'mockImage://ic_layout1',
      id: 8,
      layoutName: 'U型式',
      personNum: '350',
    },
    {
      icon: 'mockImage://ic_layout2',
      id: 9,
      layoutName: '董事会',
      personNum: '300',
    },
    {
      icon:'mockImage://ic_layout3',
      id: 10,
      layoutName: '酒会式',
      personNum: '300',
    },
    {
      icon: 'mockImage://ic_layout4',
      id: 11,
      layoutName: '剧院式',
      personNum: '500',
    },
    {
      icon: 'mockImage://ic_layout5',
      id: 12,
      layoutName: '课桌式',
      personNum: '350',
    },
    {
      icon: 'mockImage://ic_layout6',
      id: 13,
      layoutName: '宴会式',
      personNum: '500',
    },
    {
      icon: 'mockImage://ic_layout7',
      id: 14,
      layoutName: '鱼骨式 ',
      personNum: '350',
    },
  ],
}

export class BanquetDatasetMock {
  public static getBanquetHotelList() {
    const list: BanquetHotelItem[] = [banquetHotelMock1, banquetHotelMock2];
    return getFormattedResp(list);
  }

  public static getBanquetRoomList() {
    const list: BanquetRoomItem[] = [banquetRoomMock1, banquetRoomMock2];
    return getFormattedResp(list);
  }

  public static getBanquetRoomDetail() {
    const dataCopy:GetBanquetRoomDetailResp = JSON.parse(JSON.stringify(banquetRoomDetailMock))
    return getFormattedResp(dataCopy)
  }
}