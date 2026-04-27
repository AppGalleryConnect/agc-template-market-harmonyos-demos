import { webview } from '@kit.ArkWeb';

@ComponentV2
export struct ProtocolWebView {
  @Param content: string = '';
  @Event back: () => void = () => {
  };
  webViewController: webview.WebviewController = new webview.WebviewController();

  build() {
    Column() {
      Web({
        src: 'www.example.com',
        controller: this.webViewController,
      })
        .verticalScrollBarAccess(false)
        .fileAccess(false)
        .geolocationAccess(false)
        .layoutWeight(1)
        .backgroundColor($r('sys.color.background_secondary'))
        .onControllerAttached(() => {
          setTimeout(() => {
            this.webViewController.loadData(
              this.content,
              'text/html',
              'UTF-8',
              '',
              '',
            );
          }, 100)
        })
    }
    .layoutWeight(1)
    .width('100%')
    .backgroundColor($r('sys.color.background_secondary'))
  }
}