import { common } from '@kit.AbilityKit';
import { Constants } from '../constant/Constants';
import { DateModel, Price } from '../model/DateModel';
import { CustomCalendarPickerDialog } from './CustomCalendarPickerDialog';
import { CalendarUtil } from '../utils/CalendarUtil';

@ComponentV2
export struct DateInfo {
  @Param @Require priceList: Price[] = [];
  @Local startMonth: number = CalendarUtil.getStartDate().month;
  @Local startDay: number = CalendarUtil.getStartDate().day;
  @Local endMonth: number = CalendarUtil.getEndDate().month;
  @Local endDay: number = CalendarUtil.getEndDate().day;
  dialogController: CustomDialogController = new CustomDialogController({
    builder: CustomCalendarPickerDialog({
      priceList: this.priceList,
    }),
    alignment: DialogAlignment.Bottom,
    customStyle: true,
    onWillDismiss: () => {
      this.dialogController.close();
    },
  });
  private context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;

  aboutToAppear(): void {
    this.context.eventHub.on('update_date', (startDate: DateModel, endDate: DateModel) => {
      this.startMonth = startDate.month;
      this.startDay = startDate.day;
      this.endMonth = endDate.month;
      this.endDay = endDate.day;
    });
  }

  build() {
    Row() {
      Column() {
        Text('入住日期')
          .fontColor(Color.Gray)
          .fontSize(12);
        Text(`${this.startMonth}月${this.startDay}日`)
          .margin(6)
          .fontSize(18);
      };

      Column() {
        Button(`${CalendarUtil.getNight()}晚`)
          .height(24)
          .fontSize(12)
          .backgroundColor(Color.White)
          .border({ radius: 10, width: 1 })
          .fontColor(Color.Black)
          .padding({
            left: 12,
            right: 12,
            top: 4,
            bottom: 4,
          });
      }.justifyContent(FlexAlign.Center);

      Column() {
        Text('离店日期')
          .fontColor(Color.Gray)
          .fontSize(12);
        Text(`${this.endMonth}月${this.endDay}日`)
          .margin(6)
          .fontSize(18);
      };
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .padding(16)
    .alignItems(VerticalAlign.Center)
    .width(Constants.FULL_SCREEN)
    .onClick(() => {
      this.dialogController.open();
    });
  }
}