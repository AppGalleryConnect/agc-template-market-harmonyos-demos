import { CalendarNavTitle } from '../common/CalendarNavTitle'
import { CalendarEventFooter } from './CalendarEventFooter';
import { CalendarSheetHeader } from '../common/CalendarSheetHeader';
import { UserEvent, UserEventItem } from '../../model/UserEventModel';
import { PersistenceV2 } from '@kit.ArkUI';
import { CalendarBirRem } from '../CalendarBirRem';
import CalendarEventVM from '../../viewModel/ViewModel';
import { EVENT_TYPE } from '../../constants/Constants';
import { baseActionSheet } from '../../base/ActionSheet';

@Builder
export function BirthdayRememberDetailsBuilder() {
  BirthdayRememberDetails()
}

@ComponentV2
export struct BirthdayRememberDetails {
  @Local calendarEventVM: CalendarEventVM = CalendarEventVM.instance;
  @Local userEvent: UserEvent = PersistenceV2.connect(UserEvent, () => new UserEvent())!;
  @Local eventType: string = '';
  @Local userEventInfo: UserEventItem = new UserEventItem();

  aboutToAppear(): void {
    let pageInfo = this.calendarEventVM.getPageInfo() as NavPathStack
    let params =
      pageInfo.getParamByName('BirthdayRememberDetails')[0] as Record<string, UserEventItem | string>
    if (params) {
      this.userEventInfo = params.userEventInfo as UserEventItem
      this.eventType = params.eventType as string
      this.calendarEventVM.setEventInfo(this.userEventInfo)
    }
  }

  @Builder
  sheetCustomBuilder() {
    CalendarBirRem({
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
        baseActionSheet.close('BirthdayRememberDetails')
      },
      onConfirm: () => {
        this.calendarEventVM.updateUserEventInfo(this.getUIContext()).then(resp => {
          if (resp) {
            baseActionSheet.close('BirthdayRememberDetails')
          }
        })
      },
    })

  }

  build() {
    NavDestination() {
      CalendarNavTitle({
        title: this.eventType === EVENT_TYPE.BIRTHDAY ? '生日详情' : '纪念日详情',
      })
      Column() {
        Column() {
          CalendarBirRem({
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
              id: 'BirthdayRememberDetails',
              detents:['98%','100%'],
              backgroundColor:$r('sys.color.background_secondary'),
              showClose: false,
              onWillAppear: () => {
                this.calendarEventVM.setEventInfo(this.userEventInfo)
              },
              customContent: () => {
                this.CalendarScheduleEdit()
              },
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