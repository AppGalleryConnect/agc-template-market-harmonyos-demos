import { PersistenceV2 } from '@kit.ArkUI';
import { baseActionSheet, BaseCell, getDataFromJSON, ToastUtils, ToggleItem } from 'base_apis'
import CalendarEventVM from '../viewModel/ViewModel';
import { CalendarEvent } from './CalendarEvents'
import { UserEvent, UserEventItem } from '../model/UserEventModel';
import { CalendarEventList } from '../components/CalendarEventAllList';
import { CalendarSheetHeader } from '../components/common/CalendarSheetHeader';
import { RemindEventDispatcher } from '../utils/EventDispatcher';
import { ThemeVM } from '../viewModel/ThemeController';


@ComponentV2
export struct CalendarEventMain {
  @Local calendarEventVM: CalendarEventVM = CalendarEventVM.instance;
  @Param selectColor: ResourceStr = '#c4272b';
  @Param titleColor: ResourceStr = '#ffffff';
  @Param currentColor: ResourceStr = '#c4272b';
  @Local userEvent: UserEvent = PersistenceV2.connect(UserEvent, () => new UserEvent())!;
  @Param pathStack: NavPathStack = new NavPathStack()
  @Event onCalendarEventChange: (userEventInfo: UserEventItem) => void = () => {
  }
  @Event onCalendarEventDelete: (userEventInfo: UserEventItem) => void = () => {
  }
  @Local eventList: ToggleItem[] = []
  private context: UIContext = this.getUIContext();
  @Local themeVM: ThemeVM = ThemeVM.instance;

  @Monitor('selectColor')
  selectColorChange() {
    this.themeVM.setTheme(this.selectColor, this.titleColor, this.currentColor)
  }

  aboutToAppear(): void {
    ToastUtils.setUIContext(this.getUIContext())
    RemindEventDispatcher.eventChangeCallback = (userEventInfo: UserEventItem) => {
      this.onCalendarEventChange(userEventInfo)
    }
    RemindEventDispatcher.eventDeleteCallback = (userEventInfo: UserEventItem) => {
      this.onCalendarEventDelete(userEventInfo)
    }
    this.eventList = getDataFromJSON<ToggleItem>(this.getUIContext().getHostContext()!, 'Event_list.json');
    this.calendarEventVM.setUserEvent(this.userEvent)
    this.calendarEventVM.setContext(this.context)
    this.themeVM.setTheme(this.selectColor, this.titleColor, this.currentColor)
  }

  @Builder
  sheetCustomBuilder() {
    CalendarEvent({
      eventList: this.eventList,
    })
  }

  @Builder
  CalendarReminderAdd() {
    CalendarSheetHeader({
      title: '添加',
      calendarEventBuilder: () => {
        this.sheetCustomBuilder()
      },
      onClose: () => {
        baseActionSheet.close(this.context, 'CalendarReminder')
      },
      onConfirm: async () => {
        switch (this.calendarEventVM.currentIndex) {
          case 0:
            RemindEventDispatcher.dispatchToSchedule();
            break;
          case 1:
            RemindEventDispatcher.dispatchTobBir();
            break
          case 2:
            RemindEventDispatcher.dispatchTobRem();
            break
          case 3:
            RemindEventDispatcher.dispatchTodo();
            break
        }
      },
    })
  }

  @Builder
  eventAdd() {
    Row({ space: 5 }) {
      Image($r('app.media.event_add')).width(16).height(16)
      Text('添加').fontColor('#C4272B')
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
    }
    .onClick(() => {
      baseActionSheet.show(this.context, {
        id: 'CalendarReminder',
        height: '100%',
        showClose: false,
        backgroundColor: $r('sys.color.background_secondary'),
        customContent: () => {
          this.CalendarReminderAdd()
        },
        onClose: () => {
          this.calendarEventVM.clearDate()
        },
      })
    })
    .borderRadius(14)
    .padding({
      left: 8,
      right: 8,
      top: 4,
      bottom: 4,
    })
    .backgroundColor($r('sys.color.background_secondary'))
  }

  @Builder
  calendarEventList() {
    CalendarEventList({
      eventList: this.eventList,
    })
      .onAppear(() => {
        this.calendarEventVM.setPageInfo(this.pathStack)
      })
  }

  build() {
    Column() {
      BaseCell({
        cellTitle: '重要提醒',
        rightTextBuilderParam: () => this.eventAdd(),
        customBuilderParam: () => this.calendarEventList(),
      })
    }
  }
}
