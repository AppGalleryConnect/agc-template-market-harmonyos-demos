import { BaseTextStyleModifier } from 'base_apis'
import { RouterModule } from 'router_module'

@ComponentV2
export struct VernacularContainer {
  build() {
    Column() {
      Row({ space: 8 }) {
        Image($r('app.media.books')).width(16).height(16)
        Text('查看白话文')
          .attributeModifier(new BaseTextStyleModifier('#966426/Body_M/Medium'))
      }
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .padding(8)
      .borderRadius(14)
      .onClick(() => {
        RouterModule.pushPathByName({url:'vernacular'})
      })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
    .backgroundColor($r('sys.color.background_secondary'))
  }
}