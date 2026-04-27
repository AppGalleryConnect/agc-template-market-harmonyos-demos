/**
 * 消息类型
 */
export enum CMChatElemType {
  /**
   * 未知消息
   */
  CHAT_ELEM_TYPE_NONE = 0,
  /**
   * 文本消息
   */
  CHAT_ELEM_TYPE_TEXT = 1,
  /**
   * 图片消息
   */
  CHAT_ELEM_TYPE_IMAGE = 3,
  /**
   * 语音消息
   */
  CHAT_ELEM_TYPE_SOUND = 4,
  /**
   * 视频消息
   */
  CHAT_ELEM_TYPE_VIDEO = 5,
  /**
   * 地理位置消息
   */
  CHAT_ELEM_TYPE_LOCATION = 7,
  /**
   * 群通知提醒
   */
  CHAT_ELEM_GROUP_TIPS = 9,
}

/**
 * 消息列表中单个消息的数据结构
 */
@ObservedV2
export class CMChatMessage {
  /**
   * 转发的消息对象
   */
  @Trace forwardMessage?: Object;
  /**
   * 消息 ID（消息创建的时候为空，消息发送的时候会生成）
   */
  @Trace msgID: string = '';
  /**
   * 消息的 UTC 时间戳
   */
  @Trace timestamp: number = 0;
  /**
   * 消息发送者
   */
  @Trace sender: string = '';
  /**
   * 消息发送者昵称
   */
  @Trace nickName: string = '';
  /**
   * 消息发送者好友备注
   */
  @Trace friendRemark: string = '';
  /**
   * 消息发送者头像
   * 在 C2C 场景下，陌生人的头像不会实时更新，如需更新陌生人的头像（如在 UI
   * 上点击陌生人头像以展示陌生人信息时）， 请调用 V2TIMManager.h -> GetUsersInfo
   * 接口触发信息的拉取。待拉取成功后，SDK 会更新本地头像信息，即 faceURL 字段的内容。
   * @note 请不要在收到每条消息后都去 GetUsersInfo，会严重影响程序性能。
   */
  @Trace faceURL: string = '';
  /**
   * 消息元素类型
   */
  @Trace elemType: number = CMChatElemType.CHAT_ELEM_TYPE_NONE;
  /**
   * 如果是群组消息，groupID 为会话群组 ID，否则为空
   */
  @Trace groupID?: string;
  /**
   * 如果是单聊消息，userID 为会话用户 ID，否则为空，
   * 假设自己和 userA 聊天，无论是自己发给 userA 的消息还是 userA 发给自己的消息，这里的 userID
   * 均为 userA
   */
  @Trace userID?: string;
  /**
   * 群聊中的消息序列号云端生成，在群里是严格递增且唯一的,
   * 单聊中的序列号是本地生成，不能保证严格递增且唯一。
   */
  @Trace seq: number = 0;
  /**
   * 消息发送者是否是自己
   */
  @Trace isSelf: boolean = false;
  /**
   * 消息类型 为 CHAT_ELEM_TYPE_TEXT，textElem 会存储文本消息内容
   */
  @Trace textElem: string = '';
  /**
   * 消息类型 为 CHAT_ELEM_TYPE_IMAGE，imageElem 会存储图片消息内容 图片路径
   */
  @Trace imageElem: string = '';
  /**
   * 消息类型 为 CHAT_ELEM_TYPE_SOUND，soundElem 会存储语音消息内容
   */
  @Trace soundElem?: Object;
  /**
   * 消息类型 为 CHAT_ELEM_TYPE_LOCATION，地理位置名称
   */
  @Trace locationName: string = '';
  /**
   * 消息类型 为 CHAT_ELEM_TYPE_LOCATION，地理位置描述信息
   */
  @Trace locationDesc: string = '';
  /**
   * 消息类型 为 CHAT_ELEM_TYPE_LOCATION，经度，发送消息时设置
   */
  @Trace locationLongitude: number = 0;
  /**
   * 消息类型 为 CHAT_ELEM_TYPE_LOCATION，纬度，发送消息时设置
   */
  @Trace locationLatitude: number = 0;
  /**
   * 消息类型 为 CHAT_ELEM_GROUP_TIPS，群消息提醒类型
   */
  @Trace groupTipContent: string = '';
  /**
   * 消息类型 为 V2TIM_ELEM_TYPE_VIDEO，videoElem 会存储视频消息内容
   */
  @Trace videoChatSrc: string = '';
  @Trace type: string = '' // 视频类型，如 mp4 mov 等
  @Trace duration: number = 0 // 视频时长，单位 s
  @Trace snapshotPath: string = '' // 视频封面图片路径
  /**
   * 消息类型 为 CHAT_ELEM_TYPE_IMAGE，ChatImage 会存储图片消息内容
   */
  @Trace imageInfo?: ChatImage[];
  /**
   * 消息类型 为 CHAT_ELEM_TYPE_SOUND，soundInfo 会存储语音消息内容
   */
  @Trace soundInfo?: ChatAudio;
}

/**
 * 图片元素
 */
export class ChatImage {
  /**
   * 图片 ID，内部标识，可用于外部缓存 key
   */
  uuid: string = '';
  /**
   * 图片类型，1: 原图，2：缩略图，4：大图
   */
  type: number = 0;
  /**
   * 图片大小（type == 1 有效）
   */
  size: number = 0;
  /**
   * 图片宽度
   */
  width: number = 0;
  /**
   * 图片高度
   */
  height: number = 0;
  /**
   * 图片 url
   */
  url: string = '';
}

/**
 * 语音消息
 */
export class ChatAudio {
  /**
   * 只有发送方才能获取
   */
  path: string = '';
  /**
   * 语音消息内部 ID
   */
  uuid: string = '';
  /**
   * 语音数据大小
   */
  dataSize: number = 0;
  /**
   * 语音长度（秒）
   */
  duration: number = 0;
  /**
   * 获取语音的 URL 下载地址
   */
  url: string = '';
}