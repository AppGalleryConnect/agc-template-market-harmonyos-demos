import { Constants, UserInfo } from 'common'

@ComponentV2
export struct SpaceViews {
  @Param @Require userInfo :UserInfo

  build() {
    Column() {
      Column({ space: 8 }) {
        Text('我的空间')
          .font({
            size: 16,
            weight: 500,
          })
          .fontColor($r('app.color.dark_color_444444'))
          .height(19)
          .align(Alignment.Start)

        Row() {
          Row()
            .backgroundColor($r('app.color.blue_color_2FAFFF'))
            .height(Constants.FULL_SIZE)
            .width(this.userInfo.isVip ? this.userInfo.usedMemory / 2 + '%' :this.userInfo.usedMemory+`%`)
            .borderRadius(6)
        }
        .width(Constants.FULL_SIZE)
        .height($r('app.float.vp_12'))
        .backgroundColor($r('sys.color.comp_background_secondary'))
        .justifyContent(FlexAlign.Start)
        .borderRadius(6)

        Row() {
          Text(this.userInfo.isVip ?'总容量40GB' : '总容量20GB')
            .font({
              size: 12,
              weight: 400
            })
            .align(Alignment.Start)
            .fontColor($r('app.color.gray_color_A1ABBD'))
            .height(14)
          Blank()
          Text('已使用'+this.userInfo.usedMB+'MB')
            .font({
              size: 12,
              weight: 400
            })
            .align(Alignment.End)
            .fontColor($r('app.color.gray_color_A1ABBD'))
            .height(14)
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(VerticalAlign.Center)
        .width(Constants.FULL_SIZE)
        .height(14)

      }
      .alignItems(HorizontalAlign.Start)
      .backgroundColor($r('app.color.white'))
      .borderRadius(16)
      .width(Constants.FULL_SIZE)
      .height(Constants.FULL_SIZE)
      .padding(12)
    }
    .padding({ left: 12, right: 12 })
    .height(85)
    .width(Constants.FULL_SIZE)
  }
}