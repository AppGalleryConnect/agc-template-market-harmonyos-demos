import { PersistenceV2 } from '@kit.ArkUI';
import { BaseCustomTabBar, ToggleItem } from 'base_apis'
import { CalendarNavTitle } from './common/CalendarNavTitle'
import { UserEvent } from '../model/UserEventModel';
import CalendarEventVM from '../viewModel/ViewModel';
import { ScheduleList } from './eventList/ScheduleList';
import { BirthdayRememberList } from './eventList/BirthdayRememberList';
import { TodoList } from './eventList/TodoList';
import { EVENT_TYPE, TABLET_GRID, TABLE_COL, TABLE_COL_OFFSET } from '../constants/Constants';

@Builder
export function CalendarEventDetailsBuilder() {
  CalendarEventDetails()
}

@ComponentV2
export struct CalendarEventDetails {
  @Local userEvent: UserEvent = PersistenceV2.connect(UserEvent, () => new UserEvent())!;
  @Local currentIndex: number = 0
  @Local calendarEventVM: CalendarEventVM = CalendarEventVM.instance;
  @Local eventList: ToggleItem[] = []

  aboutToAppear(): void {
    let params =
      this.calendarEventVM.getPageInfo()?.getParamByName('CalendarEventDetails')[0] as Record<string, number | ToggleItem[]>
    if (params !== undefined) {
      this.currentIndex = params.index as number
      this.eventList = params.eventList as ToggleItem[]
    }
  }

  build() {
    NavDestination() {
      CalendarNavTitle({
        title: '重要提醒',
      })
      BaseCustomTabBar({
        currentIndex: this.currentIndex,
        rawSource: 'Event_list.json',
        tabIndexChange: (index: number) => {
          this.currentIndex = index
        },
      })
      GridRow(TABLET_GRID) {
        GridCol({
          span: TABLE_COL,
          offset: TABLE_COL_OFFSET,
        }) {
          Tabs({ index: this.currentIndex }) {
            ForEach(this.eventList, (item: ToggleItem) => {
              TabContent() {
                Column() {
                  if (item.id === EVENT_TYPE.SCHEDULE) {
                    ScheduleList({
                      scheduleList: this.calendarEventVM.userEvent.userEventList.filter(value => value.eventType ===
                      item.id),
                    })
                  }
                  if (item.id === EVENT_TYPE.BIRTHDAY) {
                    BirthdayRememberList({
                      birthdayRememberList: this.userEvent.userEventList.filter(value => value.eventType === item.id),
                      eventType: item.id,
                    })
                  }
                  if (item.id === EVENT_TYPE.ANNIVERSARIES) {
                    BirthdayRememberList({
                      birthdayRememberList: this.userEvent.userEventList.filter(value => value.eventType === item.id),
                      eventType: item.id,
                    })
                  }
                  if (item.id === EVENT_TYPE.TODO) {
                    TodoList({
                      todoList: this.userEvent.userEventList.filter(value => value.eventType === item.id),
                    })
                  }
                }
                .layoutWeight(1)
              }
            }, (item: ToggleItem) => item.id)
          }
          .scrollable(false)
          .barHeight(0)
          .layoutWeight(1)
          .padding({ left: 16, right: 16 })
        }
      }
      .layoutWeight(1)
    }
    .hideTitleBar(true)
  }
}