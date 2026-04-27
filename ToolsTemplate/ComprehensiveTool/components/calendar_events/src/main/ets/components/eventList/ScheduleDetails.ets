import { CalendarSchedule } from '../CalendarSchedule'
import { CalendarNavTitle } from '../common/CalendarNavTitle'
import { CalendarEventFooter } from './CalendarEventFooter';
import { CalendarSheetHeader } from '../common/CalendarSheetHeader';
import { UserEventItem } from '../../model/UserEventModel';
import CalendarEventVM from '../../viewModel/ViewModel';
import { baseActionSheet } from '../../base/ActionSheet';

@Builder
export function ScheduleDetailsBuilder() {
  ScheduleDetails()
}

@ComponentV2
export struct ScheduleDetails {
  @Local calendarEventVM: CalendarEventVM = CalendarEventVM.instance;
  @Local scheduleInfo: UserEventItem = new UserEventItem()

  aboutToAppear(): void {
    this.scheduleInfo = this.calendarEventVM.getPageInfo()?.getParamByName('ScheduleDetails')[0] as UserEventItem
    this.calendarEventVM.setEventInfo(this.scheduleInfo)
  }

  @Builder
  sheetCustomBuilder() {
    CalendarSchedule({
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
        baseActionSheet.close('ScheduleDetails')
      },
      onConfirm: () => {
        this.calendarEventVM.updateUserEventInfo(this.getUIContext()).then(resp => {
          if (resp) {
            baseActionSheet.close('ScheduleDetails')
          }
        })
      },
    })
  }

  build() {
    NavDestination() {
      CalendarNavTitle({
        title: '日程详情',
      })
      Column() {
        Column() {
          CalendarSchedule({
            userEventInfo: this.scheduleInfo,
            readonly: true,
          })
        }
        .layoutWeight(1)
        .backgroundColor('#F1F3F5')
        .padding({ left: 16, right: 16 })

        CalendarEventFooter({
          onDelete: () => {
            this.calendarEventVM.deleteUserEventInfo(this.scheduleInfo, this.getUIContext(), () => {
              this.calendarEventVM.getPageInfo()?.pop()
            })
          },
          onEdit: () => {
            baseActionSheet.show({
              id: 'ScheduleDetails',
              detents:['98%','100%'],
              backgroundColor:$r('sys.color.background_secondary'),
              showClose: false,
              customContent: () => {
                this.CalendarScheduleEdit()
              },
              onWillAppear:() => {
                this.calendarEventVM.setEventInfo(this.scheduleInfo)
              }
            },this.getUIContext())
          },
        })
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.SpaceBetween)

    }
    .hideTitleBar(true)
  }
}