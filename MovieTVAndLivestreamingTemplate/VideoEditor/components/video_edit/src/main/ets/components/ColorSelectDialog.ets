import { HSBColorPicker, HSBColorPickerLayout } from '@keke/color-picker'
import { PrompterListVM } from '../viewmodel/PrompterListVM'

@ComponentV2
export struct ColorSelectDialog {
  @Param @Require teleprompterListVM: PrompterListVM
  @Local defaultColor: string | Color = '#FFFFFFFF'

  aboutToAppear(): void {
    this.defaultColor = this.teleprompterListVM.editTexts[this.teleprompterListVM.activeIndex].colorVal
  }

  resetColor() {
    this.teleprompterListVM.editTexts[this.teleprompterListVM.activeIndex].colorVal = this.defaultColor
  }

  build() {
    Column() {
      Row() {
        Image($r('app.media.icon_telepromter_cancel')).width(20).height(20)
          .onClick(() => {
            this.resetColor()
            this.teleprompterListVM.colorSelectStatus = false
          })
      }.width('100%').justifyContent(FlexAlign.End)
      .margin({ top: 9 })

      HSBColorPicker({
        layout: HSBColorPickerLayout.COLUMN,
        color: this.defaultColor.toString().toLowerCase(),
        radius: 8,
        showAlpha: true,
        onChange: (colorStr: string) => {
          this.teleprompterListVM.editTexts[this.teleprompterListVM.activeIndex].colorVal = colorStr
        }
      }).margin({ top: 9 }).width('100%').height(212)

      Text('确定')
        .textAlign(TextAlign.Center)
        .fontSize(16)
        .fontColor('#000000')
        .margin({ top: 24, bottom: 29 })
        .width(304)
        .height(40)
        .borderRadius(20)
        .linearGradient({
          angle: 90,
          colors: [['#01A8FE', 0.0], ['#01FCEA', 1]]
        })
        .onClick(() => {
          this.teleprompterListVM.colorSelectStatus = false
        })

    }.width('100%')
    .borderRadius({
      topLeft: 20,
      topRight: 20,
      bottomLeft: 0,
      bottomRight: 0
    })
    .alignItems(HorizontalAlign.Center)
    .backgroundColor('#262626')
    .padding({ left: 26.88, right: 26.88, bottom: 27 })
  }
}