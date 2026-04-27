import { hilog } from '@kit.PerformanceAnalysisKit';
import { common } from '@kit.AbilityKit';
import { systemDateTime } from '@kit.BasicServicesKit';
import {
  V2TIMAdvancedMsgListener,
  V2TIMConversation,
  V2TIMConversationFilterType,
  V2TIMConversationListener,
  V2TIMConversationListFilter,
  V2TIMCreateGroupInfo,
  V2TIMCreateGroupMemberInfo,
  V2TIMElemType,
  V2TIMFriendAddApplication,
  V2TIMFriendInfo,
  V2TIMFriendRelationType,
  V2TIMFriendshipListener,
  V2TIMFriendType,
  V2TIMGroupAddOpt,
  V2TIMGroupInfo,
  V2TIMGroupMemberFullInfo,
  V2TIMGroupType,
  V2TIMLogLevel,
  V2TIMManager,
  V2TIMMessage,
  V2TIMMessageGetType,
  V2TIMMessageListGetOption,
  V2TIMSDKConfig,
  V2TIMSDKListener,
  V2TIMSetFriendInfoParam,
  V2TIMSetGroupInfoParam,
  V2TIMSetSelfInfoParam,
  V2TIMGroupTipsType,
  V2TIMMessageSearchResult,
  V2TIMKeywordListMatchType,
  V2TIMMessageSearchParam
} from '@tencentcloud/imsdk';
import { CMChatBase } from './CMChatBase';
import {
  CMChatConversation,
  CMChatConversationOperationResult,
  CMChatConversationResult
} from '../viewmodels/CMChatConversation';
import {
  ChatAudio, ChatImage, CMChatMessage,
} from '../viewmodels/CMChatMessage';
import { CMChatConversationListener } from '../listener/CMChatConversationListener';
import { CMChatSDKListener } from '../listener/CMChatSDKListener';
import {
  CMChatGroupMemberInfo,
  CMChatGroupMemberResult,
  CMChatUserInfo,
  GroupMemberOperationResult
} from '../viewmodels/CMChatGroupMemberInfo';
import {
  CMChatFriendCheckResult,
  CMChatFriendInfo,
  CMChatFriendOperationResult,
  CMChatGroupInfo,
} from '../viewmodels/CMChatGroupMemberInfo';
import { CMChatAdvanceMsgListener } from '../listener/CMChatAdvanceMsgListener';
import { MESSAGE_COUNT, CONVERSATION_COUNT } from '../constants/Constants';
import { CMChatTencentUtlis } from '../utlis/CMChatTencentUtlis';
import { CMChatFriendshipListener } from '../listener/CMChatFriendshipListener';

const TAG = 'CMChatTencent';

/**
 * 1、腾讯云SDK群消息中没有群备注和个人在群里面的昵称，两个字段的读写；需要在腾讯云控制台中功能配置->群组配置->群自定义字段中添加
 * 群备注：groupRemark和个人在群里面的昵称：groupMiRemark，两个字段，群类型是public 陌生人社交群；
 *
 * 2、
 */
interface optionDatas {
  reasons: string;
  duration: number;
}

export class CMChatTencent extends CMChatBase {
  private friendshipListener: V2TIMFriendshipListener | undefined;
  private advancedMsgListener: V2TIMAdvancedMsgListener | undefined;
  private conversationListener: V2TIMConversationListener | undefined;
  private cmchatTencentUtlis: CMChatTencentUtlis = new CMChatTencentUtlis();

  //************** Manager im SDK 的初始化、登录、消息收发，建群退群等功能
  /**
   * 初始化 SDK

   * @return true：成功；false：失败
   */
  initSDK(context: common.ApplicationContext, sdkAppID: number): boolean {
    let config: V2TIMSDKConfig = {
      logLevel: V2TIMLogLevel.V2TIM_LOG_DEBUG,
      logListener: undefined
    }
    let result = V2TIMManager.getInstance().initSDK(context, sdkAppID, config);
    hilog.info(0x0000, TAG, '%{public}s', `init sdk  result ` + result);
    return result;
  }

  /**
   * 添加 SDK 监听
   */
  addSDKListener(listener: CMChatSDKListener): void {
    let imListener: V2TIMSDKListener = {
      onKickedOffline: () => {
        hilog.info(0x0000, TAG, '%{public}s', `kicked offline`);
        listener.onKickedOffline?.();
      }
    }
    V2TIMManager.getInstance().addSDKListener(imListener);
  }

  /**
   * 登录
   */
  async login(userID: string, userSig: string): Promise<void> {
    await V2TIMManager.getInstance().login(userID, userSig);
  }

  /**
   * 登出
   */
  async logout(): Promise<void> {
    await V2TIMManager.getInstance().logout();
  }

  /**
   * 获取登录状态
   *
   * 1: 已登录
   * 2: 登录中
   * 3: 无登录
   */
  getLoginStatus(): number {
    let result = V2TIMManager.getInstance().getLoginStatus();
    hilog.info(0x0000, TAG, '%{public}s', `login status result ` + result);
    return result;
  }

  /**
   * 修改个人资料（昵称、头像）
   */
  async setSelfInfo(nickName: string, avatar: string , introDesc : string): Promise<void> {
    let info: V2TIMSetSelfInfoParam = {
      nickName: nickName,
      faceURL: avatar,
      selfSignature : introDesc
    }
    await V2TIMManager.getInstance().setSelfInfo(info);
  }

