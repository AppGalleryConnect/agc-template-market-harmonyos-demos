import { baseActionSheet } from 'base_apis';
import { RemindSheet } from './common/RemindSheet';
import { ReminderSheet, ReminderType, UserEventItem } from '../model/UserEventModel';

@ComponentV2
export struct CalendarReminder {
  @Param userEventInfo: UserEventItem = new UserEventItem()
  @Param readonly: boolean = false
  @Local reminder: string[] = []
  @Builder
  reminderBuilder() {
    RemindSheet({
      userEventInfo:this.userEventInfo
    })
  }

  build() {
    List() {
      ForEach(this.userEventInfo.remindList, (item: string, index: number) => {
        ListItem() {
          Row() {
            Text(!index ? '提醒' : `提醒${index}`).fontWeight(FontWeight.Medium)
            Row() {
              Text(item)
                .fontSize(14)
                .fontColor(this.readonly?$r('sys.color.font_secondary'):$r('sys.color.font_primary'))
              Image(this.readonly?$r('app.media.chevron_up_grey'):$r('app.media.chevron_up')).width(12).height(24)
            }
          }
          .onClick(() => {
            if (this.readonly) {
              return
            }
            baseActionSheet.show(this.getUIContext(),{
              id: 'CalendarEvent',
              title: {
                title: '提醒',
              },
              detents:[340,341],
              customContent: () => {
                this.reminderBuilder()
              },
            })
          })
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .padding({ top: 12, bottom: 12 })
        }
      }, (item: string) => item)
    }
    .edgeEffect(EdgeEffect.None)
    .scrollBar(BarState.Off)
  }
}