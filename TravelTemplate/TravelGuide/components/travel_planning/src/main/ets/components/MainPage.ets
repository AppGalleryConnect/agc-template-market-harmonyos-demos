import { City } from 'city_select'
import { RoutePlanningPageVM } from '../viewmodel/RoutePlanningPageVM'
import { SafeAreaUtils } from '../utils/SafeAreaUtils'
import { pushPathByName } from '../utils/RouterUtils'
import { RouteListParams } from '../model/RouteListModel'

// 定义路由名称常量
export const ROUTE_PLANNING_PAGE = 'RoutePlanningPage'

export const ROUTE_CITY_SELECT_PAGE = 'RouteCitySelectPage'

export const ROUTE_LIST_PAGE = 'RouteListPage'

export const ROUTE_DETAIL_PAGE = 'RouteDetailPage'

/**
 * @usage: 路线规划主页面组件，用于选择出发地、目的地和游玩天数，进行智能路线推荐
 * @layout: 单列布局，顶部导航栏+背景图+出发地选择+目的地选择+天数选择+智能推荐按钮
 * @isGen: true
 * @fileType: component
 * @zhName: 路线规划主页面
 * @domain: 旅游
 * @subPage: RouteCitySelectPage, RouteListPage
 */
@Builder
export function RoutePlanningPageBuilder(_param?: string) {
  RoutePlanningPage()
}


@ComponentV2
export struct RoutePlanningPage {
  vm: RoutePlanningPageVM = new RoutePlanningPageVM()
  dayOptions: string[] = Array.from<number, string>({ length: 15 }, (_: number, i: number): string => `${i + 1}天`)
  @Local select: number | number[] = 2
  @Local v: string = ''
  stack: NavPathStack | null = null
  @Local statusBarHeight: number = 24
  @Local bottomSafeArea: number = 0

  async aboutToAppear() {
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
  }

  build() {
    NavDestination() {
      this.render()
    }
    .hideTitleBar(true)
    .backgroundColor(Color.Transparent)
    .onReady((context: NavDestinationContext) => {
      this.stack = context.pathStack
    })
    .onBackPressed(() => {
      this.stack?.pop()
      return true
    })
  }

  @Builder
  render() {
    Column() {
      // 状态栏占位
      Column().height(this.statusBarHeight)

      // 自定义导航栏
      this.customHeader()

      Scroll() {
        Column() {
          // 内容区域
          Column().height(90)
          Column({ space: 10 }) {
            // 出发地
            this.departureCityField()

            // 目的地
            this.destinationCityField()

            // 游玩天数
            this.travelDaysField()
          }
          .width('100%')
          .padding({ left: 16, right: 16, bottom: 20 })
        }
        .alignItems(HorizontalAlign.Start)
        .width('100%')
      }
      .layoutWeight(1)
      .width('100%')
      .align(Alignment.Top)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)

      // 底部按钮
      Column() {
        Text('智能推荐')
          .fontSize(16)
          .fontColor('#333')
          .backgroundColor('#FEE231')
          .width('100%')
          .height('100%')
          .textAlign(TextAlign.Center)
          .borderRadius(24)
      }
      .padding({ left: 16, right: 16 })
      .margin({ bottom: 16 })
      .width('100%')
      .height(43)
      .onClick(() => {
        this.validateAndRecommend()
      })
    }
    .width('100%')
    .height('100%')
    .backgroundImage($r('app.media.ic_route_planning_bg'))
    .backgroundImageSize({ width: '100%' })
    .padding({ bottom: this.bottomSafeArea })
  }

  @Builder
  departureCityField() {
    Row() {
      Text('出发地')
        .fontSize(14)
        .fontColor('#B3000000')
        .fontWeight(400)

      Blank()

      Row({ space: 4 }) {
        Text(this.vm.departureCity)
          .fontSize(16)
          .fontColor('#000')
        Image($r('app.media.ic_right_btn'))
          .width(16)
          .height(16)
      }
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor('#fff')
    .borderRadius(16)
    .onClick(() => {
      const currentCity = this.vm.departureCity === '选择城市' ? '' : this.vm.departureCity
      pushPathByName(this.stack, ROUTE_CITY_SELECT_PAGE, currentCity, (popInfo?: PopInfo) => {
        const result = popInfo?.result as City
        if (result && result.name) {
          this.vm.departureCity = result.name
        }
      }, false)
    })
  }

  @Builder
  destinationCityField() {
    Row() {
      Text('目的地')
        .fontSize(14)
        .fontColor('#B3000000')
        .fontWeight(400)

      Blank()

      Row({ space: 4 }) {
        Text(this.vm.destinationCity)
          .fontSize(16)
          .fontColor('#000')
        Image($r('app.media.ic_right_btn'))
          .width(16)
          .height(16)
      }
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor('#fff')
    .borderRadius(16)
    .onClick(() => {
      const currentCity = this.vm.destinationCity === '选择城市' ? '' : this.vm.destinationCity
      pushPathByName(this.stack, ROUTE_CITY_SELECT_PAGE, currentCity, (popInfo?: PopInfo) => {
        const result = popInfo?.result as City
        if (result && result.name) {
          this.vm.destinationCity = result.name
        }
      }, false)
    })
  }

  @Builder
  travelDaysField() {
    Row() {
      Text('游玩天数')
        .fontSize(14)
        .fontColor('#B3000000')
        .fontWeight(400)

      Blank()

      Row({ space: 4 }) {
        Text(this.vm.travelDays)
          .fontSize(16)
          .fontColor('#000')
        Image($r('app.media.ic_right_btn'))
          .width(16)
          .height(16)
      }
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor('#fff')
    .borderRadius(16)
    .onClick(() => {
      // 初始化 selected，如果已选择过天数，则显示对应的索引
      let currentSelected: number | number[] = 2
      if (this.vm.travelDays !== '选择天数') {
        const currentIndex = this.dayOptions.findIndex((day: string) => day === this.vm.travelDays)
        currentSelected = currentIndex >= 0 ? currentIndex : 2
      }

      this.getUIContext().showTextPickerDialog({
        range: this.dayOptions,
        selected: currentSelected,
        value: this.vm.travelDays === '选择天数' ? '' : this.vm.travelDays,
        selectedTextStyle: { font: { size: 20 } },
        cancelButtonStyle: {
          fontColor: '#99000000',
        },
        onAccept: (value: TextPickerResult) => {
          this.select = value.index
          this.v = value.value as string
          this.vm.travelDays = value.value as string
        },
        onCancel: () => {
        },
      })
    })
  }

  validateAndRecommend(): void {
    const uiContext = this.getUIContext()
    if (!uiContext) {
      return
    }

    if (this.vm.departureCity === '选择城市') {
      uiContext.getPromptAction().showToast({ message: '请选择出发地', duration: 2000 })
      return
    }
    if (this.vm.destinationCity === '选择城市') {
      uiContext.getPromptAction().showToast({ message: '请选择目的地', duration: 2000 })
      return
    }
    if (this.vm.travelDays === '选择天数') {
      uiContext.getPromptAction().showToast({ message: '请选择游玩天数', duration: 2000 })
      return
    }

    // 解析天数
    const daysMatch = this.vm.travelDays.match(/(\d+)/)
    const days = daysMatch ? parseInt(daysMatch[1]) : 1

    // 跳转到列表页面
    if (this.stack) {
      const params: RouteListParams = {
        city: this.vm.destinationCity,
        days: days
      }
      // 将参数序列化为JSON字符串传递
      pushPathByName(this.stack, ROUTE_LIST_PAGE, JSON.stringify(params), undefined, false)
    }
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
}
