import { DoctorAppointmentModel } from '../model/AppointmentModels';
import { DoctorInfoView } from '../view/DoctorInfoView';
import { SearchBarView } from '../view/SearchBarView';
import { AppointmentViewModel } from '../viewmodel/AppointmentViewModel';
import { SkeletonTheme, UISkeleton } from 'common';

/**
 * 医生选择页面
 */
@ComponentV2
export struct DoctorSelectPage {
  @Local appointmentViewModel: AppointmentViewModel = AppointmentViewModel.getInstance()
  @Local searchText: string | undefined = undefined

  aboutToAppear(): void {
    this.appointmentViewModel.loadDoctorList()
  }

  build() {
    Column() {
      SearchBarView({
        onSearch: (text) => {
          this.searchText = text
        }
      })
        .padding({ left: 16, right: 16, bottom: 10 })
        .backgroundColor($r('sys.color.ohos_id_color_background'))

      if (this.appointmentViewModel.doctorList.length === 0) {
        Stack() {
          UISkeleton({
            theme: SkeletonTheme.PARAGRAPH, options: [
              1, 1, { width: '60%', margin: { bottom: 24 } },
              1, 1, { width: '60%', margin: { bottom: 24 } },
              1, 1, { width: '60%', margin: { bottom: 24 } }
            ]
          })
        }
        .width('100%')
        .height('100%')
        .padding(16)
      } else {
        List({ space: 10 }) {
          ForEach(this.appointmentViewModel.doctorList, (doctor: DoctorAppointmentModel, index) => {
            DoctorInfoView(
              {
                picUrl: doctor.picUrl,
                name: doctor.name,
                title: doctor.title,
                appointmentType: doctor.appointmentType,
                remainingAppointments: doctor.remainingAppointments,
                price: doctor.price,
                onAppointmentButtonClick: () => {
                  this.appointmentViewModel.selectDoctor(doctor)
                }
              }
            )
              .visibility(doctor.name.includes(this.searchText || '') ? Visibility.Visible : Visibility.None)
              .onClick(() => {
                this.appointmentViewModel.selectDoctor(doctor)
              })
          }, (doctor: DoctorAppointmentModel) => doctor.id)
        }
        .width('100%')
        .layoutWeight(1)
        .padding(16)
      }
    }
  }
}