import { SheetTitle } from './SheetTitle'
import { Constants, WindowParam, WindowPopManager } from 'common'
import { shapeTypesList } from '../constants/StyleConstants'
import { SliderComponent } from './SilderComp'
import { CommonConstants } from '../constants/Constant'
import { DrawingBoardVM } from '../viewmodel/DrawingBoardVM'
import { WindowBuilder } from './WindowBuilder'
import { MenuItem } from '../types/StyleType'

@Builder
export function ShapeMenuContentBuilder(param: WindowParam) {
  ShapeMenuContent({ param: param })
}


@ComponentV2
export struct ShapeMenuContent {
  @Local drawingBoardVM: DrawingBoardVM = DrawingBoardVM.instance
  @Param @Require param: WindowParam

  @Builder
  render() {
    Column() {
      SheetTitle({ title: '图形' })
      Row() {
        ForEach(shapeTypesList, (shape: MenuItem) => {
          Image(this.drawingBoardVM.currentShape === shape.type ? shape.activeIcon : shape.normalIcon)
            .width(100)
            .height(100)
            .border({
              width: this.drawingBoardVM.currentShape === shape.type ? 1 : 0,
              color: $r('app.color.theme_color')
            })
            .borderRadius($r('sys.float.corner_radius_level4'))
            .margin({ right: 14 })
            .onClick(() => {
              this.drawingBoardVM.currentShape = shape.type
              WindowPopManager.destroyWindow(CommonConstants.WINDOW_NAME)
            })
        },(shape:MenuItem)=>shape.id.toString())
      }
      .width(Constants.FULL_SIZE)
      .justifyContent(FlexAlign.SpaceBetween)
      .backgroundColor(Color.White)
      .padding({ left: 16, right: 16 })

      SliderComponent({
        sliderName: $r('app.string.slider_shape_stroke_size'),
        sliderMax: CommonConstants.TWENTY,
        sliderMin: CommonConstants.ZERO_POINT_ONE,
        sliderValue: this.drawingBoardVM.shapeStrokeWidth,
        sliderStep: CommonConstants.ONE,
        sliderChange: (value) => {
          this.drawingBoardVM.shapeStrokeWidth = Math.round(value)
        }
      })
        .margin({ bottom: 39 })
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
      isPreview:true,
      isEraser :false,
      previewSize:this.drawingBoardVM.shapeStrokeWidth,
      previewColor:this.drawingBoardVM.color
    })
  }
}