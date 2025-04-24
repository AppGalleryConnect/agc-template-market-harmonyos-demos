import { UICalendarPicker } from '@hw-agconnect/ui-calendar-picker';
import { Constant, getInitDates, Logger, padWithZeros } from 'common';
import { TicketType } from '../model/TicketInfo';
import { TicketVM } from '../viewmodel/TicketVM';
import { UICalendar } from './UICalendar';

@ComponentV2
export struct TourDateManagement {
  vm: TicketVM = TicketVM.instance;
  @Local isShow: boolean = false;
  @Param @Require ticketType: TicketType | null;

  aboutToAppear(): void {
    let date = new Date();
    this.vm.initDates = getInitDates(date.getFullYear(), date.getMonth(), date.getDate());
  }

  @Builder
  DateItem(item: Date, index: number) {
    Column() {
      Text(`${padWithZeros(item.getMonth() + 1)}-${padWithZeros(item.getDate())}`)
        .opacity(0.6)
        .fontColor(this.vm.selectedIndex === index ? '#64BB5C' : Color.Black);
      Text(`￥${this.ticketType?.discountPrice}`)
        .opacity(0.6)
        .fontColor(this.vm.selectedIndex === index ? '#64BB5C' : Color.Black);
    }
    .border({
      width: 1,
      radius: 8,
      color: this.vm.selectedIndex === index ? 'rgb(100, 187, 92)' : 'rgba(0, 0, 0, 0.05)',
    })
    .backgroundColor(this.vm.selectedIndex === index ? 'rgba(100, 187, 92, 0.2)' : 'rgb(255, 255, 255)')
    .padding({
      left: 20,
      right: 20,
      top: 6,
      bottom: 6,
    })
    .onClick(() => {
      this.vm.selectedIndex = index;
      this.vm.selectedDate = item;
    });
  }

  @Builder
  DateSelectBuilder() {
    UICalendarPicker({});
  }

  build() {
    Column() {
      Text('选择日期')
        .fontSize(14)
        .fontWeight(500)
        .width(Constant.FULL_PERCENT)
        .textAlign(TextAlign.Start)
        .margin({ bottom: 12 });
      List({ space: 8 }) {
        ForEach(this.vm.initDates, (item: Date, index: number) => {
          ListItem() {
            this.DateItem(item, index);
          };
        }, (item: Date, index: number) => index + '__' + JSON.stringify(item));
        ListItem() {
          UICalendar();
        }.width(50);
      }
      .listDirection(Axis.Horizontal)
      .alignListItem(ListItemAlign.Start)
      .width(Constant.FULL_PERCENT)
      .height(50)
      .scrollBar(BarState.Off);
    };
  }
}