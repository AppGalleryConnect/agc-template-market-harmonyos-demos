import web_webview from '@ohos.web.webview'
import { PreviewVM } from '../viewModels/PreviewVM';


@Entry
@ComponentV2
struct Preview {
  vm: PreviewVM = PreviewVM.instance
  controller: web_webview.WebviewController = new web_webview.WebviewController();

  build() {
    NavDestination() {
      Column() {
        Web({
          src:
          this.vm.url,
          controller: this.controller
        })
          .fileAccess(false)
          .domStorageAccess(true)
          .geolocationAccess(false)
      }
    }
    .onShown(() => {
      this.vm.init()
    })
    .onHidden(() => {
      this.vm.clear()
    })
  }
}

@Builder
export function PreviewBuilder() {
  Preview()
}