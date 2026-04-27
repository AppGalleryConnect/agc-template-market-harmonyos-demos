import { BreakpointSystem } from 'lib_foundation';
import { CartPrice, DiscountItem } from 'lib_network';
import { CommonConfirmDialog } from 'lib_widget';
import { PopupSheet } from './PopupSheet';

@ComponentV2
export struct CartControlPanel {
  // 是否是编辑态
  @Param isEdit: boolean = false;
  // 是否是子页面路由
  @Param isChildRoute: boolean = false;
  // 总价
  @Param cartPrice: CartPrice = {
    originalPrice: 0,
    finalPrice: 0,
    discountList: [],
  };
  // 优惠
  @Param discountAmount: number = 0;
  // 选择的商品个数
  @Param quantity: number = 0;
  // 全选的回调事件
  @Event onSelectAll: () => void = () => {
  };
  // 删除事件
  @Event onDelete: () => void = () => {
  };
  // 结算
  @Event onCheckout: () => void = () => {
  };
  @Local visible: boolean = false;
  @Local popupMaskHeight: Length = '';

  build() {
    Column() {
      Row() {
        Row() {
          CheckboxGroup({ group: 'checkboxGroup' })
            .selectedColor('#FFE64566')
            .unselectedColor($r('app.color.font_color_level2'))
            .checkboxShape(CheckBoxShape.CIRCLE)
            .onChange(() => {
              this.visible = false;
              this.onSelectAll && this.onSelectAll();
            })
          Text('全选')
            .fontColor($r('app.color.font_color_level1'))
            .fontSize(14)
            .baselineOffset(-1)
            .margin({ left: 8, right: 8 })
        }

        Row() {
          if (this.isEdit) {
            // 删除
            this.DeleteBtn();
          } else {
            // 总价大于0，需要展示明细
            if (this.cartPrice.finalPrice > 0) {
              this.TotalCostDetailView();
            } else {
              this.TotalView();
            }
            // 结算按钮
            this.CheckoutBtn();
          }
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.End)
      }
      .width('100%')
      .height(60)
      .borderWidth(this.isChildRoute ? { top: 0.1 } : {})
      .borderColor('#30000000')
      .backgroundColor($r('app.color.background_color_primary'))
      .margin({ bottom: (this.isChildRoute || BreakpointSystem.isTablet) ? 0 : 56 })
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({ left: 16, right: 16 })

      PopupSheet({
        visible: this.visible!!,
        maskHeight: this.popupMaskHeight,
        customContentBuilder: () => {
          this.PopupContentBuilder();
        },
        title: '金额明细',
      })
    }
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    .backgroundColor($r('app.color.background_color_primary'))
    .onAreaChange((_ov, nv) => {
      if (nv.globalPosition.y) {
        this.popupMaskHeight = nv.globalPosition.y;
      }
    })
  }

  @Builder
  DeleteBtn() {
    Button('删除')
      .width(80)
      .fontColor(this.quantity ? $r('app.color.theme_color') : $r('app.color.font_color_level2'))
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .margin({ left: 16 })
      .onClick(() => {
        CommonConfirmDialog.show({
          content: '确认删除选中的商品吗？',
          confirm: () => {
            this.onDelete();
          },
        })
      })
      .transition(TransitionEffect.OPACITY.animation({ duration: 200, curve: Curve.Ease }))
  }

  @Builder
  TotalView() {
    Row() {
      Text('合计: ')
        .fontSize(12)
        .fontColor($r('app.color.font_color_level1'))
      Text('¥')
        .fontSize(12)
        .fontColor($r('app.color.theme_color'))
        .fontWeight(FontWeight.Medium)
      Text(this.cartPrice.finalPrice.toString())
        .fontSize(16)
        .fontColor($r('app.color.theme_color'))
        .fontWeight(FontWeight.Medium)
    }
    .justifyContent(FlexAlign.End)
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  TotalCostDetailView() {
    Column({ space: 4 }) {
      Row() {
        Text(`已选${this.quantity}件, `).fontSize(12).fontColor('#959496')
        this.TotalView();
      }
      .justifyContent(FlexAlign.End)
      .alignItems(VerticalAlign.Center)

      Row() {
        if (this.discountAmount) {
          Text() {
            Span('共减 ¥')
            Span(this.discountAmount.toString())
          }
          .fontSize(10).fontColor($r('app.color.theme_color'))
          .margin({ right: 8 })
        }
        Text('查看明细').fontSize(10).fontColor($r('app.color.theme_color')).margin({ right: 2 })
        Image($r('app.media.ic_left_arrow'))
          .height(12)
          .objectFit(ImageFit.Contain)
          .rotate({ angle: 90 })
          .fillColor($r('app.color.theme_color'))
          .draggable(false)
      }
      .onClick(() => {
        this.visible = !this.visible;
      })
    }
    .alignItems(HorizontalAlign.End)
  }

  @Builder
  CheckoutBtn() {
    Button('结算')
      .width(80)
      .backgroundColor($r('app.color.theme_color'))
      .margin({ left: 16 })
      .onClick(() => {
        this.onCheckout && this.onCheckout();
        this.visible = false;
      })
      .transition(TransitionEffect.OPACITY.animation({ duration: 1000, curve: Curve.Ease }))
  }

  @Builder
  PopupContentBuilder() {
    Column({ space: 16 }) {
      this.PopupContentItem('商品金额', this.cartPrice.originalPrice);
      // 是否有优惠
      if (this.discountAmount) {
        this.PopupContentItem('活动优惠', this.discountAmount);
      }
      ForEach(this.cartPrice.discountList, (discount: DiscountItem) => {
        this.PopupContentItem(discount.label, discount.discountPrice, true);
      }, (discount: DiscountItem) => discount.type + '__' + discount.discountPrice)
      // 合计
      Row() {
        Text('合计')
          .fontSize(16)
          .fontColor($r('app.color.font_color_level1'))
          .fontWeight(FontWeight.Medium)

        Text() {
          Span('¥').fontSize(12)
          Span(this.cartPrice.finalPrice.toString())
            .fontSize(24)
        }
        .fontColor($r('app.color.theme_color'))
        .fontWeight(FontWeight.Medium)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .backgroundColor($r('app.color.background_color_primary'))
  }

  @Builder
  PopupContentItem(label: string, value: number, isDiscount: boolean = false) {
    Row() {
      Text(label)
        .fontSize(14)
        .fontColor($r('app.color.font_color_level2'))
        .fontWeight(FontWeight.Regular)

      Text() {
        if (isDiscount) {
          Span('-')
        }
        Span(`¥${value}`)
      }
      .fontSize(14)
      .fontColor($r('app.color.font_color_level2'))
      .fontWeight(FontWeight.Medium)
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }
}