  //************** ConversationManager 会话的获取，删除，更新的逻辑

  /**
   * 获取会话列表
   */
  async getConversationListByFilter(nextSeq: number, count?: number): Promise<CMChatConversationResult> {
    if (count === undefined) {
      count = CONVERSATION_COUNT;
    }
    let filter: V2TIMConversationListFilter = {
      filterType: V2TIMConversationFilterType.V2TIM_CONVERSATION_FILTER_TYPE_NONE,
      markType: 0,
      hasUnreadCount: true
    }
    let result = await V2TIMManager.getConversationManager().getConversationListByFilter(nextSeq, count, filter);

    let chatResult = new CMChatConversationResult();
    chatResult.nextSeq = result.nextSeq;
    chatResult.isFinished = result.isFinished;
    chatResult.conversationList = await this.parseConversationList(result.conversationList);

    hilog.info(0x0000, TAG, '%{public}s', `get conversation list result ` + JSON.stringify(chatResult));

    return chatResult;
  }

  private async parseConversationList(conversationList: V2TIMConversation[]) {
    let chatConversationList: CMChatConversation[] = [];
    for (let index = 0; index < conversationList.length; index++) {
      const element = conversationList[index];
      let conversationModel = new CMChatConversation();
      conversationModel.type = element.type;
      conversationModel.userId = element.userID;
      conversationModel.groupID = element.groupID;
      conversationModel.showName = element.showName;
      conversationModel.faceURL = element.faceUrl;
      conversationModel.conversationID = element.conversationID;
      conversationModel.unreadCount = element.unreadCount;
      conversationModel.isPinned = element.isPinned;
      conversationModel.lastMessage = await this.parseMessage(element.lastMessage);
      chatConversationList.push(conversationModel);
    }
    return chatConversationList;
  }

  /**
   * 添加会话监听器
   */
  addConversationListener(listener: CMChatConversationListener) {
    this.conversationListener = {
      onNewConversation: async (conversationList: V2TIMConversation[]) => {
        hilog.info(0x0000, TAG, '%{public}s', `on new conversation`);
        let conversations = await this.parseConversationList(conversationList);
        listener.onNewConversation?.(conversations);
      },
      onConversationChanged: async (conversationList: V2TIMConversation[]) => {
        hilog.info(0x0000, TAG, '%{public}s', `on conversation changed`);
        let conversations = await this.parseConversationList(conversationList);
        listener.onConversationChanged?.(conversations);
      }
    }
    V2TIMManager.getConversationManager().addConversationListener(this.conversationListener);
  }

  /**
   * 移除会话监听器
   */
  removeConversationListener() {
    if (this.conversationListener) {
      V2TIMManager.getConversationManager().removeConversationListener(this.conversationListener);
    }
  }

  /**
   * 会话置顶
   */
  async pinConversation(conversationID: string, isPinned: boolean): Promise<void> {
    await V2TIMManager.getConversationManager().pinConversation(conversationID, isPinned);
  }

  /**
   * 删除会话
   */
  async deleteConversation(conversationID: string): Promise<void> {
    await V2TIMManager.getConversationManager().deleteConversation(conversationID);
  }

  /**
   * 删除会话列表
   *
   * @param conversationIDList 会话唯一 ID 列表，C2C 单聊组成方式为: "c2c_userID"：群聊组成方式为: "group_groupID"
   * @param clearMessage 是否删除会话中的消息；设置为 false 时，保留会话消息；设置为 true 时，本地和服务器的消息会一起删除，并且不可恢复
   */
  async deleteConversationList(conversationIDList: string[],
    clearMessage: boolean): Promise<CMChatConversationOperationResult[]> {
    let result = await V2TIMManager.getConversationManager().deleteConversationList(conversationIDList, clearMessage);
    let operationResults: CMChatConversationOperationResult[] = [];
    for (let index = 0; index < result.length; index++) {
      const element = result[index];
      let operationResult = new CMChatConversationOperationResult();
      operationResult.conversationID = element.conversationID;
      operationResult.resultCode = element.resultCode;
      operationResult.resultInfo = element.resultInfo;
      operationResults.push(operationResult);
    }
    hilog.info(0x0000, TAG, '%{public}s',
      `delete conversation list clear=${clearMessage} result= ` + JSON.stringify(operationResults));
    return operationResults;
  }

  /**
   * 清理会话的未读消息计数
   *
   * @param conversationID  会话唯一 ID，C2C 单聊组成方式为: "c2c_userID"；群聊组成方式为: "group_groupID"
   */
  async cleanConversationUnreadMessageCount(conversationID: string, cleanTimestamp: number): Promise<void> {
    return await V2TIMManager.getConversationManager().cleanConversationUnreadMessageCount(conversationID,
      { cleanTimestamp: cleanTimestamp, cleanSequence: 0 });
  }

  //************** FriendshipManager 好友的添加、删除，黑名单的添加、删除等逻辑
  /**
   * 添加好友
   */
  async addFriend(userID: string, nickName: string): Promise<CMChatFriendOperationResult> {
    let application: V2TIMFriendAddApplication = {
      userID: userID,
      friendRemark: nickName,
      addType: 2
    }
    let result = await V2TIMManager.getFriendshipManager().addFriend(application);
    let operationResult = new CMChatFriendOperationResult();
    operationResult.resultCode = result.resultCode;
    operationResult.resultInfo = result.resultInfo;
    operationResult.userID = result.userID;
    hilog.info(0x0000, TAG, '%{public}s', `add friend result ` + JSON.stringify(operationResult));
    return operationResult;
  }

