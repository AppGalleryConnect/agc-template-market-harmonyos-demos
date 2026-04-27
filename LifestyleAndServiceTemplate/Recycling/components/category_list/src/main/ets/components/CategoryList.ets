import { CategoryItem, ItemInfo, SubCategoryItem } from '../types/Index';
import { Constants, LayoutType } from '../common/Constant';
import { GridRowColSetting } from '../common/GridRowColSetting';
import { CategoryBasicDataSource } from '../common/CategoryBasicDataSource';

@ComponentV2
export struct CategoryList {
  // 分类列表
  @Param categoryTabs: CategoryItem[] = [];
  // 子列表
  @Param productList: SubCategoryItem[] = []
  @Param themeColor: ResourceColor = '#0A59F7';
  @Param tabBarScroller: Scroller = new Scroller();
  @Param subBarScroller: Scroller = new Scroller();
  // 一级选中索引初始值
  @Param initIndex: number = 0;
  // 控制布局方式
  @Param layoutType: LayoutType = LayoutType.GRID;
  @Param scroller: Scroller = new Scroller();
  @BuilderParam itemBuilderParam: (item: ItemInfo) => void = this.itemBuilder;
  @Local dataSource: CategoryBasicDataSource = new CategoryBasicDataSource()
  @Local curIndex: number = this.initIndex;
  @Local curSubIndex: number = 0;
  @Local breakpoint: string = 'sm';
  @Local scrollStatus: boolean = false;
  @Event onTabClick: (tab: CategoryItem) => void = () => {
  }
  @Event onItemClick: (itemDetail: ItemInfo) => void = () => {
  }
  @Local curItemIndex: number = 0;
  @Local curAllList: ItemInfo[][] = [];
  @Local curSectionList: ItemInfo[] = [];

  @Monitor('productList')
  onProductListChange() {
    this.dataSource.setData(this.productList);
  }

