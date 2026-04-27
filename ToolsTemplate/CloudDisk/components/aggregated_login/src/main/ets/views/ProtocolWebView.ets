import { webview } from '@kit.ArkWeb';
import { ProtocolRouterParams } from '../model/Index';
import { Constants, TValueType } from '../common/Constant';

export const protocolWebViewName = 'ProtocolWebView'

@Builder
export function ProtocolWebViewBuilder(params: TValueType) {
  ProtocolWebView({
    pageParams: params
  })
}

/**
 * @usage: 协议内容展示页面，用于显示隐私协议、用户协议等法律文档内容。支持WebView加载网页内容，可配置为全屏页面或半模态展示。
 * 包含页面导航、返回按钮、WebView控制器等功能。
 * @layout: 导航页面布局，顶部为返回按钮和标题栏，主体为WebView组件用于加载协议内容。根据isSheet和sheetType参数调整页面样式和布局。
 * @constraints: 不允许修改WebView控制器逻辑、页面导航逻辑、路由参数处理逻辑。协议内容必须为有效的HTML格式。页面返回逻辑不可修改。
 * @isGen: true
 * @fileType: page
 * @zhName: 协议内容展示页面
 * @subPage:
 * @component: SymbolGlyph
 */
@ComponentV2
struct ProtocolWebView {
  @Param pageParams: TValueType = null;
  @Local content: string = '';
  @Local isSheet: boolean = false;
  @Local sheetType: SheetType = SheetType.BOTTOM;
  webViewController: webview.WebviewController = new webview.WebviewController();
  stack: NavPathStack = new NavPathStack();

  aboutToAppear(): void {
    this.content = (this.pageParams as ProtocolRouterParams)?.content
    this.isSheet = (this.pageParams as ProtocolRouterParams)?.isSheet ?? false
    this.sheetType = (this.pageParams as ProtocolRouterParams)?.sheetType ?? SheetType.BOTTOM
  }

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
        bottom: this.isSheet ? Constants.WINDOW_BOTTOM_PADDING : Constants.ZERO,
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
    .padding({ top: 40, bottom: Constants.WINDOW_BOTTOM_PADDING })
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
