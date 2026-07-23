import { getColor } from '@agctemplate/resources'
import { AppStorageV2, window } from '@kit.ArkUI'
import {
  AiBarHeight,
  AppStorageKeys,
  FontModel,
  fp2pxUtil,
  MinorsMode,
  MinorsProtectionUtils,
  StatusBarHeight
} from '@agctemplate/widgets'
import { DramaCoverVM } from '../viewmodels/DramaCoverVM'
import { getRecommendList, getVipRecommendList } from '../mapper/DramaCoverMapper'
import { getBannerList, getVipBannerList } from '../mapper/BannerMapper'
import { Context } from '@kit.AbilityKit'
import { UIStickyScroll } from '../components/UIStickyScroll'
import { NewDrama } from '../views/NewDrama'
import { VIP } from '../views/VIP'
import { BillboardPageBuilder } from './BillboardPage'
import { RecommendPanel } from '../components/RecommendPanel'
import { GlobalContext, SafeJson } from '@agctemplate/utils'

const reTabs = ['精选', '古装', '家庭', '年代', '穿越', '职场', '重生', '权谋', '其他']
const chaTabs = ['热播榜', '飙升榜', '新剧榜', '热搜榜']
const minorsMode: MinorsMode =
  AppStorageV2.connect(MinorsMode, 'isMinorsMode', () => new MinorsMode(MinorsProtectionUtils.getMinorsMode()))!

@ComponentV2
struct TheaterMainPage {
  @Local statusBarHeight: StatusBarHeight = AppStorageV2.connect(StatusBarHeight, AppStorageKeys.STATUS_BAR_HEIGHT,
    () => new StatusBarHeight())!;
  @Local gutter: number = 8
  @Local bannerList: Array<DramaCoverVM> = []
  @Local vipBannerList: Array<DramaCoverVM> = []
  @Local currentRecommendPageNum: number = 1
  @Local currentVipPageNum: number = 1
  @Local headerHeight: number = 56
  @Local mainHeight: number = 60
  @Local recommendList: Array<DramaCoverVM> = []
  @Local vipRecommendList: Array<DramaCoverVM> = []
  @Local recommendTagList: Array<DramaCoverVM> = []
  @Provider('fTabs') selectedIndex: number = 0
  @Provider('sTabs') selIndex: number = 0
  @Provider('rank') rankTab: string = reTabs[this.selIndex]
  @Provider('scroll') scroller: Scroller = new Scroller()
  @Local fontModel: FontModel = AppStorageV2.connect(FontModel, () => new FontModel())!;
  @Local aiBarHeight: AiBarHeight = AppStorageV2.connect(AiBarHeight, AppStorageKeys.AI_BAR_HEIGHT,
    () => new AiBarHeight())!;

  @Computed
  get _rankTab(): string {
    if (this.selectedIndex === 0) {
      return reTabs[this.selIndex]
    }
    if (this.selectedIndex === 1) {
      return chaTabs[this.selIndex]
    }
    return ''
  }

  @Monitor('_rankTab')
  change() {
    this.rankTab = this._rankTab
    if (this.selectedIndex === 0) {
      if (this.rankTab === '精选' || this.rankTab === '其他') {
        this.recommendTagList = this.recommendList
      } else {
        this.recommendTagList = this.recommendList.filter(drama => {
          return drama.tags.includes(this.rankTab);
        });
      }
    }
  }

  @Monitor('selectedIndex', 'selIndex')
  idxChange() {
    this.scroller.scrollToIndex(0)
  }

  async initViewData(): Promise<void> {
    // 刷新短剧推荐数据
    this.recommendList = await getRecommendList(1)
    this.recommendTagList = await getRecommendList(1)
    // 刷新轮播图图片信息
    this.bannerList = await getBannerList()
    this.vipBannerList = await getVipBannerList()
    this.vipRecommendList = await getVipRecommendList(1)
  }

  async aboutToAppear() {
    await this.initViewData()
    // 计算优选短剧的间距
    this.gutter = await this.calcRecommendGutter(this.getUIContext().getHostContext()!)
  }

  async calcRecommendGutter(context: Context): Promise<number> {
    const padding = 48, coverWidth = 104
    let width: number = 0
    try {
      let windowClass = await window.getLastWindow(context)
      let properties = windowClass.getWindowProperties()
      width = this.getUIContext().px2vp(properties.windowRect.width)
    } catch (error) {
      console.error('Failed. Cause:' + SafeJson.ohAegJsonStringify(error));
    }
    let num = Math.floor((width - padding) / coverWidth)
    return (width - padding - num * coverWidth) / (num - 1)
  }

