import { RouteItem, RouteListParams } from '../model/RouteListModel'
import { getRoutes } from '../mock/RoutePlanningMockData'
import { pushPathByName } from '../utils/RouterUtils'
import { SafeAreaUtils } from '../utils/SafeAreaUtils'
import { ROUTE_DETAIL_PAGE } from './MainPage'

/**
 * @usage: 路线列表页面，展示根据目的地和天数推荐的旅游路线列表
 * @layout: 单列布局，顶部导航栏+路线卡片列表（封面图+标题+天数+地点数+景点路线）
 * @isGen: true
 * @fileType: component
 * @zhName: 路线列表页面
 * @domain: 旅游
 * @subPage: RouteDetailPage
 */
@Builder
export function RouteListPageBuilder(params?: RouteListParams) {
  RouteListPage({
    pageParam: params
  })
}

@ComponentV2
struct RouteListPage {
  @Param pageParam: RouteListParams | null = null
  stack: NavPathStack | null = null
  @Local statusBarHeight: number = 38
  @Local bottomSafeArea: number = 0
  @Local routeList: RouteItem[] = []

  aboutToAppear() {
    const uiContext = this.getUIContext()
    SafeAreaUtils.getBottomArea(uiContext).then((height: number) => {
      if (height > 0) {
        this.bottomSafeArea = height
      }
    })
    if (this.pageParam) {
      this.routeList = getRoutes(this.pageParam.city, this.pageParam.days)
    }
  }

  build() {
    NavDestination() {
      Column() {
        // 状态栏占位
        Column().height(this.statusBarHeight)
        
        // 自定义导航栏
        this.customHeader()
        Scroll() {
          List() {
            ForEach(this.routeList, (item: RouteItem) => {
              ListItem() {
                this.routeItemBuilder(item)
              }
            }, (item: RouteItem) => item.id)
            ListItem() {
              Column().height(20)
            }
          }
          .margin({ top: 20 })
          .scrollBar(BarState.Off)
          .width('100%')
          .height('100%')
          .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .padding({ bottom: this.bottomSafeArea })
    }
    .height('100%')
    .width('100%')
    .hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      this.stack = context.pathStack
      const paramStr = context.pathInfo.param as string
      if (paramStr) {
        try {
          const param = JSON.parse(paramStr) as RouteListParams
          if (param?.city && param?.days) {
            this.routeList = getRoutes(param.city, param.days)
          }
        } catch (e) {
        }
      }
    })
    .onBackPressed(() => {
      this.stack?.pop()
      return true
    })
  }

  @Builder
  customHeader() {
    Row() {
      Button() {
        SymbolGlyph($r('sys.symbol.chevron_backward'))
          .fontSize(24)
          .fontColor([$r('sys.color.icon_primary')])
          .fontWeight(FontWeight.Normal)
      }
      .width(40)
      .height(40)
      .type(ButtonType.Circle)
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .onClick(() => {
        this.stack?.pop()
      })
      .margin({ left: 16 })

      Text('路线规划')
        .fontSize(20)
        .fontWeight(400)
        .fontColor($r('sys.color.font_primary'))
        .margin({ left: 8 })
    }
    .height(40)
    .width('100%')
    .justifyContent(FlexAlign.Start)
    .margin({ top: 8 })
  }

  @Builder
  routeItemBuilder(item: RouteItem) {
    Row() {
      Image(item.coverImage)
        .width(105)
        .height(140)
        .borderRadius({ topLeft: 12, topRight: 0, bottomLeft: 12, bottomRight: 0 })
        .objectFit(ImageFit.Cover)

      Column() {
        Text(item.title)
          .fontSize(14)
          .fontColor('#333')
          .fontWeight(FontWeight.Medium)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')

        Row({ space: 8 }) {
          Text(`${item.days}天`)
            .fontSize(12)
            .fontColor('#66000000')
          Text(`${item.locations}个地点`)
            .fontSize(12)
            .fontColor('#66000000')
        }
        .margin({ top: 10, bottom: 24 })

        Blank()

        Text(item.attractions.join(' - '))
          .fontSize(12)
          .fontColor('#b3000000')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .height(140)
      .backgroundColor('#F7F9FA')
      .padding(12)
      .borderRadius({ topLeft: 0, topRight: 12, bottomLeft: 0, bottomRight: 12 })
    }
    .width('100%')
    .padding({ left: 16, right: 16 })
    .backgroundColor('#fff')
    .margin({ bottom: 10 })
    .onClick(() => {
      pushPathByName(this.stack, ROUTE_DETAIL_PAGE, JSON.stringify({ route: item }), undefined, false)
    })
  }
}

