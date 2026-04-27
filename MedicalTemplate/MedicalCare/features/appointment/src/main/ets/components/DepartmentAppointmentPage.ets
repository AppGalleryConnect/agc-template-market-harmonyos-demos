import { CommonEmptyView, CommonNavDestination } from 'common';
import { DoctorAppointmentModel } from '../model/AppointmentModels';
import { DateSelectView } from '../view/DateSelectView';
import { DoctorInfoView } from '../view/DoctorInfoView';
import { TimeSlotView } from '../view/TimeSlotView';
import { AppointmentViewModel } from '../viewmodel/AppointmentViewModel';

/**
 * 科室挂号排班信息页面
 */
@Builder
export function DepartmentAppointmentPageBuilder() {
  CommonNavDestination({ title: AppointmentViewModel.getInstance().appointmentInfoModel.departmentInfo.name }) {
    DepartmentAppointmentPage()
  }
}

@ComponentV2
export struct DepartmentAppointmentPage {
  @Provider() selectedDateIndex: number = 0
  @Local appointmentViewModel: AppointmentViewModel = AppointmentViewModel.getInstance()
  @Local isShowSheet: boolean = false

  aboutToAppear(): void {
    this.appointmentViewModel.loadDepartmentSchedule()
  }

  build() {
    if (this.appointmentViewModel.departmentScheduleList.length > 0) {
      Column({ space: 6 }) {
        Text('日期选择')
          .fontSize(14)
          .width('100%')
          .textAlign(TextAlign.Start)
          .padding({
            left: 16,
            right: 16
          })

        DateSelectView({
          dayOfWeekList: this.appointmentViewModel.departmentScheduleList.map(value => value.dayOfWeek),
          dateList: this.appointmentViewModel.departmentScheduleList.map(value => `${value.month}-${value.day}`)
        })
          .padding({
            left: 16,
            right: 16
          })

        if (this.appointmentViewModel.departmentScheduleList[this.selectedDateIndex].doctors?.length > 0) {
          List({ space: 10 }) {
            ForEach(this.appointmentViewModel.departmentScheduleList[this.selectedDateIndex].doctors,
              (item: DoctorAppointmentModel) => {
                DoctorInfoView(
                  {
                    picUrl: item.picUrl,
                    name: item.name,
                    title: item.title,
                    appointmentType: item.appointmentType,
                    remainingAppointments: item.remainingAppointments,
                    price: item.price,
                    onAppointmentButtonClick: () => {
                      this.appointmentViewModel.setSelectedDoctor(item)
                      this.isShowSheet = true
                    },
                  }
                )
                  .onClick(() => {
                    this.appointmentViewModel.selectDoctor(item)
                  })
              }, (item: DoctorAppointmentModel) => item.id)
          }
          .width('100%')
          .layoutWeight(1)
          .padding({ top: 6, left: 16, right: 16 })
        } else {
          CommonEmptyView('暂无医生信息')
        }
      }
      .width('100%')
      .height('100%')
      .bindSheet(this.isShowSheet, this.sheetBuilder(),
        {
          detents: [SheetSize.MEDIUM, SheetSize.LARGE],
          blurStyle: BlurStyle.Thick,
          showClose: true,
          onWillDisappear: () => {
            this.isShowSheet = false
          }
        }
      )
    }
  }

  @Builder
  sheetBuilder() {
    Column() {
      Text('挂号')
        .fontSize(20)
        .fontWeight(700)
        .padding({
          top: 15,
          bottom: 15,
          left: 16,
          right: 16
        })
        .width('100%')

      TimeSlotView({
        timeSlots: this.appointmentViewModel.appointmentInfoModel.doctorInfo.availableSlots
          .map(value => `${value.startTime}-${value.endTime}`),
        isClickable: this.appointmentViewModel.appointmentInfoModel.doctorInfo.availableSlots
          .map(value => value.remainingAppointments > 0),
        onTimeSlotClick: (_index, time) => {
          this.isShowSheet = false
          this.appointmentViewModel.selectDate(
            this.appointmentViewModel.departmentScheduleList[this.selectedDateIndex].year,
            this.appointmentViewModel.departmentScheduleList[this.selectedDateIndex].month,
            this.appointmentViewModel.departmentScheduleList[this.selectedDateIndex].day,
            time
          )
        }
      }).padding(16)
    }
  }
}