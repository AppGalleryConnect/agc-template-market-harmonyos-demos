import { CommonConfirmDialog } from 'module_ui_base';
import { MessageGroup, MessageItem } from '../commons/Types'
import { formatTimestamp } from '../commons/Utils';
import { NoticeApis } from '../https/Apis'

import('../https/MockApis');

@Builder
export function buildNoticeListPage() {
  NoticeListPage()
}

@ComponentV2
export struct NoticeListPage {
  @Local
  title: string = ''
  @Local
  group: MessageGroup | undefined
  @Local
  list: MessageItem[] = []
  @Local
  isLoading: boolean = false

  build() {
    NavDestination() {
      if (this.isLoading) {
        LoadingProgress().height(32)
      } else if (!this.list.length) {
        Column() {
          Image($r('app.media.ic_search_empty'))
            .width(120)
          Text('暂无消息通知')
            .fontSize(12)
            .fontColor($r('app.color.font_color_level2'))
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        List({ space: 12 }) {
          Repeat<MessageItem>(this.list)
            .each((ri: RepeatItem<MessageItem>) => {
              ListItem() {
                this.buildMessageCard(ri.item)
              }
              .swipeAction({
                end: this.buildDeleteIcon(ri.item.id),
              })
            })
          ListItem().height($r('app.float.space_l'))
        }
        .padding({
          left: $r('app.float.space_l'),
          right: $r('app.float.space_l'),
        })
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
      }

    }
    .title(this.title)
    .onReady(async (context) => {
      this.group = context.pathInfo.param as MessageGroup | undefined
      if (this.group) {
        this.title = this.group.title;
        this.isLoading = true
        this.list = await NoticeApis.getNoticeList(this.group.type)
      }
      this.isLoading = false;
    })
    .backgroundColor($r('app.color.background_color_grey'))
  }

  @Builder
  buildDeleteIcon(id: string) {
    Row() {
      Row() {
        SymbolGlyph($r('sys.symbol.trash_fill'))
          .fontColor([$r('app.color.background_color_primary')])
          .fontSize(20)
      }
      .backgroundColor($r('sys.color.warning'))
      .width(40)
      .height(40)
      .borderRadius(20)
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        this.handleNoticeDelete(id)
      })
    }
    .width(72)
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor($r('app.color.background_color_grey'))
  }

  @Builder
  buildMessageCard(message: MessageItem) {
    if (this.group) {
      Column() {
        Row() {
          Image(this.group.icon)
            .height(16)
            .margin({ right: $r('app.float.space_xs') })

          Text(this.group.title).contentStyle()
          Blank()
          Text(formatTimestamp(message.timestamp)).contentStyle()
        }
        .width($r('app.string.size_percent_full'))

        Text(message.title).titleStyle()
        Text(message.content).contentStyle()
      }
      .backgroundColor($r('app.color.background_color_primary'))
      .borderRadius($r('app.float.border_radius_l'))
      .padding($r('app.float.space_m'))
      .width($r('app.string.size_percent_full'))
      .alignItems(HorizontalAlign.Start)
    }

  }

  handleNoticeDelete(id: string) {
    CommonConfirmDialog.show({
      content: '是否确认删除此条消息？',
      confirm: () => {
        NoticeApis.deleteNotice(id)
          .then(async (res) => {
            if (res === 0) {
              this.getUIContext().getPromptAction().showToast({ message: '消息删除成功！' })
              this.isLoading = true
              this.list = await NoticeApis.getNoticeList(this.group!.type)
              this.isLoading = false
            }
          })
      },
    })
  }
}

@Extend(Text)
function titleStyle() {
  .fontWeight(FontWeight.Medium)
  .fontColor($r('app.color.font_color_level1'))
  .margin({
    top: $r('app.float.space_m'),
    bottom: $r('app.float.space_m'),
  })
}

@Extend(Text)
function contentStyle() {
  .fontSize(12)
  .fontColor($r('app.color.font_color_level2'))
}