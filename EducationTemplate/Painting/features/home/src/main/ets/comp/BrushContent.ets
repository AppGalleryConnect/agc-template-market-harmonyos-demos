import { Constants, WindowParam } from 'common'
import { CommonConstants } from '../constants/Constant'
import { brushTypesList } from '../constants/StyleConstants'
import { BrushItem } from '../types/StyleType'
import { DrawingBoardVM } from '../viewmodel/DrawingBoardVM'
import { SheetTitle } from './SheetTitle'
import { SliderComponent } from './SilderComp'
import { WindowBuilder } from './WindowBuilder'

@Builder
export function BrushMenuContentBuilder(param: WindowParam) {
  BrushMenuContent({ param: param })
}

@ComponentV2
export struct BrushMenuContent {
  @Local drawingBoardVM: DrawingBoardVM = DrawingBoardVM.instance
  @Param @Require param: WindowParam

  @Builder
  render() {
    Column() {

      SheetTitle({ title: '画笔' })

      Grid() {
        ForEach(brushTypesList, (brushItem: BrushItem) => {
          GridItem() {
            Column() {
              Image(brushItem.icon)
                .width(24)
                .height(57)
                .margin({ bottom: 5 })

              Text(brushItem.name)
                .fontSize(14)
                .fontWeight(this.drawingBoardVM.brushSelectIndex === brushItem.id ? FontWeight.Medium :
                FontWeight.Normal)
                .fontColor(this.drawingBoardVM.brushSelectIndex === brushItem.id ? $r('app.color.mask_black') :
                $r('sys.color.icon_secondary'))
            }
            .alignItems(HorizontalAlign.Center)
            .justifyContent(FlexAlign.Center)
            .width(64)
            .height(100)
            .border({
              width: this.drawingBoardVM.brushSelectIndex === brushItem.id ? 1 : 0,
              color: $r('app.color.theme_color'),
              radius: $r('sys.float.corner_radius_level4')
            })
            .onClick(() => {
              this.drawingBoardVM.brushSelectIndex = brushItem.id
              this.drawingBoardVM.drawWithPen(brushItem.type, brushItem.id)
            })
          }
        }, (brushItem: BrushItem) => brushItem.id.toString())
      }
      .width(Constants.FULL_SIZE)
      .padding({
        left: 20,
        right: 20,
        top: 12,
        bottom: 20
      })
      .height(232)
      .columnsTemplate('1fr 1fr 1fr 1fr 1fr')
      .backgroundColor(Color.White)
      .columnsGap(12)
      .rowsGap(5)

      SliderComponent({
        sliderName: $r('app.string.slider_brush_size'),
        sliderMax: CommonConstants.TWENTY,
        sliderMin: CommonConstants.ZERO_POINT_ONE,
        sliderValue: this.drawingBoardVM.strokeWidth,
        sliderStep: CommonConstants.ONE,
        sliderChange: (value) => {
          this.drawingBoardVM.strokeWidth = Math.round(value)
        }
      })
        .margin({ bottom: 37 })
    }
    .backgroundColor(Color.White)
    .width(Constants.FULL_SIZE)
    .borderRadius({ topLeft: $r('sys.float.corner_radius_level16'), topRight: $r('sys.float.corner_radius_level16') })
  }

  build() {
    WindowBuilder({
      sheetBuilder: () => {
        this.render()
      },
      isPreview: true,
      isEraser: false,
      previewSize: this.drawingBoardVM.strokeWidth,
      previewColor: this.drawingBoardVM.color
    })
  }
}
