import { UserEventItem } from '../../model/UserEventModel';
import CalendarEventVM from '../../viewModel/ViewModel';

@ComponentV2
export struct ListEndSwiperAction {
  @Local calendarEventVM: CalendarEventVM = CalendarEventVM.instance;
  @Require @Param userEventInfo: UserEventItem;
  @Event onDelete: () => void = () => {
  };

  build() {
    Row() {
      Image($r('app.media.delete_w'))
        .width(24)
        .height(24)
    }
    .onClick(() => {
      this.calendarEventVM.deleteUserEventInfo(this.getUIContext(),this.userEventInfo,this.onDelete)
    })
    .justifyContent(FlexAlign.Center)
    .width(48)
    .height(48)
    .borderRadius('50%')
    .backgroundColor('#E84026')
    .margin({ left: 16 })
  }
}