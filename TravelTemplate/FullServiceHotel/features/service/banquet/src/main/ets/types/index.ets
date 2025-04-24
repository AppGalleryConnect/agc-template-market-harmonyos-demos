export interface BanquetHotelItem {
  id: number;
  hotelName: string;
  hotelAddress: string;
  maxArea: string;
  maxCapacity: string;
  displayImg: string;
}

export interface BanquetRoomItem {
  banquetName: string;
  hotelId: number;
  id: number;
  hotelName: string;
  labelList: string[];
  banner: string;
  introduce: string;
  profile: string;
}

export interface BanquetRoomDetail {
  banquetName: string;
  banquetTel: string;
  labelList: string;
  introduce: string;
  bannerList: string[];
  profile: string;
  siteInformation: SiteInformationItem[];
  layoutMethod: LayoutMethodItem[];
}

export interface SiteInformationItem {
  id: number;
  orderNum: number;
  content: string;
  siteName: string;
}

export interface LayoutMethodItem {
  icon: string;
  id: number;
  layoutName: string;
  personNum: string;
}

export interface BanquetListRouteParam{
  hotelName: string;
  id: number;
}
