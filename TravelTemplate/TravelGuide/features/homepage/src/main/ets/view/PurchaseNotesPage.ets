import { BarVM } from 'common';
import { phoneRouterControl } from 'oh_router';
import { tableItem, tableContent } from 'common_travel_guide'
import { PurchaseNotesPageVM } from '../viewmodel/PurchaseNotesPageVM'


@Builder
export function PurchaseNotesPageBuilder() {
  PurchaseNotesPage()
}

@ComponentV2
export struct PurchaseNotesPage {
  vm: PurchaseNotesPageVM = new PurchaseNotesPageVM()

  // 顶部标题
  @Builder
  HeaderTitleBuilder() {
    Row({ space: 8 }) {
      // 返回按钮
      Image($r('app.media.icon_back')).height(40).width(40)
        .onClick(() => {
          this.vm.backPage();
        })
      Text('购买须知')
        .fontColor('#000000')
        .fontSize(20)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width('100%')
    .padding({
      top: 8,
      left: 16,
      bottom: 8,
      right: 16
    })

  }

  // 左边标题，右边内容的table
  @Builder
  tableListVerticalBuilder(list: tableItem[], isShowLeft?: boolean) {
    Column() {
      ForEach(list, (item: tableItem, index: number) => {
        Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Stretch }) {
          // 左边
          if (isShowLeft) {
            Row() {
              Text(item.title)
                .fontSize(13)
                .fontColor('#000000')
            }
            .borderRadius({
              topRight: index === 0 ? 8 : 0,
              topLeft: index === 0 ? 8 : 0,
              bottomLeft: index === list.length - 1 ? 8 : 0,
              bottomRight: index === list.length - 1 ? 8 : 0
            })
            .width(88)
            .justifyContent(FlexAlign.Center)
            .backgroundColor('#EFEFF4')
          }

          // 右边
          Column() {
            ForEach(item.contentList, (contentItem: string, contentIndex: number) => {
              Text(contentItem)
                .fontSize(13)
                .fontColor(item.color ? item.color : 'rgba(0,0,0,0.5)')
            },(contentItem: string) => JSON.stringify(contentItem))
          }
          .padding(10)
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
        }
        .border({
          width: { bottom: index !== list.length - 1 ? 0.5 : 0 },
          color: '#E1E1E1'
        })
      },(item: tableItem) => JSON.stringify(item))
    }
    .width('100%')
    .borderRadius(8)
    .backgroundColor('#FAFAFA')
  }

  @Builder
  tableContentVerticalBuilder(title: string, list: tableItem[], isShowLeft?: boolean) {
    Column() {
      Text(title)
        .fontColor('#000000')
        .fontSize(16)
        .fontWeight(500)
        .margin({ bottom: 14 })
      this.tableListVerticalBuilder(list, isShowLeft);
    }
    .alignItems(HorizontalAlign.Start)
    .backgroundColor($r('sys.color.background_primary'))
    .padding(16)
    .margin({ bottom: 10 })
  }

  // 水平方向
  @Builder
  tableListHorizontalBuilder(list: tableItem[], color: string | undefined) {
    Column() {
      ForEach(list, (item: tableItem, index: number) => {
        Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Stretch }) {
          // 左边
          Row() {
            Text(item.title)
              .fontSize(13)
              .fontColor(color ? color : 'rgba(0,0,0,0.5)')
          }
          .border({
            width: { right: 0.5 },
            color: '#E1E1E1'
          })
          .width('50%')
          .height(28)
          .justifyContent(FlexAlign.Center)

          // 右边
          Column() {
            ForEach(item.contentList, (contentItem: string, contentIndex: number) => {
              Text(contentItem)
                .fontSize(13)
                .fontColor(color ? color : 'rgba(0,0,0,0.5)')
            },(contentItem: string) => JSON.stringify(contentItem))
          }
          .width('50%')
          .height(28)
          .justifyContent(FlexAlign.Center)
          .layoutWeight(1)
        }
        .backgroundColor(index === 0 ? '#FAFAFA' : $r('sys.color.background_primary'))
        .border({
          width: { bottom: index !== list?.length - 1 ? 1 : 0 },
          color: '#E5E5E5'
        })
      },(item: tableItem) => JSON.stringify(item))
    }
    .width('100%')
    .border({
      width: 1,
      color: '#E5E5E5'
    })
  }

  @Builder
  tableContentHorizontalBuilder(title: string, list: tableContent[]) {
    Column() {
      Text(title)
        .fontColor('#000000')
        .fontSize(16)
        .fontWeight(500)
        .margin({ bottom: 14 })
      Column() {
        ForEach(list, (item: tableContent, index: number) => {
          Column() {
            Text(item.describe)
              .fontSize(13)
              .fontColor(item.color ? item.color : 'rgba(0,0,0,0.5)')
            Text(item.subDescribe)
              .fontSize(13)
              .fontColor(item.color ? item.color : 'rgba(0,0,0,0.5)')
              .margin({ bottom: 16 })
            this.tableListHorizontalBuilder(item.tableList, item.color);
            Text(item.remark)
              .fontSize(13)
              .fontColor(item.color ? item.color : 'rgba(0,0,0,0.5)')
              .margin({ top: 16 })
          }
          .margin({ bottom: index !== list.length - 1 ? 20 : 0 })
          .width('100%')
          .alignItems(HorizontalAlign.Start)
        },(item: tableContent) => JSON.stringify(item))
      }
      .alignItems(HorizontalAlign.Start)
      .width('100%')
      .borderRadius(8)
      .padding(10)
      .backgroundColor('#FAFAFA')

    }
    .alignItems(HorizontalAlign.Start)
    .backgroundColor($r('sys.color.background_primary'))
    .padding(16)
    .margin({ bottom: 10 })
  }

  @Builder
  render() {
    Column() {
      this.HeaderTitleBuilder()
      Scroll() {
        Column() {
          this.tableContentVerticalBuilder('预定限制', this.vm.reserveLimitList, true)
          this.tableContentVerticalBuilder('单人/多人入住政策', this.vm.checkInPolicyList, true)
          this.tableContentVerticalBuilder('成团说明', this.vm.groupNotesList, true)
          this.tableContentVerticalBuilder('预定及出行须知', this.vm.bookingTravelNotesList, false)
          this.tableContentHorizontalBuilder('违约条款', this.vm.breachClauseContentList)
          this.tableContentVerticalBuilder('保障提示', this.vm.assuranceTipsList, false)
        }
        .margin({ top: 10 })
      }.layoutWeight(1)
      .scrollBar(BarState.Off)
      .backgroundColor('#F1F3F5')
    }
    .backgroundColor($r('sys.color.background_primary'))
    .padding({ top: BarVM.instance.staBarH, bottom: BarVM.instance.aiBarH })
  }

  build() {
    NavDestination() {
      this.render()
    }
    .hideTitleBar(true)
    .onBackPressed(() => {
      phoneRouterControl.popPage()
      return true
    })
  }
}
