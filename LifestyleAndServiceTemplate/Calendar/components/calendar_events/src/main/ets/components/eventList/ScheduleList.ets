import dayjs from 'dayjs';
import { ListEndSwiperAction } from '../common/ListEndSwiperAction';
import { UserEventItem } from '../../model/UserEventModel';
import CalendarEventVM from '../../viewModel/ViewModel';
import { COL_SPAN, GRID_ROW_OPTIONS } from '../../constants/Constants';

@ComponentV2
export struct ScheduleList {
  @Param scheduleList: UserEventItem[] = []
  @Local calendarEventVM: CalendarEventVM = CalendarEventVM.instance;

  @Builder
  itemEnd(item: UserEventItem) {
    ListEndSwiperAction({
      userEventInfo: item,
    })
  }

  build() {
    Scroll() {
      Column() {
        Column() {
          Image($r('app.media.no_data')).width(120).height(120)
          Text('暂无重要提醒')
            .fontSize(14)
            .fontColor($r('sys.color.font_secondary'))
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .height('100%')
        .visibility(this.scheduleList.length ? Visibility.None : Visibility.Visible)

        GridRow(GRID_ROW_OPTIONS) {
          ForEach(this.scheduleList, (item: UserEventItem, index: number) => {
            GridCol({
              span: COL_SPAN,
            }) {
              List() {
                ListItem() {
                  Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
                    Column() {
                      Image($r('app.media.ic_schedule')).width(24).height(24)
                    }
                    .width(30)
                    .height(30)

                    Column({ space: 5 }) {
                      Text(item.content)
                        .fontWeight(FontWeight.Medium)
                        .fontSize(14)
                        .maxLines(1)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                      Column({ space: 3 }) {
                        Text(`开始时间：${item.date[0].isLunar ? item.date[0].lunarDate :
                          dayjs(item.date[0].date).format('YYYY年MM月DD日')} ${item.date[0].time}`)
                          .fontSize(12)
                          .fontColor($r('sys.color.font_secondary'))
                        Text(`结束时间：${item.date[1].isLunar ? item.date[1].lunarDate :
                          dayjs(item.date[1].date).format('YYYY年MM月DD日')} ${item.date[1].time}`)
                          .fontSize(12)
                          .fontColor($r('sys.color.font_secondary'))
                      }.alignItems(HorizontalAlign.Start)
                    }
                    .flexGrow(1)
                    .margin({ left: 16 })
                    .alignItems(HorizontalAlign.Start)
                  }
                  .backgroundColor('#FAFAFA')
                  .borderRadius(16)
                  .padding({ left: 12, right: 12 })
                  .height(80)
                  .width('100%')
                  .onClick(() => {
                    this.calendarEventVM.getPageInfo()?.pushPathByName('ScheduleDetails', item)
                  })
                }
                .clip(true)
                .swipeAction({
                  end: {
                    builder: () => {
                      this.itemEnd(item)
                    },
                    onAction: () => {
                      this.getUIContext()?.animateTo({ duration: 1000 }, () => {
                        this.calendarEventVM.deleteUserEventInfo(this.getUIContext(), item)
                      });
                    },
                  },
                })
                .visibility(this.scheduleList.length ? Visibility.Visible : Visibility.None)
              }
              .scrollBar(BarState.Off)
              .edgeEffect(EdgeEffect.Spring, {alwaysEnabled: true})
            }
          }, (item: UserEventItem) => JSON.stringify(item))
        }
      }
      .height('100%')
      .justifyContent(FlexAlign.Start)
    }
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .layoutWeight(1)
    .padding({ bottom: 16, top: 16 })
  }
}