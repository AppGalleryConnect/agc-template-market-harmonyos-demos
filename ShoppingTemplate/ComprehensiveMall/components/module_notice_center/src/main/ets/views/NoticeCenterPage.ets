import { CommonSymbol, WindowUtil } from 'module_ui_base';
import { NoticeRouterMap } from '../commons/Enums';
import { MessageGroup } from '../commons/Types'
import { formatTimestamp } from '../commons/Utils';
import { NoticeApis } from '../https/Apis';
import { MOCK_MESSAGE_GROUP } from '../https/MockData';

@Builder
export function buildNoticeCenterPage() {
  NoticeCenterPage()
}

@ComponentV2
export struct NoticeCenterPage {
  @Local
  groups: MessageGroup[] = MOCK_MESSAGE_GROUP
  @Local
  stack: NavPathStack = new NavPathStack()
  @Local
  loading: boolean = false

  aboutToAppear(): void {
    WindowUtil.initWindowUtil(this.getUIContext())
  }

  build() {
    NavDestination() {
      Column() {
        this.buildHeader()
        if (this.loading) {
          LoadingProgress().width(32).height(32).layoutWeight(1)
        } else {
          this.buildMessageGroup()
        }
      }
      .layoutWeight(1)
    }
    .hideTitleBar(true)
    .padding({
      left: $r('app.float.space_l'),
      right: $r('app.float.space_l'),
    })
    .onReady((context) => {
      if (context.pathStack) {
        this.stack = context.pathStack;
      }
    })
    .onShown(() => {
      this.getMessageGroup()
    })
  }

  @Builder
  buildHeader() {
    Row() {
      if (this.stack?.size?.()) {
        CommonSymbol({
          src: $r('sys.symbol.chevron_left'),
          color: $r('app.color.font_color_level1'),
        })
          .margin({ right: $r('app.float.space_l') })
          .onClick(() => {
            this.stack.pop()
          })
      }
      Text('消息通知')
        .fontSize($r('sys.float.Title_S'))
        .fontColor($r('app.color.font_color_level1'))
        .fontWeight(FontWeight.Bold)
      Blank()
      Row() {
        SymbolGlyph($r('sys.symbol.clean'))
          .fontSize(24)
          .fontColor([$r('sys.color.font_primary')])
      }
      .width(40)
      .height(40)
      .borderRadius(20)
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        NoticeApis.changeAllNoticeReadStatus().then(async (res) => {
          if (res === 0) {
            await this.getMessageGroup()
            WindowUtil.toast('操作成功')
          }
        })
      })
    }
    .width('100%')
  }

  @Builder
  buildMessageGroup() {
    List() {
      ForEach(this.groups, (group: MessageGroup) => {
        ListItem() {
          Row() {
            Badge({
              count: group.unreadCount,
              style: {
                badgeSize: 16,
                badgeColor: $r('app.color.theme_color'),
                fontWeight: FontWeight.Medium,
                fontSize: 10,
              },
              position: BadgePosition.RightTop,
            }) {
              Image(group.icon)
                .width(48)
                .height(48)
                .borderRadius(24)
            }
            .margin({ right: $r('app.float.space_s') })

            Column({ space: 4 }) {
              Row() {
                Text(group.title)
                  .layoutWeight(1)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .fontWeight(FontWeight.Medium)
                Text(formatTimestamp(group.latestTime))
                  .fontSize(12)
                  .fontColor($r('app.color.font_color_level2'))

              }
              .width('100%')


              Text(group.latestContent)
                .width('100%')
                .fontSize(12)
                .fontColor($r('app.color.font_color_level2'))
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .justifyContent(FlexAlign.Start)
            .layoutWeight(1)
          }
          .padding({
            top: $r('app.float.space_m'),
            bottom: $r('app.float.space_m'),
          })
          .onClick(() => {
            this.stack.pushPath({ name: NoticeRouterMap.NOTICE_LIST, param: group })
            NoticeApis.changeNoticeReadStatus(group.type)
          })
        }
      }, (group: MessageGroup) => group.type + group.title)
    }
    .divider({
      strokeWidth: 1,
      startMargin: 56,
    })
    .scrollBar(BarState.Off)
    .padding({ top: $r('app.float.space_l') })
  }

  async getMessageGroup() {
    this.loading = true
    const res = await NoticeApis.getNoticeGroups()
    if (res.length) {
      this.groups = res;
    }
    this.loading = false;
  }
}