import { BaseTextStyleModifier } from 'base_apis'
import { ThemeVM } from '../../viewModel/ThemeController'
import CalendarEventVM from '../../viewModel/ViewModel'

@ComponentV2
export struct CalendarNavTitle {
  @Param title: ResourceStr = ''
  @Param bgImage: ResourceStr = ''
  @Local titleColor: ResourceStr = '#ffffff'
  @Local selectColor: ResourceStr = '#c4272b'
  @Local calendarEventVM: CalendarEventVM = CalendarEventVM.instance;
  @Local themeVM: ThemeVM = ThemeVM.instance;
  aboutToAppear(): void {
    this.titleColor = this.themeVM.titleColor
    this.selectColor = this.themeVM.selectColor
  }

  build() {
    Row({ space: 8 }) {
      Row() {
        SymbolGlyph($r('sys.symbol.chevron_left'))
          .fontColor([$r('sys.color.font_primary')])
          .fontWeight(FontWeight.Normal)
          .fontSize(24)
      }
      .width(40)
      .justifyContent(FlexAlign.Center)
      .height(40)
      .backgroundColor($r('sys.color.comp_background_secondary'))
      .borderRadius('50%')

      Text(this.title)
        .attributeModifier(new BaseTextStyleModifier(`font_primary/Title_S/Bold`))
    }
    .height(102)
    .width('100%')
    .onClick(() => {
      this.calendarEventVM.getPageInfo()?.pop()
    })
    .padding({ top: Number(AppStorage.get('topRectHeight')), left: 16, right: 16 })
    .backgroundImage(this.bgImage)
    .backgroundImageSize(ImageSize.Cover)
  }
}