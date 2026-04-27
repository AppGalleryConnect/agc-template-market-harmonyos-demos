import { canvasToolsList } from '../constants/StyleConstants';
import { MenuItem } from '../types/StyleType';
import { Constants, WindowPopManager } from 'common';
import { ColorMenuContentBuilder } from './ColorContent';
import { BrushMenuContentBuilder } from './BrushContent';
import { EraserMenuContentBuilder } from './EraserContent';
import { ShapeMenuContentBuilder } from './ShapeContent';
import { BackgroundMenuContentBuilder } from './BackgroundContent';
import { DrawingBoardVM } from '../viewmodel/DrawingBoardVM';
import { CommonConstants} from '../constants/Constant';
import { sheetParam } from '../constants/WindowConstants';


@ComponentV2
export struct BottomMenuBar {
  @Local drawingBoardVM: DrawingBoardVM = DrawingBoardVM.instance

  build() {
    Row() {
      ForEach(canvasToolsList, (item: MenuItem, index: number) => {
        Column() {
          Image(this.drawingBoardVM.tabCurrentIndex === index ? item.activeIcon : item.normalIcon)
            .width($r('app.float.vp_24'))
            .height($r('app.float.vp_24'))

          Text(item.title)
            .fontSize($r('app.float.vp_10'))
            .lineHeight($r('app.float.vp_12'))
            .width(Constants.FULL_SIZE)
            .textAlign(TextAlign.Center)
            .margin({ top: $r('app.float.vp_4') })
            .fontColor(this.drawingBoardVM.tabCurrentIndex === index ? $r('app.color.theme_color') :
            $r('sys.color.font_tertiary'))
        }
        .width(Constants.TWENTY_PERCENT)
        .height($r('app.float.vp_40'))
        .padding({ top: $r('app.float.vp_3'), left: $r('app.float.vp_3'), right: $r('app.float.vp_4') })
        .alignItems(HorizontalAlign.Center)
        .onClick(() => {
          WindowPopManager.destroyWindow(CommonConstants.WINDOW_NAME)
          this.drawingBoardVM.tabCurrentIndex = index
          switch (item.type) {
            case 'brush':
              sheetParam.builder = wrapBuilder(BrushMenuContentBuilder)
              break
            case 'color':
              sheetParam.builder = wrapBuilder(ColorMenuContentBuilder)
              break
            case 'eraser':
              sheetParam.builder = wrapBuilder(EraserMenuContentBuilder)
              break
            case 'shape':
              sheetParam.builder = wrapBuilder(ShapeMenuContentBuilder)
              break
            case 'background':
              sheetParam.builder = wrapBuilder(BackgroundMenuContentBuilder)
              break
            default:
              sheetParam.builder = wrapBuilder(BackgroundMenuContentBuilder)
              break

          }
          WindowPopManager.showWindow(sheetParam)
        })
      }, (item: MenuItem) => item.type)
    }
    .width(Constants.FULL_SIZE)
    .height($r('app.float.vp_48'))
  }
}
