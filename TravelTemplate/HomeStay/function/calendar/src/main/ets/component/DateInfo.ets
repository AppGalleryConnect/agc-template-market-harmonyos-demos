import { Constants } from 'constant';
import { DateModel, Price } from '../model/DateModel';
import { CustomCalendarPickerDialog } from '../pages/CustomCalendarPickerDialog';
import { CalenderUtil } from '../utils/CalenderUtil';

@Component
export struct DateInfo {
  @Prop startDate: DateModel | undefined;
  @Prop endDate: DateModel | undefined;
  @Prop night: number;
  @Prop isShowPrice: boolean;
  @Prop priceList: Price[] = [];
  @State readyCloseDialog: boolean = false;
  @State currentMonth: number | undefined = CalenderUtil.getCurrentDate()?.month;
  @State currentDay: number | undefined = CalenderUtil.getCurrentDate()?.day;
  @State currentYear: number | undefined = CalenderUtil.getCurrentDate()?.year;
  dialogController: CustomDialogController = new CustomDialogController({
    builder: CustomCalendarPickerDialog({
      currentMonth: this.currentMonth,
      currentDay: this.currentDay,
      currentYear: this.currentYear,
      startDate: this.startDate,
      endDate: this.endDate,
      night: this.night,
      cancel: this.onCancel,
      isShowPrice: this.isShowPrice,
      readyCloseDialog: this.readyCloseDialog,
      priceList: this.priceList,
    }),
    alignment: DialogAlignment.Bottom,
    customStyle: true,
    onWillDismiss: () => {
      this.readyCloseDialog = true;
      setTimeout(() => {
        this.readyCloseDialog = false;
      }, Constants.TRANSITION_DURATION);
    },
  });

  // 点击遮障层退出时的回调
  onCancel() {
  }

  build() {
    Row() {
      Column() {
        Text('入住日期')
          .fontColor(Color.Gray)
          .fontSize(12);
        Text(`${this.startDate?.month}月${this.startDate?.day}日`)
          .margin(6)
          .fontSize(18);
      };

      Column() {
        Button(`${this.night}晚`)
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
        Text(`${this.endDate?.month}月${this.endDate?.day}日`)
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