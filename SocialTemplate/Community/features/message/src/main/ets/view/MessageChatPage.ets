/**
 * @usage: 单聊/群聊聊天页面（输入、消息列表、弹窗）
 * @layout: OHPage + ChatWindowComponent + ChatInputComponent + 背景图层
 * @constraints: 键盘高度监听；IM监听注册与释放；页面返回栈处理；提示菜单桥接
 * @isGen: false
 * @fileType: page
 * @domain: 社交交友
 * @zhName: 消息聊天页
 * @subPage:
 * @component: AvatarUrlView
 * @image: screenshots/messageChat.png
 */
import { AppStorageV2, KeyboardAvoidMode, window } from '@kit.ArkUI';
import { ChatInputComponent, ChatInputSendMessageModel } from 'chat_input';
import { ChatWindowComponent, POP_MENU_TYPE, PromptActionClass } from 'chat_window';
import { OHPage, OHPageConfig, phoneRouterControl } from 'oh_router';
import { MessageChatModel } from '../viewmodel/MessageChatModel';
import { RouterMap, TCLogger, TempBarHeight, TValueType } from 'common';
import { ChatHistoryCollectionPageBuilder } from './ChatHistoryCollectionPage';
import { CMChatConversation, CMChatGroupInfo } from 'instant_messaging';
import { ChatBreakpoint, ChatContentSingleModel } from 'chat_window';
import { AvatarUrlViewPageBuilder } from './AvatarUrlView';

@Builder
export function MessageChatPageBuilder(valueVM: TValueType) {
  MessageChatPage({ valueVM: valueVM })
}

const TAG = 'MessageChatPage';

@ComponentV2
export struct MessageChatPage {
  @Param @Require valueVM: TValueType;
  @Local messageChatVM: MessageChatModel = new MessageChatModel(this.getUIContext());
  @Local tempBarHeight: TempBarHeight = AppStorageV2.connect(TempBarHeight, () => new TempBarHeight())!;
  @Local onceLoad: boolean = false;
  @Local chatBreakpoint: ChatBreakpoint = AppStorageV2.connect(ChatBreakpoint, () => new ChatBreakpoint())!;
  @Local keyboardHeight: number = 0
  private currentWindow?: window.Window
  @Local pageConfig: OHPageConfig = new OHPageConfig({
    onPageShow: () => {
      this.tempBarHeight.topValue = 0;
      this.tempBarHeight.bottomValue = 0;
      if (!this.onceLoad) {
        this.onceLoadData();
      }

      // 关闭键盘避让，监听键盘高度
      this.getUIContext().setKeyboardAvoidMode(KeyboardAvoidMode.NONE);
      try {
        window.getLastWindow(getContext()).then((currentWindow) => {
          this.currentWindow = currentWindow
          this.currentWindow.on('keyboardHeightChange',(height: number) => {
            this.keyboardHeight = Math.max(0, px2vp(height) - this.chatBreakpoint.bottomValue);
            if (height > 0) {
              this.messageChatVM.scroller.scrollToIndex(this.messageChatVM.chatContentList.length - 1, true);
            }
          })
        })
      } catch (err) {
      }
    },
    onPageHide: () => {
      this.currentWindow?.off('keyboardHeightChange');
      this.messageChatVM.soundStop();
    },
    onBackPress: () => {
      this.onReturnClick();
      return true;
    }
  })
  @Local onReturnClick: () => void = () => {
    if (this.messageChatVM.conversationVM.isBackTop) {
      phoneRouterControl.popMulPage(phoneRouterControl.getNavPageInfoList().length)
    } else {
      phoneRouterControl.popPage();
    }
  }
  @Local menuList: MenuElement[] = [
    {
      value: '聊天设置',
      action: () => {
        this.messageChatVM.gotoChatSettingPage();
      }
    },
    {
      value: '收藏列表',
      action: () => {
        phoneRouterControl.jumpPage({
          pageName: RouterMap.CHAT_HISTORY_COLLECTION_PAGE,
          builder: wrapBuilder(ChatHistoryCollectionPageBuilder)
        })
      }
    }
  ];
  // 消息点击回调
  @Local onChatBubbleClick: (chatVM: ChatContentSingleModel) => void =
    (chatVM: ChatContentSingleModel) => {
      TCLogger.info(TAG, `click chat bubble ` + JSON.stringify(chatVM));
      this.messageChatVM.chatBubbleClick(chatVM);
    }
  // 头像点击回调
  @Local onChatAvatarClick: (chatVM: ChatContentSingleModel) => void =
    (chatVM: ChatContentSingleModel) => {
      TCLogger.info(TAG, `click chat avatar ` + JSON.stringify(chatVM));
      phoneRouterControl.jumpPage({
        pageName: RouterMap.AVATAR_URL_VIEW,
        builder: wrapBuilder(AvatarUrlViewPageBuilder),
        param: chatVM.sender as TValueType,
        onPop: (_popInfo: PopInfo) => {
          this.messageChatVM.checkFriend();
          this.messageChatVM.getFriendsInfo();
        }
      })
    }
  @Local cmChatGroupInfo: CMChatGroupInfo = new CMChatGroupInfo()
  // 输入组件数据回调
  @Local sendMessageAction: (content: ChatInputSendMessageModel) => void =
    (content: ChatInputSendMessageModel) => {
      this.messageChatVM.sendMessageAction(content);
    }
  //气泡菜单点击事件
  @Local onPopMenuClick: (chatVM: ChatContentSingleModel, type: POP_MENU_TYPE) => void =
    (chatVM: ChatContentSingleModel, type: POP_MENU_TYPE) => {
      this.messageChatVM.onPopMenuClick(chatVM, type)
      PromptActionClass.closeDialog()
    }

