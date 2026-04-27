import { AppStorageV2 } from '@kit.ArkUI';
import { ChatBreakpoint } from 'chat_window';
import { OHPage, OHPageConfig, phoneRouterControl } from 'oh_router';
import { BarVM, BreakpointModel, CommonHeader, TempBarHeight } from 'common';
import { CMChatConversation } from 'instant_messaging';
import { MessageChatModel } from '../viewmodel/MessageChatModel';

@ComponentV2
export struct BackgroundImageView {
  @Local chatBreakpoint: ChatBreakpoint = AppStorageV2.connect(ChatBreakpoint, () => new ChatBreakpoint())!;
  @Param leftImageMargin: Length = this.chatBreakpoint.pagePadding;
  @Param fontWightParam: FontWeight | number = 700
  @Param isShowLeftImage: boolean = true;
  @Local tempBarHeight: TempBarHeight = AppStorageV2.connect(TempBarHeight, () => new TempBarHeight())!;
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Local pageConfig: OHPageConfig = new OHPageConfig({
    onPageShow: () => {
      this.tempBarHeight.topValue = 0;
      this.tempBarHeight.bottomValue = 0;
    }
  })
  @Local onReturnClick: () => void = () => {
    phoneRouterControl.popPage()
  }
  @Local cmChatConversation: CMChatConversation = new CMChatConversation()
  messageChatModel: MessageChatModel = new MessageChatModel(this.getUIContext())
  backGroundImageSrc: string[] = [
    'backGroundImage_one',
    'backGroundImage_tow',
    'backGroundImage_three',
    'backGroundImage_four',
    'backGroundImage_five',
  ]

  build() {
    OHPage({
      childBuilder: () => {
        this.render();
      },
      pageConfig: this.pageConfig
    })
  }

  @Builder
  render() {
    Column() {
      Blank().height(BarVM.instance.staBarH);

      CommonHeader({
        title: '预制聊天背景',
        onReturnClick: this.onReturnClick
      })
        .padding({
          left: this.breakPointModel.pagePadding,
          right: this.breakPointModel.pagePadding
        })

      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.backGroundImageSrc, (item: string) => {
          Stack({ alignContent: Alignment.BottomEnd }) {
            Image($r('app.media.' + item))
              .width(100)
              .height(100)
              .borderRadius(16)
            Radio({ value: item, group: 'radioGroup' })
              .onChange((isChecked: boolean) => {
                if (isChecked) {
                  this.messageChatModel.userInfo.chatBgImage = item
                }
              })
          }
          .margin({ left: 13, top: 10 , bottom :10})
        }, (item : string) => JSON.stringify(item))
      }
      .width('91%')
      .backgroundColor(Color.White)
      .borderRadius(16)
      .margin({ left: this.leftImageMargin,right : this.leftImageMargin, top: 10, bottom: 10 })
    }

  }
}

@Builder
export function BackgroundImageViewPageBuilder() {
  BackgroundImageView()
}