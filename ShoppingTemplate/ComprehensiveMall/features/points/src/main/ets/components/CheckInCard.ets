import { LengthMetrics } from '@kit.ArkUI'

@ComponentV2
export struct CheckInCard {
  @Param
  checkedDays: number = 0
  @Param
  pointsList: number[] = [5, 10, 15, 20, 25, 30, 40]
  @Param
  isCheckedToday: boolean = false
  @Event
  handleCheckIn: () => void = () => {
  }

  build() {
    Column({ space: 16 }) {
      Row() {
        Text('签到7天 赚积分')
          .fontColor($r('app.color.font_color_level1'))
          .fontWeight(FontWeight.Bold)
        Text() {
          Span('已打卡')
          Span(this.checkedDays.toString()).fontColor($r('app.color.theme_color'))
          Span('/7天')
        }
        .fontSize($r('app.float.font_size_12'))
        .fontColor($r('app.color.font_color_level2'))
      }
      .width($r('app.string.size_percent_full'))
      .justifyContent(FlexAlign.SpaceBetween)

      Flex({ space: { main: LengthMetrics.vp(12) } }) {
        ForEach(this.pointsList, (points: number, index: number) => {
          Column({ space: 8 }) {
            Stack({ alignContent: Alignment.Bottom }) {
              Image(index < this.checkedDays ? $r('app.media.ic_checked_bg') : $r('app.media.ic_check_bg'))
                .width('100%')
                .opacity(index < this.checkedDays ? 0.4 : 1)
              Text(points.toString())
                .fontSize($r('app.float.font_size_12'))
                .fontColor($r('app.color.font_color_level1_invert'))
                .margin({ bottom: $r('app.float.space_xs') })
            }

            Text(`第${index + 1}天`)
              .fontColor($r('app.color.font_color_level1'))
              .fontSize($r('app.float.font_size_10'))
          }
        }, (point: number, index: number) => index + '__' + point)
      }

      Button(this.isCheckedToday ? '已签到' : '签到')
        .backgroundColor($r('app.color.theme_color'))
        .width($r('app.string.size_percent_full'))
        .constraintSize({ maxWidth: 280 })
        .enabled(!this.isCheckedToday)
        .onClick(() => {
          this.handleCheckIn?.()
        })
    }
    .width($r('app.string.size_percent_full'))
    .constraintSize({ maxWidth: 720 })
    .borderRadius($r('app.float.border_radius_l'))
    .padding($r('app.float.space_m'))
    .backgroundColor($r('app.color.background_color_primary'))
  }
}
