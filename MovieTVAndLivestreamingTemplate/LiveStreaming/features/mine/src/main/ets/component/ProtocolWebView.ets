import { BarVM } from '@agctemplate/widgets';
import { AppStorageV2 } from '@kit.ArkUI';
import { webview } from '@kit.ArkWeb';
import { Header } from './Header';

@ComponentV2
export struct ProtocolWebView {
  @Param content: string = '';
  @Event back: () => void = () => {
  };
  webViewController: webview.WebviewController = new webview.WebviewController();

  build() {
    Column() {
      Header()
      Column() {
        Web({
          src: $rawfile(this.content),
          controller: this.webViewController,
        })
          .fileAccess(false)
          .geolocationAccess(false)
          .layoutWeight(1)
          .backgroundColor($r('sys.color.background_secondary'))
          .darkMode(WebDarkMode.Auto)
          .forceDarkAccess(true)
          // .onControllerAttached(() => {
            // setTimeout(() => {
            //   this.webViewController.loadData(
            //     this.content,
            //     'text/html',
            //     'UTF-8',
            //     '',
            //     '',
            //   );
            // }, 100)
          // })
      }
      .height('100%')
      .width('100%')
      .backgroundColor($r('sys.color.background_secondary'))
      .padding({
        left: 16,
        right: 16,
        bottom: BarVM.instance.aiBarH,
      })
    }
  }
}