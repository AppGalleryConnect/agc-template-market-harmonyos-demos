import { PersistenceV2 } from '@kit.ArkUI';
import { UserInfo } from 'common';
import {
  CMChatFactory, CMChatGroupMemberInfo, CMChatGroupMemberRole
} from 'instant_messaging';
import { ChatJumpManager } from '../utils/ChatJumpManager';
import { MessageContactModel } from './MessageContactModel';
import { MessageGroupInfoModel } from './MessageGroupInfoModel';

@ObservedV2
export class CreateGroupFromOldGroupModel {
  @Trace contactList: MessageContactModel[] = [];
  scroller: ListScroller = new ListScroller();
  @Trace groupInfoVM?: MessageGroupInfoModel;
  @Trace selectContactList: MessageContactModel[] = [];
  @Trace isShowBottom: boolean = false;
  @Trace userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;
  @Trace pageTitle: string = '';

  selectContact(friendInfoVM: MessageContactModel) {
    let index = this.selectContactList.indexOf(friendInfoVM);
    if (friendInfoVM.isSelect) {
      if (index === -1) {
        this.selectContactList.push(friendInfoVM);
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

  selectAllContact() {
    this.selectContactList = [];
    for (let index = 0; index < this.contactList.length; index++) {
      const element = this.contactList[index];
      element.isSelect = true;
      this.selectContactList.push(element);
    }

    this.isShowBottom = true;
  }

  async startGroupChat() {
    let memberList: CMChatGroupMemberInfo[] = [];
    let memberOwner = new CMChatGroupMemberInfo();
    memberOwner.role = CMChatGroupMemberRole.CHAT_GROUP_MEMBER_ROLE_SUPER;
    memberOwner.userId = this.userInfo.id;
    memberOwner.nickName = this.userInfo.nickName;
    memberList.push(memberOwner);

    for (let index = 0; index < this.selectContactList.length; index++) {
      const element = this.selectContactList[index];
      let member = new CMChatGroupMemberInfo();
      member.role = CMChatGroupMemberRole.CHAT_GROUP_MEMBER_ROLE_MEMBER;
      member.userId = element.userId;
      member.nickName = element.nickName;
      memberList.push(member);
    }

    let result = await CMChatFactory.instance.createGroup(memberList);

    if (result.length > 0) {
      ChatJumpManager.gotoGroupChatPage(result);
    }
  }

  async getGroupMemberList() {
    let result = await CMChatFactory.instance.getGroupMemberList(this.groupInfoVM?.groupId ?? '', 0, 0);
    for (let index = 0; index < result.memberInfoList.length; index++) {
      const element = result.memberInfoList[index];
      if (this.userInfo.id === element.userId) {
        continue;
      }
      let contactVM = new MessageContactModel();
      contactVM.userId = element.userId;
      contactVM.nickName = element.nickName;
      contactVM.avatarUrl = element.avatarUrl;
      this.contactList.push(contactVM);
    }
  }
}