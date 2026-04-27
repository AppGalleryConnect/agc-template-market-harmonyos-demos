import { PersistenceV2 } from '@kit.ArkUI';
import { Constants, GlobalContext, UserInfo } from 'common';
import {
  CMChatFactory, CMChatGroupMemberInfo, CMChatGroupMemberRole
} from 'instant_messaging';
import { ChatJumpManager } from '../utils/ChatJumpManager';
import { MessageContactModel } from './MessageContactModel';

@ObservedV2
export class StartGroupModel {
  @Trace pageTitle: string = '创建群聊';
  @Trace friendList: MessageContactModel[] = [];
  @Trace selectFriendList: MessageContactModel[] = [];
  @Trace userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;
  beforeUserId: string = '';
  scroller: ListScroller = new ListScroller();

  selectFriend(friendVM: MessageContactModel) {
    let index = this.selectFriendList.indexOf(friendVM);
    if (friendVM.isSelect) {
      if (index === -1) {
        this.selectFriendList.push(friendVM);
      }
    } else {
      if (index !== -1) {
        this.selectFriendList.splice(index, 1);
      }
    }
  }

  /**
   * 创建群，开始群聊
   */
  async startGroupChat() {
    if (this.selectFriendList.length === 0) {
      GlobalContext.getUIContext().getPromptAction().showToast({
        message: '创建群组需要再选择一个好友'
      })
      return;
    }
    let startMemberList: CMChatGroupMemberInfo[] = [];
    let ownerInfo = new CMChatGroupMemberInfo();
    ownerInfo.role = CMChatGroupMemberRole.CHAT_GROUP_MEMBER_ROLE_SUPER;
    ownerInfo.userId = this.userInfo.id;
    ownerInfo.nickName = this.userInfo.nickName;
    startMemberList.push(ownerInfo);

    let beforeInfo = new CMChatGroupMemberInfo();
    beforeInfo.role = CMChatGroupMemberRole.CHAT_GROUP_MEMBER_ROLE_MEMBER;
    beforeInfo.userId = this.beforeUserId;
    beforeInfo.nickName = Constants.getMockNickName(this.beforeUserId);
    startMemberList.push(beforeInfo);

    for (let index = 0; index < this.selectFriendList.length; index++) {
      const element = this.selectFriendList[index];
      let otherInfo = new CMChatGroupMemberInfo();
      otherInfo.role = CMChatGroupMemberRole.CHAT_GROUP_MEMBER_ROLE_MEMBER;
      otherInfo.userId = element.userId;
      otherInfo.nickName = element.nickName;
      startMemberList.push(otherInfo);
    }

    let result = await CMChatFactory.instance.createGroup(startMemberList);

    if (result.length > 0) {
      ChatJumpManager.gotoGroupChatPage(result);
    }
  }

  async getStartGroupFriendList() {
    let friendResult = await CMChatFactory.instance.getFriendList();
    this.friendList = [];
    for (let index = 0; index < friendResult.length; index++) {
      const element = friendResult[index];
      if (element.userId === this.userInfo.id) {
        continue;
      }

      let friendVM = new MessageContactModel();
      friendVM.userId = element.userId;
      friendVM.isChange = !(this.beforeUserId === element.userId);
      friendVM.isSelect = (this.beforeUserId === element.userId);
      friendVM.nickName = element.nickName;
      friendVM.avatarUrl = element.avatarUrl;
      this.friendList.push(friendVM);
    }
  }
}