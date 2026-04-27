/**
 * 添加好友类型
 */
export enum AddFriendTypeEnum {
  /**
   * 手机联系人添加
   */
  CHAT_TYPE_Contact = 1,
  /**
   * 扫一扫
   */
  CHAT_TYPE_Scan = 2,
}

/**
 * 搜索好友的类型
 */
export enum SearchContactTypeEnum {
  /**
   * 昵称
   */
  CHAT_TYPE_NICK_NAME = 1,
  /**
   * 手机号
   */
  CHAT_TYPE_PHONE = 2,
}

/**
 * 单聊设置、好友聊天设置、陌生人聊天设置
 */
export enum PrivateChatSettingEnum {
  /**
   * 单聊聊天设置
   */
  C2C = 1,
  /**
   * 好友聊天设置
   */
  FRIEND = 2,
  /**
   * 陌生人聊天设置
   */
  STRANGER = 3
}

/**
 * 页面布局
 */
export enum PrivateChatSettingSingleEnum {
  /**
   * 头像
   */
  AVATAR = 1,
  /**
   * 标题
   */
  TITLE = 2,
  /**
   * 开关
   */
  SWITCH = 3,
  /**
   * 按钮
   */
  BUTTON = 4,
  /**
   * 区头
   */
  GROUP = 5,
  /**
   * 间隙
   */
  LINE = 6,
}