import { CommonConstants } from '../constants/CommonConstants'
import { DrawBoardVM } from '../viewmodel/DrawVM'
import { ToolsNav } from './ToolsNav'

@ComponentV2
export struct RubbersContent {
  @Local drawBoardVM: DrawBoardVM = DrawBoardVM.instance

  aboutToAppear(): void {
    this.drawBoardVM.activateEraser()
  }

  build() {
    Column() {
      ToolsNav({ title: $r('app.string.eraser') })

      Column() {
        Slider({
          style: SliderStyle.InSet,
          value: this.drawBoardVM.eraserSize,
          min: 5,
          max: 50,
        })
          .height($r('app.float.brash_width'))
          .width('100%')
          .minResponsiveDistance(CommonConstants.ONE)
          .onChange((value: number) => {
            this.drawBoardVM.setEraserSize(value);
            this.drawBoardVM.activateEraser()
          })
        Flex({ justifyContent: FlexAlign.SpaceBetween }) {
          Text($r('app.string.small'))
            .fontSize($r('sys.float.Body_M'))
          Text($r('app.string.large'))
            .fontSize($r('sys.float.Body_M'))
        }
        .width('100%')
      }
    }
    .alignItems(HorizontalAlign.Start)
    .width(CommonConstants.ONE_HUNDRED_PERCENT)
    .padding({
      bottom: 36,
      left: 16,
      right: 16,
      top: 16,
    })
  }
}