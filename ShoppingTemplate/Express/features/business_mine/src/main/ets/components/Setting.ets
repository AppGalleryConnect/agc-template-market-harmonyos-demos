import { RouterModule } from 'lib_foundation'
import { RouterMap } from 'module_base'

@ComponentV2
export struct Setting {
  build() {
    Row() {
      Row() {
        Image($r('app.media.ic_setting'))
          .width(16)
          .height(16)
          .margin({ right: 4 })
        Text('设置')
          .fontSize(14)
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_primary'))
      }

      Image($r('app.media.ic_arrow_right'))
        .width(14)
        .height(14)
    }
    .width('100%')
    .height(48)
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor(Color.White)
    .margin({ bottom: 12 })
    .padding({
      left: 12,
      right: 12
    })
    .borderRadius(16)
    .onClick(() => {
      RouterModule.push({ url: RouterMap.SETTING_PAGE })
    })
  }
}