  /**
   * 删除好友
   *
   * @param userIDList 要删除的好友 userID 列表
   *                 - ID 建议一次最大 100
   * 个，因为数量过多可能会导致数据包太大被后台拒绝，后台限制数据包最大为 1M。
   */
  async deleteFromFriendList(userIDList: string[]): Promise<CMChatFriendOperationResult[]> {
    let result = await V2TIMManager.getFriendshipManager()
      .deleteFromFriendList(userIDList, V2TIMFriendType.V2TIM_FRIEND_TYPE_BOTH);
    let operationList: CMChatFriendOperationResult[] = [];
    for (let index = 0; index < result.length; index++) {
      const element = result[index];
      let operationResult = new CMChatFriendOperationResult();
      operationResult.resultCode = element.resultCode;
      operationResult.resultInfo = element.resultInfo;
      operationResult.userID = element.userID;
      operationList.push(operationResult);
    }
    hilog.info(0x0000, TAG, '%{public}s', `delete from friend list result ` + JSON.stringify(operationList));
    return operationList;
  }

  /**
   * 获取好友列表
   */
  async getFriendList(): Promise<CMChatFriendInfo[]> {
    let result = await V2TIMManager.getFriendshipManager().getFriendList();
    let friendList: CMChatFriendInfo[] = [];
    for (let index = 0; index < result.length; index++) {
      const element = result[index];
      let message = this.parseFriendInfo(element);
      friendList.push(message);
    }
    hilog.info(0x0000, TAG, '%{public}s', `get friend list result ` + JSON.stringify(friendList));
    return friendList;
  }

  private parseFriendInfo(element: V2TIMFriendInfo) {
    let friend = new CMChatFriendInfo();
    friend.userId = element.userID;
    friend.nickName = element.userFullInfo.nickName;
    friend.avatarUrl = element.userFullInfo.faceURL;
    friend.friendRemark = element.friendRemark;
    friend.selfSignature = element.userFullInfo.selfSignature;
    return friend;
  }

  /**
   * 监听好友变化
   */
  addFriendshipListener(listener: CMChatFriendshipListener) {
    if (this.friendshipListener !== undefined) {
      this.removeFriendListener()
    }

    this.friendshipListener = {
      onFriendListAdded: (userIDList: V2TIMFriendInfo[]) => {
        if (listener.onFriendListAdded) {
          let friendList: CMChatFriendInfo[] = [];
          userIDList.forEach((item) => {
            let message = this.parseFriendInfo(item);
            friendList.push(message);
          })
          listener.onFriendListAdded(friendList)
        }
      },
      onFriendListDeleted: (userIDList: string[]) => {
        listener.onFriendListDeleted?.(userIDList)
      },
      onBlackListAdded: (infoList: V2TIMFriendInfo[]) => {
        if (listener.onBlackListAdded) {
          let friendList: CMChatFriendInfo[] = [];
          infoList.forEach((item) => {
            let message = this.parseFriendInfo(item);
            friendList.push(message);
          })
          listener.onBlackListAdded(friendList)
        }
      },
      onBlackListDeleted: (userIDList: string[]) => {
        listener.onBlackListDeleted?.(userIDList)
      },
      onFriendInfoChanged: (infoList: V2TIMFriendInfo[]) => {
        if (listener.onFriendInfoChanged) {
          let friendInfoList: CMChatFriendInfo[] = [];
          infoList.forEach((item) => {
            let message = this.parseFriendInfo(item);
            friendInfoList.push(message);
          })
          listener.onFriendInfoChanged(friendInfoList)
        }
      }
    }

    V2TIMManager.getFriendshipManager().addFriendListener(this.friendshipListener);
  }

  /**
   * 1.2 移除关系链监听器
   */
  removeFriendListener() {
    if (this.friendshipListener === undefined) {
      hilog.info(0x0000, TAG, '%{public}s', `friendshipListener is empty`);
      return
    }

    V2TIMManager.getFriendshipManager().removeFriendListener(this.friendshipListener)
    this.friendshipListener = undefined
  }

  /**
   * 获取指定好友资料
   *
   * @param userIDList 好友 userID 列表
   *                 - ID 建议一次最大 100
   * 个，因为数量过多可能会导致数据包太大被后台拒绝，后台限制数据包最大为 1M。
   */
  async getFriendsInfo(userIDList: string[]): Promise<CMChatFriendInfo[]> {
    let result = await V2TIMManager.getFriendshipManager().getFriendsInfo(userIDList);
    let friendList: CMChatFriendInfo[] = [];
    for (let index = 0; index < result.length; index++) {
      const element = result[index];
      let message = this.parseFriendInfo(element.friendInfo);
      friendList.push(message);
    }
    hilog.info(0x0000, TAG, '%{public}s', `get friends info result ` + JSON.stringify(friendList));
    return friendList;
  }

  /**
   * 设置指定好友备注
   */
  async setFriendInfo(userID: string, friendRemark: string): Promise<void> {
    let option: V2TIMSetFriendInfoParam = {
      userID: userID,
      friendRemark: friendRemark
    }
    return await V2TIMManager.getFriendshipManager().setFriendInfo(option)
      .then(() => {
        hilog.info(0x0000, TAG, '%{public}s', `set friend info success`);
      })
      .catch(() => {
        hilog.info(0x0000, TAG, '%{public}s', `set friend info fail`);
      });
  }

