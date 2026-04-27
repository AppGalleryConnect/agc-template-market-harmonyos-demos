import { UIDialog } from '@hw-agconnect/ui-dialog';
import { MessageGroup, MessageItem } from '../commons/Types'
import { formatTimestamp } from '../commons/Utils';
import { NoticeApis } from '../https/Apis'
import { WindowLayoutUtil } from '../utils/WindowLayoutUtil';

// 启动axios-mock
import('../https/MockApis');

@Builder
export function noticeListPageBuilder() {
  NoticeListPage()
}

@ComponentV2
export struct NoticeListPage {
  @Local stack: NavPathStack = new NavPathStack();
  @Local title: string = '';
  @Local group: MessageGroup | undefined;
  @Local list: MessageItem[] = [];
  @Local isLoading: boolean = false;
  win: WindowLayoutUtil = WindowLayoutUtil.instance;

  aboutToAppear(): void {
    this.win.setAvoidSize(this.getUIContext())
  }

  build() {
    NavDestination() {
      Column() {
        this.builderTitle()
        if (this.isLoading) {
          LoadingProgress().height(32)
        } else if (!this.list.length) {
          Column() {
            Image($r('app.media.ic_search_empty'))
              .width(120)
            Text('暂无消息通知')
              .fontSize(12)
              .fontColor($r('sys.color.font_secondary'))
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
          }
          .width('100%')
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
          .contentEndOffset(16)
        }
      }
      .width('100%')
      .height('100%')
      .padding(this.win.isAvoidArea ? {
        top: this.win.windowTopPadding,
        bottom: this.win.windowBottomPadding,
        left: $r('app.float.space_l'),
        right: $r('app.float.space_l'),
      } : {
        left: $r('app.float.space_l'),
        right: $r('app.float.space_l'),
      })
    }
    .hideTitleBar(true)
    .onReady(async (context) => {
      if (context.pathStack) {
        this.stack = context.pathStack;
      }
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
  builderTitle() {
    Row({ space: 8 }) {
      Button() {
        SymbolGlyph($r('sys.symbol.chevron_backward'))
          .fontColor([$r('sys.color.font_primary')])
          .fontWeight(FontWeight.Normal)
          .fontSize(24)
      }
      .width(40)
      .height(40)
      .type(ButtonType.Circle)
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .onClick(() => {
        this.stack.pop();
      })
      Text(this.title)
        .fontSize(20)
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Bold)
    }
    .height(56)
    .width('100%')
  }

  @Builder
  buildDeleteIcon(id: string) {
    Row() {
      Row() {
        SymbolGlyph($r('sys.symbol.trash_fill'))
          .fontColor([$r('sys.color.white')])
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
        .width('100%')

        Text(message.title).titleStyle()
        Text(message.content).contentStyle()
      }
      .backgroundColor($r('sys.color.white'))
      .borderRadius($r('app.float.border_radius_16'))
      .padding($r('app.float.space_m'))
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }

  }

  handleNoticeDelete(id: string) {
    UIDialog.open({
      content: '是否确认删除此条消息？',
      showConfirmButton: true,
      showCancelButton: true,
      confirmButtonOptions: {
        buttonFontColor: $r('sys.color.font_emphasize'),
        buttonFontSize: 16,
        buttonBgColor: Color.Transparent
      },
      cancelButtonOptions: {
        buttonFontColor: $r('sys.color.font_secondary'),
        buttonFontSize: 16,
        buttonBgColor: Color.Transparent
      },
      onConfirm: () => {
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
      closeOnClickMask: false,
      closeOnBackPress: false,
    })
  }
}

@Extend(Text)
function titleStyle() {
  .fontWeight(FontWeight.Medium)
  .fontColor($r('sys.color.font_primary'))
  .margin({
    top: $r('app.float.space_m'),
    bottom: $r('app.float.space_m'),
  })
}

@Extend(Text)
function contentStyle() {
  .fontSize(12)
  .fontColor($r('sys.color.font_secondary'))
}