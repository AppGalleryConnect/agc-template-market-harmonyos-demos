import { RouterMap, routerStack } from 'lib_foundation';
import { ContainerColumn } from 'lib_widget';

@Builder
export function buildNoOrderCard(canJump: boolean = false) {
  ContainerColumn() {
    Image($r('app.media.empty_status_logo'))
      .width(200)
      .height(200)
      .borderRadius(100)
      .draggable(false)
      .objectFit(ImageFit.Cover)
      .margin({ bottom: $r('app.float.space_l'), top: $r('app.float.space_l') })
    Text('还没有相关的订单哟')
      .fontSize($r('app.float.font_size_14'))
      .fontColor($r('app.color.font_color_level2'))
    if (canJump) {
      Text('快去商城选购心仪的商品吧~')
        .fontSize($r('app.float.font_size_14'))
        .fontColor($r('app.color.font_color_level2'))
        .margin({ bottom: $r('app.float.space_xl') })
      Button('去商城')
        .backgroundColor($r('app.color.theme_color'))
        .width($r('app.string.size_percent_half'))
        .onClick(() => {
          routerStack.pushPath({ name: RouterMap.PRODUCT_CATEGORY })
        })
    }
    Blank().height($r('app.float.space_l'))
  }
}