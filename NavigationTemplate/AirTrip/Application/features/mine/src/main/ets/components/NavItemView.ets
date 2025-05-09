import { NavItem } from '../model/MinePageModel'

@ComponentV2
export struct NavItemView {
  @Param data: NavItem = new NavItem('','','')
  @Event clickItem: () => void

  build() {
    Row() {
      Row({ space: 10 }) {
        Image(this.data.icon).width(24).height(24)
        Text(this.data.label).fontWeight(400).fontSize(16)
      }

      Image($r('app.media.ic_right_arrow'))
        .width(16)
        .height(16)
        .fillColor('#cccccc')
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({left: 12, right: 12, top: 13, bottom: 13})
    .borderRadius(16)
    .backgroundColor($r('sys.color.white'))
    .onClick(() => {
      this.clickItem && this.clickItem()
    })
  }
}