import { webview } from '@kit.ArkWeb';
import { MainPageVM } from '../viewModels/MainPageVM';

@Builder
export function privacyPolicyPageBuilder() {
  PrivacyPolicyPage()
}

@ComponentV2
export struct PrivacyPolicyPage {
  controller: webview.WebviewController = new webview.WebviewController();
  vm: MainPageVM = MainPageVM.instance;
  build() {
    NavDestination() {
      Column() {
        Web({ src: $rawfile('privacy_policy.html'), controller: this.controller });
      }
      .padding(8)
      .layoutWeight(1)
    }
    .width('100%')
    .padding({
      left: 8,
    })
    .backgroundColor('#ffffff')
    .height('100%')
    .hideTitleBar(false)
    .title('隐私协议')
  }
}