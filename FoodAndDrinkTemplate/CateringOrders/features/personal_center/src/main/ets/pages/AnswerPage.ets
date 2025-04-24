import web_webview from '@ohos.web.webview';
import { Constants, NavHeaderBar } from 'common/Index';

@Component
export struct AnswerPage {
  @Consume('pageStack') pageStack: NavPathStack
  @State answerDetail: string = ''
  @State windowBottomHeight: number = AppStorage.get('windowBottomHeight') as number || 28
  controller: web_webview.WebviewController = new web_webview.WebviewController();
  private scroller: Scroller = new Scroller()

  getAnswerDetail() {
    let paramsArr: string[] = this.pageStack.getParamByName('AnswerPage') as string[]
    if (paramsArr.length) {
      this.answerDetail =
        `<meta name="viewport" content="width=device-width, initial-scale=1.0">${paramsArr[paramsArr.length-1]}`
    }
  }

  aboutToAppear(): void {
    this.getAnswerDetail()
  }

  build() {
    NavDestination() {
      NavHeaderBar({ title: '' })
      Scroll(this.scroller) {
        Web({ src: '', controller: this.controller }).onControllerAttached(() => {
          this.controller.loadData(this.answerDetail, 'text/html', 'UTF-8')
        }).nestedScroll({
          scrollForward: NestedScrollMode.PARENT_FIRST,
          scrollBackward: NestedScrollMode.SELF_FIRST,
        }).layoutMode(WebLayoutMode.FIT_CONTENT)
      }
      .width(Constants.FULL_SIZE)
      .height(Constants.FULL_SIZE)
      .padding({ left: Constants.BORDER_WIDTH, right: Constants.BORDER_WIDTH })
      .align(Alignment.Top)
    }
    .hideTitleBar(true)
    .padding({ bottom: this.windowBottomHeight })
  }
}