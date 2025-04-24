import { Constants, GetHelpMsgResp, getHelpMsgUtil, NavHeaderBar } from 'common/Index'

@Component
export struct FrequentQuestionPage {
  @State windowTopHeight: number = AppStorage.get('windowTopHeight') as number || 38.77
  @State windowBottomHeight: number = AppStorage.get('windowBottomHeight') as number || 28
  @Consume('pageStack') pageStack: NavPathStack
  @State questionList?: Array<GetHelpMsgResp> = undefined
  scroller: Scroller = new Scroller()

  aboutToAppear(): void {
    getHelpMsgUtil().then((resp: Array<GetHelpMsgResp>) => {
      this.questionList = resp
      console.log(JSON.stringify(this.questionList))
    })
  }

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({ title: $r('app.string.faqs') })

        Row() {
          Column() {
            Text($r('app.string.question_title'))
              .fontSize($r('sys.float.Title_S'))
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_primary'))
            Text($r('app.string.question_desc'))
              .fontSize($r('sys.float.Body_S'))
              .fontColor($r('sys.color.font_secondary'))
              .margin({ top: 4 })
          }
          .alignItems(HorizontalAlign.Start)

          Image($r('app.media.report_icon')).width(60).height(60)
        }
        .width(Constants.FULL_SIZE)
        .padding({
          left: 24,
          right: 42,
          top: 14,
          bottom: 12,
        })
        .justifyContent(FlexAlign.SpaceBetween)

        Scroll(this.scroller) {
          Column() {
            ForEach(this.questionList, (item: GetHelpMsgResp) => {
              Row() {
                Text(item.question)
                  .fontSize($r('sys.float.Body_M'))
                  .fontColor($r('sys.color.font_secondary'))
                Image($r('app.media.right_arrow'))
                  .width(16)
                  .height(16)
              }
              .width(Constants.FULL_SIZE)
              .padding({
                top: 12,
                bottom: 12,
                left: 8,
                right: 8,
              })
              .justifyContent(FlexAlign.SpaceBetween)
              .border({
                width: { top: 1 },
                color: { top: $r('sys.color.comp_divider') },
              })
              .onClick(() => {
                this.pageStack.pushPath({ name: 'AnswerPage', param: item.answer })
              })
            }, (item: GetHelpMsgResp) => item.question)
          }.alignItems(HorizontalAlign.Start)
        }
        .width(Constants.FULL_SIZE)
        .padding({ left: Constants.BORDER_WIDTH, right: Constants.BORDER_WIDTH })
        .align(Alignment.Top)
      }.backgroundColor($r('sys.color.background_primary'))
    }
    .hideTitleBar(true)
    .padding({ bottom: this.windowBottomHeight })
    .backgroundColor($r('sys.color.background_secondary'))
  }
}