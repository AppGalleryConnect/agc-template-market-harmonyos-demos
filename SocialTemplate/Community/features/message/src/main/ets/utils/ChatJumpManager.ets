import { ChatContentSingleModel } from 'chat_window';
import { RouterMap, TValueType } from 'common';
import { CMChatConversation, CMChatConversationType } from 'instant_messaging';
import { phoneRouterControl } from 'oh_router';
import { AvatarUrlViewPageBuilder } from '../view/AvatarUrlView';
import { CheckFullImagePageBuilder } from '../view/CheckFullImagePage';
import { MessageChatPageBuilder } from '../view/MessageChatPage';
import { PrivateChatSettingsPageBuilder } from '../view/PrivateChatSettingsPage';
import { VideoPageViewBuilder } from '../view/VideoPageView';
import { ViewLocationPageBuilder } from '../view/ViewLocationPage';
import { PrivateChatSettingModel } from '../viewmodel/PrivateChatSettingModel';
import { PrivateChatSettingEnum } from './MessageEnum';

export class ChatJumpManager {
  /**
   * 跳转到单聊聊天页面
   */
  static gotoC2CChatPage(userId: string, isBackTop?: boolean) {
    if (userId.length === 0) {
      return;
    }

    let messageVM = new CMChatConversation();
    messageVM.userId = userId;
    messageVM.conversationID = 'c2c_' + userId;
    messageVM.type = CMChatConversationType.CHAT_C2C;
    if (isBackTop === undefined) {
      messageVM.isBackTop = true;
    } else {
      messageVM.isBackTop = isBackTop;
    }
    phoneRouterControl.jumpPage({
      pageName: RouterMap.MESSAGE_CHAT_PAGE,
      builder: wrapBuilder(MessageChatPageBuilder),
      param: messageVM as TValueType
    })
  }

  /**
   * 跳转到群聊聊天页面
   */
  static gotoGroupChatPage(groupId: string, isBackTop?: boolean) {
    if (groupId.length === 0) {
      return;
    }

    let messageVM = new CMChatConversation();
    messageVM.groupID = groupId;
    messageVM.conversationID = 'group_' + groupId;
    messageVM.type = CMChatConversationType.CHAT_GROUP;
    if (isBackTop === undefined) {
      messageVM.isBackTop = true;
    } else {
      messageVM.isBackTop = isBackTop;
    }
    phoneRouterControl.jumpPage({
      pageName: RouterMap.MESSAGE_CHAT_PAGE,
      builder: wrapBuilder(MessageChatPageBuilder),
      param: messageVM as TValueType
    })
  }

  /**
   * 点击头像跳转到个人信息页面
   */
  static gotoContactInfo(userId: string, popCallback?: () => void) {
    phoneRouterControl.jumpPage({
      pageName: RouterMap.AVATAR_URL_VIEW,
      builder: wrapBuilder(AvatarUrlViewPageBuilder),
      param: userId as TValueType,
      onPop: (_popInfo: PopInfo) => {
        popCallback?.();
      }
    })
  }

  /**
   * 点击地理位置消息跳转查看地址页面
   */
  static gotoViewLocation(chatVM: ChatContentSingleModel) {
    phoneRouterControl.jumpPage({
      pageName: RouterMap.VIEW_LOCATION_PAGE,
      builder: wrapBuilder(ViewLocationPageBuilder),
      param: chatVM as TValueType
    })
  }

  /**
   * 点击视频消息跳转查看视频页面
   */
  static gotoVideoPage(chatVM: ChatContentSingleModel, videoMutyStatus: boolean = true) {
    phoneRouterControl.jumpPage({
      pageName: RouterMap.VIDEO_PAGE_VIEW,
      param: {
        'videoChatSrc': chatVM.videoChatSrc,
        'videoMutyStatus': videoMutyStatus
      } as Record<string, string | boolean>,
      builder: wrapBuilder(VideoPageViewBuilder)
    })
  }

  /**
   * 点击图片消息跳转查看图片页面
   */
  static gotoFullImagePage(chatVM: ChatContentSingleModel) {
    phoneRouterControl.jumpPage({
      pageName: RouterMap.FULL_IMAGE_PAGE,
      param: chatVM.imageInfo![0].url,
      builder: wrapBuilder(CheckFullImagePageBuilder)
    })
  }

  /**
   * 跳转单聊聊天设置页面
   */
  static gotoPrivateChatSettingPage(type: PrivateChatSettingEnum, conversationID: string,
    userId: string, pageTitle: string, popCallback: () => void) {
    let settingsVM = new PrivateChatSettingModel();
    settingsVM.pageType = type;
    settingsVM.conversationID = conversationID;
    settingsVM.userId = userId;
    settingsVM.showName = pageTitle;
    phoneRouterControl.jumpPage({
      pageName: RouterMap.PRIVATE_CHAT_SETTINGS_PAGE,
      builder: wrapBuilder(PrivateChatSettingsPageBuilder),
      param: settingsVM as TValueType,
      onPop: (_popInfo: PopInfo) => {
        popCallback()
      }
    })
  }
}