  /**
   * 检查指定用户的好友关系
   *
   * @param userIDList 要检查的 userID 列表
   */
  async checkFriend(userIDList: string[]): Promise<CMChatFriendCheckResult[]> {
    let result = await V2TIMManager.getFriendshipManager().checkFriend(userIDList, 2);
    let friendList: CMChatFriendCheckResult[] = [];
    for (let index = 0; index < result.length; index++) {
      const element = result[index];
      let friend = new CMChatFriendCheckResult();
      friend.userId = element.userID;
      friend.resultCode = element.resultCode;
      friend.resultInfo = element.resultInfo;
      friend.isFriend = element.relationType === V2TIMFriendRelationType.V2TIM_FRIEND_RELATION_TYPE_BOTH_WAY;
      friendList.push(friend);
    }
    hilog.info(0x0000, TAG, '%{public}s', `check friend result ` + JSON.stringify(friendList));
    return friendList;
  }

  /**
   * 添加用户到黑名单
   */
  async addToBlackList(userIDList: string[]): Promise<CMChatFriendOperationResult[]> {
    let result = await V2TIMManager.getFriendshipManager().addToBlackList(userIDList);
    let operationList: CMChatFriendOperationResult[] = [];
    for (let index = 0; index < result.length; index++) {
      const element = result[index];
      let operationResult = new CMChatFriendOperationResult();
      operationResult.resultCode = element.resultCode;
      operationResult.resultInfo = element.resultInfo;
      operationResult.userID = element.userID;
      operationList.push(operationResult);
    }
    hilog.info(0x0000, TAG, '%{public}s', `add to blacklist result ` + JSON.stringify(operationList));
    return operationList;
  }

  /**
   * 把用户从黑名单中删除
   */
  async deleteFromBlackList(userIDList: string[]): Promise<CMChatFriendOperationResult[]> {
    let result = await V2TIMManager.getFriendshipManager().deleteFromBlackList(userIDList);
    let operationList: CMChatFriendOperationResult[] = [];
    for (let index = 0; index < result.length; index++) {
      const element = result[index];
      let operationResult = new CMChatFriendOperationResult();
      operationResult.resultCode = element.resultCode;
      operationResult.resultInfo = element.resultInfo;
      operationResult.userID = element.userID;
      operationList.push(operationResult);
    }
    hilog.info(0x0000, TAG, '%{public}s', `add to blacklist result ` + JSON.stringify(operationList));
    return operationList;
  }

  /**
   * 获取黑名单列表
   */
  async getBlackList(): Promise<CMChatFriendInfo[]> {
    let result = await V2TIMManager.getFriendshipManager().getBlackList();
    let blackList: CMChatFriendInfo[] = [];
    for (let index = 0; index < result.length; index++) {
      const element = result[index];
      let info = this.parseFriendInfo(element);
      blackList.push(info);
    }
    hilog.info(0x0000, TAG, '%{public}s', `get black list result ` + JSON.stringify(blackList));
    return blackList;
  }

  //************** MessageManager 高级消息(图片、语音、视频等)的创建、收发逻辑

  /**
   * 监听 - 高级（图片、语音、视频等）消息
   */
  /**
   * 添加高级消息的事件监听器
   */
  addAdvancedMsgListener(listener: CMChatAdvanceMsgListener) {
    this.advancedMsgListener = {
      onRecvNewMessage: async (message: V2TIMMessage) => {
        hilog.info(0x0000, TAG, '%{public}s', `on recv new message`);
        listener.onRecvNewMessage?.(await this.parseMessage(message));
      }
    }
    V2TIMManager.getMessageManager().addAdvancedMsgListener(this.advancedMsgListener);
  }

  removeAdvancedMsgListener() {
    if (this.advancedMsgListener) {
      V2TIMManager.getMessageManager().removeAdvancedMsgListener(this.advancedMsgListener);
    }
  }

  /**
   * 获取历史消息、撤回、删除、标记已读等高级接口
   *
   * 可以设置从云端、本地拉取更老或更新的消息
   */
  async getHistoryMessageList(userID?: string, groupID?: string, count?: number): Promise<CMChatMessage[]> {
    if (count === undefined) {
      count = MESSAGE_COUNT;
    }
    let option: V2TIMMessageListGetOption = {
      getType: V2TIMMessageGetType.V2TIM_GET_CLOUD_OLDER_MSG,
      count: count,
      userID: userID,
      groupID: groupID
    }
    let result = await V2TIMManager.getMessageManager().getHistoryMessageList(option);
    let messageList: CMChatMessage[] = [];
    for (let index = result.length - 1; index >= 0; index--) {
      const element = result[index];
      let message = await this.parseMessage(element);
      messageList.push(message);
    }
    hilog.info(0x0000, TAG, '%{public}s', `get history message list = ` + JSON.stringify(messageList));
    return messageList;
  }

  private async parseMessage(element: V2TIMMessage) {
    let message = new CMChatMessage();
    message.forwardMessage = element;
    message.msgID = element.msgID;
    message.timestamp = element.timestamp;
    message.sender = element.sender;
    message.nickName = element.nickName;
    message.friendRemark = element.friendRemark;
    message.faceURL = element.faceURL;
    message.elemType = element.elemType;
    message.groupID = element.groupID;
    message.userID = element.userID;
    message.seq = element.seq;
    message.isSelf = element.isSelf;
    message.textElem = element.textElem?.text ?? '';
    message.imageElem = element.imageElem?.path ?? '';
    message.soundElem = element.soundElem;
    this.parseLocationMessage(message, element);
    this.parseVideoMessage(message, element);
    message.imageInfo = this.parseImageInfo(element)
    message.soundInfo = await this.parseSoundInfo(element)
    message.groupTipContent = this.setGroupTip(element);
    return message;
  }

