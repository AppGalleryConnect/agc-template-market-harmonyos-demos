import { LengthMetrics } from '@kit.ArkUI';
import { ProductDetailInfo, SeckillProductInfo } from 'lib_network';
import { ProductOperationType } from '../commons/Enums';
import { ProductSelectorVM } from '../viewmodels/ProductSelectorVM';
import { SpecViewModel } from '../commons/Models';
import { WindowUtil } from 'lib_foundation';

@ComponentV2
export struct ProductSelector {
  @Param
  productInfo: ProductDetailInfo | undefined = undefined;
  // 购物车规格修改场景下，productInfo 为空时作为降级初始化入口
  @Param
  productId: string = '';
  // 购物车规格修改场景下，需要预选的 skuCode（即当前已加入购物车的规格）
  @Param
  preSelectedSkuCode: string = '';
  // 购物车规格修改场景下，需要预填的商品数量
  @Param
  preSelectedCount: number = 1;
  @Param
  seckillInfo?: SeckillProductInfo = undefined
  @Param
  isSeckillOngoing: boolean = false
  @Param
  operationType: ProductOperationType = ProductOperationType.ADD_TO_CART;
  @Param
  hasPurchased: boolean = true
  @Event
  handleAddCart: (skuCode: string, count: number) => void
  @Event
  handlePayNow: (skuCode: string, count: number) => void
  vm: ProductSelectorVM = new ProductSelectorVM();

  @Computed
  get enablePurchase() {
    if (!this.hasPurchased) {
      return true;
    }
    if (this.isSeckillOngoing && this.hasPurchased) {
      return false;
    }
    return true;
  }

  async aboutToAppear() {
    const id = this.productInfo?.productId ?? this.productId;
    if (id) {
      await this.vm.initData(id);
      this.vm.seckillInfo = this.seckillInfo;
      this.vm.isSeckillOngoing = this.isSeckillOngoing;
      if (this.preSelectedSkuCode) {
        this.vm.preSelectBySku(this.preSelectedSkuCode, this.preSelectedCount);
      }
    }
  }

