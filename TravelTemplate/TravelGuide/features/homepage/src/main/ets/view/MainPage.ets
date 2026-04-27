/**
 * @usage: 首页模块，用于展示旅游攻略内容，提供搜索、分类导航（酒店、机票、火车票、旅游、景点）、旅游热点、口碑榜入口、
 * 帖子瀑布流浏览功能
 * @layout: 页面整体采用垂直布局（Column），顶部是搜索栏，下方依次是分类图标区、广告区、旅游热点/口碑榜入口、帖子瀑布流区域
 * @constraints: classificationList为分类导航数据，包含酒店、机票、火车票、旅游、景点五个入口；瀑布流columnsTemplate
 * 根据折叠屏状态动态调整
 * @isGen: true
 * @fileType: page
 * @zhName: 首页
 * @domain: 旅游
 * @image: screenshots/homepage.jpg
 * @subPage: SearchPage,HotelPage,PlaneTicketPage,TourPage,AttractionPage,
 * TravelHotspotPage,ReputationPage,PostDetailPage
 * @component: LookAD
 */
import { LookAD } from 'look_ad';
import { OHPage, phoneRouterControl } from 'oh_router';
import { BarVM, BreakpointModel, RouterMap, UserInfo } from 'common';
import { MockOverseasService, MockService, MockTourListService, PostInfo } from 'common_travel_guide';
import { SearchImgType } from '../common/model';
import { MainPageVM } from '../viewmodel/MainPageVM';
import { SearchPageBuilder } from './SearchPage';
import { HotelPageBuilder } from './HotelPage';
import { PlaneTicketPageBuilder } from './PlaneTicketPage';
import { TourPageBuilder } from './TourPage';
import { AttractionPageBuilder } from './AttractionPage';
import { TravelHotspotPageBuilder } from './TravelHotspotPage';
import { ReputationPageBuilder } from './ReputationPage';
import { PostDetailPageBuilder } from './PostDetailPage';
import { GridRowColSetting } from 'common/src/main/ets/constant/GridRowColSetting';
import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI';

const TAG = 'MainPage';

@ComponentV2
export struct MainPage {
  vm: MainPageVM = new MainPageVM()
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  // 是否折叠屏展开状态
  @Local collapseExpandState: boolean = GridRowColSetting.checkColumnCountModel();
  @Local userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;

  @Monitor('breakPointModel.currentBreakpoint')
  breakPointChange() {
    this.collapseExpandState = GridRowColSetting.checkColumnCountModel()
  }

  build() {
    OHPage({
      childBuilder: () => {
        this.render();
      },
      useSafePadding: true,
      pageBackgroundColor: $r('sys.color.background_primary')
    })
  }

  aboutToAppear(): void {
    MockService.init()
    MockOverseasService.init()
    MockTourListService.init()
  }

  // 页面内容渲染
  @Builder
  render() {
    Scroll() {
      Column() {
        // 顶部内容区域 - 现在在Scroll内部
        Column() {
          // 首页搜索
          this.SearchText()

          // 五个图标
          this.imageBuilder()

          LookAD({ award: '领现金' })

          // 旅游热点和口碑榜入口
          this.travelSection()
        }
        .width('100%')

        this.waterFlowSection()
      }
      .width('100%')
    }
    .padding({ top: BarVM.instance.staBarH })
    .scrollable(ScrollDirection.Vertical)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .align(Alignment.Top)
    .width('100%')
    .height('100%')
  }

  @Builder
  SearchText() {
    Column() {
      Row() {
        // 搜索图标
        Row() {
          Image($r('app.media.icon_search'))
            .width(28)
            .height(28)
        }
        .justifyContent(FlexAlign.Center)

        Text('请输入搜索内容')
          .fontSize(14)
          .fontColor('#999EA2')
          .borderRadius(24)
          .height(50)
          .margin({ left: 4 })
          .layoutWeight(1)
      }
      .onClick(() => {
        phoneRouterControl.jumpPage({
          pageName: RouterMap.SEARCH_PAGE,
          builder: wrapBuilder(SearchPageBuilder)
        })
      })
      .width('100%')
      .height(40)
      .backgroundColor('#F6F6F6')
      .borderRadius(20)
      .padding({ left: 16, right: 12 })
    }
  }

