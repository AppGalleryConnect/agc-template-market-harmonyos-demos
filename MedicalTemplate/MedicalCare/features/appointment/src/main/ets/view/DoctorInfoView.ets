import { DoctorProfileView } from './DoctorProfileView'

@ComponentV2
@Preview
export struct DoctorInfoView {
  @Param @Once picUrl: string = ''
  @Param @Once name: string = ''
  @Param @Once title: string = ''
  @Param @Once appointmentType: string = ''
  @Param @Once remainingAppointments: number = 0
  @Param @Once price: number = 0
  @Param onAppointmentButtonClick: () => void = () => {
  }

  build() {
    Row({ space: 16 }) {
      DoctorProfileView({
        imageSize: 52,
        imageUrl: this.picUrl,
      })

      Column() {
        Row({ space: 6 }) {
          Text(this.name)
            .fontSize(14)
            .fontWeight(500)
            .fontColor($r('sys.color.ohos_id_color_text_primary'))

          Text(this.title)
            .fontSize(12)
            .fontColor($r('sys.color.ohos_id_color_text_secondary'))
            .layoutWeight(1)

          Text(`￥${this.price}`)
            .fontSize(14)
            .fontColor($r('sys.color.ohos_id_color_palette_aux8'))
        }
        .alignItems(VerticalAlign.Bottom)

        Text(this.appointmentType)
          .fontSize(12)
          .fontColor($r('sys.color.ohos_id_color_text_secondary'))

        Blank()
          .layoutWeight(1)

        Row() {
          Text(`剩余号源：${this.remainingAppointments}`)
            .fontSize(12)
            .fontColor($r('sys.color.ohos_id_color_text_secondary'))
            .layoutWeight(1)

          Button(this.remainingAppointments > 0 ? '挂号' : '已约满')
            .enabled(this.remainingAppointments > 0)
            .borderRadius(14)
            .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
            .fontSize(14)
            .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
            .height(28)
            .onClick(() => {
              this.onAppointmentButtonClick()
            })
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .alignItems(VerticalAlign.Top)
    .width('100%')
    .height(102)
    .borderRadius(8)
    .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
    .padding({
      top: 16,
      bottom: 16,
      left: 16,
      right: 16
    })
  }
}