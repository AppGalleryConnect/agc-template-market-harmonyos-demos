import {
  CategoryBasicDataSource,
  CategoryItem,
  Constants,
  GridRowColSetting,
  ItemInfo,
  LayoutType,
  SubCategoryItem
} from 'category_list';

@ComponentV2
export struct CategoryListCommonView {
  // 分类列表
  @Param categoryTabs: CategoryItem[] = [];
  // 子列表
  @Param productList: SubCategoryItem[] = []
  // 一级选中索引初始值
  @Param initIndex: number = 0;
  // 控制布局方式
  @Param layoutType: LayoutType = LayoutType.GRID;
  @Param themeColor: ResourceColor = '#0A59F7';
  @Param tabBarScroller: Scroller = new Scroller();
  @Param subBarScroller: Scroller = new Scroller();
  @Param scroller: Scroller = new Scroller();
  @BuilderParam itemBuilderParam: (item: ItemInfo) => void = this.itemBuilder;
  @Local dataSource: CategoryBasicDataSource = new CategoryBasicDataSource()
  @Local curAllList: ItemInfo[][] = [];
  @Local curSectionList: ItemInfo[] = [];
  @Local curIndex: number = this.initIndex;
  @Local curItemIndex: number = 0;
  @Local curSubIndex: number = 0;
  @Local scrollStatus: boolean = false;
  @Local breakpoint: string = 'sm';
  @Event onItemClick: (itemDetail: ItemInfo) => void = () => {
  }
  @Event onTabClick: (tab: CategoryItem) => void = () => {
  }

  @Monitor('productList')
  onProductListChange() {
    this.dataSource.setData(this.productList);
  }