  private async parseLocationMessage(message: CMChatMessage, element: V2TIMMessage) {
    let locationDesc = element.locationElem?.desc ?? '';
    let locationDescList = locationDesc.split('|LOCATION|');
    message.locationName = locationDescList[0] ?? '';
    message.locationDesc = locationDescList[1] ?? '';
    message.locationLongitude = element.locationElem?.longitude ?? 0;
    message.locationLatitude = element.locationElem?.latitude ?? 0;
  }

  private async parseVideoMessage(message: CMChatMessage, element: V2TIMMessage) {
    message.videoChatSrc = await element.videoElem?.getVideoUrl() ?? '';
    message.type = element.videoElem?.videoType ?? '';
    message.duration = element.videoElem?.videoSize ?? 0;
    message.snapshotPath = await element.videoElem?.getSnapshotUrl() ?? '';
  }

  private setGroupTip(element: V2TIMMessage) {
    if (element.elemType === V2TIMElemType.V2TIM_ELEM_TYPE_GROUP_TIPS) {
      switch (element.groupTipsElem?.type) {
        case V2TIMGroupTipsType.V2TIM_GROUP_TIPS_TYPE_INVITE: {
          // 被邀请入群（opMember 邀请 memberList 入群)
          const addMember = new Set(element.groupTipsElem?.memberList.map(item => item.nickName));
          return element.groupTipsElem?.opMember.nickName + ' 邀请 ' + Array.from(addMember).join('、') + ' 入群'
        }
        case V2TIMGroupTipsType.V2TIM_GROUP_TIPS_TYPE_QUIT: {
          // 退出群 (opMember 退出群组)
          return element.groupTipsElem?.opMember.nickName + ' 退出群组'
        }
        case V2TIMGroupTipsType.V2TIM_GROUP_TIPS_TYPE_KICKED: {
          // 踢出群 (opMember 把 memberList 踢出群组)
          const removeMember = new Set(element.groupTipsElem?.memberList.map(item => item.nickName));
          return element.groupTipsElem?.opMember.nickName + ' 把 ' + Array.from(removeMember).join('、') + ' 踢出群组'
        }
        case V2TIMGroupTipsType.V2TIM_GROUP_TIPS_TYPE_SET_ADMIN: {
          // 设置管理员 (opMember 把 memberList 设置为管理员)
          const setAdminMember = new Set(element.groupTipsElem?.memberList.map(item => item.nickName));
          return element.groupTipsElem?.opMember.nickName + ' 把 ' + Array.from(setAdminMember).join('、') + ' 设置为管理员'
        }
        case V2TIMGroupTipsType.V2TIM_GROUP_TIPS_TYPE_CANCEL_ADMIN: {
          // 取消管理员 (opMember 取消 memberList 管理员身份)
          const cancelAdminMember = new Set(element.groupTipsElem?.memberList.map(item => item.nickName));
          return element.groupTipsElem?.opMember.nickName + ' 取消 ' + Array.from(cancelAdminMember).join('、') +
            ' 管理员身份'
        }
        default: {
          return '群资料变更'
        }
      }
    } else {
      return '';
    }
  }

  /**
   * 图片数据解析，排序返回
   */
  private parseImageInfo(element: V2TIMMessage): ChatImage[] {
    if (element.imageElem === undefined) {
      return [];
    }

    let imgInfoList: ChatImage[] = []
    element.imageElem?.imageList.forEach((item) => {
      const tmpImgInfo = new ChatImage()
      tmpImgInfo.uuid = item.uuid
      tmpImgInfo.type = item.type
      tmpImgInfo.size = item.size
      tmpImgInfo.width = item.width
      tmpImgInfo.height = item.height
      tmpImgInfo.url = item.url
      imgInfoList.push(tmpImgInfo)
    })
    imgInfoList.sort((a: ChatImage, b: ChatImage) => {
      if (a.type === 2) {
        return -1
      }

      if (b.type === 2) {
        return 1
      }

      // 倒叙，大图在前，原图在后
      return b.type - a.type
    })

    return imgInfoList
  }

  /**
   * 图片数据解析，排序返回
   */
  private async parseSoundInfo(element: V2TIMMessage): Promise<ChatAudio | undefined> {
    if (element.elemType !== V2TIMElemType.V2TIM_ELEM_TYPE_SOUND || element.soundElem === undefined) {
      return undefined;
    }

    const audioInfo: ChatAudio = new ChatAudio()
    audioInfo.path = element.soundElem!.path
    audioInfo.uuid = element.soundElem!.uuid
    audioInfo.dataSize = element.soundElem!.dataSize
    audioInfo.duration = element.soundElem!.duration
    audioInfo.url = await element.soundElem!.getUrl()

    return audioInfo
  }

  /**
   * 创建文本消息
   */
  async createTextMessage(text: string, userId?: string, groupId?: string): Promise<CMChatMessage> {
    let customMessage = V2TIMManager.getMessageManager().createTextMessage(text);
    let result = V2TIMManager.getMessageManager().sendMessage(customMessage,
      { receiver: userId, groupID: groupId, priority: 2 });
    let messageResult = await result.promise;
    hilog.info(0x0000, TAG, '%{public}s',
      `create send custom message msgID= ` + result.msgID + '； message=' + JSON.stringify(messageResult));
    let message = this.parseMessage(messageResult);
    return message;
  }

