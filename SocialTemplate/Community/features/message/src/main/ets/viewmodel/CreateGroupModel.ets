import { PersistenceV2 } from '@kit.ArkUI';
import { UserInfo } from 'common';
import {
  CMChatGroupInfo,
  CMChatFactory,
  CMChatGroupMemberInfo,
  CMChatGroupMemberRole
} from 'instant_messaging';
import { MessageUtil } from '../utils/MessageUtil';
import { ChatJumpManager } from '../utils/ChatJumpManager';
import { MessageGroupInfoModel } from './MessageGroupInfoModel';
import { MessageContactModel } from './MessageContactModel';

@ObservedV2
export class CreateGroupModel {
  @Trace pageTitle: string = '创建群聊';
  @Trace groupList: MessageGroupInfoModel[] = [];
  scroller: ListScroller = new ListScroller();
  @Trace selectContactList: MessageContactModel[] = [];
  @Trace contactList: MessageContactModel[] = [];
  @Trace isShowBottom: boolean = false;
  @Trace userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;

  constructor() {
    this.getJoinedGroupList();
    this.getFriendListCreateGroup();
  }

  selectContactCreateGroup(contactVM: MessageContactModel) {
    let index = this.selectContactList.indexOf(contactVM);
    if (contactVM.isSelect) {
      if (index === -1) {
        this.selectContactList.push(contactVM);
      }
    } else {
      if (index !== -1) {
        this.selectContactList.splice(index, 1);
      }
    }

    if (this.selectContactList.length >= 2) {
      this.isShowBottom = true;
    } else {
      this.isShowBottom = false;
    }
  }

  /**
   * 创建群，开始群聊
   */
  async startGroupChat() {
    let menberInfoList: CMChatGroupMemberInfo[] = [];
    let memberInfoOwner = new CMChatGroupMemberInfo();
    memberInfoOwner.role = CMChatGroupMemberRole.CHAT_GROUP_MEMBER_ROLE_SUPER;
    memberInfoOwner.userId = this.userInfo.id;
    memberInfoOwner.nickName = this.userInfo.nickName;
    menberInfoList.push(memberInfoOwner);

    for (let index = 0; index < this.selectContactList.length; index++) {
      const element = this.selectContactList[index];
      let memberInfoOther = new CMChatGroupMemberInfo();
      memberInfoOther.role = CMChatGroupMemberRole.CHAT_GROUP_MEMBER_ROLE_MEMBER;
      memberInfoOther.userId = element.userId;
      memberInfoOther.nickName = element.nickName;
      menberInfoList.push(memberInfoOther);
    }

    let result = await CMChatFactory.instance.createGroup(menberInfoList);

    if (result.length > 0) {
      ChatJumpManager.gotoGroupChatPage(result);
    }
  }

  async getFriendListCreateGroup() {
    let contactResult = await CMChatFactory.instance.getFriendList();
    this.contactList = [];
    for (let index = 0; index < contactResult.length; index++) {
      const element = contactResult[index];
      let contactModel = new MessageContactModel();
      contactModel.userId = element.userId;
      contactModel.nickName = element.nickName;
      contactModel.avatarUrl = element.avatarUrl;
      this.contactList.push(contactModel);
    }

    this.parseGroupFriend();
  }

  async getJoinedGroupList() {
    let result = await CMChatFactory.instance.getJoinedGroupList();
    this.groupList = [];
    for (let index = 0; index < result.length; index++) {
      const element = result[index];
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

  async getGroupMemberList(groupInfoVM: CMChatGroupInfo) {
    let result = await CMChatFactory.instance.getGroupMemberList(groupInfoVM.groupId, 0, 0);
    groupInfoVM.memberInfoList = result.memberInfoList;
  }
}