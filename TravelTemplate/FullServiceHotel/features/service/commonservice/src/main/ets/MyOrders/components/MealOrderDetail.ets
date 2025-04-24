import { FormatUtil } from 'commonlib';
import { OrderDetailPageVM } from '../viewModels/OrderDetailPageVM';

@ComponentV2
export struct MealOrderDetail {
  vm: OrderDetailPageVM = OrderDetailPageVM.instance;

  build() {
    Scroll() {
      Column({ space: '16lpx' }) {
        this.mealInfoCardBuilder();
        this.usageRuleCardBuilder();
        this.orderInfoBuilder();
      }
      .backgroundColor($r('app.color.system_color_background_auxiliary'))
      .padding($r('app.string.padding_s'))
      .flexGrow(1);
    }
    .height($r('app.string.height_percent_full'))
    .width($r('app.string.width_percent_full'));
  }

  @Builder
  mealInfoCardBuilder() {
    if (this.vm.mealOrderItem) {
      Column() {
        Flex({ alignItems: ItemAlign.Start }) {
          Image(FormatUtil.getImgResource(this.vm.mealOrderItem.images))
            .width(80)
            .borderRadius($r('app.string.border_radius_8'))
            .margin({ right: $r('app.string.margin_s') })
            .aspectRatio(4 / 3);
          Column() {
            Text(this.vm.mealOrderItem.packageName)
              .fontSize($r('app.string.font_size_32'))
              .fontWeight(500)
              .margin({ bottom: $r('app.string.margin_s') });
          }
          .alignItems(HorizontalAlign.Start)
          .flexGrow(1);

          Column() {
            Text(`¥${this.vm.mealOrderItem.actualPaidPrice}`)
              .margin({ bottom: $r('app.string.margin_s') })
              .fontSize($r('app.string.font_size_32'));
            Text(`×${this.vm.mealOrderItem.totalCount}`)
              .fontColor($r('app.color.font_color_level2'))
              .fontSize($r('app.string.font_size_28'));
          }
          .width(80)
          .justifyContent(FlexAlign.SpaceBetween)
          .alignItems(HorizontalAlign.End);
        };

        if (this.vm.mealOrderItem.status === '2') {
          Divider().color($r('app.color.icon_color_level4'))
            .margin({
              top: $r('app.string.margin_m'),
              bottom: $r('app.string.margin_m'),
            });

          Row() {
            Text('券码').labelTextStyle();
            Text(this.vm.mealOrderItem.orderNo).detailTextStyle();
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween);

          QRCode(this.vm.mealOrderItem.orderNo)
            .width(140)
            .height(140)
            .padding({
              top: $r('app.string.padding_s'),
              bottom: $r('app.string.padding_m'),
            });
        }

      }
      .backgroundColor(Color.White)
      .padding({
        top: $r('app.string.padding_m'),
        left: $r('app.string.padding_s'),
        right: $r('app.string.padding_s'),
      })
      .borderRadius($r('app.string.border_radius_16'));
    }
  }

  @Builder
  usageRuleCardBuilder() {
    if (this.vm.mealOrderItem) {
      Flex({
        alignItems: ItemAlign.Start,
      }) {
        Text('使用须知')
          .fontColor($r('app.color.icon_color_level2'))
          .fontSize($r('app.string.font_size_28'))
          .width(80);
        Text(this.vm.mealOrderItem.usageRule)
          .fontSize($r('app.string.font_size_28'))
          .fontColor($r('app.color.font_color_level1'));
      }
      .width('100%')
      .backgroundColor(Color.White)
      .padding({
        top: $r('app.string.padding_m'),
        bottom: $r('app.string.padding_m'),
        left: $r('app.string.padding_s'),
        right: $r('app.string.padding_s'),
      })
      .borderRadius($r('app.string.border_radius_16'));
    }
  }

  @Builder
  orderInfoBuilder() {
    if (this.vm.mealOrderItem) {
      Column() {
        Row() {
          Text('支付方式').labelTextStyle();
          Text('华为支付').detailTextStyle();
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween);

        this.commonDividerBuilder();

        Row() {
          Text('订单编号').labelTextStyle();
          Text(this.vm.mealOrderItem.orderNo).detailTextStyle();
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween);

        this.commonDividerBuilder();

        Row() {
          Text('下单时间').labelTextStyle();
          Text(this.vm.mealOrderItem.updateTime).detailTextStyle();
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween);

        this.commonDividerBuilder();

        Row() {
          Text('总价').labelTextStyle();
          Text(`¥${this.vm.mealOrderItem.actualPaidPrice}`)
            .detailTextStyle();
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween);
      }
      .width('100%')
      .backgroundColor(Color.White)
      .padding({
        top: $r('app.string.padding_m'),
        bottom: $r('app.string.padding_m'),
        left: $r('app.string.padding_s'),
        right: $r('app.string.padding_s'),
      })
      .borderRadius($r('app.string.border_radius_16'));
    }

  }

  @Builder
  commonDividerBuilder() {
    Divider().color($r('app.color.system_color_grey_level1'))
      .margin({
        top: $r('app.string.margin_s'),
        bottom: $r('app.string.margin_s'),
      });
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
  .fontSize($r('app.string.font_size_28'))
  .lineHeight('40lpx');
}

@Extend(Text)
function highlightTextStyle() {
  .fontSize($r('app.string.font_size_32'))
  .fontColor($r('app.color.system_color_highlight'))
  .fontWeight(500);
}