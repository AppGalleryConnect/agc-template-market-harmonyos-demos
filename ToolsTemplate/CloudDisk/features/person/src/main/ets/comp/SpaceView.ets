import { Constants, FileInfo, RouterMap, UserInfo } from 'common'
import { phoneRouterControl } from 'oh_router'
import { LoginPageBuilder } from '../views/LoginPage'

// 个人空间组件
@ComponentV2
export struct SpaceView {
  @Param isLogin: boolean = true
  @Event blockClick: () => void
  @Param @Require isVip: boolean
  @Param @Require userInfo: UserInfo

  build() {
    Column() {
      Column() {
        Row({ space: 8 }) {
          Text(this.isVip ? '会员个人空间' : '个人空间')
            .font({
              size: $r('sys.float.Body_M'),
              weight: FontWeight.Medium,
            })
            .fontColor(this.isVip ? $r('app.color.orange_color_C48458') : $r('app.color.dark_color_444444'))
            .height($r('app.float.vp_16'))
            .align(Alignment.Start)
          if (this.userInfo.isLogin) {
            Text(this.isVip ? this.userInfo.usedMemorytitle + '/40G' :
              this.userInfo.usedMemorytitle + '/20G')
              .font({
                size: $r('sys.float.Body_S'),
                weight: FontWeight.Medium,
              })
              .fontColor($r('sys.color.font_tertiary'))
              .height($r('app.float.vp_14'))
              .align(Alignment.End)
          } else {
            Text('0/20G')
              .font({
                size: $r('sys.float.Body_S'),
                weight: FontWeight.Medium,
              })
              .fontColor($r('sys.color.font_tertiary'))
              .height($r('app.float.vp_14'))
              .align(Alignment.End)
          }
          Blank()
          Image($r('app.media.iconRight'))
            .width($r('app.float.vp_20'))
            .height($r('app.float.vp_20'))
        }
        .width(Constants.FULL_SIZE)
        .justifyContent(FlexAlign.Start)
        .alignItems(VerticalAlign.Center)

        Row() {
          if (this.userInfo.isLogin) {
            Row()
              .backgroundColor(this.isVip ? $r('app.color.orange_color_FFC775') : $r('app.color.blue_color_2FAFFF'))
              .height(Constants.FULL_SIZE)
              .width((this.isVip ? this.userInfo.usedMemory / 2 :
              this.userInfo.usedMemory).toString() + '%')
              .borderRadius(1.5)
          } else {
            Row()
              .backgroundColor($r('app.color.blue_color_2FAFFF'))
              .height(Constants.FULL_SIZE)
              .width('0%')
              .borderRadius(1.5)
          }
        }
        .width(Constants.FULL_SIZE)
        .height($r('app.float.vp_3'))
        .backgroundColor($r('sys.color.comp_background_secondary'))
        .margin({ top: $r('app.float.vp_10') })
        .justifyContent(FlexAlign.Start)
        .borderRadius(1.5)

          if (!this.isLogin) {
          Row({ space: 4 }) {
            Image($r('app.media.icon_vip'))
              .width($r('app.float.vp_23'))
              .height($r('app.float.vp_13'))
            Text('加入会员获取更大容量')
              .font({
                size: $r('sys.float.Body_S')
              })
              .textAlign(TextAlign.Start)
              .fontColor($r('app.color.orange_color_C48458'))
          }
          .margin({ top: $r('app.float.vp_10') })
          .justifyContent(FlexAlign.Start)
          .alignItems(VerticalAlign.Center)

        }
      }
      .alignItems(HorizontalAlign.Start)
      .backgroundColor($r('app.color.white'))
      .borderRadius($r('app.float.vp_16'))
      .width(Constants.FULL_SIZE)
      .height(Constants.FULL_SIZE)
      .padding({
        top: $r('app.float.vp_14'),
        left: $r('app.float.vp_12'),
        bottom: $r('app.float.vp_12'),
        right: $r('app.float.vp_12')
      })
    }
    .onClick(() => {
      if (!this.isLogin) {
        phoneRouterControl.jumpPage({
          pageName: RouterMap.LOGIN_PAGE,
          builder: wrapBuilder(LoginPageBuilder)
        })
      } else {
        if (this.blockClick) {
          this.blockClick()
        }
      }

    })
    .height(this.isLogin ? $r('app.float.vp_56') : $r('app.float.vp_78'))
    .width(Constants.FULL_SIZE)
  }
}