import { ChatTypeEnum } from 'chat_base'

// 消息发送类型
export class ChatInputSendMessageModel {
  // 消息内容
  content: string = ''

  // 消息类型
  messageType: ChatTypeEnum

  // messageType=IMAGE时，本地缓存图片地址
  pictureUrl: string = ''

  // messageType=VIDEO时，本地缓存图片地址
  videoUrl: string = ''

  // messageType=SOUND，本地缓存图片地址
  audioUrl: string = ''

  // 消息生成时的时间戳
  timeStamp: number

  // 图片|视频宽度
  width: number = 0

  // 图片|视频高度
  height: number = 0

  // 视频时长，单位毫秒
  duration: number = 0

  // 视频格式
  mimeType: string = '';

  // 视频封面路径
  snapshotPath: string = '';

  // 图片|视频大小
  size: number = 0
  /**
   * 消息类型 为 LOCATION，地理位置名称
   */
 locationName: string = '';
  /**
   * 消息类型 为 LOCATION，地理位置描述信息
   */
  locationDesc: string = '';
  /**
   * 消息类型 为 LOCATION，经度，发送消息时设置
   */
  locationLongitude: number = 0;
  /**
   * 消息类型 为 LOCATION，纬度，发送消息时设置
   */
  locationLatitude: number = 0;

  constructor(messageType: ChatTypeEnum, timeStamp: number = Date.now()) {
    this.messageType = messageType
    this.timeStamp = timeStamp
  }
}