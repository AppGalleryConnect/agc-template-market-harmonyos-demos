import { DateUtils, FormatUtil, RouterMap, RouterModule } from '@ohos_agcit/office_attendance_common_lib';
import { TaskItem } from '../types/Types';

@ComponentV2
export struct AgencyTaskListItem {
  @Param item: TaskItem = {};
  @Param checkCallback: (check: boolean) => void = (check) => {
  };
  @Param editCallback: () => void = () => {
  };

  formatDate(): string {
    if (this.item.planTime) {
      return FormatUtil.formatDate(new Date(this.item.planTime), FormatUtil.DATE_YYYY_MM_DD_24H_mm);
    }
    return '';
  }

  build() {
    Column() {
      Row() {
        Column() {
          Checkbox({ name: 'checkBox', group: 'checkBoxGroup' })
            .select(this.item.isFinished)
            .width(20)
            .height(20)
            .borderRadius(4)
            .backgroundColor($r('app.color.white'))
            .border({ color: $r('app.color.black_1'), style: BorderStyle.Solid })
            .selectedColor($r('app.color.sys_default_blue'))
            .shape(CheckBoxShape.ROUNDED_SQUARE)
            .onChange((value: boolean) => {
              this.checkCallback(value);
            })
        }.width(20)
        Column().width('3%')
        Column() {
          Column() {
            Text(this.item.title)
              .fontSize(14)
              .width('100%')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .fontWeight(FontWeight.Medium)
              .opacity(this.item.isFinished ? 0.4 : 0.9)
          }.height(19)
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          .justifyContent(FlexAlign.Center)

          Row() {
            Text($r('app.string.deadTime'))
              .fontSize(12)
              .fontWeight(FontWeight.Regular)
              .opacity(this.item.isFinished ? 0.4 : 0.6)
            Text(this.formatDate())
              .fontSize(12)
              .fontWeight(FontWeight.Regular)
              .opacity(this.item.isFinished ? 0.4 : 0.6)
          }.height(16)
          .width('100%')
        }.alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Center)
        .layoutWeight(1)
        .height('100%')
      }
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Center)
      .width('100%')
      .height(56)
      .backgroundColor(Color.White)
      .onClick(() => {
        RouterModule.push({
          url: RouterMap.EDIT_AGENCY_TASK, param: this.item.taskID, onPop: () => {
            this.editCallback()
          }
        })
      })

      Divider().width('100%').height(1)
    }
  }
}