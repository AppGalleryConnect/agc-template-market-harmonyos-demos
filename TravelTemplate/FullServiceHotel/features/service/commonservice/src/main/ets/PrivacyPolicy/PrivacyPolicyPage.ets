import { webview } from '@kit.ArkWeb';
import { CommonHeader } from 'componentlib';

@Builder
export function privacyPolicyPageBuilder() {
  PrivacyPolicyPage()
}

@ComponentV2
export struct PrivacyPolicyPage {
  controller: webview.WebviewController = new webview.WebviewController();

  build() {
    NavDestination() {
      CommonHeader({ title: '隐私政策' });
      Column() {
        Web({ src: $rawfile('privacy_policy.html'), controller: this.controller });
      }
      .padding($r('app.string.padding_s'))
      .layoutWeight(1)
    }
    .height($r('app.string.height_percent_full'))
    .hideTitleBar(true)
  }
}