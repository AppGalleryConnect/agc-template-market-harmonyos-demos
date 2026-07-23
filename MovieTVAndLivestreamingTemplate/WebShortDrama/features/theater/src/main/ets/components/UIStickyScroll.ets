import { TabStyle } from './Type'
import { AppStorageV2 } from '@kit.ArkUI'
import {
  AppStorageKeys,
  BreakPoint,
  FontModel,
  fp2pxUtil,
  MinorsMode,
  MinorsProtectionUtils
} from '@agctemplate/widgets'
import { SearchItem, SearchView, SearchViewController } from 'search'
import { getRankList } from '../mapper/DramaCoverMapper'
import { DramaCoverVM } from '../viewmodels/DramaCoverVM'


export const DEFAULT_SMALL_HEIGHT = 48

export const DEFAULT_LARGE_HEIGHT = 60

const HOT_SEARCH_CATEGORY: string = '热搜榜'

const minorsMode: MinorsMode =
  AppStorageV2.connect(MinorsMode, 'isMinorsMode', () => new MinorsMode(MinorsProtectionUtils.getMinorsMode()))!

@ComponentV2
export struct UIStickyScroll {
  @Local fontModel: FontModel = AppStorageV2.connect(FontModel, () => new FontModel())!;
  @Consumer('navStack') navPathStack: NavPathStack = new NavPathStack();
  controller: SearchViewController = new SearchViewController();
  @Param @Once headerHeight: number = DEFAULT_SMALL_HEIGHT
  @Param @Once mainHeight: number = DEFAULT_LARGE_HEIGHT
  @Require @Param tabList: string[] = []
  // 是否根据滑动手势切换tab
  @Param isToggleByPan: Boolean = true
  @Param tabStyle: TabStyle = {
    // tab栏高度
    tabHeight: 40,
    // tab选中颜色
    tabActiveColor: '#EC6E45',
    // tab字体颜色
    tabFontColor: $r('sys.color.font_secondary'),
    // tab字重
    tabFontWeight: 500,
    // tab字体大小
    tabFontSize: 14
  }
  @Local tabWidth: number = 0
  @Local tabItemWidthList: number[] = []
  // 控制头部标题栏显隐
  @Local headerTitleVisible: boolean = false
  //选中tab的索引
  @Consumer('fTabs') activeIndex: number = 0
  @Consumer('sTabs') actIndex: number = 0
  // 上滑的比率
  @Local ratio: number = 0
  @Provider('hot') rankList: SearchItem[] = []
  @Local currentPageNum: number = 1
  @BuilderParam contentBuilderParam: () => void = this.contentBuilder;
  @BuilderParam mainBuilderParam: () => void = this.mainBuilder;
  @BuilderParam backgroundBuilderParam: () => void = this.backgroundBuilder;
  scroller: Scroller = new Scroller()
  private scrollerForTabList: Scroller = new Scroller()
  private panOption: PanGestureOptions = new PanGestureOptions({ direction: PanDirection.Left | PanDirection.Right })
  breakPoint = AppStorageV2.connect(BreakPoint, AppStorageKeys.CURRENT_BREAK_POINT,
    () => new BreakPoint())!;

  @Builder
  contentBuilder() {
  };

  @Builder
  mainBuilder() {
  };

  @Builder
  backgroundBuilder() {
  };

  @Event onTabChange: (index: number) => void = () => {
  }
  // 主要信息区滚动到顶
  @Event onReachTop: () => void = () => {
  }
  // main滚动过程触发，ratio为y轴的偏移程度，取为0-1，0为未偏移，1为滚动到顶部
  @Event onProcess: (ratio: number) => void = () => {

  }

