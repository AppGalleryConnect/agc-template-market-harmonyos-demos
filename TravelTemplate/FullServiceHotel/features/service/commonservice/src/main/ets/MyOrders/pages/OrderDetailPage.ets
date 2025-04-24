import { CommonButton, CommonHeader } from 'componentlib';
import { HotelOrderDetail } from '../components/HotelOrderDetail';
import { MealOrderDetail } from '../components/MealOrderDetail';
import { OrderClassLabel, OrderType } from '../types';
import { OrderDetailPageVM } from '../viewModels/OrderDetailPageVM';

@Builder
export function orderDetailPageBuilder() {
  OrderDetailPage()
}

@ComponentV2
export struct OrderDetailPage {
  vm: OrderDetailPageVM = OrderDetailPageVM.instance;

  build() {
    NavDestination() {
      Column() {
        CommonHeader({
          title: '订单详情',
        })
        Flex({
          direction: FlexDirection.Column,
        }) {
          this.titleBuilder();
          Column() {
            if (this.vm.orderType === OrderType.HOTEL) {
              HotelOrderDetail()
            } else if (this.vm.orderType === OrderType.MEAL) {
              MealOrderDetail()
            }
          }
          .layoutWeight(1)
          .backgroundColor($r('app.color.system_color_background_white'))

          if (this.vm.getOrderTitleLabel() === OrderClassLabel.PENDING_PAYMENT) {
            Row() {
              Column() {
                Text() {
                  Span('¥').fontSize($r('app.string.font_size_24'))
                  Span(this.vm.getOrderPrice())
                    .fontSize($r('app.string.font_size_36'))
                }
                .fontColor($r('app.color.system_color_highlight'))
                .margin({ bottom: $r('app.string.margin_xs') })

                Text('总价')
                  .fontSize($r('app.string.font_size_24'))
                  .fontColor($r('app.color.font_color_level2'))
              }
              .alignItems(HorizontalAlign.Start)

              CommonButton({
                fullWidth: false,
                title: '继续支付',
                handleClick: () => {
                  this.vm.continuePayment();
                },
              })
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .padding({
              top: $r('app.string.padding_m'),
              left: $r('app.string.padding_m'),
              right: $r('app.string.padding_s'),
            })
            .shadow({ color: '#08000000', radius: 5, offsetY: -5 })
            .backgroundColor($r('app.color.system_color_background_white'))
          }
        }
        .layoutWeight(1)
      }
      .height('100%')

    }
    .hideTitleBar(true)
    .onReady(() => {
      this.vm.getOrderDetail();
    })
  }

  @Builder
  titleBuilder() {
    Column() {
      Text(this.vm.getOrderTitleLabel())
        .fontSize($r('app.string.font_size_40'))
        .fontWeight(500)
        .margin({ bottom: $r('app.string.margin_xs') })
      Text(this.vm.getSubTitleLabel())
        .fontSize($r('app.string.font_size_24'))
        .fontColor($r('app.color.font_color_level2'))
    }
    .width('100%')
    .padding($r('app.string.padding_m'))
    .alignItems(HorizontalAlign.Start)
  }
}

@Extend(Text)
function labelTextStyle() {
  .fontColor($r('app.color.icon_color_level2'))
  .margin({ bottom: $r('app.string.margin_s') })
  .fontSize($r('app.string.font_size_28'));
}

@Extend(Text)
function detailTextStyle() {
  .margin({ bottom: $r('app.string.margin_s') })
  .fontSize($r('app.string.font_size_28'));
}

@Extend(Text)
function highlightTextStyle() {
  .fontSize($r('app.string.font_size_32'))
  .fontColor($r('app.color.system_color_highlight'))
  .fontWeight(500);
}