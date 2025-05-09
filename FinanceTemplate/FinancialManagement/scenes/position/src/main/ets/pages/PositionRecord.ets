import { IPositionRecord } from 'network/src/main/ets/types/responseTypes/GetPositionInfoResp';
import { PositionRecordVM } from '../viewModels/PositionRecordVM';

@Builder
export function PositionRecordBuilder() {
  PositionRecord()
}

@Entry
@ComponentV2
struct PositionRecord {
  vm: PositionRecordVM = PositionRecordVM.instance

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          Column() {
            Text() {
              Span(this.vm.positionInfo?.productName)
              Span('(' + this.vm.positionInfo?.productNumber + ')')
            }
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
          }
          .width('100%')
          .height(56)
          .alignItems(HorizontalAlign.Start)
          .justifyContent(FlexAlign.Center)
          .padding({ left: 16, right: 16 })
          .backgroundColor(Color.White)
          .margin({ bottom: 8 })

          Column() {
            ForEach(this.vm.positionRecord, (record: IPositionRecord, index: number) => {
              Column() {
                Flex({ justifyContent: FlexAlign.SpaceBetween }) {
                  Text() {
                    if (record.type === 2) {
                      Span('购买')
                    } else if (record.type === 3) {
                      Span('到期')
                    } else if (record.type === 4) {
                      Span('赎回')
                    }
                  }
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('sys.color.font_primary'))

                  Text(record.amount + '元')
                    .fontSize(14)
                    .fontWeight(FontWeight.Medium)
                    .fontColor($r('sys.color.font_primary'))
                }
                .padding({ top: 12, bottom: 4 })

                Flex({ justifyContent: FlexAlign.SpaceBetween }) {
                  Text() {
                    Span(record.date)
                    Span(' ')
                    Span(record.time)
                  }
                  .fontSize(12)
                  .fontWeight(FontWeight.Regular)
                  .fontColor($r('sys.color.font_secondary'))

                  Text(record.state !== 1 ? '交易关闭' : '')
                    .fontSize(12)
                    .fontWeight(FontWeight.Regular)
                    .fontColor($r('sys.color.font_secondary'))
                }
                .padding({ bottom: 9 })

                if (this.vm.positionRecord.length - 1 !== index) {
                  Divider().color($r('sys.color.comp_divider'))
                }
              }
            }, (item: IPositionRecord[]) => JSON.stringify(item))
          }
          .width('100%')
          .padding({ left: 16, right: 16 })
          .backgroundColor(Color.White)
        }
      }
      .scrollBar(BarState.Off)
    }
    .title('交易记录')
    .backgroundColor($r('sys.color.background_secondary'))
    .onShown(() => {
      this.vm.init()
    })
  }
}