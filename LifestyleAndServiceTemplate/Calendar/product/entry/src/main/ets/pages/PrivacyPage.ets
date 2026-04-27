import { NavigationTitle, WebView } from 'common';
import { webview } from '@kit.ArkWeb';
import { FastWeb, controllerMap } from '@hw-agconnect/fast-web';

export const PRIVACY_WEB = 'privacy_web1Id'

@Entry
@ComponentV2
struct PrivacyPage {
  @Local url:string = 'privacy-statement-zh-cn.html'
  @Local webViewController: webview.WebviewController = new webview.WebviewController();

  build() {
    Column() {
      NavigationTitle({
        title:$r('app.string.privacy_statement'),
        routerBack:() => {
          this.getUIContext().getRouter().back()
        }
      })
      if(this.url.startsWith('https://')) {
        FastWeb({ webId: PRIVACY_WEB, url: this.url, }).onAttach(() => {
          const controller = controllerMap.get(PRIVACY_WEB)
          controller?.loadUrl($rawfile('privacy-statement-zh-cn.html'))
        })
      }else {
        WebView({
          url: $rawfile(this.url),
          webViewController: this.webViewController,
        })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
    .padding({ top: AppStorage.get<number>('statusBarHeight'), bottom: 24 })
  }
}