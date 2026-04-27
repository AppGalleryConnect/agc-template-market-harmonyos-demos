import { Constants, UserInfo } from 'common'

@ComponentV2
export struct BGTopView {
  @Param @Require userInfo :UserInfo

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column()
        .width(Constants.FULL_SIZE)
        .height(Constants.FULL_SIZE)
        .linearGradient({
          angle: 180,
          direction: GradientDirection.Top,
          colors: [[$r('app.color.blue_sky'), 0], [$r('app.color.bg_color'), 1]]
        })

      Stack({ alignContent: Alignment.Center }) {
        Image($r('app.media.ic_circle'))
          .width(240)
          .height(240)

        Column({ space: 14 }) {
          Row() {
            Text(this.userInfo.isVip ? this.userInfo.usedMemory /2 + ``: this.userInfo.usedMemory.toString())
              .font({
                size: 60,
                weight: 500
              })
              .fontColor($r('app.color.white'))
              .height(60)

            Text('%')
              .font({
                size: 20,
                weight: 500
              })
              .fontColor($r('app.color.white'))
              .height(20)
          }
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Bottom)

          Text('当前已使用')
            .font({
              size: 14,
              weight: 500
            })
            .textAlign(TextAlign.Center)
            .fontColor($r('app.color.white'))
            .height(16)
        }

      }
      .margin({ bottom: 14 })
    }
    .width(Constants.FULL_SIZE)
    .height(320)
  }
}