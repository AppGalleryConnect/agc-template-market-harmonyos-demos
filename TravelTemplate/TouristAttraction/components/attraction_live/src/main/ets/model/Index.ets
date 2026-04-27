export interface RealTimeInfo {
  icon: ResourceStr
  item: string,
  count: number
}

export class ParkingSlotInfo {
  /*华为Site唯一id，预留对接开发者服务端*/
  siteId: string = ''
  name: string = ''
  distance: number = 0
  icon: ResourceStr = ''
  longitude: number = 0
  latitude: number = 0
}

export enum RealTimeItem {
  CURRENT_VISITOR = '当前游客数',
  PARKING_SPACE = '景区停车位数量',
}

@ObservedV2
export class AttractionLiveInfo {
  @Trace longitude: number = 0;
  @Trace latitude: number = 0;
  @Trace currentDate: Date = new Date();
  @Trace temperature: number = 0;
  @Trace currentDayVisitors: number = 0;
  @Trace maxVisitors: number = 0;
  @Trace maxInstantVisitors: number = 0;
  @Trace weatherId: string = '';
  @Trace atmosphereId: string = '';
  @Trace name: string = '';
  @Trace realTimeInfos?: RealTimeInfo[];
  @Trace openTime: string = '';
  @Trace ticketTime: string = '';
}