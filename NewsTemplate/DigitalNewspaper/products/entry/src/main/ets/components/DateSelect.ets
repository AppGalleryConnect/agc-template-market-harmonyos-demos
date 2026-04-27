import { DialogType, TypePicker, UICalendarPicker } from '@hw-agconnect/ui-calendar-picker';
import { Constant } from '../common/Constant';

@ComponentV2
export struct DateSelect {
  @Param selectedDate: Date = new Date();
  @Param themeColor: ResourceColor = $r('sys.color.brand');
  @Event onDateSelected: (date: Date) => void = () => {
  };

  build() {
    UICalendarPicker({
      type: TypePicker.SINGLE,
      dialogType: DialogType.DIALOG,
      customColor: this.themeColor,
      selected: this.selectedDate,
      rangeLimit: [new Date('2000-01-01'), new Date()],
      startYear: 2000,
      onClickDate: (date: Date) => {
        this.onDateSelected(date);
      },
    }) {
      Button() {
        Row({ space: Constant.PADDING_S }) {
          Text(this.formatDate)
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Medium)
          SymbolGlyph($r('sys.symbol.arrowtriangle_down_fill'))
            .fontSize(16)
            .fontColor([$r('sys.color.icon_primary')])
        }
        .height(Constant.DATA_BUTTON_HEIGHT)
        .padding({
          left: Constant.PADDING_L,
          right: Constant.PADDING_L,
          top: Constant.PADDING_S,
          bottom: Constant.PADDING_S,
        })
      }
      .backgroundColor($r('sys.color.comp_background_tertiary'))
    }
  }

  @Computed
  get formatDate() {
    return `${this.selectedDate.getFullYear()}/${(this.selectedDate.getMonth() + 1).toString()
      .padStart(2, '0')}/${this.selectedDate.getDate().toString().padStart(2, '0')}`
  }
}