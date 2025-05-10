import { router } from '@kit.ArkUI';
import { webview } from '@kit.ArkWeb';

@Entry
@ComponentV2
struct FilesPage {
  @Local name: string = '';
  webController: WebviewController = new webview.WebviewController()

  aboutToAppear(): void {
    let params: ESObject = router.getParams()
    if (params.name) {
      this.name = params.name
    }
  }

  build() {
    Column() {
      Row() {
        Image($r('app.media.ic_back'))
          .height(20)
          .position({
            x: 10,
            y: 4
          })
          .onClick(() => {
            router.back()
          })
        Text(this.name)
          .fontSize(24)
          .fontWeight(700)
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .padding({ bottom: 10 })
      .backgroundColor($r('app.color.font_color_white'))

      Divider().strokeWidth(1).color($r('app.color.background_color_light'))
        .margin({ bottom: 20 })

      Web({ src: '', controller: this.webController })
        .onControllerAttached(() => {
        })
    }
    .height('100%')
    .width('100%')
  }
}