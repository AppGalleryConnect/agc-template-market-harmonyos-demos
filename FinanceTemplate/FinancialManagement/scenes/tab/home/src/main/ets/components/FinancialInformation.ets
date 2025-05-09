import { FormatUtil, RouterMap } from 'commonlib'
import { INoticeItem } from 'network/src/main/ets/types/responseTypes/NoticeResp'
import { HomePageVM } from '../viewModels/HomePageVM'

@ComponentV2
export struct FinancialInformation {
  vm: HomePageVM = HomePageVM.instance

  build() {
    Column() {
      Flex({ justifyContent: FlexAlign.SpaceBetween }) {
        Text('理财资讯')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
        Row() {
          Text('更多')
            .fontSize(14)
            .fontWeight(FontWeight.Regular)
          Image($r('app.media.ic_chevron_right'))
            .width(12)
            .height(24)
        }
        .onClick(() => {
          FormatUtil.jumpToNext(RouterMap.FINANCIAL_INFORMATION)
        })
      }
      .margin({ bottom: 16 })

      Column() {
        ForEach(this.vm.noticeList, (notice: INoticeItem, index: number) => {
          Flex() {
            Row() {
              Image(notice.img)
                .width('100%')
                .height('100%')
                .borderRadius(8)
            }
            .width(96)
            .height(54)
            .flexShrink(0)
            .margin({ right: 12 })

            Column() {
              Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.SpaceBetween }) {
                Column() {
                  Text(notice.name)
                    .fontSize(14)
                    .fontWeight(FontWeight.Medium)
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                }

                Row() {
                  Text(notice.date)
                    .fontSize(12)
                    .fontWeight(FontWeight.Medium)
                    .opacity(0.4)
                }
              }
              .width('100%')

              if (this.vm.noticeList.length - 1 !== index) {
                Divider().color($r('sys.color.comp_divider')).margin({ top: 13 })
              }
            }
            .flexGrow(1)
            .height(54)
          }
          .padding({
            left: 12,
            right: 12,
            top: 13,
            bottom: 13
          })
          .onClick(() => {
            FormatUtil.jumpToNext(RouterMap.INFORMATION_INFO, notice)
          })
        }, (item: INoticeItem[]) => JSON.stringify(item))
      }
      .padding({ top: 8, bottom: 8 })
      .borderRadius(16)
      .backgroundColor(Color.White)
    }
    .margin({ top: 24, bottom: 30 })
  }
}