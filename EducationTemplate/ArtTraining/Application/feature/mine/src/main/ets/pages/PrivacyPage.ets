import { CommonHeader } from 'componentlib';
import { webview } from '@kit.ArkWeb';

@Builder
export function privacyPageBuilder() {
  PrivacyPage();
}

@ComponentV2
export struct PrivacyPage {
  controller: webview.WebviewController = new webview.WebviewController();

  build() {
    NavDestination() {
      CommonHeader({ title: '隐私声明' });
      Column() {
        Web({ src: $rawfile('privacy.html'), controller: this.controller });
      }
      .padding($r('app.string.padding_s'))
      .layoutWeight(1)
    }
    .hideTitleBar(true);
  }
}
