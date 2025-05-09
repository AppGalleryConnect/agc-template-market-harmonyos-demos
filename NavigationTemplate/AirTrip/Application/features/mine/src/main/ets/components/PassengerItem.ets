import { CardMap, maskCertificate, maskPhone, PassengerInfo } from 'common'

@ComponentV2
export struct PassengerItem {
  @Param data: PassengerInfo = new PassengerInfo()
  @Param isNeedPadding: boolean = true
  @Event changePassenger: (data: PassengerInfo) => void = (data: PassengerInfo) => {
  }
  @Event edit: () => void = () => {
  }

  build() {
    Row({ space: 12 }) {
      Image($r('app.media.ic_edit')).width(26).height(26)
        .onClick(() => {
          this.edit && this.edit()
        })

      Row() {
        Column({ space: 6 }) {
          Text(this.data.name).fontWeight(FontWeight.Regular).fontSize(14)

          Row({ space: 4 }) {
            Text(CardMap[this.data.certificateType]).fontSize(12).fontColor('#99000000')
            Text(maskCertificate(this.data.certificateNo, this.data.certificateType))
              .fontSize(12)
              .fontColor('#99000000')
          }

          Row({ space: 4 }) {
            Text('手机号').fontSize(12).fontColor('#99000000')
            Text('+86-' + maskPhone(this.data.phone)).fontSize(12).fontColor('#99000000')
          }
        }
        .alignItems(HorizontalAlign.Start)

        if (this.data.isChecked) {
          Image($r('app.media.ic_checked')).width(26).height(26)
        } else {
          Image($r('app.media.icon_noselect')).width(26).height(26)
        }
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.SpaceBetween)
      .onClick(() => {
        this.data.isChecked = !this.data.isChecked
        this.changePassenger && this.changePassenger(this.data)
      })
    }
    .width('100%')
    .padding(this.isNeedPadding ? 14 : undefined)
    .backgroundColor($r('sys.color.white'))
    .borderRadius(16)
  }
}