import { site } from '@kit.MapKit';

// 消息类型枚举
export enum MessageType {
  TEXT = 'text',
  IMAGE = 'image',
  LOCATION = 'location',
  URL = 'url',
}

// 消息发送状态
export enum MessageStatus {
  SENDING = 'sending',
  SENT = 'sent',
  FAILED = 'failed',
}

// 消息发送者类型
export enum SenderType {
  USER = 'user',
  CUSTOMER_SERVICE = 'customer_service',
}

export interface LocationInfo {
  // 地址
  address: string;

  //选点的地点ID
  siteId?: string;

  // 选点地址的详细信息
  addressComponent?: site.AddressComponent;

  // 地理位置描述
  name?: string;

  // 地理位置图片
  locationSnapShot?: PixelMap;

  // 经度
  locationLongitude: number;

  // 纬度
  locationLatitude: number;
}

// 消息实体类
export class MessageModel {
  // 消息ID
  id: string = '';

  // 消息类型
  type: MessageType = MessageType.TEXT;

  // 消息内容（文本内容或图片URL）
  content: ResourceStr = '';

  // 时间戳
  timestamp: number = 0;

  // 是否需要显示时间
  isShowTime: boolean = false;

  // 发送者
  sender: SenderType = SenderType.USER;

  // 图片宽高比
  imageAspectRatio?: number;

  // 发送状态
  status?: MessageStatus;

  // 地理位置描述
  locationInfo?: LocationInfo;
}

//历史消息记录类
@ObservedV2
export class MessageHistoryModel {
  @Trace list: MessageModel[] = [];
}