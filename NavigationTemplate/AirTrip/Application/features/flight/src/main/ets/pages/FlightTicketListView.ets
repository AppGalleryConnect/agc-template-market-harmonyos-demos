import { Constants } from 'common'
import { FlightSpaceInfo } from '../model/FlightPageModel'

@ComponentV2
export struct FlightTicketListView {
  @Param type: string = ''
  @Param listData: FlightSpaceInfo[] = []
  @Event bookTicket: (flight: FlightSpaceInfo) => void = (flight: FlightSpaceInfo) =>{}
  @Event viewBaggagePolicy: () => void = () =>{}

  build() {
    Column({space: 8}) {
      ForEach(this.listData, (item: FlightSpaceInfo) => {
        Column({space: 10}) {
          Row() {
            Column({space: 8}) {
              Row({space: 8}) {
                Text(Constants.RMB + item.spacePrice).fontSize(16).fontWeight(FontWeight.Medium)
                  .fontColor(Color.Red)
                Text(`${Number(item.spaceDiscount).toFixed(1)}折`).fontSize(10).fontColor('#99000000')
                  .padding({left:8, right: 8, top: 2, bottom: 2})
                  .border({
                    width: 1,
                    color: '#33000000',
                    style: BorderStyle.Solid,
                    radius: 4
                  })
              }

              Row({space: 4}) {
                Text(item.spaceType === 'ECONOMY_CLASS' ? '经济舱' : '公务舱').fontSize(12).fontColor('#99000000')
                Divider().strokeWidth(1).color('#99000000').height(10).vertical(true)
                Row({space: 4}) {
                  Text('行李改签政策').fontSize(12).fontColor('#99000000')
                  Image($r('app.media.ic_right_arrow'))
                    .width(12)
                    .height(12)
                    .fillColor('#787878')
                }
                .onClick(() => {
                  this.viewBaggagePolicy && this.viewBaggagePolicy()
                })
              }
            }
            .alignItems(HorizontalAlign.Start)
            Button('预订', { type: ButtonType.Capsule })
              .fontColor($r('sys.color.white'))
              .fontWeight(400)
              .backgroundColor('#E84026')
              .width(72)
              .height(28)
              .onClick(() => {
                this.bookTicket && this.bookTicket(item)
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)

          Divider().color($r('sys.color.comp_divider')).width('100%')

          Column({space: 8}) {
            Row({space: 8}) {
              Image($r('app.media.ic_suitcase')).width(12).height(12)
              Text(item.refundChangePolicy).fontSize(10).fontColor('#99000000')
            }
            Row({space: 8}) {
              Image($r('app.media.ic_refund_ticket')).width(12).height(12)
              Text(item.baggagePolicy).fontSize(10).fontColor('#99000000')
            }
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
        }
        .padding(14)
        .borderRadius(16)
        .alignItems(HorizontalAlign.Start)
        .backgroundColor($r('sys.color.white'))
      })
    }
    .width('100%')
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Start)
  }
}