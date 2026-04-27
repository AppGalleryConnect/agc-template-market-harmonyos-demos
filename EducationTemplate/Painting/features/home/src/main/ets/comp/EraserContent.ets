import { Constants, WindowParam } from 'common'
import { CommonConstants } from '../constants/Constant'
import { DrawingBoardVM } from '../viewmodel/DrawingBoardVM'
import { SheetTitle } from './SheetTitle'
import { SliderComponent } from './SilderComp'
import { WindowBuilder } from './WindowBuilder'

@Builder
export function EraserMenuContentBuilder(param: WindowParam) {
  EraserMenuContent({ param: param })
}

@ComponentV2
export struct EraserMenuContent {
  @Local drawingBoardVM: DrawingBoardVM = DrawingBoardVM.instance
  @Param @Require param: WindowParam

  @Builder
  render() {
    Column() {
      SheetTitle({ title: '橡皮擦' })

      SliderComponent({
        sliderName: $r('app.string.slider_eraser_size'),
        sliderMax: CommonConstants.ONE_HUNDRED,
        sliderMin: CommonConstants.ONE,
        sliderValue: this.drawingBoardVM.eraserSize,
        sliderStep: CommonConstants.TEN,
        sliderChange: (value) => {
          this.drawingBoardVM.eraserSize = Math.round(value)
        }
      })
        .padding({ bottom: 39 })
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
      isEraser :true,
      previewSize:this.drawingBoardVM.eraserSize,
      previewColor:this.drawingBoardVM.color
    })
  }
}