import { RouterModule, RouterMap } from 'commonlib';
import { HomePageVM } from '../viewModels/HomePageVM';

@ComponentV2
export struct OrderBar {
  vm: HomePageVM = HomePageVM.instance;

  build() {
    Flex({ justifyContent: FlexAlign.SpaceBetween, space: {} }) {
      Row() {
        Column() {
          Text('参观预约').margin({ bottom: 8 }).fontColor($r('app.color.font_color_green'));
          Column() {
            Image($r('app.media.icon_public_arrow_right')).width(10);
          }
          .width(24)
          .height(24)
          .borderRadius(12)
          .backgroundColor($r('sys.color.ohos_id_color_palette_aux3'))
          .justifyContent(FlexAlign.Center);
        }.width('55%');

        Image($r('app.media.icon_order_bar1')).width(60).margin({ top: 14 });
      }
      .onClick(() => {
        RouterModule.push({ url: RouterMap.ORDER_TICKET });
      })
      .height(100)
      .backgroundColor($r('sys.color.ohos_id_color_background'))
      .borderRadius(8)
      .flexGrow(1)
      .margin({ right: 10 });

      Row() {
        Column() {
          Text('特展购票').margin({ bottom: 8 }).fontColor($r('app.color.font_color_green'));
          Column() {
            Image($r('app.media.icon_public_arrow_right')).width(10);
          }
          .width(24)
          .height(24)
          .borderRadius(12)
          .backgroundColor($r('sys.color.ohos_id_color_palette_aux3'))
          .justifyContent(FlexAlign.Center);
        }.width('55%');

        Image($r('app.media.icon_order_bar2')).width(60).margin({ top: 14 });
      }
      .onClick(() => {
        RouterModule.push({ url: RouterMap.PERFORMANCE_PAGE });
      })
      .height(100)
      .backgroundColor($r('sys.color.ohos_id_color_background'))
      .borderRadius(8)
      .flexGrow(1);
    }
    .width('100%');
  }
}