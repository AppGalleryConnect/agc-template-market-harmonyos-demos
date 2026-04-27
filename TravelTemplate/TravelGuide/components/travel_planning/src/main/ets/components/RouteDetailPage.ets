import { RouteDetailParams, RouteItem } from '../model/RouteListModel'
import { getAttractionThumbnail } from '../mock/RoutePlanningMockData'
import { SafeAreaUtils } from '../utils/SafeAreaUtils'

/**
 * @usage: 路线详情页面，展示旅游路线的详细行程安排，包括每日景点和游玩建议
 * @layout: 层叠布局，顶部封面图+返回按钮+白色内容区（标题+总览按钮+每日行程列表）
 * @isGen: true
 * @fileType: component
 * @zhName: 路线详情页面
 * @domain: 旅游
 */
@Builder
export function RouteDetailPageBuilder(params?: RouteDetailParams) {
  RouteDetailPage({
    pageParam: params
  })
}

@ComponentV2
struct RouteDetailPage {
  @Param pageParam: RouteDetailParams | null = null
  stack: NavPathStack | null = null
  @Local statusBarHeight: number = 38
  @Local bottomSafeArea: number = 0
  @Local route: RouteItem | null = null

  aboutToAppear() {
    // 使用 getUIContext() 获取 UIContext，然后传递给 SafeAreaUtils
    const uiContext = this.getUIContext()
    // 异步更新真实值
    SafeAreaUtils.getTopArea(uiContext).then((height: number) => {
      if (height > 0) {
        this.statusBarHeight = height
      }
    })
    SafeAreaUtils.getBottomArea(uiContext).then((height: number) => {
      if (height > 0) {
        this.bottomSafeArea = height
      }
    })

    // 加载数据
    if (this.pageParam) {
      this.route = this.pageParam.route
    }
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Top }) {
        Scroll() {
          Stack({ alignContent: Alignment.Top }) {
            // 背景图片（使用线路的封面图）
            Image(this.route?.coverImage || $r('app.media.post_cover_01'))
              .width('100%')
              .height(300)
              .objectFit(ImageFit.Cover)

            Column() {
              // 标题和总览按钮
              Column({ space: 12 }) {
                Text(this.route?.title || '')
                  .fontSize(20)
                  .fontColor('#333')
                  .fontWeight(FontWeight.Medium)
                  .width('100%')
                  .margin({ top: 20 })


                Text('总览')
                  .fontSize(14)
                  .fontColor('#fff')
                  .backgroundColor('#333')
                  .borderRadius(8)
                  .width(80)
                  .height(36)
                  .textAlign(TextAlign.Center)
                  .margin({ top: 8 })

              }
              .width('100%')
              .alignItems(HorizontalAlign.Start)
              .padding({ left: 16, right: 16 })

              // 行程列表
              Column({ space: 16 }) {
                if (this.route) {
                  ForEach(this.route.attractions, (attraction: string, index: number) => {
                    this.dayItemBuilder(index + 1, attraction, this.route?.city || '')
                  }, (attraction: string, index: number) => `day_${index}`)
                }
              }
              .width('100%')
              .padding({
                top: 24,
                left: 16,
                right: 16,
                bottom: this.bottomSafeArea + 24
              })
            }
            .width('100%')
            .backgroundColor('#fff')
            .borderRadius({ topLeft: 16, topRight: 16 })
            .margin({ top: 290 })
            .zIndex(10)
          }
          .width('100%')
        }
        .width('100%')
        .height('100%')
        .scrollBar(BarState.Off)
        .align(Alignment.Top)
        .edgeEffect(EdgeEffect.None, { alwaysEnabled: false })

        // 导航栏（固定在顶部）
        Column() {
          Row() {
            Button() {
              SymbolGlyph($r('sys.symbol.chevron_backward'))
                .fontSize(24)
                .fontWeight(FontWeight.Normal)
            }
            .width(40)
            .height(40)
            .type(ButtonType.Circle)
            .backgroundColor('rgba(255, 255, 255, 0.2)')
            .onClick(() => {
              this.stack?.pop()
            })
          }
          .width('100%')
          .height(40)
          .padding({ left: 16, right: 16 })
        }
        .width('100%')
        .padding({ top: this.statusBarHeight + 8, bottom: 8 })
        .zIndex(100)
      }
      .width('100%')
      .height('100%')
    }
    .height('100%')
    .width('100%')
    .hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      this.stack = context.pathStack
      const paramStr = context.pathInfo.param as string
      if (paramStr) {
        try {
          const param = JSON.parse(paramStr) as RouteDetailParams
          if (param && param.route) {
            this.route = param.route
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
  dayItemBuilder(day: number, attraction: string, city: string) {
    Text(`第${day}天·${city}`)
      .fontSize(16)
      .fontColor('#333')
      .fontWeight(FontWeight.Medium)
      .width('100%')
    Row({ space: 12 }) {
      Column() {
        Image($r('app.media.ic_attraction_icon'))
          .width(20)
          .height(20)
          .objectFit(ImageFit.Contain)
        Column()
          .height(57)
          .width(0.5)
          .backgroundColor('#1A000000')
          .margin({ top: 4 })
      }

      Column() {
        Text(attraction)
          .fontSize(14)
          .fontColor('#000')

        // 口碑榜标签
        Row() {
          Image($r('app.media.ic_top_badge'))
            .height(16)
            .objectFit(ImageFit.Contain)
          Text('口碑榜')
            .fontSize(12)
            .fontColor('#C77634')
        }
        .margin({ top: 8 })

        // 建议游玩时间和开放时间
        Text('建议玩1-2天')
          .fontSize(12)
          .fontColor('#666')
          .margin({ top: 6, bottom: 4 })
        Text('09:00-20:00开放')
          .fontSize(12)
          .fontColor('#666')
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      // 右侧缩略图
      Image(getAttractionThumbnail(attraction, this.route?.city))
        .width(80)
        .height(80)
        .borderRadius(8)
        .objectFit(ImageFit.Cover)
    }
    .width('100%')
    .padding({ bottom: 16 })
    .height(97)
  }
}

