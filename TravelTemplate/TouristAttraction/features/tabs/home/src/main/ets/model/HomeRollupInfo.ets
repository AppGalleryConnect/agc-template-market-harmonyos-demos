import { AttractionInfo, ScenicBasicInfo, NoteInfo } from 'types'

export interface ParkInfo {
  parkId: number,
  name: string,
  spaces: number,
  longitude: number,
  latitude: number,
}

export enum WeatherType {
  CLOUDY = '多云',
  SUNNY = '晴',
  DRIZZLE = '小雨',
  MODERATE = '中雨',
  DOWNPOUR = '大雨'
}

export enum AtmosphereType {
  GOOD = '良好',
  GENERAL = '一般',
  MILD_POLLUTION = '轻度污染',
  MODERATE_POLLUTION = '中度污染',
  HEAVY_POLLUTION = '重度污染'
}

export class HomeRollupInfo implements ScenicBasicInfo {
  labels: string[] = ['免费开放', '自然景观', '4A景区']
  detailImages: ResourceStr[] = [];
  currentDate?: Date = new Date();
  weatherId: WeatherType = WeatherType.SUNNY;
  temperature: number = 0;
  atmosphereId: AtmosphereType = AtmosphereType.GOOD;
  currentVisitors: number = 824;
  maxVisitors: number = 2000;
  maxInstantVisitors: number = 1000;
  openTime: Date = new Date(2024, 11, 17, 8, 0);
  ticketTime: Date = new Date(2024, 11, 17, 8, 0);
  rescuePhone:string = '13760187181'
  complaintPhone: string = '13760187181';
  hotAttractions: AttractionInfo[] = [];
  hotNotes: NoteInfo[] = []
  name: string = '华为欧洲小镇';
  location: string = '中国广东省东莞市松山湖科技产业园区环湖路99号';
  longitude: number = 113.880028;
  latitude: number = 22.874712;
  banner: ResourceStr = $r('app.media.app_icon');
  introduction: string =
    '位于东莞松山湖溪流背坡村的欧洲小镇，占地1900多亩，分12区，按牛津、温德米尔、卢森堡、布鲁日、弗里堡、勃艮第、维罗纳、巴黎、格拉纳达、博洛尼亚、海德尔堡、克伦诺夫等12个欧洲小镇或经典建筑建造';
  consultPhone: string = '13760187181';
  parks: ParkInfo[] = [{
    parkId: 0,
    name: '松山湖东门停车场',
    spaces: 200,
    longitude: 113.88852986984118,
    latitude: 22.880878379924344
  }]
}