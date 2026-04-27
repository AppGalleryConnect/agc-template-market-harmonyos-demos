import { ButtonGroup } from '../components/ButtonGroup'
import { ColorPanPicker } from '../components/ColorPanPicker'
import { UploadCover } from '../components/UploadCover'
import { BUTTON_LIST, CommonConstants } from '../constants/CommonConstants'
import { DrawBoardVM } from '../viewmodel/DrawVM'
import { ToolsNav } from './ToolsNav'

@ComponentV2
export struct BackgroundColor {
  @Local drawBoardVM: DrawBoardVM = DrawBoardVM.instance
  @Local selectId: string = '1'

  build() {
    Column() {
      ToolsNav({ title: $r('app.string.backgroundColorSelect'), closePicker: () => {
        this.drawBoardVM.tabCurrentIndex = 0;
      } })
      ButtonGroup({
        buttonList: BUTTON_LIST,
        selectedId: this.selectId!!,
      })
      Column() {
        ColorPanPicker({
          selectColor: this.drawBoardVM.canvasColor,
          alpha: this.drawBoardVM.backgroundAlpha,
          percent: this.drawBoardVM.percent,
          onSelectChange: (color: string) => {
            this.drawBoardVM.canvasColor = color
            this.drawBoardVM.canvasBackgroundImage = ''
            this.drawBoardVM.tabCurrentIndex = 0
          },
          onAlphaChange: (value: number) => {
            this.drawBoardVM.backgroundAlpha = value / 100;
            this.drawBoardVM.ToggleThicknessColor();
            this.drawBoardVM.tabCurrentIndex = 0
          },
        })
          .visibility(this.selectId === '1' ? Visibility.Visible : Visibility.None)

        UploadCover()
          .visibility(this.selectId === '2' ? Visibility.Visible : Visibility.None)
      }
      .height(420)

    }
    .alignItems(HorizontalAlign.Start)
    .width(CommonConstants.ONE_HUNDRED_PERCENT)
    .padding({
      bottom: 36,
      left: 16,
      right: 16,
      top: 16,
    })
    .backgroundColor($r('sys.color.background_secondary'))
  }
}