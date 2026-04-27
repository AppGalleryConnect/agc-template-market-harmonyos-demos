import { ModelItemContentInfo, ModelItemInfo } from 'category_list';
import { Constants, LayoutType } from 'category_list';
import { GridRowColSetting } from 'category_list';
import { BasicDataSource } from 'category_list';
import { CommonPageVM } from '../viewmodel/CommonPageVM';

@ComponentV2
export struct CameraModelListView {
  @Require @Param vm: CommonPageVM
  // 子列表
  @Param productList: ModelItemInfo[] = []
  // 一级选中索引初始值
  @Param initIndex: number = 0;
  // 控制布局方式
  @Param layoutType: LayoutType = LayoutType.GRID;
  @Param subBarScroller: Scroller = new Scroller();
  @Param scroller: Scroller = new Scroller();
  @Param themeColor: ResourceColor = 'rgba(255, 75, 75, 1)';
  @Param tabBarScroller: Scroller = new Scroller();
  // 当前的选中项
  @Param currentSelectItem: string = ''
  @BuilderParam itemBuilderParam: (item: string) => void = this.itemBuilder;
  @Local dataSource: BasicDataSource = new BasicDataSource()
  @Local curSubIndex: number = 0;
  @Local curItemIndex: number = 0;
  @Local curIndex: number = this.initIndex;
  // 相机类型下标
  @Local cameraTypeIndex: number = 0;
  @Local curAllList: ModelItemInfo[][] = [];
  @Local curSectionList: ModelItemInfo[] = [];
  @Local breakpoint: string = 'sm';
  // 相机类型
  @Local cameraType: string[] = ['单反', '微单', '数码']
  @Local scrollStatus: boolean = false;
  @Event onItemClick: (itemContent: string, cameraType: string) => void = () => {
  }
  @Event onTabClick: (tab: ModelItemInfo) => void = () => {
  }

  aboutToAppear(): void {
    this.dataSource.setData(this.productList[this.curIndex].content);
  };

  @Monitor('curIndex')
  onProductListChange() {
    this.dataSource.setData(this.productList[this.curIndex].content);
  }

