import { BaseTextStyleModifier } from '../../model/TextStyleModifier'
import CalendarEventVM from '../../viewModel/ViewModel'

@ComponentV2
export struct CalendarNavTitle {
  @Param isHideBack: boolean = false
  @Param title: ResourceStr = ''
  @Local titleColor: ResourceStr = $r('sys.color.background_primary')
  @Local calendarEventVM: CalendarEventVM = CalendarEventVM.instance;
  @BuilderParam rightBuilder?: () => void;

  build() {
    Flex({ justifyContent: FlexAlign.SpaceBetween }) {
      Row({ space: 8 }) {
        Row() {
          Image($r('app.media.calendar_back')).width(40).height(40)
        }
        .width(40)
        .justifyContent(FlexAlign.Center)
        .height(40)
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .borderRadius('50%')
        .visibility(this.isHideBack ? Visibility.None : Visibility.Visible)
        .onClick(() => {
          this.calendarEventVM.getPageInfo()?.pop()
        })

        Text(this.title)
          .attributeModifier(new BaseTextStyleModifier(`${this.titleColor}/Title_S/Bold`))
      }

      if (this.rightBuilder) {
        this.rightBuilder()
      }
    }
    .padding({ left: 16, right: 16, bottom: 16 })
  }
}