import dayjs from 'dayjs'
import { UserEventItem } from '../../model/UserEventModel'
import CalendarEventVM from '../../viewModel/ViewModel';

@ComponentV2
export struct TodoListBox {
  @Local calendarEventVM: CalendarEventVM = CalendarEventVM.instance;
  @Param isBoxDone:boolean = false
  @Param @Require todoInfo:UserEventItem
  @Event onChange:() => void = () => {}

  build() {
    Row({ space: 18 }) {
      Checkbox({ name: this.todoInfo.id, group: 'checkboxGroup'+ this.todoInfo.id})
        .select(this.isBoxDone)
        .selectedColor($r('sys.color.comp_background_emphasize'))
        .shape(CheckBoxShape.ROUNDED_SQUARE)
        .onClick(() => {
          this.onChange()
        })
      Column({ space: 5 }) {
        Text(this.todoInfo.content)
          .fontWeight(FontWeight.Medium)
          .fontSize(14)
          .fontColor(this.isBoxDone ? '#969696' : $r('sys.color.font_primary'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Text(this.todoInfo.date[0].isLunar ? this.todoInfo.date[0].lunarDate :
          dayjs(this.todoInfo.date[0].date).format('YYYY年MM月DD日') + '  ' + this.todoInfo.date[0].time)
          .fontSize(12)
          .fontColor(this.todoInfo.isDone ? '#969696' : $r('sys.color.font_secondary'))
      }
      .width('80%')
      .alignItems(HorizontalAlign.Start)
    }
    .onClick(() => {
      this.calendarEventVM.getPageInfo()?.pushPathByName('TodoDetails', this.todoInfo)
    })
    .width('100%')
    .padding(14)
    .borderRadius(16)
    .backgroundColor('#FAFAFA')
  }
}