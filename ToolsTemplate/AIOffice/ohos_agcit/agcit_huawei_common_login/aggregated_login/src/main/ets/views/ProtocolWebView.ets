import { webview } from '@kit.ArkWeb';
import { ProtocolRouterParams } from '../model/Index';
import { Constants } from '../common/Constant';
import { NavHeaderBar } from 'lib_widget';

@Builder
export function ProtocolWebViewBuilder() {
  ProtocolWebView()
}

@ComponentV2
struct ProtocolWebView {
  @Local content: string = '';
  @Local isSheet: boolean = false;
  @Local sheetType: SheetType = SheetType.BOTTOM;
  webViewController: webview.WebviewController = new webview.WebviewController();
  stack: NavPathStack = new NavPathStack();

  @Computed
  get headerPaddingTop() {
    if (!this.isSheet) {
      return undefined;
    }
    if (this.sheetType === SheetType.CENTER) {
      return Constants.PADDING_L;
    }
    if (this.sheetType === SheetType.BOTTOM) {
      return Constants.ZERO;
    }
    return 0;
  }

  build() {
    NavDestination() {
      Column() {
        if(!this.isSheet){
          NavHeaderBar()
        }

        Scroll() {
          this.coreInfo()
        }
        .layoutWeight(1)
        .align(Alignment.Top)
        .scrollBar(BarState.Off)
        .padding({ bottom: 28 })
      }
      .padding({
        left: Constants.PADDING_L,
        right: Constants.PADDING_L,
        bottom: this.isSheet ? Constants.WINDOW_BOTTOM_PADDING : Constants.ZERO,
        top: this.headerPaddingTop,
      })
      .height(Constants.FULL_PERCENT)
      .width(Constants.FULL_PERCENT)
      .backgroundColor($r('sys.color.background_primary'))
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_primary'))
    .onReady((context) => {
      this.stack = context.pathStack;
      const params = context.pathInfo.param as ProtocolRouterParams;
      if (params) {
        this.content = params.content;
        this.isSheet = params.isSheet ?? false;
        this.sheetType = params.sheetType ?? SheetType.BOTTOM;
      }
    })
  }

  @Builder
  coreInfo() {
    Web({
      src: '',
      controller: this.webViewController,
    })
      .fileAccess(false)
      .geolocationAccess(false)
      .darkMode(WebDarkMode.Auto)
      .forceDarkAccess(true)
      .verticalScrollBarAccess(false)
      .backgroundColor($r('sys.color.background_primary'))
      .layoutWeight(1)
      .backgroundColor($r('sys.color.background_primary'))
      .onControllerAttached(() => {
        if (this.content.startsWith('http://') || this.content.startsWith('https://')) {
          this.webViewController.loadUrl(this.content)
        } else {
          this.webViewController.loadData(
            this.content,
            'text/html',
            'UTF-8',
            '',
            '',
          );
        }
      })
  }
}
