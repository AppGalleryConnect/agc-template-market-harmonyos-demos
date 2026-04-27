import { AddressInfo } from 'lib_network';
import { OrderButtonStyleMap } from '../common/Enums';
import { MyButtonModifier } from '../common/Types';

@Builder
export function buildAddressInfo(address?: AddressInfo, showEdit: boolean = false, handleEdit?: () => void) {
  Row() {
    Image($r('app.media.position'))
      .width(24)
      .height(24)
      .margin({ right: $r('app.float.space_m') })
    Column({ space: 4 }) {
      Text(address?.address ?? '')
        .fontSize($r('app.float.font_size_14'))
        .fontColor($r('app.color.font_color_level1'))
        .fontWeight(FontWeight.Medium)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
      Text() {
        Span(address?.name ?? '')
        Span(' ').letterSpacing(8)
        Span(address?.cellphone ?? '')
      }
      .fontSize($r('app.float.font_size_12'))
      .fontColor($r('app.color.font_color_level3'))
    }
    .alignItems(HorizontalAlign.Start)
    .layoutWeight(1)
    .margin({ right: $r('app.float.space_m') })

    if (showEdit) {
      Button('修改')
        .attributeModifier(new MyButtonModifier(OrderButtonStyleMap.OTHERS, ControlSize.SMALL))
        .onClick(() => {
          handleEdit?.()
        })
    }
  }
  .width($r('app.string.size_percent_full'))
  .justifyContent(FlexAlign.Start)
}