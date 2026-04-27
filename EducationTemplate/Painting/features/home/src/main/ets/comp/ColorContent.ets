import { ColorSelector } from 'painting_color_selector'
import { Constants, WindowParam, WindowPopManager } from 'common'
import { CommonConstants } from '../constants/Constant'
import { colorGroupList } from '../constants/StyleConstants'
import { GroupTab } from './GroupTab'
import { SheetTitle } from './SheetTitle'
import { DrawingBoardVM } from '../viewmodel/DrawingBoardVM'
import { ColorGrid } from './ColorGrid'
import { PersistenceV2 } from '@kit.ArkUI'
import { ColorHistoryVM } from '../viewmodel/ColorHistoryVM'
import { WindowBuilder } from './WindowBuilder'


@Builder
export function ColorMenuContentBuilder(param: WindowParam) {
  ColorMenuContent({ param: param })
}


@ComponentV2
export struct ColorMenuContent {
  @Local drawingBoardVM: DrawingBoardVM = DrawingBoardVM.instance
  @Local colorHistoryVM: ColorHistoryVM =
    PersistenceV2.connect(ColorHistoryVM, 'colorHistoryVM', () => new ColorHistoryVM())!;
  @Param @Require param: WindowParam
  @Local colorSelectType: string = 'Regular'

  @Builder
  RecentBuilder() {
    ColorGrid({
      colorList: this.colorHistoryVM.colors,
      selectColor: this.drawingBoardVM.color,
      colorChange: (color: string) => {
        this.chooseColor(color)
      }
    })
  }

  @Builder
  RegularBuilder() {
    ColorGrid({
      colorList: CommonConstants.COLOR_ARR,
      selectColor: this.drawingBoardVM.color,
      colorChange: (color: string) => {
        this.chooseColor(color)
      }
    })
  }

  private chooseColor(color: string) {
    this.drawingBoardVM.color = color
    WindowPopManager.destroyWindow(CommonConstants.WINDOW_NAME)
  }

  @Builder
  CustomBuilder() {
    //颜色选择组件
    ColorSelector({
      color: this.drawingBoardVM.color,
      drawingId: CommonConstants.DRAW_BOARD_ID,
      touchX: this.drawingBoardVM.touchX,
      touchY: this.drawingBoardVM.touchY,
      RGB: this.drawingBoardVM.rgb,
      selectColorChange: (color) => {
        this.drawingBoardVM.selectColor = color
      },
      RGBChange: (rgb) => {
        this.drawingBoardVM.rgb = rgb
      },
      colorChange: (color) => {
        this.chooseColor(color)
      },
      colorSampling: () => {
        this.drawingBoardVM.isColorSampling = true
        this.param.event?.hide()
      }
    })
      .margin({ top: 10, bottom: 18 })
  }

  @Builder
  render() {
    Column() {
      SheetTitle({ title: '颜色' })

      GroupTab({
        groupList: colorGroupList,
        showGroup: this.colorSelectType,
        changeGroup: (group) => {
          this.colorSelectType = group
        }
      })
      Column() {
        if (this.colorSelectType === 'Recent') {
          this.RecentBuilder()
        } else if (this.colorSelectType === 'Regular') {
          this.RegularBuilder()
        } else if (this.colorSelectType === 'Custom') {
          this.CustomBuilder()
        }
      }
      .padding({ left: 16, right: 16 })
      .margin({ top: 8 })
    }
    .backgroundColor(Color.White)
    .width(Constants.FULL_SIZE)
    .borderRadius({ topLeft: $r('sys.float.corner_radius_level16'), topRight: $r('sys.float.corner_radius_level16') })
  }

  build() {
    WindowBuilder({
      sheetBuilder: () => {
        this.render()
      }
    })
  }
}