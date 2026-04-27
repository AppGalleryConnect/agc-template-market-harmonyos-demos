import { EVENT_TYPE } from '../../constants/Constants';
import { UserEventItem } from '../../model/UserEventModel';
import CalendarEventVM from '../../viewModel/ViewModel';

@ComponentV2
export struct ListEndSwiperAction {
  @Local calendarEventVM: CalendarEventVM = CalendarEventVM.instance;
  @Require @Param userEventInfo: UserEventItem;
  @Event onDelete: () => void = () => {
  };
  @Event onToTop: (userEventInfo: UserEventItem) => void = () => {
  };

  build() {
    Row({ space: 8 }) {
      Column({ space: 5 }) {
        Image($r('app.media.toTop'))
          .width(18)
          .height(20)
        Text('置顶')
          .fontColor($r('sys.color.font_on_primary'))
          .fontWeight(FontWeight.Medium)
          .fontSize(14)
      }
      .visibility([EVENT_TYPE.BIRTHDAY, EVENT_TYPE.ANNIVERSARIES].includes(this.userEventInfo.eventType) ?
      Visibility.Visible : Visibility.None)
      .backgroundColor($r('sys.color.comp_background_emphasize'))
      .width(64)
      .height('100%')
      .borderRadius(16)
      .justifyContent(FlexAlign.Center)
      .margin({ left: 8 })
      .onClick(() => {
        this.onToTop(this.userEventInfo)
      })

      Row() {
        Column({ space: 5 }) {
          Image($r('app.media.delete_swiper'))
            .width(18)
            .height(20)
          Text('删除')
            .fontColor($r('sys.color.font_on_primary'))
            .fontWeight(FontWeight.Medium)
            .fontSize(14)
        }
      }
      .onClick(() => {
        this.calendarEventVM.deleteUserEventInfo(this.userEventInfo, this.getUIContext(), this.onDelete)
      })
      .justifyContent(FlexAlign.Center)
      .width(64)
      .height('100%')
      .borderRadius({
        topRight: 16,
        bottomRight: 16,
      })
      .backgroundColor('#E84026')
    }
  }
}