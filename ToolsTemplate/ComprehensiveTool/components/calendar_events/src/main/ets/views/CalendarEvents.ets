import { BaseSliderSwitch } from '../base/SliderSwitch';
import { CalendarBirRem } from '../components/CalendarBirRem'
import { CalendarSchedule } from '../components/CalendarSchedule'
import { CalendarTodo } from '../components/CalendarTodo'
import { EVENT_TYPE } from '../constants/Constants';
import { ToggleItem } from '../model/UserEventModel';
import { RemindEventDispatcher } from '../utils/EventDispatcher';
import CalendarEventVM from '../viewModel/ViewModel';

@ComponentV2
export struct CalendarEvent {
  @Local calendarEventVM: CalendarEventVM = CalendarEventVM.instance;
  @Local currentIndex: number = 0
  @Param eventList: ToggleItem[] = []
  listScroller: ListScroller = new ListScroller();

  aboutToAppear(): void {
    RemindEventDispatcher.eventFocusCallback = () => {
      this.listScroller.scrollEdge(Edge.Bottom, { velocity: 200 })
    }
    RemindEventDispatcher.eventBlurCallback = () => {
      this.listScroller.scrollEdge(Edge.Top, { velocity: 200 })
    }
  }

  build() {
    List({ scroller: this.listScroller }) {
      ListItem() {
        BaseSliderSwitch({
          currentIndex: this.currentIndex,
          toggleList: this.eventList,
          switchHeight: 36,
          defaultBg: '#E6E8E9',
          onChooseChange: (value: number) => {
            this.currentIndex = value
            this.calendarEventVM.setCurrentIndex(value)
          },
        })
      }
      .margin({ top: 28 })

      ListItem() {
        Tabs({ index: this.currentIndex }) {
          ForEach(this.eventList, (item: ToggleItem) => {
            TabContent() {
              if (item.id === EVENT_TYPE.SCHEDULE) {
                CalendarSchedule()
              } else if (item.id === EVENT_TYPE.TODO) {
                CalendarTodo()
              } else if (item.id === EVENT_TYPE.ANNIVERSARIES) {
                CalendarBirRem({
                  type: item.id,
                })
              } else if (item.id === EVENT_TYPE.BIRTHDAY) {
                CalendarBirRem({
                  type: item.id,
                })
              }
            }
          }, (item: ToggleItem) => JSON.stringify(item))
        }
        .scrollable(false)
        .barHeight(0)
      }
    }
    .scrollBar(BarState.Off)
    .layoutWeight(1)
  }
}
