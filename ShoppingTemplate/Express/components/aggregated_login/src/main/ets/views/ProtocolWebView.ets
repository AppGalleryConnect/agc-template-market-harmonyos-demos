import { webview } from '@kit.ArkWeb';
import { window } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { UtilLog } from '@hw-agconnect/util-log';
import { ProtocolRouterParams } from '../model/Index';
import { Constants } from '../common/Constant';

@Builder
export function ProtocolWebViewBuilder() {
  ProtocolWebView()
}

@ComponentV2
struct ProtocolWebView {
  @Local content: string = '';
  @Local isSheet: boolean = false;
  @Local sheetType: SheetType = SheetType.BOTTOM;
  @Local isAvoidArea: boolean = false;
  @Local windowTopPadding: number = 40;
  @Local windowBottomPadding: number = 28;
  webViewController: webview.WebviewController = new webview.WebviewController();
  stack: NavPathStack = new NavPathStack();

  @Computed
  get headerPaddingTop() {
    if (!this.isSheet) {
      return this.isAvoidArea ? this.windowTopPadding : 0;
    }
    if (this.sheetType === SheetType.CENTER) {
      return Constants.PADDING_L;
    }
    if (this.sheetType === SheetType.BOTTOM) {
      return Constants.ZERO;
    }
    return 0;
  }

  @Computed
  get windowPaddingBottom() {
    if (this.isSheet ) {
      return Constants.WINDOW_BOTTOM_PADDING
    }
    return this.isAvoidArea ? this.windowBottomPadding : Constants.ZERO
  }

  aboutToAppear(): void {
    // 获取当前窗口实例
    try {
      let context = this.getUIContext().getHostContext() as common.UIAbilityContext;
      const windowClass = context.windowStage.getMainWindowSync();
      const properties = windowClass.getWindowProperties();
      if (properties.isLayoutFullScreen) {
        this.isAvoidArea = true;
        this.setAvoidSize(windowClass)
      } else {
        this.isAvoidArea = false;
      }
    } catch (err) {
      UtilLog.error(`Failed to obtain the top window. Error: ${JSON.stringify(err)}`);
    }
  }

  public setAvoidSize(windowClass: window.Window) {
    try {
      const uiContext = this.getUIContext();
      let avoidArea = windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
      this.windowTopPadding = uiContext.px2vp(avoidArea.topRect.height);
      avoidArea = windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
      this.windowBottomPadding = uiContext.px2vp(avoidArea.bottomRect.height);
    } catch (error) {
      UtilLog.error('[ProtocolWebView]', `setAvoidArea fail, error: ${JSON.stringify(error)}`);
    }
  }

  build() {
    NavDestination() {
      Column() {
        Row() {
          Button({ type: ButtonType.Circle }) {
            SymbolGlyph($r('sys.symbol.chevron_backward'))
              .fontColor([$r('sys.color.icon_primary')])
              .fontSize(Constants.BACK_WIDTH)
          }
          .width(Constants.BACK_BACKGROUND_WIDTH)
          .height(Constants.BACK_BACKGROUND_HEIGHT)
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .onClick(() => {
            this.stack.pop();
          })
        }
        .width(Constants.FULL_PERCENT)
        .margin({
          bottom: Constants.SPACE_S,
        })

        Scroll() {
          this.coreInfo()
        }
        .layoutWeight(1)
        .align(Alignment.Top)
        .scrollBar(BarState.Off)
      }
      .padding({
        left: Constants.PADDING_L,
        right: Constants.PADDING_L,
        bottom: this.windowPaddingBottom,
        top: this.headerPaddingTop,
      })
      .height(Constants.FULL_PERCENT)
      .width(Constants.FULL_PERCENT)
      .backgroundColor($r('sys.color.background_secondary'))
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
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
      .backgroundColor($r('sys.color.background_secondary'))
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
