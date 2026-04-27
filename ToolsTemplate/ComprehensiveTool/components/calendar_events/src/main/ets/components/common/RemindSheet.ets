import { baseActionSheet } from '../../base/ActionSheet'
import { REMIND_TYPE } from '../../constants/Constants'
import { ReminderSheet, ReminderType, UserEventItem } from '../../model/UserEventModel'

@ComponentV2
export struct RemindSheet {
  @Local reminderSheetList: ReminderSheet = new ReminderSheet()
  @Param userEventInfo: UserEventItem = new UserEventItem()

  resetReminderList() {
    this.restRemindList()
  }

  restRemindList() {
    this.reminderSheetList.reminderSheet.forEach(item => {
      if (this.userEventInfo.remindList.includes(item.name)) {
        item.isSelected = true
      }else {
        item.isSelected = false
      }
    })
  }

  aboutToAppear(): void {
    this.restRemindList()
  }

  build() {
    Column() {
      Row({ space: 5 }) {
        Text('提醒时间')
          .fontWeight(FontWeight.Medium)
        Text('可多选')
          .fontSize(12)
          .fontColor($r('sys.color.font_secondary'))
      }
      .margin({ top: 24, bottom: 14 })

      Grid() {
        ForEach(this.reminderSheetList.reminderSheet, (item: ReminderType, index: number) => {
          GridItem() {
            Column() {
              Text(item.name)
                .fontSize(14)
            }
            .onClick(() => {
              if (item.name === REMIND_TYPE.NOT_REMIND) {
                this.reminderSheetList.reminderSheet.forEach(value => {
                  value.isSelected = false
                })
              } else {
                this.reminderSheetList.reminderSheet[0].isSelected = false
              }
              item.isSelected = !item.isSelected
              if (this.reminderSheetList.reminderSheet.every(value => !value.isSelected)) {
                this.reminderSheetList.reminderSheet[0].isSelected = true
              }
            })
            .backgroundColor(item.isSelected ? '#EACACB' : '#E8E8E8')
            .width(104)
            .justifyContent(FlexAlign.Center)
            .height(28)
            .borderRadius(14)
          }
        }, (item: ReminderType) => item.name)
      }
      .columnsTemplate('1fr 1fr 1fr')
      .rowsGap(8)
      .columnsGap(8)
      .maxCount(3)

      Row({ space: 12 }) {
        Button('重置')
          .width('48%')
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Medium)
          .backgroundColor($r('sys.color.background_secondary'))
          .onClick(() => {
            this.resetReminderList()
          })
        Button('完成')
          .width('48%')
          .fontColor($r('sys.color.font_on_primary'))
          .fontWeight(FontWeight.Medium)
          .backgroundColor('#C4272B')
          .onClick(() => {
            this.userEventInfo.remindList = []
            this.reminderSheetList.reminderSheet.forEach(item => {
              if (item.isSelected) {
                this.userEventInfo.remindList.push(item.name)
              }
            })
            baseActionSheet.close('CalendarEvent')
          })
      }
      .margin({ top: 36 })
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding({ left: 16, right: 16 })
  }
}