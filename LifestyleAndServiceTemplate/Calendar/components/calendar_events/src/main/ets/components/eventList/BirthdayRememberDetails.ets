import { baseActionSheet } from 'base_apis';
import { CalendarNavTitle } from '../common/CalendarNavTitle'
import { CalendarEventFooter } from './CalendarEventFooter';
import { CalendarSheetHeader } from '../common/CalendarSheetHeader';
import { UserEventItem } from '../../model/UserEventModel';
import { CalendarBirRem } from '../CalendarBirRem';
import CalendarEventVM from '../../viewModel/ViewModel';
import { EVENT_TYPE, TABLET_GRID, TABLE_COL, TABLE_COL_OFFSET } from '../../constants/Constants';

@Builder
export function BirthdayRememberDetailsBuilder() {
  BirthdayRememberDetails()
}

@ComponentV2
export struct BirthdayRememberDetails {
  @Local calendarEventVM: CalendarEventVM = CalendarEventVM.instance;
  @Local eventType: string = '';
  @Local userEventInfo: UserEventItem = new UserEventItem();
  context: UIContext = this.getUIContext()

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
        baseActionSheet.close(this.context, 'BirthdayRememberDetails')
      },
      onConfirm: () => {
        this.calendarEventVM.updateUserEventInfo().then(resp => {
          if (resp) {
            baseActionSheet.close(this.context, 'BirthdayRememberDetails')
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
      GridRow(TABLET_GRID) {
        GridCol({
          span: TABLE_COL,
          offset: TABLE_COL_OFFSET,
        }) {
          Column() {
            Column() {
              CalendarBirRem({
                userEventInfo: this.userEventInfo,
                readonly: true,
              })
            }
            .height('calc(100% - 88vp)')
            .backgroundColor('#F1F3F5')
            .padding({ left: 16, right: 16 })

            Blank()
            CalendarEventFooter({
              onDelete: () => {
                this.calendarEventVM.deleteUserEventInfo(this.getUIContext(), this.userEventInfo, () => {
                  this.calendarEventVM.getPageInfo()?.pop()
                })
              },
              onEdit: () => {
                baseActionSheet.show(this.context, {
                  id: 'BirthdayRememberDetails',
                  detents: ['98%', '100%'],
                  backgroundColor: $r('sys.color.background_secondary'),
                  showClose: false,
                  keyboardAvoidMode: SheetKeyboardAvoidMode.TRANSLATE_AND_SCROLL,
                  onWillAppear: () => {
                    this.calendarEventVM.setEventInfo(this.userEventInfo)
                  },
                  customContent: () => {
                    this.CalendarScheduleEdit()
                  },
                })
              },
            })
          }
          .height('100%')
        }
      }
      .layoutWeight(1)
    }
    .hideTitleBar(true)
    .backgroundColor('#F1F3F5')
  }
}