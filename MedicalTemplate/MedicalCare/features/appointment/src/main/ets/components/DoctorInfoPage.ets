import { CollapsibleText, CommonNavDestination, SkeletonTheme, UISkeleton } from 'common'
import { DateSelectView } from '../view/DateSelectView'
import { DoctorProfileView } from '../view/DoctorProfileView'
import { TimeSlotView } from '../view/TimeSlotView'
import { AppointmentViewModel } from '../viewmodel/AppointmentViewModel'

/**
 * 医生主页
 */
@Builder
export function DoctorInfoPageBuilder() {
  CommonNavDestination({ title: '医生详情', enableScroll: true }) {
    DoctorInfoPage()
  }
}

@ComponentV2
export struct DoctorInfoPage {
  @Local appointmentViewModel: AppointmentViewModel = AppointmentViewModel.getInstance()
  @Provider() selectedDateIndex: number = 0

  aboutToAppear(): void {
    this.appointmentViewModel.loadDoctorSchedule()
  }

  build() {
    Column({ space: 10 }) {
      Stack({ alignContent: Alignment.Top }) {
        Column() {
          Text(this.appointmentViewModel.appointmentInfoModel.doctorInfo.name)
            .fontSize(18)
            .fontWeight(500)

          Text(this.appointmentViewModel.appointmentInfoModel.doctorInfo.title)
            .fontSize(12)
            .margin({ top: 4 })

          CollapsibleText({ longMessage: this.appointmentViewModel.appointmentInfoModel.doctorInfo.description })
            .margin({ top: 16 })
        }
        .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
        .borderRadius(8)
        .margin({ top: 29, left: 16, right: 16 })
        .padding({
          left: 16,
          right: 16,
          bottom: 16,
          top: 42
        })

        DoctorProfileView({
          imageSize: 58,
          imageUrl: this.appointmentViewModel.appointmentInfoModel.doctorInfo.picUrl,
        })
      }

      if (this.appointmentViewModel.doctorScheduleList.length > 0) {
        Column() {
          Text('预约挂号')
            .fontSize(14)
            .width('100%')
            .textAlign(TextAlign.Start)

          DateSelectView({
            dayOfWeekList: this.appointmentViewModel.doctorScheduleList.map(item => item.dayOfWeek),
            dateList: this.appointmentViewModel.doctorScheduleList.map(item => `${item.month}-${item.day}`)
          }).margin({
            top: 6,
            bottom: 18
          })

          TimeSlotView({
            timeSlots: this.appointmentViewModel.doctorScheduleList[this.selectedDateIndex].availableSlots.map(
              value => `${value.startTime}-${value.endTime}`
            ),
            isClickable: this.appointmentViewModel.doctorScheduleList[this.selectedDateIndex].availableSlots.map(
              value => value.remainingAppointments > 0
            ),
            onTimeSlotClick: (index: number, time: string) => {
              this.appointmentViewModel.selectDate(
                this.appointmentViewModel.doctorScheduleList[this.selectedDateIndex].year,
                this.appointmentViewModel.doctorScheduleList[this.selectedDateIndex].month,
                this.appointmentViewModel.doctorScheduleList[this.selectedDateIndex].day,
                time
              )
            }
          })
        }
        .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
        .padding(16)
      } else {
        Stack() {
          UISkeleton({ theme: SkeletonTheme.PARAGRAPH, options: [1, 1, 1, { width: '60%' }] })
        }
        .padding(16)
      }
    }
  }
}