  /**
   * 创建地理位置消息
   */
  async createLocationMessage(name: string, desc: string, longitude: number, latitude: number, userId?: string,
    groupId?: string): Promise<CMChatMessage> {
    let locationDesc = name + '|LOCATION|' + desc;
    let locationMessage = V2TIMManager.getMessageManager().createLocationMessage(locationDesc, longitude, latitude);
    let result = V2TIMManager.getMessageManager().sendMessage(locationMessage,
      { receiver: userId, groupID: groupId, priority: 2 });
    let messageResult = await result.promise;
    hilog.info(0x0000, TAG, '%{public}s',
      `create send custom message msgID= ` + result.msgID + '； message=' + JSON.stringify(messageResult));
    let message = this.parseMessage(messageResult);
    return message;
  }

  /**
   * 创建图片消息
   */
  async createImageMessage(imagePath: string, userId?: string, groupId?: string): Promise<CMChatMessage> {
    let imageMessage = V2TIMManager.getMessageManager().createImageMessage(imagePath);
    let result = V2TIMManager.getMessageManager().sendMessage(imageMessage,
      { receiver: userId, groupID: groupId, priority: 2 });
    let messageResult = await result.promise;
    hilog.info(0x0000, TAG, '%{public}s',
      `create send image message msgID= ` + result.msgID + '； message=' + JSON.stringify(messageResult));
    let message = this.parseMessage(messageResult);
    return message;
  }

  /**
   * 创建语音消息
   */
  async createSoundMessage(soundPath: string, duration: number, userId?: string,
    groupId?: string): Promise<CMChatMessage> {
    let soundMessage = V2TIMManager.getMessageManager().createSoundMessage(soundPath, duration)
    let result = V2TIMManager.getMessageManager().sendMessage(soundMessage,
      { receiver: userId, groupID: groupId, priority: 2 });
    let messageResult = await result.promise;
    hilog.info(0x0000, TAG, '%{public}s',
      `create send sound message msgID= ` + result.msgID + '； message=' + JSON.stringify(messageResult));
    let message = this.parseMessage(messageResult);
    return message;
  }

  /**
   * 创建转发消息
   */
  async createForwardMessage(forwardMsg?: Object, userId?: string,
    groupId?: string): Promise<CMChatMessage | undefined> {
    if (forwardMsg) {
      try {
        let targetMsg = forwardMsg as V2TIMMessage;
        let forward = V2TIMManager.getMessageManager().createForwardMessage(targetMsg);
        let result = V2TIMManager.getMessageManager().sendMessage(forward,
          { receiver: userId, groupID: groupId, priority: 2 });
        let messageResult = await result.promise;
        hilog.info(0x0000, TAG, '%{public}s',
          `create send sound message msgID= ` + result.msgID + '； message=' + JSON.stringify(messageResult));
        let forwardResult = this.parseMessage(messageResult);
        return forwardResult;
      } catch (err) {
        return undefined;
      }
    }
    return undefined;
  }

  // ************** GroupManager 群组高级接口，里面包含了群组的高级功能，比如群成员邀请、非群成员申请进群等操作接口。
  /**
   * 创建自定义群组
   *
   * @param info       自定义群组信息
   * @param memberList 指定初始的群成员
   *
   * @note
   * - 后台限制邀请的群成员个数不能超过 20
   */
  async createGroup(memberList: CMChatGroupMemberInfo[]): Promise<string> {
    let groupName = '';
    let groupMember: V2TIMCreateGroupMemberInfo[] = [];
    for (let index = 0; index < memberList.length; index++) {
      const element = memberList[index];
      if (index <= 3) {
        if (index > 0) {
          groupName = groupName + ' ';
        }
        if (index > 2) {
          groupName = groupName + `...`;
        } else {
          groupName = groupName + element.nickName;
        }
      }

      let member: V2TIMCreateGroupMemberInfo = {
        userID: element.userId,
        role: element.role
      };

      groupMember.push(member);
    }

    let groupInfo: V2TIMCreateGroupInfo = {
      groupType: V2TIMGroupType.Public,
      groupID: systemDateTime.getTime(true).toString(),
      groupName: groupName,
      groupAddOpt: V2TIMGroupAddOpt.V2TIM_GROUP_ADD_ANY,
      groupApproveOpt: V2TIMGroupAddOpt.V2TIM_GROUP_ADD_ANY
    };

    let result = await V2TIMManager.getGroupManager().createGroup(groupInfo, groupMember);
    hilog.info(0x0000, TAG, '%{public}s', `create group = ` + result);
    return result;
  }

  /**
   * 获取当前用户已经加入的群列表
   *
   * - 该接口有频限检测，SDK 限制调用频率为1 秒 10 次，超过限制后会报
   */
  async getJoinedGroupList(): Promise<CMChatGroupInfo[]> {
    let result = await V2TIMManager.getGroupManager().getJoinedGroupList();
    let groupList: CMChatGroupInfo[] = [];
    for (let index = 0; index < result.length; index++) {
      const element = result[index];
      let group = this.parseGroupInfo(element);
      groupList.push(group);
    }
    hilog.info(0x0000, TAG, '%{public}s', `get joined group list = ` + JSON.stringify(groupList));
    return groupList;
  }

