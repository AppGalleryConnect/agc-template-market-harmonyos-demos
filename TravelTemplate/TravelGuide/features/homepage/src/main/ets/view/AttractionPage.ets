/**
 * @usage: 景点/攻略页面，展示当地指南、路线规划、旅游地图三个功能入口，以及推荐和最新两个tab的攻略帖子瀑布流
 * @layout: 页面整体采用垂直布局（Column），顶部是通用头部组件，下方是定位权限提示、城市选择、三个功能卡片、tab切换、帖子瀑布流
 * @constraints: currentCity为当前选择的城市；recommendDataSource和latestDataSource分别为推荐和最新帖子数据源；
 * 定位权限影响附近景点搜索功能
 * @isGen: true
 * @fileType: page
 * @zhName: 景点攻略
 * @domain: 旅游
 * @image: screenshots/homepage/Attraction.jpg
 * @subPage: CitySelectPage,CityGuidePage,RoutePlanningPage,AttractionMapPage,PostDetailPage
 * @component: CommonHeader,AttractionCardItem
 */
import { CommonHeader, Constants, RouterMap, getCurrentCityInfo, PermissionUtil, DeviceUtils, GlobalContext, TValueType, UserInfo } from 'common'
import { OHPage, phoneRouterControl } from 'oh_router'
import { LikesItem, MyLikeList, PostInfo, MyPostList } from 'common_travel_guide'
import { AttractionPageVM } from '../viewmodel/AttractionPageVM'
import { PostDetailPageBuilder } from './PostDetailPage'
import { CitySelectPageBuilder } from './CitySelectPage'
import { CityGuidePageBuilder } from './CityGuidePage'
import { AttractionMapPageBuilder } from './AttractionMapPage'
import { ReputationItem, reputationList } from '../common/mock/ReputationMockData'
import { BusinessError } from '@kit.BasicServicesKit'
import { Permissions } from '@kit.AbilityKit'
import { City } from 'city_select'
// 导入 travel_planning 模块，确保其 Index.ets 被执行，从而注册路由
import 'travel_planning'
// 备用方案：如果路由注册失败，可以直接导入并使用 builder
import { RoutePlanningPageBuilder } from 'travel_planning'
import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI'

@Builder
export function AttractionPageBuilder() {
  AttractionPage()
}

@ComponentV2
struct AttractionCardItem {
  @Param @Require post: PostInfo
  @Local likesList: MyLikeList = AppStorageV2.connect(MyLikeList, () => new MyLikeList())!
  @Local myPostList: MyPostList = AppStorageV2.connect(MyPostList, () => new MyPostList())!
  @Local userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!

  build() {
    Column() {
      Image(this.post.coverImg)
        .width('100%')
        .borderRadius({ topLeft: 16, topRight: 16 })
        .objectFit(ImageFit.Cover)

      Column() {
        Text(this.post.title)
          .fontSize(14)
          .fontColor('#111')
          .fontWeight(FontWeight.Medium)
          .margin({ top: 8, bottom: 6 })
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')

        Row() {
          Text(this.post.authorNickName || this.post.userInfo.nickName || '')
            .fontSize(11)
            .fontColor('#999')

          Blank()

          Row({ space: 4 }) {
            Image(this.post.liked ? $r('app.media.ic_like') : $r('app.media.ic_like_default'))
              .width(12)
              .height(12)
            Text(this.post.likes.toString())
              .fontSize(11)
              .fontColor('#999')
          }
          .alignItems(VerticalAlign.Center)
          .onClick(() => {
            this.post.handleLike()
            // 只有点赞自己的帖子时才添加到收到的赞列表
            // 通过MyPostList判断帖子是否属于当前用户
            const isMyPost = this.myPostList.getDataById(this.post.id) !== undefined
            const date = new Date()
            let likeTime =
              `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate())
                .padStart(2, '0')}`
            if (this.post.liked && isMyPost) {
              const data = new LikesItem(
                this.userInfo.nickName || '',
                this.userInfo.avatarUrl || '',
                likeTime || '',
                this.post.id || '',
                this.post.coverImg || ''
              );
              this.likesList.add(data);
            } else if (!this.post.liked && isMyPost) {
              this.likesList.deleteById(this.post.id);
            }
          })
        }
        .margin({ top: 6 })
        .width('100%')
      }
      .backgroundColor('#F8FAFA')
      .borderRadius({ bottomLeft: 12, bottomRight: 12 })
      .padding({ left: 12, right: 12, bottom: 12 })
    }
    .width('100%')
    .borderRadius(16)
    .onClick(() => {
      phoneRouterControl.jumpPage({
        pageName: RouterMap.POST_DETAIL_PAGE,
        builder: wrapBuilder(PostDetailPageBuilder),
        param: this.post
      })
    })
  }
}

