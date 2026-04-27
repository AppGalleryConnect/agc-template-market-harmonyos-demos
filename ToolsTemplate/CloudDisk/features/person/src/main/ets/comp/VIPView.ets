import { VipCenterPageBuilder } from 'collect_personal_info'
import { Constants, RouterMap } from 'common'
import { phoneRouterControl } from 'oh_router'

@ComponentV2
export  struct VIPView {
  build() {
    Column() {
      Row() {
        Image($r('app.media.ic_vip'))
          .size({
            width: 40,
            height: 40
          })

        Column({ space: 5 }) {
          Text('加入会员VIP获取更多流量')
            .font({
              size: 12,
              weight: 500
            })
            .align(Alignment.Start)
            .height(14)
            .fontColor($r('app.color.black_color'))

          Text('另有新人专属福利 送完即止')
            .font({
              size: 10,
              weight: 400
            })
            .align(Alignment.Start)
            .height(12)
            .fontColor($r('app.color.orange_color_FF8D4F'))
        }
        .margin({ left: 14 })
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Start)

        Blank()

        Text('立即加入')
          .onClick(() => {
            phoneRouterControl.jumpPage({
              pageName: RouterMap.VIP_CENTER_PAGE,
              builder: wrapBuilder(VipCenterPageBuilder)
            })
          })
          .backgroundColor($r('app.color.orange_color_FF8D4F'))
          .font({
            size: 12,
            weight: 500
          })
          .textAlign(TextAlign.Center)
          .fontColor($r('app.color.white'))
          .width(80)
          .height(26)
          .borderRadius(15)
      }
      .justifyContent(FlexAlign.Start)
      .alignItems(VerticalAlign.Center)
      .backgroundColor($r('app.color.white'))
      .borderRadius(16)
      .width(Constants.FULL_SIZE)
      .height(Constants.FULL_SIZE)
      .padding({ left: 20, right: 24 })
    }
    .padding({ left: 12, right: 12 })
    .height(52)
    .width(Constants.FULL_SIZE)
  }
}