  //剧场里推荐、排行榜、新剧、VIP专区等内容
  @Builder
  contentBuilder() {
    List({ scroller: this.scroller }) {
      if (minorsMode.isMinorsMode || this.selectedIndex === 0) {
        RecommendPanel({ recommendList: this.recommendTagList, gutter: this.gutter })
      } else if (this.selectedIndex === 1) {
        BillboardPageBuilder(1)
      } else if (this.selectedIndex === 2) {
        NewDrama({ bannerList: this.bannerList, recommendList: this.recommendList, gutter: this.gutter })
      } else {
        VIP({ bannerList: this.vipBannerList, recommendList: this.vipRecommendList, gutter: this.gutter })
      }
    }
    .borderColor(Color.Red)
    .padding({ left: 8, right: 8 })
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    .scrollBar(BarState.Off)
    .nestedScroll({
      scrollForward: NestedScrollMode.PARENT_FIRST,
      scrollBackward: NestedScrollMode.SELF_FIRST
    })
    .onReachEnd(async () => {
      if (this.selectedIndex === 3) {
        const list = await getVipRecommendList(++this.currentVipPageNum)
        this.vipRecommendList = this.vipRecommendList.concat(list)
      } else if (this.selectedIndex !== 1) {
        const list = await getRecommendList(++this.currentRecommendPageNum)
        this.recommendList = this.recommendList.concat(list)
        if (this.selectedIndex === 0) {
          if (this.rankTab === '精选' || this.rankTab === '其他') {
            this.recommendTagList = this.recommendTagList.concat(list)
          } else {
            this.recommendTagList = this.recommendList.filter(drama => {
              return drama.tags.includes(this.rankTab);
            });
          }
        }
      }
    })
  }

  @Builder
  mainBuilder() {
    Column() {
      Row() {
        Text('剧场')
          .fontSize(fp2pxUtil(26))
          .fontWeight(700)
          .fontColor($r('sys.color.font_primary'))
      }
      .padding({ left: 16 })
      .width('100%')
      .height(56)
      .justifyContent(FlexAlign.Start)
      .alignItems(VerticalAlign.Center)

      if (!minorsMode.isMinorsMode) {
        Flex() {
          List({ space: 8 }) {
            ForEach(['推荐', '排行榜', '新剧', 'VIP专区'], (title: string, index: number) => {
              ListItem() {
                Text(title)
                  .width(76)
                  .height(28)
                  .borderRadius(14)
                  .fontColor(this.selectedIndex === index ? '#fff' : $r('sys.color.font_primary'))
                  .backgroundColor(this.selectedIndex === index ? '#EC6E45' : $r('sys.color.comp_background_tertiary'))
                  .fontSize(fp2pxUtil(14))
                  .fontWeight(500)
                  .textAlign(TextAlign.Center)
                  .onClick(() => {
                    this.selectedIndex = index
                    this.selIndex = 0
                  })
              }
            }, (title: string) => title)
          }
          .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
          .width('100%')
          .height(104)
          .listDirection(Axis.Horizontal)
          .scrollBar(BarState.Off)
          .padding({ top: 10, left: 16 })
        }
      }
    }
    .padding({ top: 9 })
  }

  build() {
    NavDestination() {
      Column() {
        UIStickyScroll({
          tabList: this.selectedIndex === 0 ? reTabs : this.selectedIndex === 1 ? chaTabs : [],
          mainHeight: this.mainHeight,
          headerHeight: this.headerHeight,
          contentBuilderParam: (): void => {
            this.contentBuilder()
          },
          mainBuilderParam: (): void => {
            this.mainBuilder()
          },
          //main滚动过程触发，ratio为y轴的偏移程度，取为0-1，0为未向上滚动，1为滚动到顶部
          onProcess: (ratio: number) => {
          },
          //滚动到达顶部
          onReachTop: () => {
          }
        })
      }
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .padding({ top: `${this.getUIContext().px2vp(this.statusBarHeight.value)}vp` })
    }
  }
}

@Builder
export function TheaterMainPageBuilder(index: number) {
  TheaterMainPage()
}