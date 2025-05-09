import { CoursePaymentMap, FormatUtil, OrderStatusMap } from 'commonlib';
import { CommonDivider, CommonHeader, CommonLoading } from 'componentlib';
import { OrderCard } from '../components/OrderCard';
import { OrderButtonStyleMap } from '../constants/Enums';
import { OrderActionButton } from '../types/Index';
import { OrderUtil } from '../utils/OrderUtil';
import { OrderDetailPageVM } from '../viewModels/OrderDetailPageVM';

@Builder
export function orderDetailPageBuilder() {
  OrderDetailPage();
}

@ComponentV2
export struct OrderDetailPage {
  vm: OrderDetailPageVM = OrderDetailPageVM.instance;

  build() {
    NavDestination() {
      CommonHeader({
        title: '订单详情',
      });
      if (this.vm.isLoading) {
        CommonLoading();
      } else {
        Scroll() {
          Column() {
            this.orderTitleBarBuilder();
            this.courseCardBuilder();
            this.studentCardBuilder();
            this.orderCardBuilder();
            Blank().layoutWeight(1);
          }
          .padding($r('app.string.padding_l'))
          .layoutWeight(1)
          .backgroundColor($r('app.color.system_color_background_auxiliary'));
        }
        .layoutWeight(1);

        this.bottomButtonBuilder();
      }

    }
    .hideTitleBar(true)
    .onShown(() => {
      this.vm.getOrderDetail();
    })
    .onHidden(() => {
      this.vm.clearCountdown();
    });
  }

  @Builder
  orderTitleBarBuilder() {
    if (this.vm.orderInfo) {
      Column() {
        Text(OrderUtil.getStatusLabel(this.vm.orderInfo.orderStatus))
          .fontSize($r('app.string.font_size_24'))
          .fontColor($r('app.color.font_color_level1'))
          .fontWeight(FontWeight.Medium)
          .margin({ bottom: $r('app.string.margin_s') });
        if (this.vm.orderInfo.orderStatus === OrderStatusMap.PENDING_PAYMENT &&
          this.vm.orderInfo.paymentMethod === CoursePaymentMap.ONLINE) {
          Text() {
            Span('订单将在 ');
            Span(this.vm.countdownLabel).fontColor($r('app.color.system_theme_color'));
            Span(' 后自动取消，请尽快支付');
          }
          .fontSize($r('app.string.font_size_14'))
          .fontColor($r('app.color.font_color_level2'));
        } else {
          Text(OrderUtil.getStatusDescLabel(this.vm.orderInfo.orderStatus))
            .fontSize($r('app.string.font_size_14'))
            .fontColor($r('app.color.font_color_level2'));
        }
      }
      .width($r('app.string.width_percent_full'))
      .padding({ left: $r('app.string.padding_l') })
      .alignItems(HorizontalAlign.Start)
      .margin({ bottom: $r('app.string.margin_l') });
    }
  }

  @Builder
  courseCardBuilder() {
    Column() {
      Text('商品信息').cardTitleStyle();
      CommonDivider();
      if (this.vm.orderInfo) {
        OrderCard({
          course: this.vm.orderInfo.courseInfo,
        });
        CommonDivider();
      }
      Row() {
        Text() {
          Span('实际金额:').fontColor($r('app.color.font_color_level1'));
          Span(' ').letterSpacing(4);
          Span(this.vm.orderInfo?.totalPrice.toFixed(2)).fontColor($r('app.color.system_theme_color'));
        }
        .fontSize($r('app.string.font_size_16'))
        .fontWeight(FontWeight.Medium);
      }
      .width($r('app.string.width_percent_full'))
      .justifyContent(FlexAlign.End);
    }.cardContainerStyle();
  }

  @Builder
  studentCardBuilder() {
    Column() {
      Text('学员信息').cardTitleStyle();
      CommonDivider();
      if (this.vm.orderInfo) {
        Row() {
          Text('学员姓名').cardLabelStyle();
          Text(this.vm.orderInfo.student).cardContentStyle();
        }.cardFormRowStyle();

        Row() {
          Text('手机号码').cardLabelStyle();
          Text(this.vm.orderInfo.phone).cardContentStyle();
        }.cardFormRowStyle();
      }

    }.cardContainerStyle();
  }

