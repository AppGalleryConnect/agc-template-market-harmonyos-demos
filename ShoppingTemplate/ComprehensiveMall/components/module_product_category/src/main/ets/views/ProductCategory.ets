import { CategoryItem, ProductSummaryItem } from '../commons/Types';
import { ChipGroupItemOptions, ChipGroup, ChipSize } from '@kit.ArkUI';
import { AnimateType, UISkeleton, SkeletonTheme } from '@hw-agconnect/ui-skeleton';

@ComponentV2
export struct ProductCategory {
  @Param
  isChildRoute: boolean = false;
  @Param
  public initIndex: number = 0;
  @Param
  categoryTabs: CategoryItem[] = [];
  @Param
  productList: ProductSummaryItem[] = []
  @Param
  isLoading: boolean = false;
  @Local
  curIndex: number = 0;
  @Event
  handleSubCategoryChange: (id: string) => void = () => {
  }
  @Event
  handleClickCard: (item: ProductSummaryItem) => void = () => {
  }
  @Local
  curSubIndex: number = 0;
  controller: TabsController = new TabsController();

  @Computed
  get curCategoryId() {
    return this.categoryTabs[this.curIndex]?.id ?? undefined;
  }

  @Computed
  get curSubCategory() {
    const category = this.categoryTabs[this.curIndex]
    if (!category) {
      return undefined
    }
    const subCategory = category.subCategory ? (category.subCategory[this.curSubIndex] ?? undefined) : undefined
    return subCategory;
  }

  @Computed
  get curSubCategoryList() {
    const list = this.categoryTabs[this.curIndex]?.subCategory ?? []
    const chipGroup = list.map((item) => {
      return {
        label: { text: item.label },
      } as ChipGroupItemOptions
    })
    return chipGroup
  }

  @Monitor('curSubCategory')
  async getCategoryProductData() {
    this.handleSubCategoryChange?.(this.curSubCategory?.id ?? '')
  }

  @Monitor('initIndex')
  async changeCurIndex() {
    if (this.initIndex) {
      this.curIndex = this.initIndex;
    }
  }

  build() {
    Row() {
      List() {
        ForEach(this.categoryTabs, (item: CategoryItem, index: number) => {
          ListItem() {
            this.tabBarItemBuilder(item, index);
          }
          .padding({ bottom: index === this.categoryTabs.length - 1 ? 72 : 0 });
        }, (item: CategoryItem, index: number) => index + JSON.stringify(item));
      }
      .width('30%')
      .constraintSize({ maxWidth: 240 })
      .height('100%')
      .borderWidth({ right: 1 })
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      .borderColor($r('sys.color.comp_divider'))
      .scrollBar(BarState.Off)

      Column() {
        if (this.curSubCategoryList.length) {
          this.subCategoryBarBuilder()
        }
        if (this.categoryTabs && !this.isLoading && !this.productList.length) {
          Column() {
            Image($r('app.media.ic_search_empty'))
              .width(120)
              .height(120);
            Text('暂无数据')
              .fontSize($r('app.float.font_size_12'))
              .fontColor($r('app.color.font_color_level2'));
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else {
          this.productListBuilder()
        }
      }
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      .padding({ left: $r('app.float.space_l'), right: $r('app.float.space_l') })
      .layoutWeight(1)
    }
    .width('100%')
    .layoutWeight(1)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);
  }

  @Builder
  tabBarItemBuilder(item: CategoryItem, index: number) {
    Row() {
      Text(item.label)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .fontColor(index === this.curIndex ? $r('app.color.theme_color') : $r('app.color.font_color_level2'))
        .fontWeight(index === this.curIndex ? FontWeight.Medium : FontWeight.Regular)
        .fontSize(14);
    }
    .width('100%')
    .height(48)
    .padding(16)
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.curIndex = index;
      this.curSubIndex = 0;
      this.handleSubCategoryChange?.(this.curSubCategory?.id ?? '')
    });
  }

  @Builder
  subCategoryBarBuilder() {
    Column() {
      ChipGroup({
        items: this.curSubCategoryList,
        itemStyle: {
          size: ChipSize.SMALL,
          backgroundColor: $r('sys.color.ohos_id_color_button_normal'),
          fontColor: $r('sys.color.ohos_id_color_text_primary'),
          selectedBackgroundColor: $r('app.color.theme_color'),
          selectedFontColor: $r('sys.color.ohos_id_color_text_primary_contrary'),
        },
        selectedIndexes: [this.curSubIndex],
        multiple: false,
        chipGroupSpace: { itemSpace: 8, endSpace: 8, startSpace: 0 },
        chipGroupPadding: { top: 0, bottom: 12 },
        onChange: (activatedChipsIndex: Array<number>) => {
          this.curSubIndex = activatedChipsIndex[0]
        },
      })
      Text(this.curSubCategoryList[this.curSubIndex]?.label?.text ?? '')
        .fontColor($r('app.color.font_color_level1'))
        .fontSize($r('app.float.font_size_14'))
        .fontWeight(FontWeight.Bold)
        .margin({
          top: $r('app.float.space_s'),
          bottom: $r('app.float.space_s'),
        })
    }
    .width($r('app.string.size_percent_full'))
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  productListBuilder() {
    Scroll() {
      GridRow({
        columns: {
          xs: 2,
          md: 4,
        },
        gutter: { x: 12, y: 12 },
      }) {
        if (this.isLoading) {
          ForEach([1, 2, 3, 4, 5, 6, 7, 8], () => {
            GridCol({
              offset: 0,
              order: 0,
            }) {
              UISkeleton({
                theme: SkeletonTheme.IMAGE, animate: AnimateType.GRADIENT,
              }).height(96)
            }
          }, (item: number) => item.toString())
        } else {
          ForEach(this.productList, (item: ProductSummaryItem, index: number) => {
            GridCol({
              offset: 0,
              order: 0,
            }) {
              Column() {
                Image(item.banner)
                  .width($r('app.string.size_percent_full'))
                  .aspectRatio(1)
                  .borderRadius($r('app.float.border_radius_s'))
                Text(item.title)
                  .fontSize($r('app.float.font_size_14'))
                  .fontColor($r('app.color.font_color_level1'))
                  .margin({ top: $r('app.float.space_xs') })
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
              }
              .padding({ bottom: index === this.productList.length - 1 ? 72 : 0 })
              .alignItems(HorizontalAlign.Start)
              .onClick(() => {
                this.handleClickCard?.(item)
              })
            }
          }, (item: ProductSummaryItem, index: number) => index + '__' + item.id)
        }
      }
      .width($r('app.string.size_percent_full'))
      .margin({
        top: $r('app.float.space_m'),
      })
    }
    .layoutWeight(1)
    .align(Alignment.Top)
    .scrollBar(BarState.Off)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    .edgeEffect(EdgeEffect.Spring)
  }
}