import { PersistenceV2 } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import CalendarEventVM from '../viewModel/ViewModel';
import { CalendarEvent } from './CalendarEvents'
import { ToggleItem, UserEvent, UserEventItem } from '../model/UserEventModel';
import { CalendarSheetHeader } from '../components/common/CalendarSheetHeader';
import { RemindEventDispatcher } from '../utils/EventDispatcher';
import { ThemeVM } from '../viewModel/ThemeController';
import { baseActionSheet } from '../base/ActionSheet';
import { getDataFromJSON } from '../utils/Utils';
import { CalendarEventDetails } from '../components/CalendarEventList';
import { CalendarNavTitle } from '../components/common/CalendarNavTitle';


@Builder
export function CalendarEventBuilder() {
  CalendarEventMain()
}

@ComponentV2
export struct CalendarEventMain {
  @Local calendarEventVM: CalendarEventVM = CalendarEventVM.instance;
  @Param isHideBack: boolean = false;
  @Param selectColor: ResourceStr = '#c4272b';
  @Param titleColor: ResourceStr = '#ffffff';
  @Local userEvent: UserEvent = PersistenceV2.connect(UserEvent, () => new UserEvent())!;
  @Local pathStack: NavPathStack = new NavPathStack()
  @Event onCalendarEventChange: (userEventInfo: UserEventItem) => void = () => {}
  @Event onCalendarEventDelete: (userEventInfo: UserEventItem) => void = () => {}
  @Local eventList: ToggleItem[] = []
  private context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
  @Local themeVM: ThemeVM = ThemeVM.instance;

  @Monitor('selectColor')
  selectColorChange() {
    this.themeVM.setTheme(this.selectColor, this.titleColor)
  }

  aboutToAppear(): void {
    RemindEventDispatcher.eventChangeCallback = (userEventInfo: UserEventItem) => {
      this.onCalendarEventChange(userEventInfo)
    }
    RemindEventDispatcher.eventDeleteCallback = (userEventInfo: UserEventItem) => {
      this.onCalendarEventDelete(userEventInfo)
    }
    this.eventList = getDataFromJSON<ToggleItem>('Event_list.json', this.getUIContext(), this);
    this.calendarEventVM.setUserEvent(this.userEvent)
    this.calendarEventVM.setContext(this.context)
    this.themeVM.setTheme(this.selectColor, this.titleColor)
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
        baseActionSheet.close('CalendarReminder')
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
      Image($r('app.media.event_add')).width(40).height(40)
    }
    .onClick(() => {
      baseActionSheet.show({
        id: 'CalendarReminder',
        detents: ['98%', '100%'],
        showClose: false,
        backgroundColor: $r('sys.color.background_secondary'),
        customContent: () => {
          this.CalendarReminderAdd()
        },
        onClose: () => {
          this.calendarEventVM.clearDate()
        },
      }, this.getUIContext())
    })
  }

  build() {
    NavDestination() {
      CalendarNavTitle({
        title: '日程提醒',
        rightBuilder: () => {
          this.eventAdd()
        },
        isHideBack: this.isHideBack
      })
      CalendarEventDetails({
        eventList: this.eventList,
      })
    }
    .onReady((ctx) => {
      this.calendarEventVM.setPageInfo(ctx.pathStack)
    })
    .hideTitleBar(true)
  }
}