  async aboutToAppear(): Promise<void> {
    //  传入宽高异常处理
    if (this.headerHeight <= 0) {
      this.headerHeight = DEFAULT_SMALL_HEIGHT
    }
    if (this.mainHeight <= 0) {
      this.mainHeight = DEFAULT_LARGE_HEIGHT
    }
    if (this.tabStyle.tabHeight <= 0) {
      this.tabStyle.tabHeight = DEFAULT_SMALL_HEIGHT
    }
    this.tabItemWidthList = new Array(this.tabList.length).fill(0)
    const tempList: DramaCoverVM[] = await getRankList(HOT_SEARCH_CATEGORY, this.currentPageNum)
    tempList.forEach((value: DramaCoverVM) => {
      this.rankList.push({
        title: value.title,
        episodes: value.episodes,
        latestUpdate: value.latestUpdate,
        tags: value.tags,
        id: value.dramaId,
        image: value.imagePath,
        intro: value.content
      })
    })
  }

  build() {
    Stack() {
      if (!minorsMode.isMinorsMode) {
        Column() {
          // 头部区域
          Flex({ alignItems: ItemAlign.Center }) {
            List({ space: 8 }) {
              ForEach(['推荐', '排行榜', '新剧', 'VIP专区'], (title: string, index: number) => {
                ListItem() {
                  Text(title)
                    .width(76)
                    .height(28)
                    .borderRadius(14)
                    .fontColor(this.activeIndex === index ? '#fff' : $r('sys.color.font_primary'))
                    .backgroundColor(this.activeIndex === index ? '#EC6E45' : $r('sys.color.comp_background_tertiary'))
                    .fontSize(fp2pxUtil(14))
                    .fontWeight(500)
                    .textAlign(TextAlign.Center)
                    .onClick(() => {
                      this.activeIndex = index
                      this.actIndex = 0
                    })
                }
              }, (title: string) => title)
            }
            .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
            .width(this.breakPoint.value === 'sm' ? 360 : 540)
            .height(56)
            .listDirection(Axis.Horizontal)
            .visibility(this.headerTitleVisible ? Visibility.Visible : Visibility.Hidden)
            .scrollBar(BarState.Off)
            .padding({ top: 18 })

            Blank()

            Row({ space: 8 }) {
              SearchView({
                routerStack: this.navPathStack,
                themeColor: '#EC6E45',
                controller: this.controller,
                placeholder: ['输入剧名搜索'],
                showGuessLike: false,
                isShallowWindow: true,
                onClickGetMore: () => {
                  this.getUIContext().getPromptAction().showToast({ message: '前往更多页，暂未开发' })
                },
                onClickResultItem: (listItem: SearchItem) => {
                  this.getUIContext().getPromptAction().showToast({ message: '前往详情页，暂未开发' })
                }
              })
            }
            .margin({ right: 8 })
            .padding({ top: 5 })
            .borderRadius(24)
          }.height('100%')
        }
        .width('100%')
        .height(this.headerHeight)
        .backgroundColor('transparent')
        .zIndex(2)
        .padding({
          left: 16,
          right: 16,
        })
      }

      Scroll(this.scroller) {
        Column() {
          // 主要信息区域自定义
          Stack() {

            RelativeContainer() {
              this.mainBuilderParam()
            }
            .visibility(this.headerTitleVisible ? Visibility.Hidden : Visibility.Visible)
          }.width('100%')
          .height(minorsMode.isMinorsMode ? this.mainHeight : this.mainHeight + this.headerHeight)

          Column() {
            if (!minorsMode.isMinorsMode) {
              if (this.activeIndex <= 1) {
                // tab栏
                RelativeContainer() {
                  List({ scroller: this.scrollerForTabList }) {
                    ForEach(this.tabList, (item: string, index) => {
                      ListItem() {
                        Column() {
                          Row() {
                            Text(item)
                              .height('100%')
                              .textAlign(TextAlign.Center)
                              .fontColor(this.actIndex === index ? this.tabStyle.tabActiveColor :
                                this.tabStyle.tabFontColor)
                              .fontWeight(this.tabStyle.tabFontWeight)
                              .fontSize(this.fontModel.getFg(this.tabStyle.tabFontSize as number))
                              .maxLines(1)
                              .textOverflow({ overflow: TextOverflow.Ellipsis })
                          }
                          .layoutWeight(1)
                          .constraintSize({
                            maxWidth: 0.4 * this.tabWidth,
                          })
                          .height('100%')
                          .gesture(
                            GestureGroup(GestureMode.Exclusive,
                              TapGesture({ fingers: 1, count: 1 })
                                .onAction(() => {
                                  this.actIndex = index
                                  this.onTabChange(index)
                                  if (index >= 4) {
                                    this.scrollerForTabList.scrollToIndex(index - 3, true)
                                  }
                                  if (index <= 3) {
                                    this.scrollerForTabList.scrollToIndex(0, true)
                                  }
                                })
                            )
                          )
                          .onAreaChange((oldValue, newValue: Area) => {
                            if (this.tabItemWidthList[index] !== newValue.width as number) {
                              this.tabItemWidthList[index] = newValue.width as number
                            }
                          })

                          if (this.actIndex === index) {
                            Column()
                              .backgroundColor(this.tabStyle.tabActiveColor)
                              .borderRadius($r('sys.float.ohos_id_corner_radius_progress_bar'))
                              .height(2)
                              .width(this.tabItemWidthList[index])
                          }
                        }.padding({ top: this.actIndex === index ? 2 : 0 })
                      }.height('100%').margin({ right: 16 })
                    }, (item: string) => item)
                  }
                  .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
                  .listDirection(Axis.Horizontal).scrollBar(BarState.Off).scrollSnapAlign(ScrollSnapAlign.START)

                }
                .height(this.tabStyle.tabHeight)
                .padding({ left: 16, right: 16 })
                .onAreaChange((oldValue, newValue: Area) => {
                  if (this.tabWidth !== newValue.width as number) {
                    this.tabWidth = newValue.width as number
                  }
                })
              }
            }
            // 自定义内容区
            RelativeContainer() {
              this.contentBuilderParam()
            }
            .padding({ left: minorsMode.isMinorsMode ? 8 : 16, right: 16, top: 8 })
            .borderRadius({ topLeft: 4, topRight: 4 })
            .width('100%')
            .height(
              minorsMode.isMinorsMode || this.activeIndex > 1 ? '100%' : `calc(100% - ${this.tabStyle.tabHeight}vp)`)
            .gesture(PanGesture(this.panOption).onActionStart((event: GestureEvent) => {
              if (this.isToggleByPan) {
                if (event.offsetX < 0 && this.actIndex < this.tabList.length - 1) {
                  this.actIndex++
                  // 滚动到选中的tab
                  this.scrollerForTabList.scrollToIndex(this.actIndex, true, ScrollAlign.START)
                } else if (event.offsetX < 0 && this.actIndex >= this.tabList.length - 1 && this.activeIndex < 3) {
                  this.activeIndex++
                  this.actIndex = 0
                }
                if (event.offsetX > 0 && this.actIndex > 0) {
                  this.actIndex--
                  // 滚动到选中的tab
                  this.scrollerForTabList.scrollToIndex(this.actIndex, true, ScrollAlign.START)
                } else if (event.offsetX > 0 && this.actIndex <= 0 && this.activeIndex > 0) {
                  this.activeIndex--
                  this.actIndex = 0
                }
              }
            }))
          }.height(`calc(100% - ${this.headerHeight}vp)`)
        }.width('100%')
      }
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: minorsMode.isMinorsMode ? false : true })
      .friction(0.6)
      .scrollBar(BarState.Off)
      .width('100%')
      .height('100%')
      .onScrollEdge((side: Edge) => {
        // 滚动到顶部
        if (!minorsMode.isMinorsMode && side === Edge.Bottom) {
          this.headerTitleVisible = true
          this.onReachTop()
        }
      })
      .onScrollFrameBegin((offset: number) => {
        // main滚动过程触发，ratio为y轴的偏移程度，取为0-1，0为未偏移，1为滚动到顶部
        const yOffset = this.scroller.currentOffset().yOffset
        this.ratio = yOffset / this.mainHeight
        if (this.ratio !== 1) {
          this.headerTitleVisible = false // 控制标题内容显隐
        }
        this.onProcess(this.ratio)
        return { offsetRemain: offset }
      })

    }.alignContent(Alignment.Top)

  }
}