  @Builder
  orderCardBuilder() {
    Column() {
      Text('订单信息');
      CommonDivider();
      if (this.vm.orderInfo) {
        Row() {
          Text('支付方式').cardLabelStyle();
          Text(OrderUtil.getPaymentLabel(this.vm.orderInfo.paymentMethod)).cardContentStyle();
        }.cardFormRowStyle();

        Row() {
          Text('订单编号').cardLabelStyle();
          Text(this.vm.orderInfo.orderNo).cardContentStyle().layoutWeight(1);
          Image($r('app.media.ic_copy'))
            .width($r('app.integer.icon_size_16'))
            .height($r('app.integer.icon_size_16'))
            .onClick(() => {
              OrderUtil.copyOrderNo(this.vm.orderInfo!.orderNo);
            });
        }.cardFormRowStyle();

        Row() {
          Text('下单时间').cardLabelStyle();
          Text(FormatUtil.formatFullTime(new Date(this.vm.orderInfo.orderTime))).cardContentStyle();
        }.cardFormRowStyle();
      }
    }.cardContainerStyle();
  }

  @Builder
  bottomButtonBuilder() {
    if (this.vm.orderInfo) {
      Row() {
        ForEach(this.vm.getOrderActionButtonList(this.vm.orderInfo.orderStatus), (button: OrderActionButton) => {
          Row() {
            Text(button.label)
              .fontSize($r('app.string.font_size_16'))
              .fontWeight(FontWeight.Medium)
              .fontColor(button.style === OrderButtonStyleMap.OUTLINE ? $r('app.color.font_color_level2') :
              $r('app.color.font_color_level1_invert'));
          }
          .height(40)
          .width(120)
          .justifyContent(FlexAlign.Center)
          .margin({ right: $r('app.string.margin_l') })
          .borderWidth(1)
          .borderRadius($r('app.string.border_radius_capsule'))
          .backgroundColor(button.style === OrderButtonStyleMap.OUTLINE ?
          $r('app.color.system_color_background_white') : $r('app.color.system_theme_color'))
          .borderColor(button.style === OrderButtonStyleMap.OUTLINE ? $r('app.color.icon_color_level2') :
          $r('app.color.system_theme_color'))
          .onClick(() => {
            this.vm.handleOrderOperation(button.action);
          });
        }, (button: OrderActionButton) => button.action);
      }
      .margin({
        top: $r('app.string.margin_l'),
      })
      .justifyContent(FlexAlign.End)
      .width($r('app.string.width_percent_full'));
    }
  }
}

@Extend(Column)
function cardContainerStyle() {
  .backgroundColor($r('app.color.system_color_background_white'))
  .borderRadius($r('app.string.border_radius_16'))
  .padding($r('app.string.padding_l'))
  .width($r('app.string.width_percent_full'))
  .alignItems(HorizontalAlign.Start)
  .margin({
    top: $r('app.string.margin_l'),
  });
}

@Extend(Text)
function cardTitleStyle() {
  .fontSize($r('app.string.font_size_16'))
  .fontColor($r('app.color.font_color_level1'))
  .fontWeight(FontWeight.Medium);

}

@Extend(Row)
function cardFormRowStyle() {
  .width($r('app.string.width_percent_full'))
  .justifyContent(FlexAlign.Start)
  .margin({
    top: $r('app.string.margin_xs'),
    bottom: $r('app.string.margin_xs'),
  });
}

@Extend(Text)
function cardLabelStyle() {
  .fontSize($r('app.string.font_size_12'))
  .fontColor($r('app.color.font_color_level1'))
  .margin({ right: $r('app.string.margin_l') });
}

@Extend(Text)
function cardContentStyle() {
  .fontSize($r('app.string.font_size_12'))
  .fontColor($r('app.color.font_color_level2'))
  .layoutWeight(1);
}