import { CMChatGroupMemberInfo } from './CMChatGroupMemberInfo';
import { CMChatMessage } from './CMChatMessage';

/**
 * 会话类型
 */
export enum CMChatConversationType {
  /**
   * 未知
   */
  CHAT_UNKNOWN = 0,
  /**
   * 单聊
   */
  CHAT_C2C = 1,
  /**
   * 群聊
   */
  CHAT_GROUP = 2
}

/**
 * 会话列表中单个会话的数据结构
 */
@ObservedV2
export class CMChatConversation {
  /**
   * 会话类型 0：未知；1：单聊；2：群聊
   */
  @Trace type: number = CMChatConversationType.CHAT_UNKNOWN;
  /**
   * 如果会话类型为 C2C 单聊，userID 会存储对方的用户ID，否则为空字符串
   */
  @Trace userId: string = '';
  /**
   * 如果会话类型为群聊，groupID 会存储当前群的群 ID，否则为空字符串
   */
  @Trace groupID: string = '';
  /**
   * 群成员信息列表
   */
  @Trace memberInfoList: CMChatGroupMemberInfo[] = [];
  /**
   * 群成员头像二维列表
   */
  @Trace memberAvatarList: string[][] = [];
  /**
   * 会话展示名称（群组：群名称 >> 群 ID；C2C：对方好友备注 >> 对方昵称 >> 对方的 userID）
   */
  @Trace showName: string = '';
  /**
   * 会话展示头像（群组：群头像；C2C：对方头像）
   */
  @Trace faceURL: string = '';
  /**
   * 会话唯一 ID，如果是 C2C 单聊，组成方式为 c2c_userID，如果是群聊，组成方式为 group_groupID
   */
  @Trace conversationID: string = '';
  /**
   * 会话未读消息数量,直播群（AVChatRoom）不支持未读计数，默认为 0
   */
  @Trace unreadCount: number = 0;
  /**
   * 消息列表中最后一条消息内容；
   */
  @Trace lastMessage: CMChatMessage = new CMChatMessage();
  /**
   * 是否置顶
   */
  @Trace isPinned: boolean = false;
  /**
   * 是否返回首页
   */
  @Trace isBackTop: boolean = true;
}

/**
 * 会话列表数据结构
 */
@ObservedV2
export class CMChatConversationResult {
  /**
   * 获取下一次分页拉取的游标
   */
  @Trace nextSeq: number = 0;
  /**
   * 会话列表是否已经拉取完毕
   */
  @Trace isFinished: boolean = true;
  /**
   * 获取会话列表
   */
  @Trace conversationList: CMChatConversation[] = [];
}

/**
 * 会话操作结果数据结构
 */
@ObservedV2
export class CMChatConversationOperationResult {
  /**
   * 会话 ID
   */
  @Trace conversationID: string = '';
  /**
   *用户Id
   */
  @Trace userID: string = '';
  /**
   * 返回码
   */
  @Trace resultCode: number = -1;
  /**
   * 返回信息
   */
  @Trace resultInfo: string = '';
}