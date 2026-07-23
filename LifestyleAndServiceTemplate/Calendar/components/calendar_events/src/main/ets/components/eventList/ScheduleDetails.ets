import { baseActionSheet } from 'base_apis';
import { CalendarSchedule } from '../CalendarSchedule'
import { CalendarNavTitle } from '../common/CalendarNavTitle'
import { CalendarEventFooter } from './CalendarEventFooter';
import { CalendarSheetHeader } from '../common/CalendarSheetHeader';
import { UserEventItem } from '../../model/UserEventModel';
import CalendarEventVM from '../../viewModel/ViewModel';
import { TABLET_GRID, TABLE_COL, TABLE_COL_OFFSET } from '../../constants/Constants';

@Builder
export function ScheduleDetailsBuilder() {
  ScheduleDetails()
}

@ComponentV2
export struct ScheduleDetails {
  @Local calendarEventVM: CalendarEventVM = CalendarEventVM.instance;
  @Local scheduleInfo: UserEventItem = new UserEventItem()
  context: UIContext = this.getUIContext()


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
        baseActionSheet.close(this.context, 'ScheduleDetails')
      },
      onConfirm: () => {
        this.calendarEventVM.updateUserEventInfo().then(resp => {
          if (resp) {
            baseActionSheet.close(this.context, 'ScheduleDetails')
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
      GridRow(TABLET_GRID) {
        GridCol({
          span: TABLE_COL,
          offset: TABLE_COL_OFFSET,
        }) {
          Column() {
            Column() {
              CalendarSchedule({
                userEventInfo: this.scheduleInfo,
                readonly: true,
              })
            }
            .height('calc(100% - 88vp)')
            .backgroundColor('#F1F3F5')
            .padding({ left: 16, right: 16 })

            Blank()
            CalendarEventFooter({
              onDelete: () => {
                this.calendarEventVM.deleteUserEventInfo(this.getUIContext(), this.scheduleInfo, () => {
                  this.calendarEventVM.getPageInfo()?.pop()
                })
              },
              onEdit: () => {
                baseActionSheet.show(this.context, {
                  id: 'ScheduleDetails',
                  detents: ['98%', '100%'],
                  backgroundColor: $r('sys.color.background_secondary'),
                  showClose: false,
                  keyboardAvoidMode:SheetKeyboardAvoidMode.TRANSLATE_AND_SCROLL,
                  customContent: () => {
                    this.CalendarScheduleEdit()
                  },
                  onWillAppear: () => {
                    this.calendarEventVM.setEventInfo(this.scheduleInfo)
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
    .onReady((ctx) => {
      this.calendarEventVM.pageInfo = ctx.pathStack
      this.scheduleInfo = ctx.pathStack?.getParamByName('ScheduleDetails')[0] as UserEventItem
      this.calendarEventVM.setEventInfo(this.scheduleInfo)
    })
    .backgroundColor('#F1F3F5')
    .hideTitleBar(true)
  }
}