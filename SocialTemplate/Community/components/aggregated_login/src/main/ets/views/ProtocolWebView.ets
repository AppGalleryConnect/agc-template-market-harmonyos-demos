import { webview } from '@kit.ArkWeb';
import { ProtocolRouterParams } from '../model/Index';
import { Constants, TValueType } from '../common/Constant';
import { window } from '@kit.ArkUI';

@Builder
export function ProtocolWebViewBuilder(params: TValueType) {
  ProtocolWebView({
    pageParams: params
  })
}

@ComponentV2
struct ProtocolWebView {
  @Param pageParams: TValueType = null;
  @Local content: string = '';
  @Local isSheet: boolean = false;
  @Local sheetType: SheetType = SheetType.BOTTOM;
  @Local topPadding: number = 0;
  webViewController: webview.WebviewController = new webview.WebviewController();
  stack: NavPathStack = new NavPathStack();

  aboutToAppear(): void {
    this.content = (this.pageParams as ProtocolRouterParams)?.content
    this.isSheet = (this.pageParams as ProtocolRouterParams)?.isSheet ?? false
    this.sheetType = (this.pageParams as ProtocolRouterParams)?.sheetType ?? SheetType.BOTTOM

    // 定义导航栏类型
    const navigationType = window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR;
    // 获取窗口实例
    window.getLastWindow(getContext(this)).then((windowObj) => {
      // 获取导航栏区域信息
      const avoidArea = windowObj.getWindowAvoidArea(navigationType);
      // 提取底部导航栏高度（单位：px）
      const navigationBarHeight = avoidArea.bottomRect.height;
      this.topPadding = px2vp(navigationBarHeight)
    }).catch(() => {

    });

  }

  @Computed
  get headerPaddingTop() {
    if (!this.isSheet) {
      return this.topPadding;
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
          top: Constants.SPACE_S,
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
        bottom: this.isSheet ? Constants.WINDOW_BOTTOM_PADDING : Constants.ZERO,
        top: this.headerPaddingTop,
      })
      .height(Constants.FULL_PERCENT)
      .width(Constants.FULL_PERCENT)
      .backgroundColor($r('sys.color.background_secondary'))
    }
    .expandSafeArea(
      [SafeAreaType.SYSTEM, SafeAreaType.CUTOUT], // 避让类型：系统栏+摄像头挖孔
      [SafeAreaEdge.TOP, SafeAreaEdge.START] // 避让边缘：顶部+左侧
    )
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
    .onBackPressed(() => {
      this.stack.pop()
      return true
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