@ComponentV2
export struct AttractionPage {
  vm: AttractionPageVM = new AttractionPageVM()
  logTag: string = 'AttractionPage';
  @Local currentIndexTab: number = Constants.TAB_INDEX_ZERO;

  build() {
    OHPage({
      childBuilder: () => {
        this.render();
      },
      useSafePadding: true,
      isFullScreen: true,
      pageBackgroundColor: '#fff'
    })
  }

  aboutToAppear(): void {
    this.isCheckPermission()
  }

  // 检查是否开启定位权限
  isCheckPermission() {
    PermissionUtil.checkPermissionGrant('ohos.permission.LOCATION').then((res) => {
      if (res === -1) {
        this.vm.locationPermission = false
      } else {
        getCurrentCityInfo().then((city) => {
          this.vm.currentCity = city?.locality as string || '北京'
          this.vm.placeName = city?.placeName as string || ''
        })
        this.vm.locationPermission = true
      }
    })
  }

  // 开启定位权限操作
  checkPermission() {
    let permission: Permissions = 'ohos.permission.LOCATION'
    PermissionUtil.checkPermissions(permission).then(() => {
      getCurrentCityInfo().then((city) => {
        this.vm.currentCity = city?.locality as string || '北京'
        this.vm.placeName = city?.placeName as string || ''
      })
      this.vm.locationPermission = true
    }).catch((err: BusinessError) => {
    })
  }

  jumpToRoutePlanning() {
    phoneRouterControl.jumpPage({
      pageName: RouterMap.ROUTE_PLANNING_PAGE,
      builder: wrapBuilder(RoutePlanningPageBuilder)
    })
  }

