/**
 * 机票行程信息组件（用于往返场景）
 */
@ComponentV2
export struct TicketTripInfo {
  @Param label: string = '' // 标签：去程/返程
  @Param timeDate: string = ''
  @Param weekDate: string = ''
  @Param startDate: string = ''
  @Param endDate: string = ''
  @Param startLocation: string = ''
  @Param endLocation: string = ''
  @Param flightInfo: string = '国航｜海南航空HU760｜波音787｜有餐食'

  build() {
    Column() {
      Row() {
        Text(this.label)
          .fontSize(10)
          .padding(4)
          .borderRadius(4)
          .backgroundColor('#FEE231')
        Text() {
          Span(this.timeDate)
          Span(this.weekDate)
        }
        .fontSize(12)
        .margin({ left: 2 })
      }
      .margin({ bottom: 8 })

      Row() {
        Row() {
          Text(this.startDate)
            .fontSize(14)
          Image($r('app.media.ic_right'))
            .width(20)
          Text(this.endDate)
            .fontSize(14)
        }
        .margin({ right: 12 })

        Row() {
          Text(this.startLocation)
            .fontSize(14)
          Image($r('app.media.ic_right'))
            .width(20)
          Text(this.endLocation)
            .fontSize(14)
        }
      }
      .margin({ bottom: 8 })

      Row() {
        Image($r('app.media.ic_ticket'))
          .width(10)
        Text(this.flightInfo)
          .fontSize(10)
          .fontColor('#000')
          .opacity(0.4)
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
