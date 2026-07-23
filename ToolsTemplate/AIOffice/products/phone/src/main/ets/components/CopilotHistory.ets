import { StoreInfo, StoreManager } from '@hw-agconnect/copilot';
import dayJs from 'dayjs';
import utc from 'dayjs/plugin/utc';
import { TipsDialog } from '@kit.ArkUI';

dayJs.extend(utc)

@ComponentV2
export struct CopilotHistory {
  @Param isDeleted: boolean = false;
  @Param storeId?: string = undefined;
  @Event onClickEvent?: (threadId: string) => void;
  @Local infos: StoreInfo[] = []
  @Local deleteThreadIds: string[] = [];
  @Local isAllChecked: boolean = false; // 是否处于全选
  @Local isAllCheckClicked: boolean = false; // 是否点击全选按钮
  deleteController: CustomDialogController = new CustomDialogController({
    builder: TipsDialog({
      content: '确定删除历史记录吗？',
      primaryButton: {
        value: '取消',
        action: () => {
        },
      },
      secondaryButton: {
        value: '确定',
        action: () => {
          this.onDeleteConfirm()
        }
      }
    })
  })

  @Monitor('storeId')
  onStoreIdChanged(): void {
    StoreManager.getStore(this.storeId).getAll().then((stores) => {
      this.infos = stores;
    })
  }

  aboutToAppear(): void {
    StoreManager.getStore(this.storeId).getAll().then((stores) => {
      this.infos = stores;
    })
  }

  onDeleteConfirm() {
    if (this.deleteThreadIds.length) {
      this.infos = this.infos.filter((storeInfo: StoreInfo) => {
        if (this.deleteThreadIds.includes(storeInfo.threadId)) {
          StoreManager.getStore(this.storeId).deleteMessages(storeInfo.threadId)
        }
        return !this.deleteThreadIds.includes(storeInfo.threadId)
      })
      this.deleteThreadIds = []
    }
  }

  build() {
    Column() {
      if (this.infos.length) {
        List() {
          ForEach(this.infos, (item: StoreInfo) => {
            ListItem() {
              this.historyItemBuilder(item)
            }
            .onClick(() => {
              this.onClickEvent?.(item.threadId)
            })
          }, (item: StoreInfo, index: number): string => item.threadId)
        }
        .padding({ top: 8 })
        .layoutWeight(1)
        .scrollBar(BarState.Off)

        Row() {
          Column({ space: 4 }) {
            SymbolGlyph($r(this.isAllChecked ? 'sys.symbol.checkmark_square_on_square_fill' :
              'sys.symbol.checkmark_square_on_square'))
              .fontSize($r('sys.float.Title_M'))
              .fontColor([$r(this.isAllChecked ? 'sys.color.font_emphasize' : 'sys.color.font_primary')])
            Text('全选')
              .fontSize($r('sys.float.Caption_M'))
              .fontColor($r('sys.color.font_primary'))
              .fontWeight(FontWeight.Regular)
          }
          .width('50%')
          .onClick(() => {
            this.isAllCheckClicked = !this.isAllCheckClicked;
            this.isAllChecked = this.isAllCheckClicked
          })

          Column({ space: 4 }) {
            SymbolGlyph($r('sys.symbol.trash'))
              .fontSize($r('sys.float.Title_M'))
              .fontColor([$r('sys.color.font_primary')])
            Text('删除')
              .fontSize($r('sys.float.Caption_M'))
              .fontColor($r('sys.color.font_primary'))
              .fontWeight(FontWeight.Regular)
          }
          .width('50%')
          .margin({ top: 5, bottom: 5 })
          .opacity(this.deleteThreadIds.length ? 1 : 0.4)
          .enabled(this.deleteThreadIds.length > 0)
          .onClick(() => {
            this.deleteController.open()
          })
        }
        .width('100%')
        .visibility(this.isDeleted ? Visibility.Visible : Visibility.None)
      } else {
        this.noneResultComp()
      }
    }
    .margin({ bottom: 28 })
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Start)
  }

  @Builder
  historyItemBuilder(item: StoreInfo) {
    Column() {
      Text(this.getFormatTime(item.createTime, 'YYYY-MM-DD'))
        .fontColor($r('sys.color.font_secondary'))
        .fontSize($r('sys.float.Body_M'))
        .fontWeight(FontWeight.Regular)
        .margin({ bottom: 16 })
        .textAlign(TextAlign.Start)

      Row({ space: 10 }) {
        Checkbox()
          .width(20)
          .height(20)
          .visibility(this.isDeleted ? Visibility.Visible : Visibility.None)
          .select(this.isAllCheckClicked)
          .onChange((isChecked: boolean) => {
            if (isChecked) {
              this.deleteThreadIds.push(item.threadId)
            } else {
              this.deleteThreadIds.splice(this.deleteThreadIds.indexOf(item.threadId), 1)
              this.isAllChecked = false
            }
            if (this.deleteThreadIds.length === this.infos.length) {
              this.isAllChecked = true
              this.isAllCheckClicked = this.isAllChecked
            }
          })

        Text(item.title)
          .fontColor($r('sys.color.font_primary'))
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Normal)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .textAlign(TextAlign.Start)
          .wordBreak(WordBreak.BREAK_ALL)
      }
      .height(24)
    }
    .width('100%')
    .padding({ top: 8, bottom: 8 })
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Start)
  }

  @Builder
  noneResultComp() {
    Column() {
      Image($r('app.media.no_history_result'))
        .width(120)
        .height(120)
      Text('暂无历史')
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('sys.color.font_tertiary'))
        .fontWeight(FontWeight.Regular)
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
  }

  /**
   * 转化成需要格式的日期
   *
   * @param time 需要的时间
   * @param format 需要的时间格式
   */
  public getFormatTime(time: string | number | Date, format?: string): string {
    let historyTime = new Date(time).toString()
    let currentTime = new Date().toString()
    if (dayJs(historyTime).isSame(dayJs(currentTime), 'day')) {
      return '今天'
    }
    return dayJs.utc(historyTime).format(format)
  }
}