import { Constant } from 'module_base';
import { AddressInfo } from 'types';

@ComponentV2
export struct AddressCardComponent {
  @Param @Require address: AddressInfo
  @Event editAddress: (address: AddressInfo) => void;
  @Event deleteAddress: (address: AddressInfo) => void;

  build() {
    Column() {
      Column({ space: 4 }) {
        Row({ space: 12 }) {
          Text(this.address.name)
            .fontWeight(FontWeight.Medium)
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.font_primary'))
          Text(this.address.phone)
            .fontWeight(FontWeight.Medium)
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.font_primary'))
        }.width('100%').justifyContent(FlexAlign.Start)

        Text(`${this.address.district}${this.address.detail}`).width(Constant.FULL_PERCENT)
          .fontSize($r('sys.float.Body_M')).fontColor($r('sys.color.font_primary'))
      }

      Divider().color($r('sys.color.comp_divider')).margin({ top: 12, bottom: 12 })

      Row({ space: 24 }) {
        Row({ space: 8 }) {
          Toggle({ type: ToggleType.Switch, isOn: this.address.type === 1 })
            .selectedColor($r('sys.color.multi_color_04'))
            .switchPointColor($r('sys.color.comp_background_primary_contrary'))
          Text('默认地址').fontSize($r('sys.float.Body_M')).fontColor($r('sys.color.font_primary'))
        }

        Row({ space: 8 }) {
          Button('编辑', { controlSize: ControlSize.SMALL })
            .width(72)
            .fontColor($r('sys.color.multi_color_04'))
            .backgroundColor($r('sys.color.comp_background_tertiary'))
            .onClick((event: ClickEvent) => {
              this.editAddress(this.address)
            })
          Button('删除', { controlSize: ControlSize.SMALL })
            .width(72)
            .fontColor($r('sys.color.warning'))
            .backgroundColor($r('sys.color.comp_background_tertiary'))
            .onClick((event: ClickEvent) => {
              this.deleteAddress(this.address)
            })
        }
      }.width('100%').justifyContent(FlexAlign.SpaceBetween)
    }.padding(12).backgroundColor($r('sys.color.comp_background_primary')).borderRadius(16)
  }
}