  aboutToAppear(): void {
    try {
      this.messageChatVM.conversationVM = this.valueVM as CMChatConversation;
    } catch (err) {
    }
  }

  onceLoadData() {
    this.onceLoad = true;
    this.messageChatVM.getHistoryMessageList();
    this.messageChatVM.getGroupsInfo();
    this.messageChatVM.getFriendsInfo();
    this.messageChatVM.checkFriend();
    this.messageChatVM.addAdvancedMsgListener();
    setTimeout(() =>{
      PromptActionClass.menuClick = this.onPopMenuClick
      PromptActionClass.getDeviceType = () => {
        return this.messageChatVM.deviceType
      }
      PromptActionClass.getVideoMutyStatus = () => {
        return this.messageChatVM.videoMutyStatus
      }
      this.messageChatVM.audioRendererUtil.setPlayStatusCallBack(this.messageChatVM.soundStatusCallBack)
      this.messageChatVM.audioRendererUtil.init()
    }, 300)
  }

  aboutToDisappear(): void {
    this.messageChatVM.audioRendererUtil.release()
    this.messageChatVM.removeAdvancedMsgListener();
  }

  @Builder
  render() {
    Stack() {
      Column() {
        Stack() {
          if (this.messageChatVM.userInfo.chatBgImage !== '') {
            if (this.messageChatVM.userInfo.chatBgImage === 'backGroundImage_one' ||
              this.messageChatVM.userInfo.chatBgImage === 'backGroundImage_tow' ||
              this.messageChatVM.userInfo.chatBgImage === 'backGroundImage_three' ||
              this.messageChatVM.userInfo.chatBgImage === 'backGroundImage_four' ||
              this.messageChatVM.userInfo.chatBgImage === 'backGroundImage_five') {
              Image($r('app.media.' + this.messageChatVM.userInfo.chatBgImage))
                .width('100%')
                .height('100%')
            } else {
              Image(this.messageChatVM.userInfo.chatBgImage)
                .width('100%')
                .height('100%')
            }
          } else {
            Image($r('app.media.backGroundImage_default'))
              .width('100%')
              .height('100%')
          }
          ChatWindowComponent({
            onReturnClick: this.onReturnClick,
            title: this.messageChatVM.pageTitle,
            menuList: this.menuList,
            chatContentList: this.messageChatVM.chatContentList,
            scroller: this.messageChatVM.scroller,
            onChatBubbleClick: this.onChatBubbleClick,
            onChatAvatarClick: this.onChatAvatarClick,
          })
            .width('100%')
            .height('100%')
        }
        .width('100%')
        .layoutWeight(1)

        ChatInputComponent({
          sendMessageAction: this.sendMessageAction
        })
          .width('100%')
          .backgroundColor(Color.White)
      }
      .width('100%')
      .height('100%')
      .padding({
        bottom: this.keyboardHeight
      })
      .animation({ duration: 250 })
    }
  }

  build() {
    OHPage({
      childBuilder: () => {
        this.render();
      },
      pageConfig: this.pageConfig
    })
  }
}
