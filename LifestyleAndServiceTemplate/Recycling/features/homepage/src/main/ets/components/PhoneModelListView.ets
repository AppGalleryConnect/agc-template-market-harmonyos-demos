import {
  BasicDataSource,
  Constants,
  GridRowColSetting,
  LayoutType,
  ModelItemContentInfo,
  ModelItemInfo
} from 'category_list';
import { CommonPageVM } from '../viewmodel/CommonPageVM';

/**
 * @usage: 手机型号列表组件，用于展示手机品牌和型号的二级分类列表，支持网格和列表两种布局方式。
 * @layout: 采用水平布局（Row），左侧为一级品牌分类列表，右侧为型号网格/列表。
 * @constraints: 需要传入 CommonPageVM 类型的视图模型和 productList 型号数据。
 * @isGen: true
 * @fileType: component
 * @zhName: 手机型号列表组件
 * @image: screenshots/homepage/phoneModelListView.png
 */

@ComponentV2
export struct PhoneModelListView {
  @Require @Param vm: CommonPageVM
  // 子列表
  @Param productList: ModelItemInfo[] = []
  // 一级选中索引初始值
  @Param initIndex: number = 0;
  // 控制布局方式
  @Param layoutType: LayoutType = LayoutType.GRID;
  @Param themeColor: ResourceColor = 'rgba(255, 75, 75, 1)';
  @Param tabBarScroller: Scroller = new Scroller();
  @Param subBarScroller: Scroller = new Scroller();
  @Param scroller: Scroller = new Scroller();
  // 当前的选中项
  @Param currentSelectItem: string = ''
  @BuilderParam itemBuilderParam: (item: string) => void = this.itemBuilder;
  @Local dataSource: BasicDataSource = new BasicDataSource()
  @Local curIndex: number = this.initIndex;
  @Local curSubIndex: number = 0;
  @Local curItemIndex: number = 0;
  @Local curAllList: ModelItemInfo[][] = [];
  @Local curSectionList: ModelItemInfo[] = [];
  @Local breakpoint: string = 'sm';
  @Local scrollStatus: boolean = false;
  @Event onTabClick: (tab: ModelItemInfo) => void = () => {
  }
  @Event onItemClick: (itemContent: string, itemDetail: ModelItemContentInfo) => void = () => {
  }

  @Monitor('curIndex')
  onProductListChange() {
    this.dataSource.setData(this.productList[this.curIndex].content);
  }

  aboutToAppear(): void {
    this.dataSource.setData(this.productList[this.curIndex].content);
  };

