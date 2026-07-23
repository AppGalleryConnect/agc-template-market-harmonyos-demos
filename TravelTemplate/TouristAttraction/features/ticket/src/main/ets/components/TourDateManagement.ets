import { UICalendarPicker } from '@hw-agconnect/ui-calendar-picker';
import { CommonUtil, Constant } from 'common';
import { TicketType } from '../model/TicketInfo';
import { TicketVM } from '../viewmodel/TicketVM';
import { UICalendar } from './UICalendar';

@ComponentV2
export struct TourDateManagement {
  vm: TicketVM = TicketVM.instance;
  @Local isShow: boolean = false;
  @Param @Require ticketType: TicketType | null;

  async aboutToAppear() {
    this.vm.getDate();
    this.vm.getWindowSizeChange(this.getUIContext().getHostContext()!);
  }

  @Builder
  DateItem(item: Date, index: number) {
    Stack() {
      Column() {
        Text(`${CommonUtil.padWithZeros(item.getMonth() + 1)}-${CommonUtil.padWithZeros(item.getDate())}`)
          .fontSize($r('sys.float.Body_M'))
          .fontColor($r('sys.color.font_primary'));
        Text() {
          Span(`￥`).fontSize($r('sys.float.Caption_M'));
          Span(`${this.ticketType?.discountPrice}`).fontSize($r('sys.float.Body_M'));
        }.fontColor($r('sys.color.warning'));
      }
      .border(this.vm.selectedIndex === index ? {
        width: 1,
        radius: 8,
        color: $r('sys.color.multi_color_04'),
      } : { radius: 8 })
      .backgroundColor(this.vm.selectedIndex === index ? '#1A64BB5C' : $r('sys.color.comp_background_tertiary'))
      .padding({
        left: 16,
        right: 16,
        top: 8,
        bottom: 8,
      });

      Row() {
        SymbolGlyph($r('sys.symbol.checkmark'))
          .width(12)
          .height(12)
          .fontSize(12)
          .fontColor([$r('sys.color.icon_on_primary')]);
      }
      .backgroundColor($r('sys.color.multi_color_04'))
      .borderRadius({ topLeft: 8, bottomRight: 8 })
      .padding(2)
      .visibility(this.vm.selectedIndex === index ? Visibility.Visible : Visibility.Hidden)
      .clip(true);
    }.alignContent(Alignment.BottomEnd)
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
    Column({ space: 8 }) {
      Text('选择日期').fontSize($r('sys.float.Body_L')).fontWeight(FontWeight.Medium);
      Row(){
        List({ space: 8 }) {
          ForEach(this.vm.initDates, (item: Date, index: number) => {
            ListItem() {
              this.DateItem(item, index);
            };
          }, (item: Date, index: number) => index + '__' + JSON.stringify(item));
        }
        .edgeEffect(EdgeEffect.Spring)
        .listDirection(Axis.Horizontal)
        .alignListItem(ListItemAlign.Start)
        .layoutWeight(1)
        .scrollBar(BarState.Off);
        UICalendar();
      }.width(Constant.FULL_PERCENT)

    }.alignItems(HorizontalAlign.Start);
  }
}