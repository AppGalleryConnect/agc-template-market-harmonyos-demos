import { FormatUtil, RouterMap } from 'commonlib'
import { INoticeItem } from 'network/src/main/ets/types/responseTypes/NoticeResp'
import { FinancialInformationVM } from '../viewModels/FinancialInformationVM'

@Builder
export function FinancialInformationBuilder() {
  FinancialInformation()
}

@ComponentV2
struct FinancialInformation {
  vm: FinancialInformationVM = FinancialInformationVM.instance

  async aboutToAppear() {
    await this.vm.init()
  }

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          ForEach(this.vm.noticeList, (notice: INoticeItem) => {
            Flex() {
              Column() {
                Image(notice.img)
                  .width(96)
                  .height(54)
                  .borderRadius(8)
              }
              .width(96)
              .flexShrink(0)
              .padding({
                top: 13,
                bottom: 13
              })
              .margin({ right: 12 })

              Row() {
                Column() {
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
                .height(54)
                .alignItems(HorizontalAlign.Start)
                .justifyContent(FlexAlign.SpaceBetween)
              }
              .flexGrow(1)
              .padding({
                top: 13,
                bottom: 13
              })
              .borderWidth({ bottom: 1 })
              .borderColor($r('sys.color.comp_divider'))
            }
            .width('100%')
            .height(80)
            .onClick(() => {
              FormatUtil.jumpToNext(RouterMap.INFORMATION_INFO, notice)
            })
          }, (item: INoticeItem[]) => JSON.stringify(item))
        }
        .padding({ left: 16, right: 16 })
      }
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .title('理财资讯')
  }
}