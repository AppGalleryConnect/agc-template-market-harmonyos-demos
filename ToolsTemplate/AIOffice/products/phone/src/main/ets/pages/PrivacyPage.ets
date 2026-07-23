import { AppStorageV2 } from '@kit.ArkUI';
import { webview } from '@kit.ArkWeb';
import { CommonConstants, WindowModel } from 'lib_common';
import { NavHeaderBar } from '../widget/NavHeaderBar';

@Builder
export function PrivacyPageBuilder() {
  PrivacyPage()
}

@ComponentV2
struct PrivacyPage {
  windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!;
  webViewController: webview.WebviewController = new webview.WebviewController();
  mode: WebDarkMode = WebDarkMode.Auto;

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          customPadding: {
            left: 0,
            right: 0,
          },
        })
        Web({
          src: $rawfile('privacy-statement.htm'),
          controller: this.webViewController,
        })
          .fileAccess(false)
          .geolocationAccess(false)
          .darkMode(this.mode)
          .forceDarkAccess(true)
          .backgroundColor($r('sys.color.background_secondary'))
          .layoutWeight(1)
      }
      .height(CommonConstants.FULL_PERCENT)
      .width(CommonConstants.FULL_PERCENT)
      .backgroundColor($r('sys.color.background_secondary'))
      .padding({
        left: CommonConstants.PADDING_PAGE,
        right: CommonConstants.PADDING_PAGE,
        bottom: this.windowModel.windowBottomPadding,
      })
    }
    .hideTitleBar(true)
  }
}
