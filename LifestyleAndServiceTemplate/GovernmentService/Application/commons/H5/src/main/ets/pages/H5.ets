import webview from '@ohos.web.webview';
import web_webview from '@ohos.web.webview';

@Component
export struct H5 {
  @State title: string = '';
  @State loadUrl: string = '';
  controllerWeb: web_webview.WebviewController = new web_webview.WebviewController();
  @Consume('pageInfos') pageInfos: NavPathStack

  build() {
    NavDestination() {
      Column() {
        Web({ controller: this.controllerWeb, src: $rawfile(this.loadUrl) })
          .width('100%')
          .javaScriptAccess(true)
          .domStorageAccess(true)
          .geolocationAccess(false)
          .onPageEnd(() => {
            this.controllerWeb.runJavaScript(`setTitle(${JSON.stringify(this.title)})`);
          })
      }
      .width('100%')
      .height('100%')
    }
    .title(this.title)
    .padding({ top: Number(AppStorage.get('topRectHeight')) })
  }
}