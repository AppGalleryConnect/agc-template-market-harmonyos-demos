import { TypePicker, UICalendarPicker } from '@hw-agconnect/ui-calendar-picker';
import { CommonUtil, Logger } from 'common';
import { TicketVM } from '../viewmodel/TicketVM';

@ComponentV2
export struct UICalendar {
  vm: TicketVM = TicketVM.instance;

  build() {
    UICalendarPicker({
      selected: this.vm.selectedDate,
      type: TypePicker.SINGLE,
      customColor: Color.Blue,
      rangeLimit: [new Date()],
      onSelected: (date) => {
        this.vm.selectedDate = date as Date;
        if (CommonUtil.isDisplayModeFull()) {
          this.vm.initDates.splice(6, 1, this.vm.selectedDate);
          this.vm.selectedIndex = 6;
        } else {
          this.vm.initDates.splice(2, 1, this.vm.selectedDate);
          this.vm.selectedIndex = 2;
        }
        Logger.info('select date is ' + this.vm.selectedDate);
      },
    }) {
      Row({space:4}) {
        Text('更多日期').maxLines(2).width(29).fontColor($r('sys.color.font_primary')).fontSize($r('sys.float.Body_S')).textAlign(TextAlign.End);
        SymbolGlyph($r('sys.symbol.chevron_right'))
          .width(12)
          .height(24)
          .fontSize(24)
          .fontColor([$r('sys.color.icon_fourth')])
      }
      .padding({left:8,top:8,bottom:8})
      .height(54)
      .alignItems(VerticalAlign.Center)
      .backgroundColor($r('sys.color.comp_background_primary'))
    };
  }
}