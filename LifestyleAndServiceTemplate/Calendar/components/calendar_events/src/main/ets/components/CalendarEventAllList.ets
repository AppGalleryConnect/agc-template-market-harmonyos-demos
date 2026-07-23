import dayjs from 'dayjs';
import { ToggleItem } from 'base_apis';
import { UserEventItem } from '../model/UserEventModel';
import CalendarEventVM from '../viewModel/ViewModel';
import { eventRecord, EVENT_TYPE, FOLDER_SPAN, GRID_ROW_OPTIONS, routerMap } from '../constants/Constants';
import { DistanceToday } from './common/DistanceToday';


@ComponentV2
export struct CalendarEventList {
  @Local calendarEventVM: CalendarEventVM = CalendarEventVM.instance;
  @Param eventList: ToggleItem[] = []

  build() {
    Column() {
      Flex({ justifyContent: FlexAlign.SpaceAround }) {
        ForEach(this.eventList, (item: ToggleItem, index: number) => {
          Column({ space: 8 }) {
            Text(this.calendarEventVM.getEventLength(item.id).toString())
              .fontSize(20)
              .fontWeight(FontWeight.Medium)
            Text(item.name)
              .fontSize(12)
              .fontColor($r('sys.color.font_secondary'))
          }
          .onClick(() => {
            const navigationParams: Record<string, number | ToggleItem[]> = {
              'eventList': this.eventList,
              'index': index,
            }
            this.calendarEventVM.getPageInfo()?.pushPathByName('CalendarEventDetails', navigationParams)
          })
        }, (item: ToggleItem) => JSON.stringify(item))
      }

      Scroll() {
        GridRow({
          columns: {
            sm: 4,
            md: 8,
            lg: 12,
            xl: 12,
          },
          gutter: {
            x: 8,
            y: 8,
          },
        }) {
          ForEach(this.calendarEventVM.userEvent.userEventList, (item: UserEventItem) => {
            GridCol({
              span: FOLDER_SPAN,
            }) {
              Row() {
                Row({ space: 16 }) {
                  Image($r(eventRecord[item.eventType])).width(24).height(24)
                  Column({ space: 5 }) {
                    Text(item.content)
                      .fontSize(14)
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                    Text(item.date[0].isLunar ? item.date[0].lunarDate :
                      dayjs(item.date[0].date).format('YYYY年MM月DD日'))
                      .fontSize(12)
                      .fontColor($r('sys.color.font_secondary'))
                  }
                  .width('70%')
                  .alignItems(HorizontalAlign.Start)
                }

                Column() {
                  DistanceToday({
                    endDate: item.date[0].date,
                  })
                }
              }
              .onClick(() => {
                if ([EVENT_TYPE.BIRTHDAY, EVENT_TYPE.ANNIVERSARIES].includes(item.eventType)) {
                  const params: Record<string, UserEventItem | string> = {
                    'userEventInfo': item,
                    'eventType': item.eventType,
                  }
                  this.calendarEventVM.getPageInfo()?.pushPathByName(routerMap[item.eventType], params)
                  return
                }
                this.calendarEventVM.getPageInfo()?.pushPathByName(routerMap[item.eventType], item)
              })
              .width('100%')
              .justifyContent(FlexAlign.SpaceBetween)
              .padding({ left: 16, right: 16 })
              .height(56)
              .backgroundColor('#FAFAFA')
              .borderRadius(16)
            }
          }, (item: UserEventItem) => JSON.stringify(item))
        }
        .margin({ top: 16 })
      }
      .scrollBar(BarState.Off)
      .constraintSize({ maxHeight: 280 })
      .nestedScroll({
        scrollForward: NestedScrollMode.PARENT_FIRST,
        scrollBackward: NestedScrollMode.SELF_FIRST
      })
      .padding({ bottom: 16 })
      .edgeEffect(EdgeEffect.Spring)
    }
    .margin({ top: 20 })
  }
}