  build() {
    Row() {
      GridRow(GridRowColSetting.DEFAULT_GRID_ROW_OPTIONS) {
        GridCol({ span: GridRowColSetting.TITLE_COL_SPAN }) {
          Row() {
            List({ scroller: this.tabBarScroller }) {
              ForEach(this.productList, (product: ModelItemInfo, index: number) => {
                ListItem() {
                  this.tabBarItemViewBuilder(product, index)
                }
              }, (product: ModelItemInfo) => JSON.stringify(product.label))
            }
            .width(80)
            .height(Constants.FULL_PERCENT)
            .listDirection(Axis.Vertical)
            .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
            .layoutWeight(1)
            .scrollBar(BarState.Off)
            .borderRadius({ topRight: 8 })
            .padding({ top: 2 })
            .backgroundColor('rgba(0, 0, 0, 0.05)')

          }
          .justifyContent(FlexAlign.SpaceBetween)
          .margin({ top: Constants.PADDING_S * 3 })

        }

        GridCol({ span: GridRowColSetting.SUBTITLE_COL_SPAN }) {
          Column() {
            this.productListViewBuilder()
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
  tabBarItemViewBuilder(item: ModelItemInfo, index: number) {
    Row() {
      Text(item.label)
        .fontSize(14)
        .backgroundColor(this.curIndex === index ? 'rgba(255, 255, 255, 1)' : 'rgba(0, 0, 0, 0)')
        .textAlign(TextAlign.Center)
        .maxLines(Constants.FONT_LINES)
        .borderRadius(8)
        .layoutWeight(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .height(56)
        .margin({ left: 2, right: 2 })
        .fontWeight(this.curIndex === index ? FontWeight.Medium : FontWeight.Regular)
        .fontColor(this.curIndex === index ? this.themeColor : 'rgba(0, 0, 0, 0.6)')
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .width('100%')
    .height(56)
    .onClick(() => {
      this.curIndex = index;
      this.curItemIndex = 0;
      this.curSubIndex = 0;
      this.subBarScroller.scrollToIndex(this.curSubIndex)
      this.scroller.scrollToIndex(this.curItemIndex)
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
      .height(Constants.BUTTON_HEIGHT)
      .controlSize(ControlSize.SMALL)
      .padding({
        bottom: Constants.PADDING_XXS,
        right: Constants.PADDING_S,
        top: Constants.PADDING_XXS,
        left: Constants.PADDING_S
      })
  }

  @Builder
  productListViewBuilder() {
    List({ space: Constants.SPACE_L, scroller: this.scroller }) {
      LazyForEach(this.dataSource, (data: ModelItemContentInfo, index: number) => {
        ListItemGroup({
          header: this.listTitleBuilder(data, index),
        }) {
          if (this.layoutType === LayoutType.GRID) {
            ListItem() {
              Grid() {
                ForEach(data.content, (gridItem: string) => {
                  GridItem() {
                    Column() {
                      this.itemBuilderParam(gridItem)
                    }
                  }
                  .onClick(() => {
                    this.onItemClick(gridItem, data)
                  })
                }, (gridItem: ModelItemContentInfo) => JSON.stringify(gridItem))
              }
              .rowsGap(Constants.SPACE_S)
              .columnsGap(Constants.SPACE_S)
              .columnsTemplate('1fr 1fr')
            }
            .width(Constants.FULL_PERCENT)
          } else if (this.layoutType === LayoutType.LIST) {
            ListItem() {
              List({ space: Constants.SPACE_M }) {
                ForEach(data.content, (listItem: string) => {
                  ListItem() {
                    Column() {
                      this.itemBuilderParam(listItem)
                    }
                  }.onClick(() => {
                    this.onItemClick(listItem, data)
                  })
                }, (listItem: ModelItemContentInfo) => JSON.stringify(listItem))
              }
              .lanes(GridRowColSetting.getListNum(this.breakpoint), Constants.SPACE_M)
              .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
            }
            .width(Constants.FULL_PERCENT)
          }
        }
      }, (data: ModelItemContentInfo) => JSON.stringify(data.title))
    }
    .listDirection(Axis.Vertical)
    .scrollBar(BarState.Off)
    .sticky(StickyStyle.None)
    .layoutWeight(1)
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
  listTitleBuilder(item: ModelItemContentInfo, index: number) {
    if (item.title.length) {
      Column() {
        if (index === 0) {
          Text(item.title)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('rgba(0, 0, 0, 1)')
        } else {
          Text(item.title)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('rgba(0, 0, 0, 0.9)')

          if (item.description && item.description.length) {
            Text(item.description)
              .fontSize(12)
              .fontWeight(FontWeight.Regular)
              .fontColor('rgba(0, 0, 0, 0.4)')
              .margin({ top: 4 })
          }

        }
      }
      .height(56)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Start)
    }
  }

  @Builder
  itemBuilder(item: string) {
    Column() {
      Text(item)
        .fontSize(14)
        .fontColor(this.currentSelectItem === item ? 'rgba(255, 75, 75, 1)' : 'rgba(0, 0, 0, 1)')
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .height(44)
    .borderRadius(8)
    .backgroundColor(this.currentSelectItem === item ? 'rgba(255, 75, 75, 0.1)' : 'rgba(0, 0, 0, 0.05)')
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .padding({
      left: 8,
      right: 8,
      top: 4,
      bottom: 4
    })
  }
}