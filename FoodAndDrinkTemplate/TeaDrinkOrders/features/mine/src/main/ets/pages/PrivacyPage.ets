import { Constants, HttpRequest, NavHeaderBar, WindowModel } from 'common/Index';
import { AppStorageV2 } from '@kit.ArkUI';
import web_webview from '@ohos.web.webview';

@Builder
export function PrivacyPageBuilder() {
  PrivacyPage()
}

@ComponentV2
struct PrivacyPage {
  @Consumer('pageStack') pageStack?: NavPathStack
  @Local windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!
  @Local privacyInfo: string = ''
  controller: web_webview.WebviewController = new web_webview.WebviewController();

  aboutToAppear() {
    this.getPrivacyInfo()
  }

  getPrivacyInfo() {
    HttpRequest.getPrivacyInfo().then((res) => {
      this.privacyInfo = `<meta name="viewport" content="width=device-width, initial-scale=1.0">${res ?? ''}`;
    })
  }

  build() {
    NavDestination() {
      NavHeaderBar({ title: $r('app.string.privacy') })
      Column() {
        Web({ src: '', controller: this.controller }).onControllerAttached(() => {
          this.controller.loadData(this.privacyInfo, 'text/html', 'UTF-8');
        })
          .fileAccess(false)
          .geolocationAccess(false)
          .layoutMode(WebLayoutMode.FIT_CONTENT);
      }
      .width(Constants.FULL_SIZE)
      .constraintSize({ maxWidth: Constants.FULL_SIZE })
      .backgroundColor($r('sys.color.background_primary'))
      .margin({
        top: 12,
        left: Constants.BORDER_WIDTH,
        right: Constants.BORDER_WIDTH,
        bottom: this.windowModel.getWindowBottomHeight(),
      })
    }.hideTitleBar(true)
  }
}