  private parseGroupInfo(element: V2TIMGroupInfo) {
    let groupInfo = new CMChatGroupInfo();
    let groupRemarkvalue = element.customInfo.get('groupRemark')
    let groupMiRemarkvalue = element.customInfo.get('groupMiRemark')
    groupInfo.groupId = element.groupID;
    groupInfo.groupName = element.groupName;
    groupInfo.notification = element.notification;
    groupInfo.introduction = element.introduction;
    groupInfo.faceURL = element.faceURL;
    groupInfo.owner = element.owner;
    groupInfo.createTime = element.createTime;
    groupInfo.role = element.role;
    if (groupRemarkvalue) {
      groupInfo.groupRemark = CMChatTencentUtlis.arrayBufferToStr(groupRemarkvalue);
    }
    if (groupMiRemarkvalue) {
      groupInfo.groupMiRemark = CMChatTencentUtlis.arrayBufferToStr(groupMiRemarkvalue);
    }
    return groupInfo;
  }

  /**
   * 获取群成员列表
   */
  async getGroupMemberList(groupID: string, filter: number, nextSeq: number): Promise<CMChatGroupMemberResult> {
    let result = await V2TIMManager.getGroupManager().getGroupMemberList(groupID, filter, nextSeq);
    let groupMemberResult = new CMChatGroupMemberResult();
    groupMemberResult.nextSequence = result.nextSequence;
    for (let index = 0; index < result.memberInfoList.length; index++) {
      const element = result.memberInfoList[index];
      let memberInfo = this.parseGroupMemberInfo(element);
      groupMemberResult.memberInfoList.push(memberInfo);
    }
    hilog.info(0x0000, TAG, '%{public}s', `get group member list = ` + JSON.stringify(groupMemberResult));
    return groupMemberResult;
  }

  /**
   * 创建视频图片接口请求
   * @param element
   * @returns
   */
  async createVideoMessage(videoFilePath: string, type: string, duration: number,
    snapshotPath: string, userId?: string, groupId?: string): Promise<CMChatMessage> {
    let videoMessage =
      V2TIMManager.getMessageManager().createVideoMessage(videoFilePath, type, duration, snapshotPath);
    let result = V2TIMManager.getMessageManager().sendMessage(videoMessage,
      { receiver: userId, groupID: groupId, priority: 2 });
    let videoResult = await result.promise;
    hilog.info(0x0000, TAG, '%{public}s',
      `create send custom message msgID= ` + result.msgID + '； message=' + JSON.stringify(videoResult));
    let message = this.parseMessage(videoResult);
    return message;
  }

  private parseGroupMemberInfo(element: V2TIMGroupMemberFullInfo) {
    let memberInfo = new CMChatGroupMemberInfo();
    memberInfo.userId = element.userID;
    memberInfo.nickName = element.nickName;
    memberInfo.avatarUrl = element.faceURL;
    memberInfo.role = element.role;
    return memberInfo;
  }

  /**
   * 拉取群资料
   *
   * @param groupIDList 群组 ID 列表
   */
  async getGroupsInfo(groupIDList: string[]): Promise<CMChatGroupInfo[]> {
    let result = await V2TIMManager.getGroupManager().getGroupsInfo(groupIDList);
    let groupList: CMChatGroupInfo[] = [];
    for (let index = 0; index < result.length; index++) {
      const element = result[index];
      let group = this.parseGroupInfo(element.info);
      groupList.push(group);
    }
    hilog.info(0x0000, TAG, '%{public}s', `get groups info result = ` + JSON.stringify(groupList));
    return groupList;
  }

  /**
   * 修改群资料
   * @param info
   * @returns
   */
  async setGroupInfo(info: CMChatGroupInfo): Promise<void> {
    this.cmchatTencentUtlis.map.set('groupRemark', CMChatTencentUtlis.strToArrayBuffer(info.groupRemark))
    this.cmchatTencentUtlis.map.set('groupMiRemark', CMChatTencentUtlis.strToArrayBuffer(info.groupMiRemark))
    let infoGroupInfoParam: V2TIMSetGroupInfoParam = {
      groupID: info.groupId,
      faceURL: info.faceURL,
      groupName: info.groupName,
      notification: info.notification,
      introduction: info.introduction,
      customInfo: this.cmchatTencentUtlis.map
    }
    await V2TIMManager.getGroupManager().setGroupInfo(infoGroupInfoParam);
  }

  /**
   * 退出群聊
   */
  async quitGroup(groupID: string): Promise<void> {
    await V2TIMManager.getInstance().quitGroup(groupID)
  }

  /**
   * 解散群聊
   */
  async dismissGroup(groupID: string): Promise<void> {
    await V2TIMManager.getInstance().dismissGroup(groupID)
  }

  /**
   * 邀请他人入群
   */
  async inviteUserToGroup(groupID: string, userList: string[]): Promise<GroupMemberOperationResult[]> {
    let inviteUserToGroup = await V2TIMManager.getGroupManager().inviteUserToGroup(groupID, userList)
    let groupMemberOperationResult: GroupMemberOperationResult[] = []
    for (let i = 0; i < inviteUserToGroup.length; i++) {
      groupMemberOperationResult[i].userID = inviteUserToGroup[i].userID;
      groupMemberOperationResult[i].result = inviteUserToGroup[i].result
    }
    return groupMemberOperationResult;
  }