  @Builder
  render() {
    Column() {
      CommonHeader({
        title: '景点/攻略',
        onReturnClick: () => {
          phoneRouterControl.popPage();
        },
        backgroundColorParam: '#fff'
      })
      Scroll() {
        Column() {
          Column() {
            Row() {
              Text('开启定位权限，为你搜索附近景点').fontColor('#C1771C').fontSize(12)
              Text('开启权限')
                .onClick(() => {
                  this.checkPermission()
                })
                .fontColor('#C1771C')
                .fontSize(12)
                .padding({
                  left: 10,
                  right: 10,
                  top: 4,
                  bottom: 4
                })
                .borderRadius(11)
                .borderColor('#C1771C')
                .borderWidth(0.5)
            }
            .justifyContent(FlexAlign.SpaceBetween)
            .alignItems(VerticalAlign.Center)
            .height(38)
            .padding({ left: 10, right: 10 })
            .margin({
              top: 8,
            })
            .width('100%')
            .backgroundColor('#FFFADB')
            .borderRadius(8)
            .visibility(this.vm.locationPermission ? Visibility.None : Visibility.Visible)

            Row() {
              Text(this.vm.currentCity).fontSize(18).fontColor('#333333').fontWeight(500)
                .onClick(() => {
                  phoneRouterControl.jumpPage({
                    pageName: RouterMap.CITY_SELECT_PAGE,
                    builder: wrapBuilder(CitySelectPageBuilder),
                    param: this.vm.currentCity,
                    onPop: (popInfo: PopInfo) => {
                      let result = popInfo?.result as City;
                      if (result && result.name) {
                        this.vm.currentCity = result.name
                      }
                    }
                  })
                })
              Image($r('app.media.ic_down')).width(20).height(20).margin({ left: 2 })

              Blank()

              Image($r('app.media.ic_position')).width(20).height(20)
              .onClick(() => {
                this.checkPermission()
              })
            }.width('100%').alignItems(VerticalAlign.Center).justifyContent(FlexAlign.SpaceBetween).height(56)
          }
          // 三个功能卡片
          this.featureCards()
          
          // 顶部内容区域（标题和Tab）
          Column() {
            // 标题
            Text('大家怎么玩')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor('#111')
              .width('100%')
              .margin({ bottom: 4 })

            // Tab 切换
            Row({ space: 24 }) {
              this.tabBuilder('推荐', Constants.TAB_INDEX_ZERO)
              this.tabBuilder('最新', Constants.TAB_INDEX_ONE)
            }
            .padding({ left: 8, right: 8 })
            .height(37)
            .width('100%')
            .justifyContent(FlexAlign.Start)
          }
          .width('100%')
          .margin({ bottom: 12 })

          // 瀑布流内容（根据当前选中的tab显示）
          if (this.currentIndexTab === Constants.TAB_INDEX_ZERO) {
            this.tabContentBuilder(Constants.TAB_INDEX_ZERO)
          } else {
            this.tabContentBuilder(Constants.TAB_INDEX_ONE)
          }
        }
        .width('100%')
      }
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .align(Alignment.Top)
      .layoutWeight(1)
      .width('100%')
    }
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Start)
    .width('100%')
    .height('100%')
    .backgroundColor('#fff')
  }

  @Builder
  tabContentBuilder(index: number) {
      WaterFlow() {
        if (index === Constants.TAB_INDEX_ZERO) {
          LazyForEach(this.vm.recommendDataSource, (item: PostInfo) => {
            this.playCard(item)
          }, (item: PostInfo) => item.id)
        } else {
          LazyForEach(this.vm.latestDataSource, (item: PostInfo) => {
            this.playCard(item)
          }, (item: PostInfo) => item.id)
        }
      }
      .width('100%')
      .columnsTemplate('1fr 1fr')
      .columnsGap(12)
      .rowsGap(12)
      .cachedCount(10)
    }

  @Builder
  playCard(item: PostInfo) {
    AttractionCardItem({
      post: item
    })
  }

  @Builder
  tabBuilder(title: string, index: number) {
    Column({ space: 4 }) {
      Text(title)
        .fontSize(14)
        .fontColor(this.currentIndexTab === index ? '#000' : 'rgba(0, 0, 0, 0.50)')
      if (this.currentIndexTab === index) {
        Row().width(12).height(3).borderRadius(2).backgroundColor('#333')
      }
    }
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Center)
    .padding({ top: 10, bottom: 4 })
    .height(37)
    .onClick(() => {
      this.currentIndexTab = index;
    })
  }

  // 三个功能卡片
  @Builder
  featureCards() {
    Row({ space: 12 }) {
      this.featureCard('当地指南', '出行前必看', this.getGuideImage())
      this.featureCard('路线规划', '安排好行程', this.getRouteImage())
      this.featureCard('旅游地图', '哪些景点城市', this.getMapImage())
    }
    .width('100%')
  }

  @Builder
  featureCard(title: string, subtitle: string, image: ResourceStr) {
    Stack({ alignContent: Alignment.TopStart }) {
      // 背景图片
      Image(image)
        .width('100%')
        .height(72)
        .borderRadius(12)
        .objectFit(ImageFit.Cover)
      
      // 文字内容
      Column({ space: 4 }) {
        Text(title)
          .fontSize(14)
          .fontColor('#333')
          .fontWeight(FontWeight.Medium)
        Text(subtitle)
          .fontSize(11)
          .fontColor('#666')
      }
      .alignItems(HorizontalAlign.Start)
      .padding({ left: 12, top: 12})
    }
    .layoutWeight(1)
    .height(92)
    .onClick(() => {
      // 如果是"当地指南"卡片，跳转到城市指南页面
      if (title === '当地指南') {
        phoneRouterControl.jumpPage({
          pageName: RouterMap.CITY_GUIDE_PAGE,
          builder: wrapBuilder(CityGuidePageBuilder),
          param: this.vm.currentCity
        })
      } else if (title === '路线规划') {
        // 跳转到线路规划页面
        this.jumpToRoutePlanning()
      } else if (title === '旅游地图') {
        // 跳转到旅行地图页面，使用口碑榜的第一个mock数据
        const mockReputationItem: ReputationItem = reputationList[0]
        phoneRouterControl.jumpPage({
          pageName: RouterMap.ATTRACTION_MAP_PAGE,
          builder: wrapBuilder(AttractionMapPageBuilder),
          param: mockReputationItem as TValueType
        })
      }
    })
  }

  // 根据屏幕类型获取图片资源
  getGuideImage(): ResourceStr {
    const uiContext = GlobalContext.getUIContext()
    if (DeviceUtils.isMediumSquare(uiContext)) {
      // 阔折叠
      return $r('app.media.ic_attraction_guide_wide')
    } else if (DeviceUtils.isSmallScreen(uiContext)) {
      // 普通屏幕
      return $r('app.media.ic_attraction_guide')
    } else {
      // 折叠屏
      return $r('app.media.ic_attraction_guide_fold')
    }
  }

  getRouteImage(): ResourceStr {
    const uiContext = GlobalContext.getUIContext()
    if (DeviceUtils.isMediumSquare(uiContext)) {
      // 阔折叠
      return $r('app.media.ic_attraction_route_wide')
    } else if (DeviceUtils.isSmallScreen(uiContext)) {
      // 普通屏幕
      return $r('app.media.ic_attraction_route')
    } else {
      // 折叠屏
      return $r('app.media.ic_attraction_route_fold')
    }
  }

  getMapImage(): ResourceStr {
    const uiContext = GlobalContext.getUIContext()
    if (DeviceUtils.isMediumSquare(uiContext)) {
      // 阔折叠
      return $r('app.media.ic_attraction_map_wide')
    } else if (DeviceUtils.isSmallScreen(uiContext)) {
      // 普通屏幕
      return $r('app.media.ic_attraction_map')
    } else {
      // 折叠屏
      return $r('app.media.ic_attraction_map_fold')
    }
  }
}

