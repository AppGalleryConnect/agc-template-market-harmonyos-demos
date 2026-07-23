import { baseActionSheet } from 'base_apis';
import { CalendarNavTitle } from '../common/CalendarNavTitle'
import { CalendarEventFooter } from './CalendarEventFooter';
import { CalendarSheetHeader } from '../common/CalendarSheetHeader';
import { UserEventItem } from '../../model/UserEventModel';
import CalendarEventVM from '../../viewModel/ViewModel';
import { CalendarTodo } from '../CalendarTodo';
import { TABLET_GRID, TABLE_COL, TABLE_COL_OFFSET } from '../../constants/Constants';

@Builder
export function TodoDetailsBuilder() {
  TodoDetails()
}

@ComponentV2
export struct TodoDetails {
  @Local calendarEventVM: CalendarEventVM = CalendarEventVM.instance;
  @Local userEventInfo: UserEventItem = new UserEventItem();
  context: UIContext = this.getUIContext()

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
        baseActionSheet.close(this.context, 'TodoDetails')
      },
      onConfirm: () => {
        this.calendarEventVM.updateUserEventInfo().then(resp => {
          if (resp) {
            baseActionSheet.close(this.context, 'TodoDetails')
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
      GridRow(TABLET_GRID) {
        GridCol({
          span: TABLE_COL,
          offset: TABLE_COL_OFFSET,
        }) {
          Stack({ alignContent: Alignment.Bottom }) {
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
                this.calendarEventVM.deleteUserEventInfo(this.getUIContext(), this.userEventInfo, () => {
                  this.calendarEventVM.getPageInfo()?.pop()
                })
              },
              onEdit: () => {
                baseActionSheet.show(this.context, {
                  id: 'TodoDetails',
                  detents: ['98%', '100%'],
                  backgroundColor: $r('sys.color.background_secondary'),
                  showClose: false,
                  keyboardAvoidMode:SheetKeyboardAvoidMode.TRANSLATE_AND_SCROLL,
                  customContent: () => {
                    this.CalendarScheduleEdit()
                  },
                  onWillAppear: () => {
                    this.calendarEventVM.setEventInfo(this.userEventInfo)
                  },
                })
              },
            })
          }
        }
      }
      .layoutWeight(1)
    }
    .hideTitleBar(true)
    .backgroundColor('#F1F3F5')
  }
}