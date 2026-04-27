import { NoticeRouterMap } from '../commons/Enums';
import { MessageGroup } from '../commons/Types';
import { formatTimestamp } from '../commons/Utils';
import { SetReadIcon } from '../components/SetReadIcon';
import { ToastLoading } from '../components/ToastLoading';
import { NoticeApis } from '../https/Apis';
import { MOCK_DEFAULT_MESSAGE_GROUP } from '../https/MockData';
import { PopViewUtils } from '../utils/PopViewUtil';
import { WindowLayoutUtil } from '../utils/WindowLayoutUtil';


@Builder
export function noticeCenterPageBuilder() {
  NoticeCenterPage()
}

@ComponentV2
export struct NoticeCenterPage {
  @Local stack: NavPathStack = new NavPathStack();
  @Local groups: MessageGroup[] = MOCK_DEFAULT_MESSAGE_GROUP;
  @Local loading: boolean = false;
  win: WindowLayoutUtil = WindowLayoutUtil.instance;

  aboutToAppear(): void {
    // 初始化
    const uiContext = this.getUIContext();
    PopViewUtils.initContext(uiContext);
    this.win.setAvoidSize(uiContext)
  }

  @Computed
  get allowClean() {
    return this.groups.some(v => v.unreadCount !== 0);
  }

  build() {
    NavDestination() {
      Column() {
        this.buildHeader()
        this.buildMessageGroup()
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
    .onReady((context) => {
      if (context.pathStack) {
        this.stack = context.pathStack;
      }
    })
    .onWillShow(() => {
      this.getMessageGroup()
    })
  }

  @Builder
  buildHeader() {
    Row() {
      if (this.stack?.size?.()) {
        Button() {
          SymbolGlyph($r('sys.symbol.chevron_backward'))
            .fontSize(20)
            .fontColor([$r('sys.color.icon_primary')])
        }
        .width(40)
        .height(40)
        .margin({ right: $r('app.float.space_s') })
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .onClick(() => {
          this.stack.pop()
        })
      }
      Text('消息通知')
        .fontSize($r('sys.float.Title_S'))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Bold)
      Blank()

      SetReadIcon({
        enable: this.allowClean,
        confirm: () => {
          NoticeApis.changeAllNoticeReadStatus().then(async (res) => {
            if (res === 0) {
              await this.getMessageGroup()
              this.getUIContext().getPromptAction().showToast({
                message: '操作成功',
              })
            }
          })
        },
      })
    }
    .width('100%')
    .height(56)
  }

  @Builder
  buildMessageGroup() {
    List() {
      Repeat(this.groups)
        .each((group: RepeatItem<MessageGroup>) => {
          ListItem() {
            Row() {
              Badge({
                count: group.item.unreadCount,
                style: {
                  badgeSize: 16,
                  badgeColor: $r('app.color.theme_color'),
                  fontWeight: FontWeight.Medium,
                  fontSize: 10,
                },
                position: BadgePosition.RightTop,
              }) {
                Image(group.item.icon)
                  .width(48)
                  .height(48)
                  .borderRadius(24)
              }
              .margin({ right: $r('app.float.space_s') })

              Column({ space: 4 }) {
                Row() {
                  Text(group.item.title)
                    .layoutWeight(1)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .fontWeight(FontWeight.Medium)
                  if (group.item.latestTime) {
                    Text(formatTimestamp(group.item.latestTime))
                      .fontSize(12)
                      .fontColor($r('sys.color.font_secondary'))
                  }
                }
                .width('100%')

                Text(group.item.latestContent || `暂无最新${group.item.title}`)
                  .width('100%')
                  .fontSize(12)
                  .fontColor($r('sys.color.font_secondary'))
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
              this.stack.pushPath({ name: NoticeRouterMap.NOTICE_LIST, param: group.item })
              NoticeApis.changeNoticeReadStatus(group.item.type)
            })
          }
        })
        .key((group: MessageGroup) => JSON.stringify(group))
    }
    .divider({
      color: $r('sys.color.comp_divider'),
      strokeWidth: 0.5,
      startMargin: 56,
    })
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
  }

  async getMessageGroup() {
    ToastLoading.open();
    const res = await NoticeApis.getNoticeGroups()
    if (res.length) {
      this.groups = res;
    }
    ToastLoading.close();
  }
}