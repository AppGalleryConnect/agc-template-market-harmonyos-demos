import { BreakpointStorage, BreakpointSystem, BreakpointTypeEnum } from 'lib_foundation';
import { PriceType } from 'lib_network';
import { ProductModel } from '../commons/Model';
import { CartCard } from './CartCard';

@ComponentV2
export struct CartListView {
  // 数据源
  @Param listData: ProductModel[] = [];
  // 是否编辑态
  @Param isEdit: boolean = false;
  // 购物车商品数量变化的事件回调
  @Event onChangeCount: (skuCode: string) => void = (skuCode: string) => {
  };
  // 删除操作
  @Event onDelete: (skuCode: string) => void = (skuCode: string) => {
  };
  // 商品卡片事件回调
  @Event onCardClick: (id: string, slotId?: string) => void = (id: string) => {
  };
  // 规格行点击事件回调
  @Event onSpecClick: (productId: string, skuCode: string, count: number, priceType: PriceType,
    slotId?: string) => void = () => {
  };
  @Local curBreakpoint: BreakpointStorage = BreakpointSystem.currentBreakpoint

  build() {
    List({ space: 12 }) {
      ForEach(this.listData, (card: ProductModel, index: number) => {
        ListItem() {
          CartCard({
            data: card,
            isEdit: this.isEdit,
            onChangeCount: (skuCode: string) => {
              this.onChangeCount && this.onChangeCount(skuCode);
            },
            onCardClick: () => {
              this.onCardClick && this.onCardClick(card.productId, card.slotId);
            },
            onSpecClick: () => {
              this.onSpecClick &&
                this.onSpecClick(card.productId, card.skuCode, card.count, card.priceType, card.slotId);
            },
            onDelete: (skuCode: string) => {
              this.onDelete && this.onDelete(skuCode);
            },
          })
        }
        .margin({ left: 8, right: 8 })
        .borderRadius(16)
        .transition({ type: TransitionType.Delete, opacity: 0 })
        .swipeAction(this.isEdit ? {} : {
          end: this.CardItemEnd(card, index),
          edgeEffect: SwipeEdgeEffect.None,
        })
      }, (item: ProductModel, index: number) => index + '__' + JSON.stringify(item))
    }
    .width('100%')
    .height('auto')
    .lanes(this.curBreakpoint.value === BreakpointTypeEnum.LG ? 2 : 1)
    .edgeEffect(EdgeEffect.None)
    .margin({ top: 10 })
    .padding({ left: 8, right: 8 })
    .clip(true)
  }

  @Builder
  CardItemEnd(card: ProductModel, index: number) {
    Row() {
      Button({ type: ButtonType.Normal, stateEffect: true }) {
        Text('删除')
          .fontSize(14)
          .fontColor(Color.White)
      }
      .height('100%')
      .padding({ left: 14, right: 14 })
      .backgroundColor($r('app.color.theme_color'))
      .onClick(() => {
        this.onDelete && this.onDelete(card.skuCode);
      })
    }
    .justifyContent(FlexAlign.SpaceEvenly)
  }
}