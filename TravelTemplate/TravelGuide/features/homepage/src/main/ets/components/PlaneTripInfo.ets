/**
 * 火车票行程信息组件（用于往返场景）
 */
@ComponentV2
export struct PlaneTripInfo {
  @Param label: string = ''  // 标签：去程/返程
  @Param timeDate: string = ''
  @Param weekDate: string = ''
  @Param duration: string = ''
  @Param trainNumber: string = ''
  @Param startDate: string = ''
  @Param endDate: string = ''
  @Param startLocation: string = ''
  @Param endLocation: string = ''

  build() {
    Column() {
      Row() {
        Row() {
          Text(this.label)
            .fontSize(10)
            .padding(4)
            .borderRadius(4)
            .backgroundColor('#FEE231')
          Text() {
            Span(this.timeDate + ' ')
            Span(this.weekDate + ' ')
            Span('全程' + this.duration)
          }
          .fontSize(12)
          .margin({ left: 2 })
        }
        Text('车次' + this.trainNumber)
          .fontSize(12)
          .opacity(0.5)
          .textAlign(TextAlign.End)
          .layoutWeight(1)
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 10 })

      Row() {
        Column() {
          Text(this.startDate)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .margin({ bottom: 10 })
          Text(this.endDate)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
        }
        .margin({ right: 12 })
        Column() {
          Image($r('app.media.ic_car_line'))
            .width(4)
        }
        .margin({ right: 12 })
        Column() {
          Text(this.startLocation)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .margin({ bottom: 10 })
          Text(this.endLocation)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
        }
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
