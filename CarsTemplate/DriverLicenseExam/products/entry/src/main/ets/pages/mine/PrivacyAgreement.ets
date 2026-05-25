import { webview } from '@kit.ArkWeb';
import { CommonModel, ObjectUtil } from '@ohos_agcit/driver_license_exam_commonlib';

@Builder
export function PrivacyAgreementBuilder() {
  PrivacyAgreement();
}

@ComponentV2
export struct PrivacyAgreement {
  topRectHeight: number = 0;
  vm: CommonModel = CommonModel.instance;
  controller: webview.WebviewController = new webview.WebviewController();
  privacyAgreementPath : string = (this.getUIContext().getHostContext() as Context).resourceManager.getStringSync($r('app.string.privacyAgreementPath').id);

  build() {
    NavDestination() {
      Web({ src: this.privacyAgreementPath, controller: this.controller })
        .verticalScrollBarAccess(false)
        .fileAccess(false)
        .geolocationAccess(false)
    }
    .hideTitleBar(true)
    .margin({
      top: this.getUIContext().px2vp(this.topRectHeight)
    })
    .backgroundColor($r('sys.color.background_secondary'))
    .onReady((cxt: NavDestinationContext) => {
      let param = cxt.pathInfo.param as Record<string, Object>;
      if (ObjectUtil.isNotNull(param)) {
        this.privacyAgreementPath = param.protocolUrl as string;
      }
    })
    .onBackPressed(() => {
      this.vm.navStack.pop();
      return true;
    })
  }
}
