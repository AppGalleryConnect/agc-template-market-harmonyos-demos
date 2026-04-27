@ObservedV2
export class LocationInfo {
  longitude: number = 0;
  latitude: number = 0;
}

export class SongItem {
  id: number = 0;
  title: string = '';
  src: string = '';
}

export interface ScenicBasicInfo {
  /*名称*/
  name: string,

  /*位置*/
  location: string,

  /*经度*/
  longitude: number,

  /*纬度*/
  latitude: number,

  /*封面图片*/
  banner: ResourceStr,

  /*介绍*/
  introduction: string,

  /*咨询电话*/
  consultPhone: string,

  /*轮播图列表*/
  detailImages: ResourceStr[]
  /*标签列表*/
  labels: string[]
}

export class SongList extends Array<SongItem> {
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

export interface RealTimeInfo {
  icon: ResourceStr
  item: string,
  count: number
}

export interface RouteLine {
  routeId: number;
  routeName: string;
  brief: string;
  label: string[];
  routeDistance: number;
  duration: number;
  routeBanner: ResourceStr;
  attractionIds: number[];
}

@ObservedV2
export class RouteModel implements RouteLine {
  routeId: number;
  routeName: string;
  brief: string;
  routeDistance: number;
  duration: number;
  routeBanner: ResourceStr;
  attractionIds: number[];
  label: string[];

  constructor(item?: RouteModel) {
    this.routeId = item?.routeId || 0;
    this.routeName = item?.routeName || '';
    this.brief = item?.brief || '';
    this.routeDistance = item?.routeDistance || 0;
    this.duration = item?.duration || 0;
    this.routeBanner = item?.routeBanner || '';
    this.attractionIds = item?.attractionIds || [];
    this.label = item?.label || [];
  }
}

export interface RouteParam {
  route: RouteModel,
  attractionIds: number[]
}

@ObservedV2
export class PlayInfo {
  @Trace panelIcon: ResourceStr = '';
  @Trace panelName: string = '';
  @Trace playId: string = '';
  @Trace introduction: string = '';
  @Trace title: string = '';
  @Trace imageUrl: string = '';
}

@ObservedV2
export class TouristInfo {
  @Trace id: string = ''
  @Trace name: string = ''
  @Trace phone: string = ''
  @Trace cardType: number = 0
  @Trace cardNo: string = ''
  @Trace isChecked: boolean = false

  constructor(id: string = '') {
    this.id = id
  }
}

export class TouristList extends Array<TouristInfo> {
}

export interface BasicInfo {
  /*地点Id*/
  siteId: string
  /*名称*/
  name: string;

  /*位置*/
  address: string;

  /*起步价格*/
  startPrice: number;

  /*联系电话*/
  phone: string;

  /*banner图片*/
  banner: ResourceStr;

  /*banner图片*/
  banners: ResourceStr[];

  /*经度*/
  longitude: number;

  /*纬度*/
  latitude: number;

  /*详情*/
  detail: string
  /*距离*/
  distance: number
  /*评论数量*/
  comments: number
  /*评分*/
  rating: number
}

@ObservedV2
export class UserInfo {
  authCode?: string = ''
  idToken?: string = ''
  @Trace avatar: ResourceStr = '';
  @Trace phone: string = '';
  @Trace nickname: string = '';
  @Trace gender: number = 2;
  @Trace birthday: string = '';
  @Trace isLink: boolean = false
}

@ObservedV2
export class CustomShareParams {
  @Trace id: number = 0;
  @Trace pageName: string = '';
  @Trace goodId: number = 0;
  @Trace goodName: string = '';
}

export interface ShareInfo {
  showShareMenu: boolean; // 当前页面是否允许分享，面板分享开关是否打开, 不填默认为不允许
  title?: string; // 系统分享面板标题，默认为元服务名称
  description?: string; // 系统分享面板简介，默认为元服务一句话描述
  previewUri?: string; // 分享图片缩略图，为本地文件uri，预留字段，不起作用
  parameters?: Object; // 开发者自定参数
  preview?: string; // 分享缩略图的base64编码，大小限制在32kb，太大会导致分享按钮置灰
}
