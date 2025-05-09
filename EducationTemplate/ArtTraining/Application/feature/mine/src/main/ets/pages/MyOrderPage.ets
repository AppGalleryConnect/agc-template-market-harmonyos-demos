import { OrderInfo, OrderTabsMap } from 'commonlib';
import { CommonDivider, CommonHeader, CommonLoading, ContainerColumn } from 'componentlib';
import { OrderCard } from '../components/OrderCard';
import { ORDER_TAB_LIST } from '../constants/Constants';
import { OrderButtonStyleMap } from '../constants/Enums';
import { OrderActionButton, OrderType } from '../types/Index';
import { OrderUtil } from '../utils/OrderUtil';
import { MyOrderPageVM } from '../viewModels/MyOrderPageVM';

@Builder
export function myOrderPageBuilder() {
  MyOrderPage();
}

@ComponentV2
export struct MyOrderPage {
  vm: MyOrderPageVM = MyOrderPageVM.instance;

  build() {
    NavDestination() {
      CommonHeader({
        title: '我的订单',
      });
      this.orderTabBuilder();
    }
    .onReady(() => {
      this.vm.initOrderList();
    })
    .hideTitleBar(true);
  }

  @Builder
  orderTabBuilder() {
    Tabs({ barPosition: BarPosition.Start, index: this.vm.currentIndex, controller: this.vm.tabController }) {
      ForEach(ORDER_TAB_LIST, (item: OrderType, index: number) => {
        TabContent() {
          Column() {
            if (this.vm.isLoading) {
              CommonLoading();
            } else {
              if (this.vm.orderList.length) {
                List({ space: 8 }) {
                  ForEach(this.vm.orderList, (item: OrderInfo) => {
                    ListItem() {
                      this.orderCardBuilder(item);
                    };
                  }, (item: OrderInfo) => item.orderNo);
                }
                .layoutWeight(1);
              } else {
                Column() {
                  Image($r('app.media.ic_order_empty'))
                    .width(200)
                    .height(200)
                    .margin({ bottom: $r('app.string.margin_s') });
                  Text('还没有相关订单哟')
                    .fontSize($r('app.string.font_size_14'))
                    .fontColor($r('app.color.font_color_level2'));
                  if (this.vm.currentIndex === OrderTabsMap.ALL) {
                    Row() {
                      Text('选购课程')
                        .fontColor($r('app.color.font_color_level1_invert'))
                        .fontSize($r('app.string.font_size_14'))
                        .fontWeight(FontWeight.Medium)
                        .onClick(() => {
                          this.vm.jumpToCourseCenter();
                        });
                    }
                    .backgroundColor($r('app.color.system_theme_color'))
                    .justifyContent(FlexAlign.Center)
                    .width($r('app.string.width_percent_75'))
                    .padding({
                      top: $r('app.string.padding_s'),
                      bottom: $r('app.string.padding_s'),
                    })
                    .borderRadius($r('app.string.border_radius_capsule'))
                    .margin({ top: $r('app.string.margin_xl') });
                  }
                }
                .backgroundColor($r('app.color.system_color_background_white'))
                .borderRadius($r('app.string.border_radius_16'))
                .padding($r('app.string.padding_xxl'))
                .width($r('app.string.width_percent_full'))
                .layoutWeight(1);
              }
            }
          }
          .visibility(this.vm.currentIndex === index ? Visibility.Visible : Visibility.Hidden)
          .justifyContent(FlexAlign.Start)
          .padding($r('app.string.padding_l'))
          .layoutWeight(1);
        }
        .tabBar(this.tabBarBuilder(item.label, index))
        .backgroundColor($r('app.color.system_color_background_auxiliary'));
      }, (item: OrderType) => item.type + item.label);
    }
    .width($r('app.string.width_percent_full'))
    .layoutWeight(1)
    .vertical(false)
    .barHeight(40)
    .barMode(BarMode.Scrollable)
    .onChange((index: number) => {
      this.vm.getOrderList(index);
    });
  }

