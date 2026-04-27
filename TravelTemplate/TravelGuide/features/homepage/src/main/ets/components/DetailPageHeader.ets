import { phoneRouterControl } from 'oh_router';

/**
 * 详情页通用头部组件
 * 包含返回按钮和城市显示
 */
@ComponentV2
export struct DetailPageHeader {
  @Param currentCity: string = ''
  @Param returnCity: string = ''

  build() {
    Column() {
      Row() {
        Image($r('app.media.leftReturn'))
          .width(40)
          .height(40)
          .onClick(() => {
            phoneRouterControl.popPage()
            return true
          })
        Row() {
          Text(this.currentCity)
            .fontSize(16)
            .fontColor('#000')
            .margin({ right: 8 })
          Image($r('app.media.ic_right'))
            .width(20)
          Text(this.returnCity)
            .fontSize(16)
            .fontColor('#000')
            .margin({ left: 8, right: 4 })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)

        Blank()
          .width(40)
          .height(40)
      }
      .width('100%')
      .margin({ bottom: 20 })
    }
    .padding({ top: 34 })
  }
}
