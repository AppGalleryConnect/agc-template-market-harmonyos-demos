import { webview } from '@kit.ArkWeb';

@Builder
export function PrivacyAgreementBuilder() {
  PrivacyAgreement();
}

@ComponentV2
export struct PrivacyAgreement {
  topRectHeight: number = 0;
  controller: webview.WebviewController = new webview.WebviewController();
  privacyAgreementPath : string = getContext(this).resourceManager.getStringSync($r('app.string.privacyAgreementPath'));

  build() {
    NavDestination() {
      Web({ src: this.privacyAgreementPath, controller: this.controller }).verticalScrollBarAccess(false)
    }
    .hideTitleBar(true)
    .margin({
      top: px2vp(this.topRectHeight)
    })
    .onReady((cxt: NavDestinationContext) => {
      let param = cxt.pathInfo.param as Record<string, Object>;
    })
    .onBackPressed(() => {
      // this.appPathStack.pop();
      return true;
    })
  }
}