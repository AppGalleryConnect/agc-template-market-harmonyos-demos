import { RouterMap, TValueType } from 'common';
import { CMChatConversation, CMChatConversationType, CMChatFactory, CMChatFriendInfo } from 'instant_messaging';
import { phoneRouterControl } from 'oh_router';
import { PrivateChatSettingEnum } from '../utils/MessageEnum';
import { MessageChatPageBuilder } from '../view/MessageChatPage';
import { PrivateChatSettingsPageBuilder } from '../view/PrivateChatSettingsPage';
import { PrivateChatSettingModel } from './PrivateChatSettingModel';

@ObservedV2
export class AvatarUrlModel {
  @Trace userId: string = '';
  @Trace isFriend: boolean = false;
  @Trace contactVM: CMChatFriendInfo = new CMChatFriendInfo();
  @Trace isFix: boolean = false;

  /**
   * 获取指定好友资料
   */
  async getFriendsInfo() {
    let result = await CMChatFactory.instance.getFriendsInfo([this.userId]);
    this.contactVM = result[0];
  }

  /**
   * 跳转到好友或陌生人的聊天设置
   */
  gotoPrivateChatSetting() {
    const friendRemark = this.contactVM.friendRemark;
    let nickName = this.contactVM.nickName;
    if (friendRemark !== undefined && friendRemark.length > 0) {
      nickName = friendRemark;
    }
    let type = this.isFriend ? PrivateChatSettingEnum.FRIEND : PrivateChatSettingEnum.STRANGER;
    let settingsVM = new PrivateChatSettingModel();
    settingsVM.pageType = type;
    settingsVM.conversationID = '';
    settingsVM.userId = this.userId;
    settingsVM.showName = nickName;
    phoneRouterControl.jumpPage({
      pageName: RouterMap.PRIVATE_CHAT_SETTINGS_PAGE,
      builder: wrapBuilder(PrivateChatSettingsPageBuilder),
      param: settingsVM as TValueType,
      onPop: (_popInfo: PopInfo) => {
        this.getFriendsInfo();
        this.isFix = true;
      }
    })
  }

  gotoC2CChatPage(userId: string) {
    let messageVM = new CMChatConversation();
    messageVM.userId = userId;
    messageVM.conversationID = 'c2c_' + userId;
    messageVM.type = CMChatConversationType.CHAT_C2C;
    phoneRouterControl.jumpPage({
      pageName: RouterMap.MESSAGE_CHAT_PAGE,
      builder: wrapBuilder(MessageChatPageBuilder),
      param: messageVM as TValueType
    })
  }
}