
import { DateModel, getDate, TIME_NAME, TimeModel, timeOfDay } from '../mode/AppointmentModel';
import { AppointmentVM } from '../mode/AppointmentVM';
import { LocationVM, ShopCardModel } from '@ohos_agcit/car_beauty_care_shop';
import { CommonConstants } from '@ohos_agcit/car_beauty_care_commonlib';

@ComponentV2
export struct AppointmentTimePicker {
  locationVM: LocationVM = LocationVM.instance;
  @Param card:ShopCardModel = this.locationVM.shopCardList[0]
  @Local dateList: DateModel[] = [];
  @Local timeList: TimeModel[] = [];
  selectedDate:DateModel = this.dateList[0];
  selectedTime:TimeModel = this.timeList[0];
  appointmentVM: AppointmentVM = AppointmentVM.instance;

  aboutToAppear(): void {
    this.initDateList();
    this.initTimeList()
  }

  initDateList() {
    for(let i = 0; i < 6; i ++) {
      this.dateList.push(getDate(i));
    }
    this.selectedDate = this.dateList.filter((item:DateModel) => item.checked === true)[0]
  }

  initTimeList() {
    this.timeList = [];
    const isToday:boolean = this.selectedDate.label === TIME_NAME.TODAY;
    let time = new Date().getHours();
    timeOfDay.forEach((item:TimeModel) => {
      item.disabled = false;
      if (isToday && item.time <= time) {
        item.disabled = true;
      }
      item.checked = false;
      this.timeList.push(item);
    })
    this.timeList = [...this.timeList]
  }



  setDate(dt:DateModel) {
    this.dateList.forEach((item:DateModel) => {
      item.checked = false;
    })
    dt.checked = true;
    this.selectedDate = dt;
    this.dateList = [...this.dateList]
    this.initTimeList()
    this.appointmentVM.setShowSubmitBtn(false)
  }

  timeChange(selectTime:TimeModel) {
    if (selectTime.disabled === false) {
      this.timeList.forEach((item:TimeModel) => {
        item.checked = false;
      })
      selectTime.checked = true;
      this.selectedTime = selectTime;
      this.timeList = [...this.timeList];
      this.appointmentVM.updateSelectedData(this.selectedDate, this.selectedTime, this.card);
      this.appointmentVM.setShowSubmitBtn(selectTime.checked)
    }
  }

  build() {
    Column() {
      Row() {
        ForEach(this.dateList, (item:DateModel) =>{
            Column() {
              Text(item.label)
                .fontSize(12)
                .fontColor(item.checked?$r('app.color.lightRed'):'rgba(0,0,0,0.9)')
              Text(item.date)
                .fontSize(12)
                .fontColor(item.checked?$r('app.color.lightRed'):'rgba(0,0,0,0.4)')
            }
            .onClick(() => {
              this.setDate(item)
            })
        },(item:DateModel) => JSON.stringify(item))

      }
      .width(CommonConstants.FULL_WIDTH)
      .margin({
        top:16
      })
      .justifyContent(FlexAlign.SpaceAround)

      Flex({wrap:FlexWrap.Wrap}) {
        ForEach(this.timeList, (item:TimeModel) => {
          Row() {
            Text(item.label)
              .fontSize(12)
              .fontColor(item.checked?$r('app.color.lightRed'):item.disabled?'rgba(0,0,0,0.4)':'rgba(0,0,0,0.9)')
              .padding(4)
              .backgroundColor(item.disabled?'rgba(0,0,0,0.05)':Color.White)
              .borderRadius(4)
              .layoutWeight(1)
              .margin({
                right:6,
                left:6,
                top:12
              })
              .textAlign(TextAlign.Center)
              .height(24)
              .border({
                width:1,
                color: item.checked?$r('app.color.lightRed'):'rgba(0,0,0,0.05)'
              })
              .onClick(() => {
                this.timeChange(item)
              })
          }
          .width('25%')
        })
      }
      .width(CommonConstants.FULL_WIDTH)

      Divider()
        .color('rgba(0,0,0,0.2)')
        .margin({ top: 16,left:6,right:6})
    }
  }
}