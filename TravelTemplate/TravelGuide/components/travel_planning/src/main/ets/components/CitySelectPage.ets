import { City, CITY_LIST_SAMPLE, CitySelect, CitySelectController, HOT_CITY_LIST_SAMPLE } from 'city_select'
import { SafeAreaUtils } from '../utils/SafeAreaUtils'

/**
 * @usage: 路线规划城市选择页面，用于选择出发地或目的地城市
 * @layout: 单列布局，顶部导航栏+城市选择组件（热门城市+字母索引城市列表）
 * @isGen: false
 * @fileType: component
 * @zhName: 城市选择页面
 * @domain: 旅游
 * @component: CitySelect
 */
@Builder
export function RouteCitySelectPageBuilder(params?: string) {
  RouteCitySelectPage({
    pageParam: params
  })
}

@ComponentV2
struct RouteCitySelectPage {
  @Param pageParam: string = ''
  stack: NavPathStack | null = null
  currentCityName: string = this.pageParam || ''
  @Local currentCity: City = {
    name: this.currentCityName,
    code: this.getCityCodeByName(this.currentCityName) as string || '110000',
  }
  controller: CitySelectController = new CitySelectController()
  @Local statusBarHeight: number = 38
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

  getCityCodeByName(cityName: string): string | undefined {
    if (!cityName || cityName === '') {
      return undefined
    }
    const city = CITY_LIST_SAMPLE.find(city => city.name === cityName || city.name === cityName.replace('市', ''))
    return city?.code
  }

  build() {
    NavDestination() {
      Column() {
        // 自定义导航栏
        this.customHeader()
        this.CityBuilder()
      }
      .width('100%')
      .height('100%')
    }
    .height('100%')
    .width('100%')
    .hideTitleBar(true)
    .padding({
      top: this.statusBarHeight,
      bottom: this.bottomSafeArea
    })
    .onReady((context: NavDestinationContext) => {
      this.stack = context.pathStack
      const param = context.pathInfo.param as string
      if (param) {
        this.currentCityName = param
        this.currentCity = {
          name: this.currentCityName || '北京',
          code: this.getCityCodeByName(this.currentCityName) as string || '110000',
        }
      }
    })
    .onBackPressed(() => {
      if (this.currentCity && this.currentCity.name) {
        this.stack?.pop(this.currentCity)
      } else {
        this.stack?.pop()
      }
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
      .margin({ left: 16 })
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .onClick(() => {
        if (this.currentCity && this.currentCity.name) {
          this.stack?.pop(this.currentCity)
        } else {
          this.stack?.pop()
        }
      })

      Text(`城市选择：${this.currentCity.name}`)
        .fontSize(20)
        .fontWeight(400)
        .fontColor($r('sys.color.font_primary'))
        .margin({ left: 8 })
    }
    .height(40)
    .width('100%')
    .margin({ top: 8, bottom: 8 })
  }

  @Builder
  CityBuilder() {
    Column() {
      CitySelect({
        select: ((city: City) => {
          this.currentCity = city
        }),
        cancel: () => {
          this.stack?.pop()
        },
        cityList: CITY_LIST_SAMPLE,
        hotCityList: HOT_CITY_LIST_SAMPLE,
        controller: this.controller,
      })
    }
    .layoutWeight(1)
    .width('100%')
  }
}