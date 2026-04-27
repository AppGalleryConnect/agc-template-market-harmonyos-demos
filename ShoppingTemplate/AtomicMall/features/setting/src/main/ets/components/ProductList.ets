import { BreakpointSystem, BreakpointTypeEnum, ProductInfoPageParam, RouterMap, routerStack } from 'lib_foundation'
import { ProductCardLabel, ProductCardItem } from 'lib_network'
import { CommonLoading } from 'lib_widget'

enum LabelPresetType {
  PRIMARY,
  SECONDARY,
}

@ComponentV2
export struct ProductList {
  @Param
  productList: ProductCardItem[] = []
  @Param
  isEdit: boolean = false
  @Param
  isLoading: boolean = false
  @Event
  handleDelete: (list: string[]) => void = () => {
  }
  @Event
  onReachEnd: () => void = () => {
  }
  @Local
  selectedSet: Set<string> = new Set()
  private readonly _checkboxGroup: string = 'select_product'

  build() {
    Column() {
      if (this.productList.length) {
        List({ space: 16 }) {
          Repeat<ProductCardItem>(this.productList)
            .each((ri: RepeatItem<ProductCardItem>) => {
              ListItem() {
                this.buildProductCard(ri.item)
              }
              .swipeAction({
                end: this.buildDeleteIcon(ri.item.productId),
              })
            })

          if (this.isLoading) {
            ListItem() {
              CommonLoading().height(56)
            }
          }
        }
        .layoutWeight(1)
        .lanes(BreakpointSystem.currentBreakpoint.value === BreakpointTypeEnum.LG ? 2 : 1, 12)
        .scrollBar(BarState.Off)
        .onReachEnd(() => {
          this.onReachEnd()
        })
        .expandSafeArea()
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
      } else if (this.isLoading) {
        CommonLoading()
      } else {
        Column() {
          Image($r('app.media.ic_search_empty'))
            .width(160)
            .height(160)
            .margin({ bottom: $r('app.float.space_s') })
          Text('暂无数据~')
            .fontSize(14)
            .fontColor($r('app.color.font_color_level2'))
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      }


      if (this.isEdit) {
        Row() {
          Row() {
            CheckboxGroup({ group: this._checkboxGroup })
              .checkboxShape(CheckBoxShape.CIRCLE)
              .selectedColor($r('app.color.theme_color'))
            Text('全选').fontColor($r('app.color.font_color_level1'))
          }
          .layoutWeight(1)

          Button('删除')
            .backgroundColor($r('app.color.theme_color'))
            .onClick(() => {
              this.handleDelete?.(Array.from(this.selectedSet))
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
        .padding({ top: $r('app.float.space_s'), bottom: $r('app.float.space_l') })
      }
    }
    .layoutWeight(1)
    .padding({
      top: $r('app.float.space_l'),
      left: $r('app.float.space_l'),
      right: $r('app.float.space_l'),
    })
  }

  @Builder
  buildProductCard(product: ProductCardItem) {
    Row() {
      if (this.isEdit) {
        Checkbox({ name: product.productId, group: this._checkboxGroup })
          .selectedColor($r('app.color.theme_color'))
          .shape(CheckBoxShape.CIRCLE)
          .onChange((isSelected: boolean) => {
            if (isSelected) {
              this.selectedSet.add(product.productId)
            } else {
              this.selectedSet.delete(product.productId)
            }
          })
          .margin({ right: $r('app.float.space_m') })
      }
      Image(product.banner)
        .width(80)
        .height(80)
        .borderRadius($r('app.float.border_radius_s'))
        .margin({ right: $r('app.float.space_m') })
      Column({ space: 6 }) {
        Text(product.title)
          .fontColor($r('app.color.font_color_level1'))
          .fontWeight(FontWeight.Medium)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        if (product.label.length) {
          this.buildLabel(product.label)
        }
        Text() {
          Span('¥');
          Span(product.price.toString()).fontSize(16);
        }
        .fontSize(12)
        .fontColor($r('app.color.theme_color'))
        .fontWeight(FontWeight.Medium);
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Start)
      .height(80)
    }
    .onClick(() => {
      routerStack.pushPath({
        name: RouterMap.PRODUCT_INFO,
        param: {
          productId: product.productId,
          slotId: product.slotId,
        } as ProductInfoPageParam,
      });
    })
    .backgroundColor($r('app.color.background_color_primary'))
    .borderRadius($r('app.float.border_radius_l'))
    .padding($r('app.float.space_m'))
  }

  @Builder
  buildLabel(labels: ProductCardLabel[]) {
    if (labels.length) {
      Text() {
        ForEach(labels, (label: ProductCardLabel, index: number) => {
          if (label.preset === LabelPresetType.PRIMARY) {
            Span(label.data).fontColor($r('app.color.label_color_primary'));
          } else if (label.preset === LabelPresetType.SECONDARY) {
            Span(label.data).fontColor($r('app.color.label_color_secondary'));
          }
          if (index < labels.length - 1) {
            Span(' | ').fontColor($r('app.color.font_color_level3'));
          }
        }, (label: ProductCardLabel, index: number) => index + label.data);
      }
      .fontSize(12)
      .maxLines(1)
      .textOverflow({ overflow: TextOverflow.Ellipsis });
    }
  }

  @Builder
  buildDeleteIcon(id: string) {
    Row() {
      Row() {
        SymbolGlyph($r('sys.symbol.trash_fill'))
          .fontColor([$r('app.color.background_color_primary')])
          .fontSize(20)
      }
      .backgroundColor($r('sys.color.warning'))
      .width(40)
      .height(40)
      .borderRadius(20)
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        this.handleDelete?.([id])
      })
    }
    .width(72)
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}