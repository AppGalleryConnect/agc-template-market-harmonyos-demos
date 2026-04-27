import { RouterModule } from 'lib_foundation'

@ComponentV2
export struct BackTitle {
  build() {
    Row({ space: 8 }) {
      Image($r('app.media.ic_back'))
        .width(40)
        .height(40)
        .onClick(() => {
          RouterModule.pop()
        })

      Text('签到福利')
        .fontSize(24)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'))
    }
    .width('100%')
    .height(56)
    .margin({ left: 24, bottom: 8 })
  }
}