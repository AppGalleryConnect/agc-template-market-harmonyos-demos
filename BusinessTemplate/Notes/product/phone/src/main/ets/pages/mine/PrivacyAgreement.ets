import { webview } from '@kit.ArkWeb';
import { ObjectUtil } from '@ohos_agcit/notes_utils';

@Builder
export function PrivacyAgreementBuilder() {
  PrivacyAgreement();
}

@ComponentV2
export struct PrivacyAgreement {
  @Consumer('appPathStack') appPathStack: NavPathStack = new NavPathStack()
  controller: webview.WebviewController = new webview.WebviewController();
  privacyAgreementPath : string = (this.getUIContext().getHostContext() as Context).resourceManager.getStringSync($r('app.string.privacyAgreementPath').id);

  build() {
    NavDestination() {
      Column() {
        Row() {
          SymbolGlyph($r('sys.symbol.arrow_left'))
            .fontSize(20)
            .fontColor([$r('sys.color.font_primary')])
            .onClick(() => {
              this.appPathStack.pop();
            });
          Blank();
        }
        .width('100%')
        .height(44)
        .alignItems(VerticalAlign.Center)
        .padding({ left: 12, right: 12, top: 12, bottom: 8 })
        .backgroundColor($r('sys.color.background_secondary'));

        Web({ src: this.privacyAgreementPath, controller: this.controller })
          .layoutWeight(1)
          .width('100%')
          .verticalScrollBarAccess(false)
          .fileAccess(false)
          .geolocationAccess(false);
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('sys.color.background_secondary'));
    }
    .hideTitleBar(true)
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