  build() {
    Row() {
      GridRow(GridRowColSetting.DEFAULT_GRID_ROW_OPTIONS) {
        GridCol({ span: GridRowColSetting.TITLE_COL_SPAN }) {
          Row() {
            List({ scroller: this.tabBarScroller }) {
              ForEach(this.productList, (item: ModelItemInfo, index: number) => {
                ListItem() {
                  this.tabBarItemBuilder(item, index)
                }
              }, (item: ModelItemInfo) => JSON.stringify(item.label))
            }
            .width(80)
            .height(Constants.FULL_PERCENT)
            .listDirection(Axis.Vertical)
            .padding({ top: 2 })
            .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
            .layoutWeight(1)
            .backgroundColor('rgba(0, 0, 0, 0.05)')
            .scrollBar(BarState.Off)
            .borderRadius({ topRight: 8 })

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
  tabBarItemBuilder(item: ModelItemInfo, index: number) {
    Row() {
      Text(item.label)
        .fontSize(14)
        .fontWeight(this.curIndex === index ? FontWeight.Medium : FontWeight.Regular)
        .fontColor(this.curIndex === index ? this.themeColor : 'rgba(0, 0, 0, 0.6)')
        .backgroundColor(this.curIndex === index ? 'rgba(255, 255, 255, 1)' : 'rgba(0, 0, 0, 0)')
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .borderRadius(8)
        .layoutWeight(1)
        .textAlign(TextAlign.Center)
        .maxLines(Constants.FONT_LINES)
        .height(56)
        .margin({ left: 2, right: 2 })
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .width('100%')
    .height(56)
    .onClick(() => {
      this.curItemIndex = 0;
      this.curIndex = index;
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
      .fontSize($r('sys.float.Body_S'))
      .fontWeight(FontWeight.Regular)
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
      .height(Constants.BUTTON_HEIGHT)
      .padding({
        right: Constants.PADDING_S,
        left: Constants.PADDING_S,
        top: Constants.PADDING_XXS,
        bottom: Constants.PADDING_XXS,
      })
  }

  @Builder
  productListBuilder() {
    Row() {
      Row() {
        ForEach(this.cameraType, (item: string, index: number) => {
          Text(item)
            .height(28)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
            .fontColor(this.cameraTypeIndex === index ? 'rgba(255, 255, 255, 1)' : 'rgba(0, 0, 0, 0.6)')
            .backgroundColor(this.cameraTypeIndex === index ? 'rgba(255, 75, 75, 1)' : 'rgba(0, 0, 0, 0.0)')
            .borderRadius(20)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .onClick(() => {
              // 如果当前选择不同的相机类型，则清空选择
              if (this.cameraTypeIndex !== index) {
                this.cameraTypeIndex = index
                return
              }
            })
        }, (item: string, index: number) => JSON.stringify(item) + index)
      }
      .layoutWeight(1)
      .height(28)
      .borderRadius(20)
      .backgroundColor('rgba(0, 0, 0, 0.05)')
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
    .height(40)
    .margin({ bottom: 12, top: Constants.PADDING_S * 3, right: GridRowColSetting.getPageMargin(this.breakpoint) })
    .alignItems(VerticalAlign.Center)

    List({ space: Constants.SPACE_L, scroller: this.scroller }) {
      LazyForEach(this.dataSource, (item: ModelItemContentInfo, index: number) => {
        ListItemGroup({
          header: this.listTitleBuilder(item, index),
        }) {
          if (this.layoutType === LayoutType.GRID) {
            ListItem() {
              Grid() {
                ForEach(item.content, (gridItem: string) => {
                  GridItem() {
                    Column() {
                      this.itemBuilderParam(gridItem)
                    }
                  }
                  .onClick(() => {
                    this.onItemClick(gridItem, this.cameraType[this.cameraTypeIndex])
                  })
                }, (gridItem: ModelItemContentInfo) => JSON.stringify(gridItem))
              }
              .columnsGap(Constants.SPACE_S)
              .rowsGap(Constants.SPACE_S)
              .columnsTemplate('1fr 1fr')
            }
            .width(Constants.FULL_PERCENT)
          } else if (this.layoutType === LayoutType.LIST) {
            ListItem() {
              List({ space: Constants.SPACE_M }) {
                ForEach(item.content, (listItem: string) => {
                  ListItem() {
                    Column() {
                      this.itemBuilderParam(listItem)
                    }
                  }.onClick(() => {
                    this.onItemClick(listItem, this.cameraType[this.cameraTypeIndex])
                  })
                }, (listItem: ModelItemContentInfo) => JSON.stringify(listItem))
              }
              .lanes(GridRowColSetting.getListNum(this.breakpoint), Constants.SPACE_M)
              .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
            }
            .width(Constants.FULL_PERCENT)
          }
        }
      }, (item: ModelItemContentInfo) => JSON.stringify(item.title))
    }
    .listDirection(Axis.Vertical)
    .scrollBar(BarState.Off)
    .layoutWeight(1)
    .sticky(StickyStyle.None)
    .onScrollIndex((start: number) => {
      if (!this.scrollStatus) {
        this.curSubIndex = start
        this.subBarScroller.scrollToIndex(start, true)
      }
    })
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
    .margin({
      right: GridRowColSetting.getPageMargin(this.breakpoint),
    })
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
            .fontColor('rgba(0, 0, 0, 0.9)')
            .fontWeight(FontWeight.Medium)

          if (item.description && item.description.length) {
            Text(item.description)
              .fontSize(14)
              .fontWeight(FontWeight.Regular)
              .fontColor('rgba(0, 0, 0, 0.4)')
              .margin({ top: 4 })
          }

        }
      }
      .height(56)
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Center)
    }
  }

  @Builder
  itemBuilder(item: string) {
    Column() {
      Text(item)
        .fontSize(14)
        .fontColor(this.getCurrentFontColor(item))
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .height(44)
    .borderRadius(8)
    .backgroundColor(this.getCurrentBackgroundColor(item))
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .padding({
      left: 8,
      right: 8,
      top: 4,
      bottom: 4
    })
  }

  // 获取当前的字体颜色
  getCurrentFontColor(item: string) {
    let isFontColor: boolean = false
    const items: string[] = this.currentSelectItem.split('-')
    if (items.length > 1) {
      isFontColor = items[0] === item && items[1] === this.cameraType[this.cameraTypeIndex]
    }
    return isFontColor ? 'rgba(255, 75, 75, 1)' : 'rgba(0, 0, 0, 1)'
  }

  // 获取当前的背景颜色
  getCurrentBackgroundColor(item: string) {
    let isBackgroundColor: boolean = false
    const items: string[] = this.currentSelectItem.split('-')
    if (items.length > 1) {
      isBackgroundColor = items[0] === item && items[1] === this.cameraType[this.cameraTypeIndex]
    }
    return isBackgroundColor ? 'rgba(255, 75, 75, 0.1)' : 'rgba(0, 0, 0, 0.05)'
  }
}