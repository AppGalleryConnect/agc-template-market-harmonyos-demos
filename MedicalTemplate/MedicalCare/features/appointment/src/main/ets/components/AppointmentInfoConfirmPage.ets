import { CommonNavDestination, RadioSheetBuilder } from 'common';
import { DoctorProfileView } from '../view/DoctorProfileView';
import { AppointmentViewModel } from '../viewmodel/AppointmentViewModel';

/**
 * 挂号信息确认页面
 */
@Builder
export function AppointmentInfoConfirmPageBuilder(name: string, param: Object) {
  CommonNavDestination({ title: '挂号', enableScroll: true }) {
    AppointmentInfoConfirmPage()
  }
}

interface InfoTextBuilderParam {
  title: string,
  content: string,
  showArrow?: boolean,
  onClick?: () => void
}

@ComponentV2
export struct AppointmentInfoConfirmPage {
  @Local appointmentViewModel: AppointmentViewModel = AppointmentViewModel.getInstance()
  @Local showSelectPatientSheet: boolean = false

  aboutToAppear(): void {
    this.appointmentViewModel.loadPatientInfo()
  }

  build() {
    Column({ space: 8 }) {
      Column() {
        // Doctor Card
        Row({ space: 8 }) {
          DoctorProfileView({
            imageSize: 50,
            imageUrl: this.appointmentViewModel.appointmentInfoModel.doctorInfo.picUrl
          })

          Column({ space: 6 }) {
            Text(this.appointmentViewModel.getDoctorNameAndTitleString())
              .fontSize(16)
              .fontWeight(500)
              .textAlign(TextAlign.Start)
              .width('100%')
            Text(`${this.appointmentViewModel.appointmentInfoModel.hospitalInfo.name} ${this.appointmentViewModel.appointmentInfoModel.departmentInfo.name}`)
              .fontSize(12)
              .textAlign(TextAlign.Start)
              .width('100%')
          }
          .layoutWeight(1)
        }
        .width('100%')
        .padding(14)
        .borderRadius(16)
        .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
        .margin({ bottom: 14 })

        this.infoTextBuilder({
          title: '就诊科室',
          content: this.appointmentViewModel.appointmentInfoModel.departmentInfo.name
        })
        this.infoTextBuilder({
          title: '费用合计',
          content: `￥${this.appointmentViewModel.appointmentInfoModel.doctorInfo.price.toString()}`
        })
        this.infoTextBuilder({
          title: '就诊时间',
          content: this.appointmentViewModel.appointmentInfoModel.datetime
        })
      }
      .padding({
        top: 20,
        left: 20,
        right: 20
      })
      .backgroundColor($r('sys.color.ohos_id_color_background'))

      Column() {
        this.infoTextBuilder({
          title: '就诊人',
          content: this.appointmentViewModel.appointmentInfoModel.patientInfo.patientName || '请选择',
          showArrow: true,
          onClick: () => {
            if (this.appointmentViewModel.patientList.length > 0) {
              this.showSelectPatientSheet = true
            } else {
              this.appointmentViewModel.loadPatientInfo()
            }
          }
        })

        this.infoTextBuilder({
          title: '医保类型', content:
          this.appointmentViewModel.appointmentInfoModel.patientInfo.insuranceType || '请选择'
        })
        this.infoTextBuilder({
          title: '身份证号',
          content: this.appointmentViewModel.appointmentInfoModel.patientInfo.idCard || '请选择'
        })
      }
      .padding({
        left: 20,
        right: 20
      })
      .backgroundColor($r('sys.color.ohos_id_color_background'))

      Stack() {
        Button('确认挂号')
          .width('100%')
          .onClick(() => {
            this.appointmentViewModel.createAppointmentOrder()
          })
      }
      .margin({
        top: 128,
        left: 20,
        right: 20
      })
    }
    .bindSheet(this.showSelectPatientSheet, RadioSheetBuilder({
      title: '就诊人',
      dataArray: this.appointmentViewModel.patientList.map(item => item.patientName),
      checkedItem: this.appointmentViewModel.appointmentInfoModel.patientInfo.patientName,
      dataChangeListener: (index) => {
        this.appointmentViewModel.setSelectedPatient(index)
        this.showSelectPatientSheet = false
      },
      hasMultiHeight: false
    }), {
      height: this.appointmentViewModel.patientList.length < 6 ? SheetSize.MEDIUM : 740,
      blurStyle: BlurStyle.Thick,
      showClose: true,
      onWillDisappear: () => {
        this.showSelectPatientSheet = false
      }
    })
  }

  @Builder
  infoTextBuilder(param: InfoTextBuilderParam) {
    Row() {
      Text(param.title)
        .fontSize(16)
        .fontWeight(500)
        .layoutWeight(1)
      Text(param.content)
        .fontSize(16)
        .textAlign(TextAlign.End)

      if (param.showArrow) {
        Image($r('sys.media.ohos_ic_public_arrow_right'))
          .width(12)
          .height(24)
          .fillColor($r('sys.color.ohos_id_color_fourth'))
          .margin({
            left: 6
          })
      }
    }
    .padding({
      top: 20,
      bottom: 20
    })
    .onClick(() => {
      param.onClick?.()
    })
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

    }
  }
}