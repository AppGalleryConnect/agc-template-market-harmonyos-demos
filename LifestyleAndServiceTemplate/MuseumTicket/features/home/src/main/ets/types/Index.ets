import { RouterMap } from 'commonlib';




export interface LocationGuideItem {
  icon?: string;
  title: string;
  desc: string;
  image?: string;
}

export interface TrafficResp {
  id: number;
  name: string;
  coordinate: string;
  infos: LocationGuideItem[];
}

export interface HotelCoordinate {
  latitude: number;
  longitude: number;
}


// 主要服务
export interface ServerListItem {
  name: string,
  value: string | number,
  icon: ResourceStr,
  url: RouterMap
}

// 精彩推荐
export interface RecommendListItem {
  id: string,
  img: string,
  name: string,
  detail: string,
  price: number
}


// 讲解服务文本
export interface ExplainTextItem {
  title: string,
  content: string[]
}

export interface IntroduceText {
  total: string,
  content: string[]
}


export interface MuseumLocation {
  latitude: number,
  longitude: number
}


