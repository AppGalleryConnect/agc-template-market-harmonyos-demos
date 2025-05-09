import { CommonHeader } from 'componentlib';
import { OrderSubmittedVM } from '../viewmodels/OrderSubmittedVM';

@Builder
export function orderSubmittedPageBuilder() {
  OrderSubmittedPage();
}


@ComponentV2
export struct OrderSubmittedPage {
  vm: OrderSubmittedVM = OrderSubmittedVM.instance;

  build() {
    NavDestination() {
      CommonHeader({
        title: '提交成功',
      });
      Column() {
        Column() {
          Image($r('app.media.ic_submit_success'))
            .width($r('app.string.width_percent_75'))
            .margin($r('app.string.margin_l'));
          Text(this.vm.orderTips)
            .fontColor($r('app.color.font_color_level1'))
            .margin({
              top: $r('app.string.margin_s'),
              bottom: $r('app.string.margin_l'),
            });
          Row() {
            Button('返回首页')
              .backgroundColor($r('app.color.system_color_background_white'))
              .fontColor($r('app.color.system_theme_color'))
              .borderColor($r('app.color.system_theme_color'))
              .padding({ left: $r('app.string.padding_xl'), right: $r('app.string.padding_xl') })
              .borderWidth(1)
              .onClick(() => {
                this.vm.backToHome();
              });
            Button('查看订单')
              .backgroundColor($r('app.color.system_theme_color'))
              .padding({ left: $r('app.string.padding_xl'), right: $r('app.string.padding_xl') })
              .onClick(() => {
                this.vm.jumpToOrderDetail();
              });
          }
          .width($r('app.string.width_percent_full'))
          .justifyContent(FlexAlign.SpaceAround);
        }
        .backgroundColor($r('app.color.system_color_background_white'))
        .width($r('app.string.width_percent_full'))
        .borderRadius($r('app.string.border_radius_16'))
        .padding($r('app.string.padding_xl'));
      }
      .layoutWeight(1)
      .padding($r('app.string.padding_l'))
      .backgroundColor($r('app.color.system_color_background_auxiliary'));

    }
    .hideTitleBar(true)
    .onReady(() => {
      this.vm.getOrderInfo();
    });
  }
}