import { webview } from '@kit.ArkWeb';
import { PrivacyAgreementRouterMap } from '../commons/Enums';

@Builder
export function PrivacyPreviewBuilder() {
  PrivacyPreview()
}

@ComponentV2
struct PrivacyPreview {
  @Local
  privacyLink: ResourceStr = ''
  @Local
  loading: boolean = false;
  webViewController: webview.WebviewController = new webview.WebviewController();
  mode: WebDarkMode = WebDarkMode.Auto;

  @Monitor('privacyLink')
  displayLink() {
    if (this.privacyLink) {
      this.loading = true
      const timer = setTimeout(() => {
        this.webViewController.loadUrl(this.privacyLink)
        clearTimeout(timer)
        this.loading = false;
      }, 100)
    }
  }

  build() {
    NavDestination() {
      Column() {
        if (this.loading) {
          LoadingProgress()
            .width(32)
        }
        Web({
          src: this.privacyLink,
          controller: this.webViewController,
        })
          .fileAccess(false)
          .geolocationAccess(false)
          .darkMode(this.mode)
          .forceDarkAccess(true)
          .backgroundColor($r('sys.color.background_secondary'))
          .layoutWeight(1)
          .verticalScrollBarAccess(false)
          .horizontalScrollBarAccess(false)
          .visibility(this.loading ? Visibility.Hidden : Visibility.Visible)
      }
      .height($r('app.string.size_percent_full'))
      .width($r('app.string.size_percent_full'))
      .justifyContent(FlexAlign.Center)
      .padding({
        top: $r('app.float.space_l'),
        bottom: $r('app.float.space_l'),
      })
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .onReady((context) => {
      const param =
        context.pathStack.getParamByName(PrivacyAgreementRouterMap.PRIVACY_PREVIEW) as ResourceStr[] | undefined
      if (param) {
        this.privacyLink = param[0]
      }
    })
  }
}
