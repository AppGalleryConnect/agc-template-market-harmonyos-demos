import { MessageModel, SenderType } from '../models/MessageModel';
import DateUtil from '../utils/DateUtil';
import { ChatVM } from '../viewmodels/ChatVM';

@ComponentV2
export struct ChatView {
  @Param
  serviceAvatar: ResourceStr = $r('app.media.ic_custom_service')
  @Param
  serviceName: string = '小助手'
  @Param
  userAvatar: ResourceStr = $r('app.media.ic_default_avatar')
  vm: ChatVM = new ChatVM(true)

  aboutToAppear() {
    this.vm.initializeService();
  }

  aboutToDisappear() {
    this.vm.currentService.disconnect();
    this.vm.saveMessage()
  }

  build() {
    Column() {
      // 消息列表
      Scroll(this.vm.scrollController) {
        Column() {
          ForEach(this.vm.messageList, (message: MessageModel) => {
            this.buildChatBubble(message)
          }, (message: MessageModel) => message.id)
        }
        .padding($r('app.float.space_m'))
        .width($r('app.string.size_percent_full'))
      }
      .layoutWeight(1)
      .align(Alignment.Top)
      .scrollBar(BarState.Off)
      .backgroundColor($r('app.color.background_color_grey'))

      // 输入区域
      Row() {
        TextArea({ text: this.vm.inputText, placeholder: '请在此输入您的问题' })
          .height('auto')
          .maxLength(200)
          .showCounter(true, { thresholdPercentage: 90 })
          .layoutWeight(1)
          .caretColor($r('app.color.theme_color'))
          .selectedBackgroundColor($r('app.color.theme_color'))
          .onChange((value: string) => {
            this.vm.inputText = value;
          })
          .enterKeyType(EnterKeyType.Send)
          .onSubmit(() => this.vm.sendTextMessage())
      }
      .padding($r('app.float.space_l'))
      .backgroundColor($r('app.color.background_color_primary'))
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    }
    .width($r('app.string.size_percent_full'))
    .height($r('app.string.size_percent_full'))
  }

  @Builder
  buildChatBubble(message: MessageModel) {
    Flex({
      direction: FlexDirection.Row,
      justifyContent: message.sender === SenderType.USER ? FlexAlign.End : FlexAlign.Start,
    }) {
      if (message.sender === SenderType.CUSTOMER_SERVICE) {
        this.buildAvatar(this.serviceAvatar)
      }

      Column() {
        if (message.sender === SenderType.CUSTOMER_SERVICE) {
          Text(this.serviceName)
            .fontSize(10)
            .fontColor($r('app.color.font_color_level2'))
            .margin({ bottom: 2 })
        }
        // 消息内容
        Text(message.content)
          .textAlign(TextAlign.Start)
          .fontSize(12)
          .padding(12)
          .backgroundColor(message.sender === SenderType.USER ? $r('app.color.background_color_theme') :
            $r('app.color.background_color_primary'))
          .borderRadius(8)

        // 时间戳
        Text(DateUtil.formatTimeForChat(message.timestamp))
          .fontSize(10)
          .fontColor($r('app.color.font_color_level3'))
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)

      if (message.sender === SenderType.USER) {
        this.buildAvatar(this.userAvatar)
      }
    }
    .width('100%')
    .margin({ top: 12 })
  }

  @Builder
  buildAvatar(avatar?: ResourceStr) {
    Image(avatar)
      .width(40)
      .height(40)
      .borderRadius(20)
      .margin({ left: 8, right: 8 })
  }
}
