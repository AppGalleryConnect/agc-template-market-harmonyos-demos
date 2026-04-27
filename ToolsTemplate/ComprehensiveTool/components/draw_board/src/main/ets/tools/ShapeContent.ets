import { baseActionSheet } from '../components/ActionSheet'
import { CanvasShape, canvasShapeList, CommonConstants } from '../constants/CommonConstants'
import { DrawBoardVM } from '../viewmodel/DrawVM'
import { ToolsNav } from './ToolsNav'

@ComponentV2
export struct ShapeContent {
  @Local drawBoardVM: DrawBoardVM = DrawBoardVM.instance

  aboutToAppear(): void {
    this.drawBoardVM.activateEraser()
  }

  build() {
    Column({ space: 16 }) {
      ToolsNav({ title: $r('app.string.shape') })

      Grid() {
        ForEach(canvasShapeList, (item: CanvasShape) => {
          GridItem() {
            Column({ space: 5 }) {
              Image(item.resource).width(32).height(32)
              Text(item.name)
            }
            .onClick(() => {
              this.drawBoardVM.currentShape = item.id;
              this.drawBoardVM.shapeMode = true;
              baseActionSheet.close('canvasTools')
            })
          }
        },(item: CanvasShape) => JSON.stringify(item))
      }
      .columnsTemplate('1fr 1fr 1fr 1fr')
      .rowsGap(16)
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