  build() {
    Column() {
      if (this.vm.stockInfo) {
        Scroll() {
          Column() {
            this.headerInfoBuilder();
            this.specsInfoBuilder();
            this.amountInfoBuilder();
          }
        }
        .align(Alignment.Top)
        .padding({ bottom: 12 })
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.Spring)
        .scrollBar(BarState.Off)

        this.bottomOperationBuilder();
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background_color_primary'))
    .alignItems(HorizontalAlign.Start)
    .padding(16)
    .borderRadius({
      topLeft: 32,
      topRight: 32,
    })
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP]);
  }

  @Builder
  headerInfoBuilder() {
    Row() {
      if (this.vm.stockInfo) {
        // banner图
        Image(this.vm.selectorBanner)
          .width(112)
          .height(112)
          .borderRadius(8)
          .margin({ right: 12 });
        // 价格标签
        Column() {
          Text() {
            Span('实付 ¥');
            Span(this.vm.curPrice.toString()).fontSize(24);
            if (!this.vm.curSku) {
              Span('起');
            }
          }
          .fontColor($r('app.color.theme_color'))
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .margin({ bottom: 4 });

          Text() {
            Span('¥');
            Span(this.vm.curDashPrice.toString());
          }
          .fontSize(12)
          .fontColor($r('app.color.font_color_level1'))
          .decoration({ type: TextDecorationType.LineThrough })
          .margin({ bottom: 20 });

          ForEach(this.vm.stockInfo.services, (str: string) => {
            Text(str)
              .fontColor($r('sys.color.mask_tertiary'))
              .fontSize(12);
          }, (item: string) => item);
        }
        .justifyContent(FlexAlign.Start)
        .alignItems(HorizontalAlign.Start)
        .margin({ top: 16 });
      }
    }
    .width('100%')
    .height('auto')
    .alignItems(VerticalAlign.Top)
    .margin({ bottom: 20 });
  }

  @Builder
  specsInfoBuilder() {
    Column() {
      ForEach(Array.from(this.vm.specViewListMap), (item: [string, SpecViewModel[]]) => {
        Text(item[1][0]?.label ?? '').specKeyTextStyle();
        Flex({ wrap: FlexWrap.Wrap, space: { main: LengthMetrics.vp(8), cross: LengthMetrics.vp(8) } }) {
          ForEach(item[1], (item: SpecViewModel) => {
            Row() {
              if (item.image) {
                Image(item.image).height(32).width(32);
              }
              Text() {
                Span(item.value);
                Span(item.isTempOutOfStock || item.isOutOfStock ? '(缺货)' : '');
              }
              .fontColor(item.isSelected ? $r('app.color.theme_color') : $r('app.color.font_color_level1'))
              .fontSize(14)
              .margin(8)
            }
            .borderRadius(4)
            .borderWidth(1)
            .flexShrink(1)
            .borderColor(item.isSelected ? $r('app.color.theme_color') : $r('app.color.background_color_button_grey'))
            .backgroundColor(item.isSelected ? '#1ae64566' :
              $r('app.color.background_color_button_grey'))
            .opacity(item.isOutOfStock || item.isTempOutOfStock ? 0.5 : 1)
            .onClick(() => {
              this.vm.handleSpecClick(item);
            });
          }, (item: SpecViewModel, index: number) => index + '__' + JSON.stringify(item));
        }
        .margin({ bottom: 24 });
      }, (item: [string, SpecViewModel[]], index: number) => index + '__' + JSON.stringify(item));
    }
    .alignItems(HorizontalAlign.Start);

  }

  @Builder
  amountInfoBuilder() {
    Row() {
      Text('数量').specKeyTextStyle();
      Row() {
        Image($r('app.media.ic_minus'))
          .amountOperatorIconStyle()
          .fillColor(this.vm.selectedCount <= 1 ? $r('app.color.font_color_level3') : $r('app.color.font_color_level1'))
          .onClick(() => {
            this.vm.handleCountChange(false);
          });

        Text(this.vm.selectedCount.toString())
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.font_color_level1'))
          .margin(4)
          .padding(4)
          .borderRadius(0)
          .width(32)
          .textAlign(TextAlign.Center)
          .backgroundColor($r('app.color.background_color_grey'));

        Image($r('app.media.ic_plus'))
          .amountOperatorIconStyle()
          .fillColor(this.vm.enableAddCount ? $r('app.color.font_color_level1') : $r('app.color.font_color_level3'))
          .onClick(() => {
            this.vm.handleCountChange();
          });
      }
      .backgroundColor($r('app.color.background_color_grey'))
      .borderRadius(5)
      .margin({ right: 10 });
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween);
  }

  @Builder
  bottomOperationBuilder() {
    if (!this.enablePurchase) {
      Button('达到限购上限')
        .width('100%')
        .height(40)
        .backgroundColor($r('sys.color.font_tertiary'))
        .enabled(false)
        .margin({ bottom: $r('app.float.space_l') })
    } else {
      Button(this.vm.enableConfirm ? '确定' : '暂时缺货')
        .width('100%')
        .height(40)
        .backgroundColor(this.vm.enableConfirm ? $r('app.color.theme_color') : $r('app.color.font_color_level3'))
        .fontColor($r('sys.color.font_on_primary'))
        .onClick(() => {
          if (!this.vm.curSku) {
            WindowUtil.toast('还有规格没有选择');
            return;
          }
          if (this.vm.enableConfirm) {
            if (this.operationType === ProductOperationType.ADD_TO_CART) {
              this.handleAddCart(this.vm.curSku.skuCode, Number(this.vm.selectedCount));
            } else {
              this.handlePayNow(this.vm.curSku.skuCode, Number(this.vm.selectedCount));
            }
          }
        })
        .margin({ bottom: $r('app.float.space_l') })
    }
  }
}

@Extend(Text)
function specKeyTextStyle() {
  .fontSize(16)
  .fontWeight(FontWeight.Medium)
  .fontColor($r('app.color.font_color_level1'))
  .margin({ bottom: 12 });
}

@Extend(Image)
function amountOperatorIconStyle() {
  .width(16)
  .height(16)
  .margin({
    left: 12,
    right: 12,
  })
  .objectFit(ImageFit.Contain)
  .fillColor($r('app.color.font_color_level1'));
}