  @Builder
  tabBarBuilder(name: string, index: number) {
    Column() {
      Text(name)
        .fontColor(this.vm.currentIndex === index ? $r('app.color.system_theme_color') :
        $r('app.color.font_color_level1'))
        .fontSize($r('app.string.font_size_14'))
        .fontWeight(400)
        .lineHeight(22)
        .margin({ top: $r('app.string.margin_s'), bottom: $r('app.string.margin_s') });
      Divider()
        .strokeWidth(2)
        .width(20)
        .color($r('app.color.system_theme_color'))
        .borderRadius($r('app.string.border_radius_capsule'))
        .opacity(this.vm.currentIndex === index ? 1 : 0);
    }
    .backgroundColor($r('app.color.system_color_background_white'))
    .padding({
      left: $r('app.string.padding_xs'),
      right: $r('app.string.padding_xs'),
    })
    .width('25%');
  }

  @Builder
  orderCardBuilder(item: OrderInfo) {
    ContainerColumn() {
      Column() {
        Row() {
          Text('订单号：' + item.orderNo)
            .fontSize($r('app.string.font_size_12'))
            .fontColor($r('app.color.font_color_level1'))
            .margin({ right: $r('app.string.margin_xs') });
          Image($r('app.media.ic_copy'))
            .width($r('app.integer.icon_size_16'))
            .height($r('app.integer.icon_size_16'))
            .onClick(() => {
              OrderUtil.copyOrderNo(item.orderNo);
            });
          Blank();
          Text(OrderUtil.getStatusLabel(item.orderStatus))
            .fontColor($r('app.color.system_theme_color'))
            .fontSize($r('app.string.font_size_12'))
            .margin({ right: $r('app.string.margin_xs') });
          Image($r('app.media.ic_arrow_right'))
            .width($r('app.integer.icon_size_12'));
        }
        .margin({ bottom: $r('app.string.margin_l') })
        .width($r('app.string.width_percent_full'));

        OrderCard({
          course: item.courseInfo,
        });
        CommonDivider();
        Row() {
          Text() {
            Span('总计: ').fontColor($r('app.color.font_color_level1'));
            Span(' ').letterSpacing(2);
            Span(`¥${item.totalPrice.toFixed(2)}`).fontColor($r('app.color.system_theme_color'));
          }
          .fontWeight(FontWeight.Medium);
        }
        .width($r('app.string.width_percent_full'))
        .justifyContent(FlexAlign.End);

        Row() {
          ForEach(OrderUtil.getOrderActionButtonList(item.orderStatus), (button: OrderActionButton) => {
            Row() {
              Text(button.label)
                .fontSize($r('app.string.font_size_12'))
                .fontColor(button.style === OrderButtonStyleMap.OUTLINE ? $r('app.color.font_color_level2') :
                $r('app.color.font_color_level1_invert'));
            }
            .padding({
              top: $r('app.string.padding_s'),
              bottom: $r('app.string.padding_s'),
              left: $r('app.string.padding_l'),
              right: $r('app.string.padding_l'),
            })
            .margin({ left: $r('app.string.margin_l') })
            .borderWidth(1)
            .borderRadius($r('app.string.border_radius_capsule'))
            .backgroundColor(button.style === OrderButtonStyleMap.OUTLINE ?
            $r('app.color.system_color_background_white') : $r('app.color.system_theme_color'))
            .borderColor(button.style === OrderButtonStyleMap.OUTLINE ? $r('app.color.icon_color_level2') :
            $r('app.color.system_theme_color'))
            .onClick(() => {
              this.vm.handleOrderOperation(item, button.action);
            });
          }, (button: OrderActionButton) => item.orderNo + button.action);
        }
        .margin({
          top: $r('app.string.margin_l'),
        })
        .width($r('app.string.width_percent_full'))
        .justifyContent(FlexAlign.End);
      }
      .alignItems(HorizontalAlign.Start)
      .width($r('app.string.width_percent_full'))
      .backgroundColor($r('app.color.system_color_background_white'))
      .onClick(() => {
        this.vm.jumpToOrderDetail(item);
      });
    };
  }
}