import { PersistenceV2 } from '@kit.ArkUI';
import { ChatContentSingleModel, ChatConversationType } from 'chat_window';
import { GlobalContext, UserInfo } from 'common';
import {
  CMChatGroupInfo, CMChatFactory
} from 'instant_messaging';
import { phoneRouterControl } from 'oh_router';
import { MessageUtil } from '../utils/MessageUtil';
import { MessageGroupInfoModel } from './MessageGroupInfoModel';
import { SearchContactModel } from './SearchContactModel';

@ObservedV2
export class ForwardChatModel {
  @Trace pageTitle: string = '选择聊天';
  @Trace chatModel: ChatContentSingleModel = new ChatContentSingleModel();
  @Trace groupList: MessageGroupInfoModel[] = [];
  @Trace contactList: SearchContactModel[] = [];
  scroller: ListScroller = new ListScroller();
  @Trace isShowBottom: boolean = false;
  @Trace userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;

  constructor() {
  }

  init() {
    this.getJoinedGroupList(this.chatModel);
    this.getFriendListForwardChat(this.chatModel);
  }

  selectGroupOrContact(groupId?: string, userId?: string) {
    this.createForwardMessage(userId, groupId);
  }

  /**
   * 创建转发消息
   */
  async createForwardMessage(userId?: string, groupId?: string) {
    let result = await CMChatFactory.instance.createForwardMessage(this.chatModel.forwardMessage, userId, groupId);
    if (result && result.msgID.length > 0) {
      GlobalContext.getUIContext().getPromptAction().showToast({ message: '转发成功' });
      phoneRouterControl.popPage()
    } else {
      GlobalContext.getUIContext().getPromptAction().showToast({ message: '转发失败' });
    }
  }

  /**
   * 获取好友列表
   */
  async getFriendListForwardChat(valueVM: ChatContentSingleModel) {
    let result = await CMChatFactory.instance.getFriendList();
    this.contactList = [];
    for (let index = 0; index < result.length; index++) {
      const element = result[index];
      if (valueVM.conversationType === ChatConversationType.CHAT_C2C && valueVM.userId === element.userId) {
        continue;
      }
      let contactVM = new SearchContactModel();
      contactVM.userId = element.userId;
      if (element.friendRemark !== undefined && element.friendRemark.length > 0) {
        contactVM.nickName = element.friendRemark;
      } else {
        contactVM.nickName = element.nickName;
      }
      contactVM.normalArr.push(contactVM.nickName);
      contactVM.avatarUrl = element.avatarUrl;
      this.contactList.push(contactVM);
    }

    this.parseGroupFriend();
  }

  /**
   * 获取当前用户已经加入的群列表
   */
  async getJoinedGroupList(valueVM: ChatContentSingleModel) {
    let result = await CMChatFactory.instance.getJoinedGroupList();
    this.groupList = [];
    for (let index = 0; index < result.length; index++) {
      const element = result[index];
      if (valueVM.conversationType === ChatConversationType.CHAT_GROUP && valueVM.groupId === element.groupId) {
        continue;
      }
      await this.getGroupMemberList(element);
      let groupInfo = new MessageGroupInfoModel();
      groupInfo.groupId = element.groupId;
      groupInfo.groupName = element.groupName;
      groupInfo.notification = element.notification;
      groupInfo.introduction = element.introduction;
      groupInfo.faceURL = element.faceURL;
      groupInfo.owner = element.owner;
      groupInfo.createTime = element.createTime;
      groupInfo.role = element.role;
      groupInfo.memberInfoList = element.memberInfoList;
      groupInfo.memberAvatarList = MessageUtil.parseGroupAvatar(element.memberInfoList);
      this.groupList.push(groupInfo);
    }
    this.parseGroupFriend();
  }

  /**
   * 比较群成员中有几个好友
   */
  private parseGroupFriend() {
    if (this.groupList.length === 0) {
      return;
    }

    if (this.contactList.length === 0) {
      return
    }

    this.groupList.forEach((groupInfo: MessageGroupInfoModel) => {
      const memberIds = new Set(groupInfo.memberInfoList.map(item => item.userId));
      const friendIds = new Set(this.contactList.map(item => item.userId));
      groupInfo.count = 0;
      for (let id of memberIds) {
        if (friendIds.has(id)) {
          groupInfo.count++;
        }
      }
    })
  }

  /**
   * 获取群成员列表
   */
  async getGroupMemberList(groupInfoVM: CMChatGroupInfo) {
    let result = await CMChatFactory.instance.getGroupMemberList(groupInfoVM.groupId, 0, 0);
    groupInfoVM.memberInfoList = result.memberInfoList;
  }
}