  @Builder
  imageBuilder() {
    Row() {
      ForEach(this.vm.classificationList, (item: SearchImgType, index: number) => {
        Column({ space: 8 }) {
          // 图标
          Row() {
            Image(item.img)
              .width(40)
              .height(40)
              .objectFit(ImageFit.Contain)
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)

          // 文字
          Text(item.text)
            .fontSize(12)
            .fontColor('#444444')
        }
        .onClick(() => {
          if (!this.userInfo.isLogin) {
            phoneRouterControl.jumpPage({
              pageName: RouterMap.LOGIN_PAGE
            })
          } else {
            switch (index) {
              case 0:
                phoneRouterControl.jumpPage({
                  pageName: RouterMap.HOTEL_PAGE,
                  builder: wrapBuilder(HotelPageBuilder)
                })
                break;
              case 1:
                phoneRouterControl.jumpPage({
                  pageName: RouterMap.PLANE_TICKET_PAGE,
                  builder: wrapBuilder(PlaneTicketPageBuilder),
                  param: item.text
                })
                break;
              case 2:
                phoneRouterControl.jumpPage({
                  pageName: RouterMap.PLANE_TICKET_PAGE,
                  builder: wrapBuilder(PlaneTicketPageBuilder),
                  param: item.text
                })
                break;
              case 4:
                phoneRouterControl.jumpPage({
                  pageName: RouterMap.ATTRACTION_PAGE,
                  builder: wrapBuilder(AttractionPageBuilder)
                })
                break;
              case 3:
                phoneRouterControl.jumpPage({
                  pageName: RouterMap.TOUR_PAGE,
                  builder: wrapBuilder(TourPageBuilder)
                })
                break;
              default:
                break;
            }
          }
        })
      }, (item: SearchImgType) => item.toString())
    }
    .margin({ top: 8, bottom: 16 })
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }

  @Builder
  travelSection() {
    Row() {
      // 旅游热点图标入口
      Stack({ alignContent: Alignment.End }) {
        Image($r('app.media.ic_travel_hotspot_entry'))
          .objectFit(ImageFit.Contain)
          .height(40)
          .width('100%')
        Image($r('app.media.ic_right_btn'))
          .width(14)
      }
      .width('48%')
      .padding({ right: 12 })
      .backgroundColor('#F8FAFA')
      .borderRadius(12)
      .onClick(() => {
        phoneRouterControl.jumpPage({
          pageName: RouterMap.TRAVEL_HOTSPOT_PAGE,
          builder: wrapBuilder(TravelHotspotPageBuilder)
        })
      })

      Stack({ alignContent: Alignment.End }) {
        Image($r('app.media.ic_reputation_entry'))
          .objectFit(ImageFit.Contain)
          .height(40)
          .width('100%')
        Image($r('app.media.ic_right_btn'))
          .width(14)
      }
      .padding({ right: 12 })
      .width('48%')
      .backgroundColor('#F8FAFA')
      .borderRadius(12)
      .onClick(() => {
        phoneRouterControl.jumpPage({
          pageName: RouterMap.REPUTATION_PAGE,
          builder: wrapBuilder(ReputationPageBuilder)
        })
      })
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .margin({ top: 12, bottom: 12 })
  }

  // 瀑布流内容区域 - 修改为无滚动属性
  @Builder
  waterFlowSection() {
    WaterFlow() {
      LazyForEach(this.vm.homePostDataSource, (item: PostInfo) => {
        this.homePostCard(item)
      }, (item: PostInfo) => item.id)
    }
    .width('100%')
    .columnsTemplate(this.collapseExpandState ? '1fr 1fr 1fr 1fr' : '1fr 1fr')
    .columnsGap(12)
    .rowsGap(12)
    .cachedCount(10)
    .padding({ bottom: BarVM.instance.aiBarH + 20 })
  }

  // 首页卡片组件
  @Builder
  homePostCard(item: PostInfo) {
    Column() {
      Image(item.coverImg)
        .width('100%')
        .borderRadius({ topLeft: 16, topRight: 16 })
        .objectFit(ImageFit.Cover)

      Column() {
        Text(item.title)
          .fontSize(14)
          .fontColor('#111')
          .fontWeight(FontWeight.Medium)
          .margin({ top: 8, bottom: 6 })
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')

        Row() {
          Row({ space: 6 }) {
            Image(item.authorAvatarUrl ||
              (typeof item.userInfo.avatarUrl === 'string' ? item.userInfo.avatarUrl : '') ||
            $r('app.media.path2x'))
              .width(18)
              .height(18)
              .borderRadius('50%')
              .objectFit(ImageFit.Cover)
              .alt($r('app.media.ic_attraction'))
            Text(item.authorNickName || item.userInfo.nickName || '')
              .fontSize(12)
              .fontColor('#B3000000')
          }
          .alignItems(VerticalAlign.Center)

          Blank()

          Row({ space: 4 }) {
            Image($r('app.media.ic_views'))
              .width(18)
              .height(18)
              .opacity(0.6)
            Text(item.views.toString())
              .fontSize(12)
              .fontColor('#999')
          }
          .alignItems(VerticalAlign.Center)
        }
        .width('100%')
      }
      .backgroundColor('#F8FAFA')
      .padding({ left: 10, right: 10, bottom: 10 })
      .borderRadius({ bottomLeft: 16, bottomRight: 16 })
    }
    .width('100%')
    .backgroundColor($r('sys.color.background_primary'))
    .borderRadius(16)
    .onClick(() => {
      phoneRouterControl.jumpPage({
        pageName: RouterMap.POST_DETAIL_PAGE,
        builder: wrapBuilder(PostDetailPageBuilder),
        param: item
      })
    })
  }
}