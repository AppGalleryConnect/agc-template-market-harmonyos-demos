import { CategoryBasicDataSource, CategoryItem, ItemInfo, SubCategoryItem } from 'category_list';
import { Constants, LayoutType } from 'category_list';
import { GridRowColSetting } from 'category_list';
import { BreakpointModel } from 'common';
import { AppStorageV2 } from '@kit.ArkUI';

@ComponentV2
export struct CategoryListView {
  // 分类列表
  @Param categoryTabs: CategoryItem[] = [];
  // 子列表
  @Param productList: SubCategoryItem[] = []
  // 一级选中索引初始值
  @Param initIndex: number = 0;
  // 控制布局方式
  @Param layoutType: LayoutType = LayoutType.GRID;
  @Param themeColor: ResourceColor = 'rgba(255, 75, 75, 1)';
  @Param tabBarScroller: Scroller = new Scroller();
  @Param subBarScroller: Scroller = new Scroller();
  @Param scroller: Scroller = new Scroller();
  @BuilderParam itemBuilderParam: (item: ItemInfo) => void = this.itemBuilder;
  @Local dataSource: CategoryBasicDataSource = new CategoryBasicDataSource()
  @Local breakpoint: string = 'sm';
  @Local scrollStatus: boolean = false;
  @Event onTabClick: (tab: CategoryItem) => void = () => {
  }
  @Event onItemClick: (itemDetail: ItemInfo, item: SubCategoryItem) => void = () => {
  }
  @Local curIndex: number = this.initIndex;
  @Local curSubIndex: number = 0;
  @Local curItemIndex: number = 0;
  @Local curAllList: ItemInfo[][] = [];
  @Local curSectionList: ItemInfo[] = [];
  // Grid双列字符串
  @Local gridThreeColumnsModel: string = GridRowColSetting.getColumnCountModel(3)
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;

  aboutToAppear(): void {
    this.dataSource.setData(this.productList);
  };

  @Monitor('productList')
  onProductListChange() {
    this.dataSource.setData(this.productList);
  }

  @Monitor('breakPointModel.currentBreakpoint')
  breakPointChange() {
    this.gridThreeColumnsModel = GridRowColSetting.getColumnCountModel(3)
  }

