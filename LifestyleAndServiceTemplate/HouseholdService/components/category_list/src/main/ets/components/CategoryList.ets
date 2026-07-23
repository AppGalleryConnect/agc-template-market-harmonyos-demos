import { Constants, LayoutType } from '../common/Constant';
import { GridRowColSetting } from '../common/GridRowColSetting';
import { BasicDataSource } from '../common/BasicDataSource';
import { CommonUtils, IGoodCategory, IGoodInfo, WindowUtil } from 'module_base'
import { CategoryController } from '../common/Utils';

@ComponentV2
export struct CategoryList {
  // 分类列表
  @Param categoryTabs: IGoodCategory[] = [];
  // 一级选中索引初始值
  @Param initIndex: number = 0;
  // 控制布局方式
  @Param layoutType: LayoutType = LayoutType.GRID;
  @Param themeColor: ResourceColor = '#0A59F7';
  @Param tabBarScroller: Scroller = new Scroller();
  @Param scroller: Scroller = new Scroller();
  @Param controller: CategoryController = new CategoryController();
  @BuilderParam itemBuilderParam: (item: IGoodInfo) => void = this.itemBuilder;
  @Local dataSource: BasicDataSource = new BasicDataSource();
  @Local scrollStatus: boolean = false;
  @Local curIndex: number = 0;
  @Local breakpoint: string = 'sm';
  @Event onTabClick: (tab: IGoodCategory) => void = () => {
  }
  @Event onItemClick: (itemDetail: IGoodInfo) => void = () => {
  }

  aboutToAppear(): void {
    this.scrollToAssignIndex(this.initIndex, false);
    WindowUtil.initWindowUtil(this.getUIContext());
    this.dataSource.setData(this.categoryTabs);
    this.controller.scrollToIndex = (index: number) => {
      this.scrollToAssignIndex(index);
    };
  };

  scrollToAssignIndex(targetIndex: number, status: boolean = true) {
    this.scrollStatus = status;
    this.curIndex = targetIndex;
    this.scroller.scrollToIndex(this.curIndex);
  }

  @Monitor('categoryTabs')
  onProductListChange() {
    this.dataSource.setData(this.categoryTabs);
  }

  build() {
    Row() {
      GridRow(GridRowColSetting.DEFAULT_GRID_ROW_OPTIONS) {
        GridCol({ span: GridRowColSetting.TITLE_COL_SPAN }) {
          Row() {
            List({ scroller: this.tabBarScroller }) {
              ForEach(this.categoryTabs, (item: IGoodCategory, index: number) => {
                ListItem() {
                  this.tabBarItemBuilder(item, index)
                }
              }, (item: IGoodCategory) => JSON.stringify(item.categoryId))
            }
            .edgeEffect(EdgeEffect.Spring, {alwaysEnabled: true})
            .layoutWeight(1)
            .height(Constants.FULL_PERCENT)
            .listDirection(Axis.Vertical)
            .scrollBar(BarState.Off)

            Divider()
              .vertical(true)
              .color($r('sys.color.comp_divider'))
              .strokeWidth(Constants.DIVIDER_WIDTH)
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

  // 一级分类列表
  @Builder
  tabBarItemBuilder(item: IGoodCategory, index: number) {
    Row() {
      Text(item.categoryLabel)
        .fontSize($r('sys.float.Body_M'))
        .fontWeight(this.curIndex === index ? FontWeight.Bold : FontWeight.Regular)
        .fontColor(this.curIndex === index ? $r('sys.color.font_emphasize') : $r('sys.color.font_secondary'))
        .textAlign(TextAlign.Start)
        .maxLines(Constants.FONT_LINES)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .justifyContent(FlexAlign.Start)
    .width(Constants.FULL_PERCENT)
    .height(Constants.TITLE_HEIGHT)
    .margin({ left: GridRowColSetting.getTabMargin(this.breakpoint) })
    .onClick(() => {
      this.scrollStatus = false;
      this.curIndex = index;
      this.scroller.scrollToIndex(this.curIndex);
      this.onTabClick(item);
    })
  }

  @Builder
  productListBuilder() {
    List({ space: Constants.SPACE_L, scroller: this.scroller }) {
      LazyForEach(this.dataSource, (item: IGoodCategory) => {
        ListItemGroup({
          header: this.listTitleBuilder(item.categoryLabel),
        }) {
          if (this.layoutType === LayoutType.GRID) {
            ListItem() {
              Grid() {
                ForEach(item.list, (gridItem: IGoodInfo) => {
                  GridItem() {
                    Column() {
                      this.itemBuilderParam(gridItem)
                    }
                  }
                  .id('allService_' + gridItem.id)
                  .onClick(() => {
                    this.onItemClick(gridItem)
                  })
                }, (gridItem: IGoodInfo) => JSON.stringify(gridItem.id))
              }
              .rowsGap(Constants.SPACE_M)
              .columnsGap(Constants.SPACE_M)
              .columnsTemplate(GridRowColSetting.getColumnsNum(this.breakpoint))
            }
            .width(Constants.FULL_PERCENT)
          } else if (this.layoutType === LayoutType.LIST) {
            ListItem() {
              List({ space: Constants.SPACE_M }) {
                ForEach(item.list, (listItem: IGoodInfo) => {
                  ListItem() {
                    Column() {
                      this.itemBuilderParam(listItem)
                    }
                  }
                  .id('allService_' + listItem.id)
                  .onClick(() => {
                    this.onItemClick(listItem)
                  })
                }, (listItem: IGoodInfo) => JSON.stringify(listItem.id))
              }
              .lanes(GridRowColSetting.getListNum(this.breakpoint), Constants.SPACE_M)
            }
            .width(Constants.FULL_PERCENT)
          }
        }
      }, (item: IGoodCategory) => JSON.stringify(item.categoryId + item.categoryLabel))
    }
    .listDirection(Axis.Vertical)
    .layoutWeight(1)
    .height(Constants.FULL_PERCENT)
    .scrollBar(BarState.Off)
    .sticky(StickyStyle.None)
    .onScrollIndex((start: number) => {
      if (!this.scrollStatus) {
        this.scroller.scrollToIndex(this.curIndex);
        this.scrollStatus = true;
      } else {
        this.curIndex = start;
        this.tabBarScroller.scrollToIndex(start, true);
      }
    })
    .margin({
      top: Constants.PADDING_L,
      left: Constants.PADDING_S,
      right: GridRowColSetting.getPageMargin(this.breakpoint),
    })
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
  itemBuilder(item: IGoodInfo) {
    if (this.layoutType === LayoutType.GRID) {
      Image(CommonUtils.handleImgUrl(item.image))
        .aspectRatio(1)
        .borderRadius(Constants.BORDER_RADIUS)
        .alt($r('app.media.ic_placeholder_img'))
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
        Image(CommonUtils.handleImgUrl(item.image))
          .width(Constants.LIST_IMAGE_WIDTH)
          .height(Constants.LIST_IMAGE_HEIGHT)
          .borderRadius(Constants.BORDER_RADIUS)
          .alt($r('app.media.ic_placeholder_img'))
          .margin({ right: Constants.SPACE_S })

        Column({ space: Constants.SPACE_XS }) {
          Text(item.title)
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .maxLines(Constants.FONT_LINES)
            .width(Constants.FULL_PERCENT)
          Text(item.subTitle)
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