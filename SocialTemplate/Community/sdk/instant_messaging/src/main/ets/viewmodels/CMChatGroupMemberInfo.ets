/**
 * 群成员角色
 */
export enum CMChatGroupMemberRole {
  /**
   * 未定义（没有获取该字段）
   */
  CHAT_GROUP_MEMBER_UNDEFINED = 0,
  /**
   * 群成员
   */
  CHAT_GROUP_MEMBER_ROLE_MEMBER = 200,
  /**
   * 群管理员
   */
  CHAT_GROUP_MEMBER_ROLE_ADMIN = 300,
  /**
   * 群主
   */
  CHAT_GROUP_MEMBER_ROLE_SUPER = 400
}

/**
 * 用户基本资料
 */
@ObservedV2
export class CMChatUserInfo {
  /**
   * 用户 ID
   */
  @Trace userId: string = '';
  /**
   * 用户昵称
   */
  @Trace nickName: string = '';
  /**
   * 用户头像
   */
  @Trace avatarUrl: string = '';
  /**
   * 用户签名
   */
  @Trace selfSignature: string = '';
}

/**
 * 群成员详细资料
 */
@ObservedV2
export class CMChatGroupMemberInfo extends CMChatUserInfo {
  /**
   * 群成员角色,修改群成员角色请调用 SetGroupMemberRole 接口
   *
   * 0 未定义（没有获取该字段）
   * 200 群成员
   * 300 群管理员
   * 400 群主
   */
  @Trace role: number = 0;
}

@ObservedV2
export class CMChatGroupInfo {
  /**
   * 群组 ID
   * 自定义群组 ID 必须为可打印 ASCII 字符（0x20-0x7e），最长 48 个字节
   */
  @Trace groupId: string = '';
  /**
   * 群名称
   * 群名称最长30字节
   */
  @Trace groupName: string = '';
  /**
   * 群公告
   * 群公告最长300字节
   */
  @Trace notification: string = '';
  /**
   * 群简介
   * 群简介最长240字节
   */
  @Trace introduction: string = '';
  /**
   * 群头像
   * 群头像 URL 最长100字节
   */
  @Trace faceURL: string = '';
  /**
   * 群创建人/管理员
   */
  @Trace owner: string = '';
  /**
   * 创建群组的 UTC 时间戳
   */
  @Trace createTime: number = 0;
  /**
   * 当前用户在此群组中的角色，切换角色请调用 setGroupMemberRole 接口
   */
  @Trace role: number = 0;
  /**
   * 群成员信息列表
   */
  @Trace memberInfoList: CMChatGroupMemberInfo[] = [];
  /**
   * 群备注
   */
  @Trace groupRemark: string = ''
  /**
   * 群中自己的备注
   */
  @Trace groupMiRemark: string = ''
  /**
   * 群成员头像二维列表
   */
  @Trace memberAvatarList: string[][] = [];
}

/**
 * 好友资料
 */
@ObservedV2
export class CMChatFriendInfo extends CMChatUserInfo {
  /**
   * 好友备注
   * 备注长度最长不得超过 96 个字节;
   */
  @Trace friendRemark: string = '';
  /**
   * 用户签名
   */
  @Trace selfSignature: string = '';
}

/**
 * 获取群成员信息的结果
 */
@ObservedV2
export class CMChatGroupMemberResult {
  /**
   * 获取分页拉取的 seq。如果为 0 表示拉取结束
   */
  @Trace nextSequence: number = 0;
  /**
   * 群成员信息列表
   */
  @Trace memberInfoList: CMChatGroupMemberInfo[] = [];
}

/**
 * 好友关系链检查结果
 */
@ObservedV2
export class CMChatFriendCheckResult extends CMChatUserInfo {
  /**
   * 返回码
   */
  @Trace resultCode: number = 0;
  /**
   * 返回信息
   */
  @Trace resultInfo: string = '';
  /**
   * 检查结果
   */
  @Trace isFriend: boolean = false;
}

/**
 * 好友操作结果（添加、删除、加黑名单、添加分组等）
 */
@ObservedV2
export class CMChatFriendOperationResult {
  /**
   * 返回码
   */
  @Trace resultCode: number = 0;
  /**
   * 返回信息
   */
  @Trace resultInfo: string = '';
  /**
   * 用户Id
   */
  @Trace userID: string = '';
}

@ObservedV2
export class CreateGroupMemberInfo {
  /**
   * 被操作成员
   */
  @Trace userID: string = '';
  /**
   * 群成员类型，需要注意一下事项：
   * 1. role 不设置或则设置为 V2TIM_GROUP_MEMBER_UNDEFINED，进群后默认为群成员。
   * 2. 工作群（Work）不支持设置 role 为管理员。
   * 3. 所有的群都不支持设置 role 为群主。
   */
  @Trace role?: number = 0;
}

@ObservedV2
export class GroupMemberOperationResult {
  /**
   * 被操作成员
   */
  @Trace userID: string = '';
  /**
   * 返回状态
   */
  @Trace result: number = 0;
}

export class GroupMemberResult {
  /**
   * 操作失败
   */
  V2TIM_GROUP_MEMBER_RESULT_FAIL = 0
  /**
   * 操作成功
   */
  V2TIM_GROUP_MEMBER_RESULT_SUCC = 1
  /**
   * 无效操作，加群时已经是群成员，移除群组时不在群内
   */
  V2TIM_GROUP_MEMBER_RESULT_INVALID = 2
  /**
   * 等待处理，邀请入群时等待审批
   */
  V2TIM_GROUP_MEMBER_RESULT_PENDING = 3
  /**
   * 操作失败，创建群指定初始群成员列表或邀请入群时，被邀请者加入的群总数超限
   */
  V2TIM_GROUP_MEMBER_RESULT_OVERLIMIT = 4
}