  aboutToAppear(): void {
    this.dataSource.setData(this.productList);
  };

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
            .borderRadius({ topRight: 8 })
            .height(Constants.FULL_PERCENT)
            .padding({ top: 2 })
            .scrollBar(BarState.Off)
            .listDirection(Axis.Vertical)
            .backgroundColor('rgba(0, 0, 0, 0.05)')
            .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })

          }
          .justifyContent(FlexAlign.SpaceBetween)

        }

        GridCol({ span: GridRowColSetting.SUBTITLE_COL_SPAN }) {
          Column() {
            List({ space: Constants.SPACE_S, scroller: this.subBarScroller }) {
              LazyForEach(this.dataSource, (item: SubCategoryItem, index: number) => {
                ListItem() {
                  this.subBarItemBuilder(item.label, index)
                }
              }, (item: SubCategoryItem) => JSON.stringify(item.id))
            }
            .height(Constants.BUTTON_HEIGHT)
            .width(Constants.FULL_PERCENT)
            .listDirection(Axis.Horizontal)
            .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
            .scrollBar(BarState.Off)

            this.productListBuilder()
          }
          .layoutWeight(1)
        }
      }
      .onBreakpointChange((bp: string) => {
        this.breakpoint = bp;
      })
    }
    .height(Constants.FULL_PERCENT)
    .width(Constants.FULL_PERCENT)
    .padding({
      left: GridRowColSetting.getPageMargin(this.breakpoint),
    })
  }

  // 一级分类列表
  @Builder
  tabBarItemBuilder(item: CategoryItem, index: number) {
    Row() {
      Text(item.label)
        .fontSize(12)
        .fontWeight(this.curIndex === index ? FontWeight.Medium : FontWeight.Regular)
        .backgroundColor(this.curIndex === index ? 'rgba(255, 255, 255, 1)' : 'rgba(0, 0, 0, 0)')
        .textAlign(TextAlign.Center)
        .fontColor(this.curIndex === index ? this.themeColor : 'rgba(0, 0, 0, 0.6)')
        .maxLines(Constants.FONT_LINES)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .height(54)
        .margin({ left: 2, right: 2 })
        .borderRadius(8)
        .layoutWeight(1)
    }
    .width('100%')
    .height(56)
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      this.curIndex = index;
      this.curItemIndex = 0;
      this.curSubIndex = 0;
      this.scroller.scrollToIndex(this.curItemIndex)
      this.subBarScroller.scrollToIndex(this.curSubIndex)
      this.onTabClick(item);
    })
  }

  // 二级分类列表
  @Builder
  subBarItemBuilder(item: string, index: number) {
    Button(item)
      .fontWeight(FontWeight.Regular)
      .fontSize($r('sys.float.Body_S'))
      .fontColor(this.curSubIndex === index ?
      $r('sys.color.font_on_primary') : $r('sys.color.font_primary'))
      .backgroundColor(this.curSubIndex === index ?
      this.themeColor : $r('sys.color.comp_background_tertiary'))
      .onClick(() => {
        this.scrollStatus = true;
        this.curSubIndex = index;
        this.scroller.scrollToIndex(index, true);
        setTimeout(() => {
          this.scrollStatus = false;
        }, 500);

      })
      .controlSize(ControlSize.SMALL)
      .padding({
        top: Constants.PADDING_XXS,
        bottom: Constants.PADDING_XXS,
        right: Constants.PADDING_S,
        left: Constants.PADDING_S
      })
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
                    this.onItemClick(gridItem)
                  })
                }, (gridItem: ItemInfo) => JSON.stringify(gridItem))
              }
              .rowsGap(Constants.SPACE_M)
              .columnsTemplate(GridRowColSetting.getColumnsNum(this.breakpoint))
              .columnsGap(Constants.SPACE_M)
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
                    this.onItemClick(listItem)
                  })
                }, (listItem: ItemInfo) => JSON.stringify(listItem))
              }
              .lanes(GridRowColSetting.getListNum(this.breakpoint), Constants.SPACE_M)
              .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
            }
            .width(Constants.FULL_PERCENT)
          }
        }
      }, (item: SubCategoryItem) => JSON.stringify(item.id + item.label))
    }
    .scrollBar(BarState.Off)
    .listDirection(Axis.Vertical)
    .height(Constants.FULL_PERCENT)
    .sticky(StickyStyle.None)
    .layoutWeight(1)
    .margin({
      top: Constants.PADDING_L,
      right: GridRowColSetting.getPageMargin(this.breakpoint),
    })
    .onScrollIndex((start: number) => {
      if (!this.scrollStatus) {
        this.curSubIndex = start
        this.subBarScroller.scrollToIndex(start, true)
      }
    })
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
  }

  @Builder
  listTitleBuilder(title: string) {
    if (title.length) {
      Row() {
        Text(title)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('sys.color.font_primary'))
          .fontSize($r('sys.float.Body_M'))
      }
      .margin({ bottom: this.layoutType === LayoutType.GRID ? Constants.PADDING_M : Constants.PADDING_L })
    }
  }

  @Builder
  itemBuilder(item: ItemInfo) {
    if (this.layoutType === LayoutType.GRID) {
      Image($r(`app.media.${item.imgSrc}`))
        .borderRadius(Constants.BORDER_RADIUS)
        .aspectRatio(1)
      Text(item.title)
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium)
        .textAlign(TextAlign.Center)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .maxLines(Constants.FONT_LINES)
        .margin({ top: Constants.PADDING_S })
    } else if (this.layoutType === LayoutType.LIST) {
      Row() {
        Image($r(`app.media.${item.imgSrc}`))
          .width(Constants.LIST_IMAGE_WIDTH)
          .margin({ right: Constants.SPACE_S })
          .borderRadius(Constants.BORDER_RADIUS)
          .height(Constants.LIST_IMAGE_HEIGHT)

        Column({ space: Constants.SPACE_XS }) {
          Text(item.title)
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Medium)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width(Constants.FULL_PERCENT)
            .maxLines(Constants.FONT_LINES)
          Text(item.description)
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('sys.color.font_secondary'))
            .maxLines(Constants.FONT_LINES)
            .fontWeight(FontWeight.Regular)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width(Constants.FULL_PERCENT)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
    }
  }
}