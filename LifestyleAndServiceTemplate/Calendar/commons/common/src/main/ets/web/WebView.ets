import { webview } from '@kit.ArkWeb';
import { UtilLog } from '@hw-agconnect/util-log';

const TAG = '[WebView]';

@ComponentV2
export struct WebView {
  handlePageEnd?: () => void;
  shouldShowExtBtn?: () => void;
  hiddenScrollBar?: boolean = true;
  @Param url: ResourceStr = '';
  isLarge?: boolean = true;
  @Require @Param webViewController: webview.WebviewController;

  build() {
    Stack() {
      Web({ controller: this.webViewController, src: this.url })
        .darkMode(WebDarkMode.Auto)
        .domStorageAccess(true)
        .zoomAccess(true)
        .mixedMode(MixedMode.None)
        .cacheMode(CacheMode.Default)
        .verticalScrollBarAccess(!this.hiddenScrollBar)
        .javaScriptAccess(true)
        .fileAccess(false)
        .geolocationAccess(false)
        .width('100%')
        .mixedMode(MixedMode.None)
        .onProgressChange((event) => {
          UtilLog.info(TAG, 'newProgress:' + event?.newProgress);
          if (event?.newProgress === 100) {
            this.shouldShowExtBtn && this.shouldShowExtBtn();
          }
          UtilLog.info(TAG, 'onProgressChange weburl: ' + this.webViewController.getUrl());
        })
        .onPageBegin(() => {
          UtilLog.info(TAG, ' onPageBegin start loading');
          UtilLog.info(TAG, 'onPageBegin weburl: ' + this.webViewController.getUrl());
        })
        .onPageEnd((event) => {
          UtilLog.info(TAG, 'onPageEnd loading completed url: ' + event?.url);
          UtilLog.info(TAG, 'onPageEnd weburl: ' + this.webViewController.getUrl());
        })
    }
  }
}