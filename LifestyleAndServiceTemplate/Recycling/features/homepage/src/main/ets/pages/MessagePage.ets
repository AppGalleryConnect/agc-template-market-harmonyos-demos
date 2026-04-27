import { Constants, TimeUtil } from 'common';
import { MessageItem, MessagePageVM } from '../viewmodel/MessagePageVM'

@Builder
export function MessagePageBuilder() {
  MessagePage()
}

@ComponentV2
export struct MessagePage {
  private readonly logTag: string = 'MessagePage'
  // 页面上边距
  private readonly topMargin: number = Constants.PADDING_4XL;
  @Local messagePageVM: MessagePageVM = new MessagePageVM()

  // 单个的消息布局
  @Builder
  listItemLayout(item: MessageItem) {
    Column() {
      // 时间
      Text(TimeUtil.formatDate(item.time, TimeUtil.PATTERN_DATE_TIME_SLASH))
        .fontSize(12)
        .fontColor('rgba(0, 0, 0, 0.4)')
        .fontWeight(FontWeight.Regular)

      // 内容板块
      Column() {
        // 标题
        Text(item.title)
          .height(50)
          .fontSize(16)
          .fontColor('rgba(0, 0, 0, 1)')
          .fontWeight(FontWeight.Regular)
          .padding({ left: 12, right: 12 })
          .textAlign(TextAlign.Center)

        // 简要内容提示
        Text(item.simpleContent)
          .width('100%')
          .fontSize(12)
          .fontColor('rgba(0, 0, 0, 0.6)')
          .fontWeight(FontWeight.Regular)
          .padding({ left: 13, right: 13 })
          .margin({ bottom: 16 })

        // 分割线
        Row() {
          Divider().width('100%').height(0.5).backgroundColor('rgba(0, 0, 0, 0.1)')
        }
        .width('100%')
        .padding({ left: 14, right: 12 })

        // 操作提示
        Row() {
          Text(item.tag).fontSize(12).fontColor('rgba(0, 0, 0, 0.4)').margin({ left: 12 })

          Image($r('app.media.ic_right_arrow')).width(24).height(24).margin({ right: 6 })
        }
        .width('100%')
        .height(44)
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .width('100%')
      .borderRadius(16)
      .backgroundColor('rgba(255, 255, 255, 1)')
      .alignItems(HorizontalAlign.Start)
      .margin({ top: 12 })
    }
    .width('100%')
    .padding({
      left: 16,
      right: 16,
      top: 24
    })
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  render() {
    Column() {
      // 消息列表
      List() {
        ForEach(this.messagePageVM.messageList, (item: MessageItem, index) => {
          ListItem() {
            this.listItemLayout(item)
          }
          .width('100%')
        }, (item: MessageItem, index: number) => JSON.stringify(item) + index)
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor('rgba(245, 245, 245, 1)')
  }

  build() {
    NavDestination() {
      this.render()
    }
    .padding({ top: this.topMargin })
    .title('消息通知')
  }
}