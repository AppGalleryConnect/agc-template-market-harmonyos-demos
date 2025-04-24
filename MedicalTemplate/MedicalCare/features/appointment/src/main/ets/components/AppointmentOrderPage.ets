import { CommonNavDestination, RouterUtil } from 'common'
import { OrderState } from '../constant/Constant'
import { AppointmentViewModel } from '../viewmodel/AppointmentViewModel'

/**
 * 挂号订单信息支付、信息展示页面
 */
@Builder
export function AppointmentOrderPageBuilder() {
  CommonNavDestination({
    title: '挂号详情',
    contentPadding: {},
    onBack: () => {
      RouterUtil.backTo('AppointmentEntryPage')
      RouterUtil.back()
      return true
    },
    enableScroll: true
  }) {
    AppointmentOrderPage()
  }
}

@ComponentV2
export struct AppointmentOrderPage {
  @Local appointmentViewModel: AppointmentViewModel = AppointmentViewModel.getInstance()

  aboutToAppear(): void {
    this.appointmentViewModel.initOrderData()
  }

  build() {
    Column() {
      Row({ space: 12 }) {
        if (this.appointmentViewModel.appointmentInfoModel.orderState === OrderState.ORDER_STATE_SUCCESS) {
          Image($r('app.media.ic_pay_success'))
            .width(25)
            .height(25)
        } else if (this.appointmentViewModel.appointmentInfoModel.orderState === OrderState.ORDER_STATE_NEED_PAYMENT) {
          LoadingProgress().color($r('sys.color.ohos_id_color_foreground')).width(25).height(25)
        } else {
          Image($r('app.media.ic_xmark'))
            .width(25)
            .height(25)
        }

        Text(this.appointmentViewModel.appointmentInfoModel.paymentMessage)
          .fontSize(16)
          .fontColor($r('sys.color.ohos_id_color_text_primary'))
      }
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Center)
      .align(Alignment.Center)
      .width('100%')
      .margin({
        top: 14,
        bottom: 30
      })

      Column() {
        Text(this.appointmentViewModel.appointmentInfoModel.departmentInfo.name)
          .fontSize(12)
          .margin({ top: 8 })
        Text(this.appointmentViewModel.getDoctorNameAndTitleString())
          .fontSize(16)
          .margin({ top: 10 })
        Text(`就诊地址：${this.appointmentViewModel.appointmentInfoModel.hospitalInfo.name} ${this.appointmentViewModel.appointmentInfoModel.hospitalInfo.address}`)
          .fontSize(12)
          .fontColor($r('sys.color.ohos_id_color_text_tertiary'))
          .margin({ top: 8 })
        Text(`${this.appointmentViewModel.appointmentInfoModel.datetime}`)
          .fontSize(18)
          .borderRadius(8)
          .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
          .margin({ top: 16 })
          .padding({
            top: 10,
            bottom: 10,
            left: 20,
            right: 20
          })
        Divider()
          .strokeWidth(0.5)
          .color($r('sys.color.ohos_id_color_list_separator'))
          .margin({ top: 21, bottom: 16 })
        Text(`就诊人：${this.appointmentViewModel.appointmentInfoModel.patientInfo.patientName}`)
          .patientInfoTextStyle()
        Text(`证件号码：${this.appointmentViewModel.appointmentInfoModel.patientInfo.idCard}`)
          .patientInfoTextStyle()
        Text(`医保类型：${this.appointmentViewModel.appointmentInfoModel.patientInfo.insuranceType}`)
          .patientInfoTextStyle()

      }
      .borderRadius(8)
      .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
      .padding({
        top: 14, bottom: 14
      })

      Button('支付')
        .onClick(() => {
          this.appointmentViewModel.requestPayment()
        })
        .visibility(this.appointmentViewModel.shouldShowPaymentButton() ? Visibility.Visible : Visibility.None)
        .margin({ top: 32 })
        .width('80%')
    }
    .padding({
      left: 16,
      right: 16,
      top: 16,
      bottom: 16
    })
  }
}


@Extend(Text)
function patientInfoTextStyle() {
  .fontSize(12)
  .fontColor($r('sys.color.ohos_id_color_text_tertiary'))
  .width('100%')
  .textAlign(TextAlign.Start)
  .margin({ top: 10 })
  .padding({
    left: 16,
  })
}