import { webview } from '@kit.ArkWeb';
import { CommonConstants, ObjectUtil } from '@ohos_agcit/children_education_utils';

@Builder
export function PrivacyAgreementBuilder() {
  PrivacyAgreement();
}

@ComponentV2
export struct PrivacyAgreement {
  topRectHeight: number = 0;
  @Consumer(CommonConstants.APP_PATH_STACK) appPathStack: NavPathStack = new NavPathStack()
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
      if (ObjectUtil.isNotNull(param)) {
        this.privacyAgreementPath = param.protocolUrl as string;
      }
    })
    .onBackPressed(() => {
      this.appPathStack.pop();
      return true;
    })
  }
}