import { PersistenceV2 } from '@kit.ArkUI';
import { ToggleItem, UserEvent, UserEventItem } from '../model/UserEventModel';
import CalendarEventVM from '../viewModel/ViewModel';
import { ScheduleList } from './eventList/ScheduleList';
import { BirthdayRememberList } from './eventList/BirthdayRememberList';
import { TodoList } from './eventList/TodoList';
import { EVENT_TYPE } from '../constants/Constants';
import { BaseCustomTabBar } from '../base/BaseCustomTabBar';

@ComponentV2
export struct CalendarEventDetails {
  @Local userEvent: UserEvent = PersistenceV2.connect(UserEvent, () => new UserEvent())!;
  @Local currentIndex: number = 0
  @Local calendarEventVM: CalendarEventVM = CalendarEventVM.instance;
  @Param @Require eventList: ToggleItem[] = []

  sortedBirthdayRemember(userEventItem: UserEventItem[]) {
    return userEventItem.sort((a, b) => {

      if (a.isTop !== b.isTop) {
        return a.isTop ? 0 : 1 - (b.isTop ? 0 : 1);
      }

      const dateA = a.date[0]?.date as Date;
      const dateB = b.date[0]?.date as Date;

      if (!dateA) {
        return 1
      }

      if (!dateB) {
        return -1
      }

      return new Date(dateA).getTime() - new Date(dateB).getTime();
    });
  }

  getBirthdayRememberList(item: ToggleItem): UserEventItem[] {
    return this.sortedBirthdayRemember(this.userEvent.userEventList.filter(value => value.eventType === item.id))
  }

  build() {
    Column() {
      BaseCustomTabBar({
        currentIndex: this.currentIndex,
        rawSource: 'Event_list.json',
        tabIndexChange: (index: number) => {
          this.currentIndex = index
        },
      })
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
                  birthdayRememberList: this.getBirthdayRememberList(item),
                  eventType: item.id,
                })
              }
              if (item.id === EVENT_TYPE.ANNIVERSARIES) {
                BirthdayRememberList({
                  birthdayRememberList: this.getBirthdayRememberList(item),
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
          .layoutWeight(1)
        }, (item: ToggleItem) => item.id)
      }
      .scrollable(false)
      .barHeight(0)
      .layoutWeight(1)
      .padding({ left: 16, right: 16 })
    }
  }
}