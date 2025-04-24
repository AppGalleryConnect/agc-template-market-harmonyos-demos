import { TypePicker, UICalendarPicker } from '@hw-agconnect/ui-calendar-picker';
import { Constant, Logger } from 'common';
import { TicketVM } from '../viewmodel/TicketVM';

@Component
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
        this.vm.initDates.splice(2, 1, this.vm.selectedDate);
        this.vm.selectedIndex = 2;
        Logger.info('select date is ' + this.vm.selectedDate);
      },
    }) {
      Row() {
        Text('更多日期').maxLines(2).opacity(0.6).fontSize(14).padding(4);
        Image($r('app.media.chevron_right')).size({ width: 12, height: 24 });
      }
      .borderRadius(8)
      .height(Constant.FULL_PERCENT)
      .alignItems(VerticalAlign.Center)
      .border({ width: 1, radius: 8, color: Color.Black });
    };
  }
}