  build() {
    Row() {
      GridRow(GridRowColSetting.DEFAULT_GRID_ROW_OPTIONS) {
        GridCol({ span: GridRowColSetting.TITLE_COL_SPAN }) {
          Row() {
            List({ scroller: this.tabBarScroller }) {
              ForEach(this.categoryTabs, (item: CategoryItem, index: number) => {
                ListItem() {
                  this.tabBarItemBuilder(item, index)
                }
              }, (item: CategoryItem) => JSON.stringify(item.id))
            }
            .width(80)
            .height(Constants.FULL_PERCENT)
            .listDirection(Axis.Vertical)
            .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
            .layoutWeight(1)
            .backgroundColor('rgba(0, 0, 0, 0.05)')
            .scrollBar(BarState.Off)
            .borderRadius({ topRight: 8 })
            .padding({ top: 2 })

          }
          .justifyContent(FlexAlign.SpaceBetween)
          .margin({ top: Constants.PADDING_S * 3 })

        }

        GridCol({ span: GridRowColSetting.SUBTITLE_COL_SPAN }) {
          Column() {
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
    .layoutWeight(1)
  }

  // 一级分类列表
  @Builder
  tabBarItemBuilder(item: CategoryItem, index: number) {
    Row() {
      Text(item.label)
        .borderRadius(8)
        .layoutWeight(1)
        .height(56)
        .textAlign(TextAlign.Center)
        .maxLines(Constants.FONT_LINES)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .margin({ left: 2, right: 2 })
        .fontSize(14)
        .fontWeight(this.curIndex === index ? FontWeight.Medium : FontWeight.Regular)
        .fontColor(this.curIndex === index ? this.themeColor : 'rgba(0, 0, 0, 0.6)')
        .backgroundColor(this.curIndex === index ? 'rgba(255, 255, 255, 1)' : 'rgba(0, 0, 0, 0)')
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      this.curIndex = index;
      this.curSubIndex = 0;
      this.curItemIndex = 0;
      this.subBarScroller.scrollToIndex(this.curSubIndex)
      this.scroller.scrollToIndex(this.curItemIndex)
      this.onTabClick(item);
    })
    .width('100%')
    .height(56)
  }

  // 二级分类列表
  @Builder
  subBarItemBuilder(item: string, index: number) {
    Button(item)
      .fontColor(this.curSubIndex === index ?
      $r('sys.color.font_on_primary') : $r('sys.color.font_primary'))
      .backgroundColor(this.curSubIndex === index ?
      this.themeColor : $r('sys.color.comp_background_tertiary'))
      .fontSize($r('sys.float.Body_S'))
      .fontWeight(FontWeight.Regular)
      .onClick(() => {
        this.scrollStatus = true;
        this.curSubIndex = index;
        this.scroller.scrollToIndex(index, true);
        setTimeout(() => {
          this.scrollStatus = false;
        }, 500);

      })
      .padding({
        top: Constants.PADDING_XXS,
        bottom: Constants.PADDING_XXS,
        right: Constants.PADDING_S,
        left: Constants.PADDING_S
      })
      .controlSize(ControlSize.SMALL)
      .height(Constants.BUTTON_HEIGHT)
  }

  @Builder
  productListBuilder() {
    List({ space: Constants.SPACE_L, scroller: this.scroller }) {
      LazyForEach(this.dataSource, (item: SubCategoryItem) => {
        ListItemGroup({
          header: this.listTitleBuilder(item.label),
        }) {
          if (this.layoutType === LayoutType.GRID) {
            ListItem() {
              Grid() {
                ForEach(item.itemList, (gridItem: ItemInfo) => {
                  GridItem() {
                    Column() {
                      this.itemBuilderParam(gridItem)
                    }
                  }
                  .onClick(() => {
                    this.onItemClick(gridItem, item)
                  })
                }, (gridItem: ItemInfo) => JSON.stringify(gridItem))
              }
              .rowsGap(Constants.SPACE_M)
              .columnsTemplate(this.gridThreeColumnsModel)
            }
            .width(Constants.FULL_PERCENT)
          } else if (this.layoutType === LayoutType.LIST) {
            ListItem() {
              List({ space: Constants.SPACE_M }) {
                ForEach(item.itemList, (listItem: ItemInfo) => {
                  ListItem() {
                    Column() {
                      this.itemBuilderParam(listItem)
                    }
                  }.onClick(() => {
                    this.onItemClick(listItem, item)
                  })
                }, (listItem: ItemInfo) => JSON.stringify(listItem))
              }
              .lanes(GridRowColSetting.getListNum(this.breakpoint), Constants.SPACE_M)
              .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
            }
            .width(Constants.FULL_PERCENT)
          }
        }
      }, (item: SubCategoryItem) => JSON.stringify(item.id + item.label))
    }
    .listDirection(Axis.Vertical)
    .layoutWeight(1)
    .scrollBar(BarState.Off)
    .sticky(StickyStyle.None)
    .onScrollIndex((start: number) => {
      if (!this.scrollStatus) {
        this.curSubIndex = start
        this.subBarScroller.scrollToIndex(start, true)
      }
    })
    .margin({
      top: Constants.PADDING_S * 3,
      right: GridRowColSetting.getPageMargin(this.breakpoint),
    })
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
  }

  @Builder
  listTitleBuilder(title: string) {
    if (title.length) {
      Row() {
        Text(title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('rgba(0, 0, 0, 1)')
      }
      .height(56)
      .justifyContent(FlexAlign.Start)
      .alignItems(VerticalAlign.Center)
    }
  }

  @Builder
  itemBuilder(item: ItemInfo) {
    if (this.layoutType === LayoutType.GRID) {
      Image($r(`app.media.${item.imgSrc}`))
        .aspectRatio(1)
        .borderRadius(Constants.BORDER_RADIUS)
      Text(item.title)
        .fontSize(12)
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