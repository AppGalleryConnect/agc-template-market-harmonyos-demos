import { CommonEmptyView, CommonNavDestination, ConfirmDialogUtil, LogUtil, SkeletonTheme, UISkeleton } from 'common'
import { OrderState } from '../constant/Constant'
import { AppointmentInfoModel } from '../model/AppointmentModels'
import { AppointmentViewModel } from '../viewmodel/AppointmentViewModel'

@Builder
export function AppointmentOrderListPageBuilder() {
  CommonNavDestination({ title: '挂号记录', contentPadding: { top: 16 } }) {
    AppointmentOrderListPage()
  }
}

@ComponentV2
export struct AppointmentOrderListPage {
  @Local viewModel: AppointmentViewModel = AppointmentViewModel.getInstance(true)

  async aboutToAppear() {
    await this.viewModel.loadDefaultAppointmentOrderList()
  }

  build() {
    Column({ space: 16 }) {
      Row() {
        Text(`当前就诊人：${this.viewModel.appointmentInfoModel.patientInfo.patientName || '正在加载'}`)
          .fontSize(14)
          .textAlign(TextAlign.Start)
          .layoutWeight(1)
          .onAppear(() => {

          })
        Row({ space: 6 }) {
          Text('切换就诊人')
            .fontSize(14)
          Image($r('sys.media.ohos_ic_public_arrow_down'))
            .width(12)
            .height(12)
        }
        .borderRadius(20)
        .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
        .padding({
          top: 5,
          bottom: 5,
          left: 8,
          right: 8
        })
        .bindMenu(this.viewModel.patientList.map((value, index) => {
          return {
            value: value.patientName,
            action: () => {
              LogUtil.info(`patient index: ${index}`)
              this.viewModel.appointmentInfoModel.patientInfo = value
              this.viewModel.loadAppointmentOrderList(value.cardId)
            }
          } as MenuElement
        }))
      }
      .padding({
        left: 16, right: 16
      })

      if (this.viewModel.isAppointmentOrderListLoading) {
        Stack() {
          UISkeleton({
            loading: this.viewModel.isLoading,
            theme: SkeletonTheme.PARAGRAPH,
            options: [
              1,
              1,
              1,
              { margin: { bottom: 16 } },
              1,
              1,
              1,
              { margin: { bottom: 16 } }
            ]
          })
        }
        .width('100%')
        .layoutWeight(1)
        .padding({
          left: 16,
          right: 16
        })
      } else {
        List({ space: 16 }) {
          if (this.viewModel.appointmentOrderList.length === 0) {
            CommonEmptyView()
          }
          ForEach(this.viewModel.appointmentOrderList, (item: AppointmentInfoModel, index) => {
            ListItem() {
              Column({ space: 10 }) {
                Row() {
                  Text(item.departmentInfo.name)
                    .fontSize(16)
                    .layoutWeight(1)
                    .textAlign(TextAlign.Start)

                  Text(OrderState.getOrderStateString(item.orderState))
                    .fontSize(12)
                    .backgroundColor(item.orderState === OrderState.ORDER_STATE_SUCCESS ?
                    $r('sys.color.ohos_id_color_palette4') : $r('sys.color.ohos_id_color_sub_background'))
                    .fontColor(item.orderState === OrderState.ORDER_STATE_SUCCESS ?
                    $r('sys.color.ohos_id_color_text_primary_contrary') :
                    $r('sys.color.ohos_id_color_text_primary'))
                    .borderRadius(4)
                    .padding({
                      top: 2,
                      bottom: 2,
                      left: 4,
                      right: 4
                    })
                }

                Divider()
                  .strokeWidth(0.5)
                  .color($r('sys.color.ohos_id_color_list_separator'))
                  .margin({ top: 3 })

                Text(`预约医生：${item.doctorInfo.name}`)
                  .infoTextStyle()

                Text(`就诊日期：${item.datetime}`)
                  .infoTextStyle()

                Text(`订单日期：${item.datetime}`)
                  .infoTextStyle()

                Row({ space: 16 }) {
                  Blank()
                    .layoutWeight(1)

                  Button('查看详情')
                    .customButtonStyle()
                    .onClick(() => {
                      this.viewModel.toOrderDetail(index)
                    })

                  Button('取消预约')
                    .customButtonStyle()
                    .enabled(this.viewModel.shouldAllowCancelAppointment(item.orderState))
                    .onClick(() => {
                      ConfirmDialogUtil.showConfirmDialog(
                        {
                          title: '确认取消预约',
                          onConfirm: () => {
                            this.viewModel.cancelOrder(index, item.orderId)
                          }
                        }
                      )
                    })
                }
                .margin({
                  top: 6
                })
              }
              .padding(16)
              .borderRadius(8)
              .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
            }
          }, (item: object) => JSON.stringify(item))
        }
        .layoutWeight(1)
        .padding({
          left: 16,
          right: 16,
          bottom: 16
        })
      }

    }
  }
}

@Extend(Text)
function infoTextStyle() {
  .fontSize(12)
  .width('100%')
  .textAlign(TextAlign.Start)
}

@Extend(Button)
function customButtonStyle() {
  .width(90)
  .height(28)
  .borderRadius(14)
  .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
  .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
  .fontSize(14)
}