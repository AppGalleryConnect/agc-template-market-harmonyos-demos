import { CategoryItem, ItemInfo } from '../types/Index';
import { Constants, LayoutType } from '../common/Constant';
import { GridRowColSetting } from '../common/GridRowColSetting';


@ComponentV2
export struct CategoryList {
  // 分类列表
  @Param categoryTabs: CategoryItem[] = [];
  // 子列表
  @Param productList: ItemInfo[] = []
  // 一级选中索引初始值
  @Param @Require initIndex: number
  @Param @Require initSubIndex: number
  @Param hotelListNum: number = 0
  // 控制布局方式
  @Param layoutType: LayoutType = LayoutType.GRID;
  @Param themeColor: ResourceColor = '#0A59F7';
  @Param tabBarScroller: Scroller = new Scroller();
  @Param subBarScroller: Scroller = new Scroller();
  @Param scroller: Scroller = new Scroller();
  @Local curAllList: ItemInfo[][] = [];
  @Local curSectionList: ItemInfo[] = [];
  @Local breakpoint: string = 'sm';
  @Local scrollStatus: boolean = false;
  @Event onTabClick: (tab: CategoryItem, index: number) => void = () => {
  }
  @Event onSearch: (itemDetail: ItemInfo) => void = () => {
  }
  @Event clear: () => void = () => {
  }
  @Event onTabClickItem: (index: number) => void = () => {
  }

  build() {
    Column() {
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
              .layoutWeight(1)
              .height(Constants.FULL_PERCENT)
              .listDirection(Axis.Vertical)
              .scrollBar(BarState.Off)
              .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
            }
            .justifyContent(FlexAlign.SpaceBetween)
            .margin({ top: Constants.PADDING_S })
          }.backgroundColor('#F3F3F3')

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
      .layoutWeight(1)

      Row() {
        Text('清空')
          .fontSize(14)
          .fontColor('#333333')
          .fontWeight(500)
          .padding({
            top: 12,
            left: 27,
            bottom: 12,
            right: 27
          })
          .borderWidth(0.5)
          .borderRadius(24)
          .borderColor('rgba(0, 0, 0, 0.10)')
          .onClick(() => {
            this.clear()
          })
        Column() {
          Text('查看酒店').fontSize(14).fontColor('#333333').fontWeight(500)
        }
        .onClick(() => {
          this.onSearch(this.productList[this.initSubIndex])
        })
        .margin({ left: 10 })
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .layoutWeight(1)
        .height(40)
        .backgroundColor('#FEE231')
        .borderRadius(24)
      }.height(60).justifyContent(FlexAlign.SpaceBetween).padding({ left: 16, right: 16 })
    }.borderRadius({ bottomLeft: 24, bottomRight: 24 }).backgroundColor('#FFFFFF')
  }

  // 一级分类列表
  @Builder
  tabBarItemBuilder(item: CategoryItem, index: number) {
    Row() {
      Text(item.label)
        .fontSize($r('sys.float.Body_M'))
        .fontWeight(this.initIndex === index ? FontWeight.Bold : FontWeight.Regular)
        .fontColor(this.initIndex === index ? this.themeColor : '#A7A7A7')
        .textAlign(TextAlign.Start)
        .maxLines(Constants.FONT_LINES)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .justifyContent(FlexAlign.Start)
    .width(Constants.FULL_PERCENT)
    .height(Constants.TITLE_HEIGHT)
    .padding({ left: GridRowColSetting.getPageMargin(this.breakpoint) })
    .margin({ left: GridRowColSetting.getTabMargin(this.breakpoint) })
    .onClick(() => {
      if (this.initIndex === index) {
        return
      } else {
        this.onTabClick(item, index);
      }
    })
  }

  @Builder
  productListBuilder() {
    List({ scroller: this.scroller }) {
      ForEach(this.productList, (item: ItemInfo, index: number) => {
        ListItem() {
          this.itemBuilder(item, index)
        }
      }, (item: ItemInfo) => JSON.stringify(item))
    }
    .width('100%')
    .listDirection(Axis.Vertical)
    .layoutWeight(1)
    .height('100%')
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
  }

  @Builder
  itemBuilder(item: ItemInfo, index: number) {
    Row() {
      Text(item.title)
        .fontWeight(this.initSubIndex === index ? FontWeight.Bold : FontWeight.Regular)
        .fontColor(this.initSubIndex === index ? this.themeColor : '#A7A7A7')
        .fontSize($r('sys.float.Body_M'))
        .textAlign(TextAlign.Center)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      if (this.initSubIndex === index) {
        Image($r('app.media.ic_choose')).width(20).height(20)
      }
    }
    .padding({ left: 10, right: 22 })
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
    .width('100%')
    .height(52)
    .onClick(() => {
      this.onTabClickItem(index)
    })
  }
}