  build() {
    Row() {
      GridRow(GridRowColSetting.DEFAULT_GRID_ROW_OPTIONS) {
        GridCol({ span: GridRowColSetting.TITLE_COL_SPAN }) {
          Row() {
            List({ scroller: this.tabBarScroller }) {
              ForEach(this.categoryTabs, (category: CategoryItem, index: number) => {
                ListItem() {
                  this.tabBarItemBuilder(category, index)
                }
              }, (category: CategoryItem) => JSON.stringify(category.id))
            }
            .layoutWeight(1)
            .height(Constants.FULL_PERCENT)
            .scrollBar(BarState.Off)
            .listDirection(Axis.Vertical)
            .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })

            Divider()
              .vertical(true)
              .strokeWidth(Constants.DIVIDER_WIDTH)
              .color($r('sys.color.comp_divider'))
              .padding({ top: Constants.DIVIDER_TOP })
              .margin({
                left: Constants.PADDING_M,
              })
          }
          .justifyContent(FlexAlign.SpaceBetween)
          .margin({ top: Constants.PADDING_S })
        }

        GridCol({ span: GridRowColSetting.SUBTITLE_COL_SPAN }) {
          Column() {
            List({ space: Constants.SPACE_S, scroller: this.subBarScroller }) {
              LazyForEach(this.dataSource, (subCategory: SubCategoryItem, index: number) => {
                ListItem() {
                  this.subBarItemBuilder(subCategory.label, index)
                }
              }, (item: SubCategoryItem) => JSON.stringify(item.id))
            }
            .margin({ top: Constants.PADDING_XL })
            .width(Constants.FULL_PERCENT)
            .height(Constants.BUTTON_HEIGHT)
            .listDirection(Axis.Horizontal)
            .scrollBar(BarState.Off)
            .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })

            this.productListBuilder()
          }
          .layoutWeight(1)
        }
      }
      .onBreakpointChange((bp: string) => {
        this.breakpoint = bp;
      })
    }
    .width(Constants.FULL_PERCENT)
    .height(Constants.FULL_PERCENT)
    .padding({
      left: GridRowColSetting.getPageMargin(this.breakpoint),
    })
  }

  aboutToAppear(): void {
    this.dataSource.setData(this.productList);
  };

  // 一级分类列表
  @Builder
  tabBarItemBuilder(item: CategoryItem, index: number) {
    Row() {
      Text(item.label)
        .fontSize($r('sys.float.Body_M'))
        .fontWeight(this.curIndex === index ? FontWeight.Bold : FontWeight.Regular)
        .fontColor(this.curIndex === index ? this.themeColor : $r('sys.color.font_secondary'))
        .maxLines(Constants.FONT_LINES)
        .textAlign(TextAlign.Start)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .height(Constants.TITLE_HEIGHT)
    .justifyContent(FlexAlign.Start)
    .width(Constants.FULL_PERCENT)
    .margin({ left: GridRowColSetting.getTabMargin(this.breakpoint) })
    .onClick(() => {
      this.curIndex = index;
      this.curSubIndex = 0;
      this.curItemIndex = 0;
      this.subBarScroller.scrollToIndex(this.curSubIndex)
      this.scroller.scrollToIndex(this.curItemIndex)
      this.onTabClick(item);
    })
  }

  // 二级分类列表
  @Builder
  subBarItemBuilder(barItem: string, index: number) {
    Button(barItem)
      .fontSize($r('sys.float.Body_S'))
      .fontWeight(FontWeight.Regular)
      .fontColor(this.curSubIndex === index ?
      $r('sys.color.font_on_primary') : $r('sys.color.font_primary'))
      .backgroundColor(this.curSubIndex === index ?
      this.themeColor : $r('sys.color.comp_background_tertiary'))
      .onClick(() => {
        this.curSubIndex = index;
        this.scrollStatus = true;
        this.scroller.scrollToIndex(index, true);
        setTimeout(() => {
          this.scrollStatus = false;
        }, 500);

      })
      .controlSize(ControlSize.SMALL)
      .height(Constants.BUTTON_HEIGHT)
      .padding({
        top: Constants.PADDING_XXS,
        right: Constants.PADDING_S,
        bottom: Constants.PADDING_XXS,
        left: Constants.PADDING_S
      })
  }

  @Builder
  productListBuilder() {
    List({ space: Constants.SPACE_L, scroller: this.scroller }) {
      LazyForEach(this.dataSource, (subCategory: SubCategoryItem) => {
        ListItemGroup({
          header: this.listTitleBuilder(subCategory.label),
        }) {
          if (this.layoutType === LayoutType.GRID) {
            ListItem() {
              Grid() {
                ForEach(subCategory.itemList, (gridItem: ItemInfo) => {
                  GridItem() {
                    Column() {
                      this.itemBuilderParam(gridItem)
                    }
                  }
                  .onClick(() => {
                    this.onItemClick(gridItem)
                  })
                }, (gridItem: ItemInfo) => JSON.stringify(gridItem))
              }
              .rowsGap(Constants.SPACE_M)
              .columnsGap(Constants.SPACE_M)
              .columnsTemplate(GridRowColSetting.getColumnsNum(this.breakpoint))
            }
            .width(Constants.FULL_PERCENT)
          } else if (this.layoutType === LayoutType.LIST) {
            ListItem() {
              List({ space: Constants.SPACE_M }) {
                ForEach(subCategory.itemList, (listItem: ItemInfo) => {
                  ListItem() {
                    Column() {
                      this.itemBuilderParam(listItem)
                    }
                  }.onClick(() => {
                    this.onItemClick(listItem)
                  })
                }, (listItem: ItemInfo) => JSON.stringify(listItem))
              }
              .lanes(GridRowColSetting.getListNum(this.breakpoint), Constants.SPACE_M)
              .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
            }
            .width(Constants.FULL_PERCENT)
          }
        }
      }, (subCategory: SubCategoryItem) => JSON.stringify(subCategory.id + subCategory.label))
    }
    .listDirection(Axis.Vertical)
    .layoutWeight(1)
    .height(Constants.FULL_PERCENT)
    .scrollBar(BarState.Off)
    .sticky(StickyStyle.None)
    .onScrollIndex((start: number) => {
      if (!this.scrollStatus) {
        this.curSubIndex = start
        this.subBarScroller.scrollToIndex(start, true)
      }
    })
    .margin({
      top: Constants.PADDING_L,
      right: GridRowColSetting.getPageMargin(this.breakpoint),
    })
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
  }

  @Builder
  listTitleBuilder(title: string) {
    if (title.length) {
      Row() {
        Text(title)
          .fontSize($r('sys.float.Body_M'))
          .fontWeight(FontWeight.Bold)
          .fontColor($r('sys.color.font_primary'))
      }
      .margin({ bottom: this.layoutType === LayoutType.GRID ? Constants.PADDING_M : Constants.PADDING_L })
    }
  }

  @Builder
  itemBuilder(item: ItemInfo) {
    if (this.layoutType === LayoutType.GRID) {
      Image($r(`app.media.${item.imgSrc}`))
        .aspectRatio(1)
        .borderRadius(Constants.BORDER_RADIUS)
      Text(item.title)
        .fontSize($r('sys.float.Body_M'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'))
        .textAlign(TextAlign.Center)
        .maxLines(Constants.FONT_LINES)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .margin({ top: Constants.PADDING_S })
    } else if (this.layoutType === LayoutType.LIST) {
      Row() {
        Image($r(`app.media.${item.imgSrc}`))
          .width(Constants.LIST_IMAGE_WIDTH)
          .height(Constants.LIST_IMAGE_HEIGHT)
          .borderRadius(Constants.BORDER_RADIUS)
          .margin({ right: Constants.SPACE_S })

        Column({ space: Constants.SPACE_XS }) {
          Text(item.title)
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .maxLines(Constants.FONT_LINES)
            .width(Constants.FULL_PERCENT)
          Text(item.description)
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.font_secondary'))
            .maxLines(Constants.FONT_LINES)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width(Constants.FULL_PERCENT)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
    }
  }
}