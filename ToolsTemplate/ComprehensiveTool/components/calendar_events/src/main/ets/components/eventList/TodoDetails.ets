import { CalendarNavTitle } from '../common/CalendarNavTitle'
import { CalendarEventFooter } from './CalendarEventFooter';
import { CalendarSheetHeader } from '../common/CalendarSheetHeader';
import { UserEventItem } from '../../model/UserEventModel';
import CalendarEventVM from '../../viewModel/ViewModel';
import { CalendarTodo } from '../CalendarTodo';
import { baseActionSheet } from '../../base/ActionSheet';

@Builder
export function TodoDetailsBuilder() {
  TodoDetails()
}

@ComponentV2
export struct TodoDetails {
  @Local calendarEventVM: CalendarEventVM = CalendarEventVM.instance;
  @Local userEventInfo: UserEventItem = new UserEventItem();

  aboutToAppear(): void {
    this.userEventInfo = this.calendarEventVM.getPageInfo()?.getParamByName('TodoDetails')[0] as UserEventItem
    this.calendarEventVM.setEventInfo(this.userEventInfo)
  }

  @Builder
  sheetCustomBuilder() {
    CalendarTodo({
      userEventInfo: this.calendarEventVM.userEventInfo,
    })
  }

  @Builder
  CalendarScheduleEdit() {
    CalendarSheetHeader({
      title: '编辑',
      calendarEventBuilder: () => {
        this.sheetCustomBuilder()
      },
      onClose: () => {
        baseActionSheet.close('TodoDetails')
      },
      onConfirm: () => {
        this.calendarEventVM.updateUserEventInfo(this.getUIContext()).then(resp => {
          if (resp) {
            baseActionSheet.close('TodoDetails')
          }
        })
      },
    })
  }

  build() {
    NavDestination() {
      CalendarNavTitle({
        title: '待办详情',
      })
      Column() {
        Column() {
          CalendarTodo({
            userEventInfo: this.userEventInfo,
            readonly: true,
          })
        }
        .layoutWeight(1)
        .backgroundColor('#F1F3F5')
        .padding({ left: 16, right: 16 })

        CalendarEventFooter({
          onDelete: () => {
            this.calendarEventVM.deleteUserEventInfo(this.userEventInfo, this.getUIContext(), () => {
              this.calendarEventVM.getPageInfo()?.pop()
            })
          },
          onEdit: () => {
            baseActionSheet.show({
              id: 'TodoDetails',
              detents: ['98%', '100%'],
              backgroundColor: $r('sys.color.background_secondary'),
              showClose: false,
              customContent: () => {
                this.CalendarScheduleEdit()
              },
              onWillAppear: () => {
                this.calendarEventVM.setEventInfo(this.userEventInfo)
              },
            }, this.getUIContext())
          },
        })
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .hideTitleBar(true)
  }
}