  /**
   * 群聊踢人
   */
  async kickGroupMember(groupID: string, memberList: string[],
    reason: string,
    duration: number): Promise<GroupMemberOperationResult[]> {
    let option: optionDatas = {
      reasons: reason,
      duration: duration,
    }
    let inviteUserToGroup = await V2TIMManager.getGroupManager().kickGroupMember(groupID, memberList, option)
    let groupMemberOperationResult: GroupMemberOperationResult[] = []
    for (let i = 0; i < inviteUserToGroup.length; i++) {
      groupMemberOperationResult[i].userID = inviteUserToGroup[i].userID;
      groupMemberOperationResult[i].result = inviteUserToGroup[i].result
    }
    return groupMemberOperationResult;
  }

  /**
   * 设置管理员和取消管理员接口
   */
  async setGroupMemberRole(groupID: string, userID: string, role: number): Promise<void> {
    await V2TIMManager.getGroupManager().setGroupMemberRole(groupID, userID, role)
  }

  /**
   * 搜索聊天记录
   * @param info
   * @returns
   */
  async searchMessage(searchKey: string, userId?: string,
    groupId?: string, startDate?: number): Promise<CMChatMessage[]> {
    let allId: string[] = [];
    if (!userId && !groupId) {
      let friendList: CMChatFriendInfo[] = await this.getFriendList();
      let groupList: CMChatGroupInfo[] = await this.getJoinedGroupList();
      friendList.forEach((item) => {
        allId.push('c2c_' + item.userId);
      })
      groupList.forEach((item) => {
        allId.push('group_' + item.groupId);
      })
    }
    let searchParam: V2TIMMessageSearchParam = {
      keywordList: searchKey?.length > 0 ? [searchKey] : [],
      senderUserIDList: [],
      conversationID: userId ? ('c2c_' + userId) : groupId ? ('group_' + groupId) : '',
      pageIndex: 0,
      pageSize: MESSAGE_COUNT,
      keywordListMatchType: V2TIMKeywordListMatchType.V2TIM_KEYWORD_LIST_MATCH_TYPE_OR,
      messageTypeList: [V2TIMElemType.V2TIM_ELEM_TYPE_TEXT, V2TIMElemType.V2TIM_ELEM_TYPE_IMAGE,
        V2TIMElemType.V2TIM_ELEM_TYPE_SOUND,
        V2TIMElemType.V2TIM_ELEM_TYPE_VIDEO, V2TIMElemType.V2TIM_ELEM_TYPE_LOCATION],
      searchTimePosition: startDate ? ((startDate / 1000) + 24 * 60 * 60 - 1) : 0,
      searchTimePeriod: startDate ? (24 * 60 * 60 - 1) : 0,
      searchCount: 1000,
      searchCursor: '',
    };
    let cmChatSearchResultList: CMChatMessage[] = [];
    if (userId || groupId) {
      let curList = await this.searchMessageWithParam(searchParam);
      cmChatSearchResultList.push(...curList);
    } else {
      for (let index = 0; index < allId.length; index++) {
        searchParam.conversationID = allId[index];
        let curList = await this.searchMessageWithParam(searchParam);
        cmChatSearchResultList.push(...curList);
      }
    }
    return cmChatSearchResultList;
  }

  private async searchMessageWithParam(searchParam: V2TIMMessageSearchParam): Promise<CMChatMessage[]> {
    let cmChatSearchResultList: CMChatMessage[] = [];
    let searchResultList: V2TIMMessageSearchResult =
      await V2TIMManager.getMessageManager().searchCloudMessages(searchParam);
    hilog.info(0x0000, TAG, '%{public}s', `search cloud messages result = ` + JSON.stringify(searchResultList));
    for (let index = 0; index < searchResultList.messageSearchResultItems?.length; index++) {
      let item = searchResultList.messageSearchResultItems[index];
      for (let index_ = 0; index_ < item.messageList?.length; index_++) {
        let item_ = item.messageList[index_];
        let parsedItem = await this.parseMessage(item_);
        cmChatSearchResultList.push(parsedItem);
      }
    }
    return cmChatSearchResultList;
  }

  /**
   * 搜索好友
   * @param info
   * @returns
   */
  async searchContact(searchKey: string): Promise<CMChatFriendInfo[]> {
    let friendList: CMChatFriendInfo[] = await this.getFriendList();
    friendList = friendList.filter((item) => {
      return item.nickName.toLowerCase().includes(searchKey.toLowerCase())
    })
    return friendList;
  }

  /**
   * 删除消息
   */
  async delMessages(messages: object[]) {
    await V2TIMManager.getMessageManager().deleteMessages(messages as V2TIMMessage[])
  }
  /**
   * 获取用户资料
   */
  async getUsersInfo(userIDList: string[]): Promise<CMChatUserInfo[]> {
    let cMChatUserInfoList = await V2TIMManager.getInstance().getUsersInfo(userIDList)
    let groupMemberOperationResult: CMChatUserInfo[] = []
    for (let i = 0; i < cMChatUserInfoList.length; i++) {
      groupMemberOperationResult[i].userId = cMChatUserInfoList[i].userID;
      groupMemberOperationResult[i].nickName = cMChatUserInfoList[i].nickName
      groupMemberOperationResult[i].avatarUrl = cMChatUserInfoList[i].faceURL
      groupMemberOperationResult[i].selfSignature = cMChatUserInfoList[i].selfSignature
    }
    return groupMemberOperationResult
  }
}