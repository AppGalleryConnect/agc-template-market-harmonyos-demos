import { AddressInfo } from 'types'

@ComponentV2
export struct AddressCardComponent {
  @Param @Require address: AddressInfo
  @Event editAddress: (address: AddressInfo) => void;
  @Event deleteAddress: (address: AddressInfo) => void;

  build() {
    Column({ space: 4 }) {
      Row({ space: 8 }) {
        Text(`${this.address.name} ${this.address.phone}`)
          .fontWeight(500)
          .opacity(0.9)

        if (this.address.type === 1) {
          Text('默认')
            .fontSize(10)
            .padding(4)
            .border({ width: 1, color: '#64BB5C', radius: 4 })
            .fontColor('#64BB5C')
        }
      }.width('100%').justifyContent(FlexAlign.Start)

      Text(`${this.address.district}${this.address.detail}`)
        .fontSize(14)
        .opacity(0.6)
        .width('100%')
        .textAlign(TextAlign.Start)

      Row({ space: 24 }) {
        Image($r('app.media.edit')).size({ width: 24, height: 24 }).onClick(() => {
          this.editAddress(this.address)
        })
        Image($r('app.media.delete')).size({ width: 24, height: 24 }).onClick(() => {
          this.deleteAddress(this.address)
        })
      }.width('100%').justifyContent(FlexAlign.End)
    }.padding(12).backgroundColor(Color.White).borderRadius(8)
  }
}