/**
 * @usage: 城市指南页面，展示城市的旅游指南信息，包括城市介绍、热门景点推荐，支持切换不同城市查看
 * @layout: 页面整体采用Stack布局，顶部是城市大图背景，下方是可滚动的城市介绍和景点列表
 * @constraints: guideInfo为城市指南数据；attractions为景点列表；点击城市名称可切换到其他城市
 * @isGen: true
 * @fileType: page
 * @zhName: 城市指南
 * @domain: 旅游
 * @image: screenshots/homepage/CityGuide.jpg
 * @subPage: CitySelectPage
 */
import { BarVM, RouterMap, TValueType } from 'common'
import { phoneRouterControl } from 'oh_router'
import { getCityGuideByCityName, CityGuideInfo, CityAttraction } from '../common/mock/CityGuideMockData'
import { CitySelectPageBuilder } from './CitySelectPage'
import { City } from 'city_select'

@Builder
export function CityGuidePageBuilder(param: TValueType) {
  CityGuidePage({
    cityName: (param as string) || '北京'
  })
}

@ComponentV2
export struct CityGuidePage {
  @Param cityName: string = '北京'
  @Local guideInfo: CityGuideInfo | null = null
  @Local currentCityName: string = '北京'

  aboutToAppear(): void {
    this.currentCityName = this.cityName
    this.guideInfo = getCityGuideByCityName(this.cityName)
  }

  // 更新城市信息
  updateCity(newCityName: string): void {
    this.currentCityName = newCityName
    this.guideInfo = getCityGuideByCityName(newCityName)
  }

  build() {
    NavDestination() {
      this.render()
    }
    .hideTitleBar(true)
    .onBackPressed(() => {
      phoneRouterControl.popPage()
      return true
    })
    .backgroundColor($r('sys.color.background_secondary'))
  }

  @Builder
  render() {
    if (this.guideInfo) {
      Stack({ alignContent: Alignment.Top }) {
        Scroll() {
          Stack({ alignContent: Alignment.Top }) {
            // 背景图片
            Image(this.guideInfo.headerImage)
              .width('100%')
              .height(300)
              .objectFit(ImageFit.Cover)

            Column() {
              Column({ space: 12 }) {
                Row() {
                  Text(this.guideInfo.cityName)
                    .fontSize(20)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#000')
                  Image($r('app.media.ic_down'))
                    .width(16)
                    .height(16)
                    .margin({ left: 4 })
                }
                .width('100%')
                .alignItems(VerticalAlign.Center)
                .onClick(() => {
                  phoneRouterControl.jumpPage({
                    pageName: RouterMap.CITY_SELECT_PAGE,
                    builder: wrapBuilder(CitySelectPageBuilder),
                    param: this.currentCityName,
                    onPop: (popInfo: PopInfo) => {
                      let result = popInfo?.result as City;
                      if (result && result.name) {
                        this.updateCity(result.name)
                      }
                    }
                  })
                })

                Text(this.guideInfo.introduction)
                  .fontSize(14)
                  .fontColor('#000')
                  .fontWeight(300)
                  .lineHeight(22)
                  .width('100%')
              }
              .width('100%')
              .padding({ top: 20, left: 16, right: 16 })

              Column({ space: 24 }) {
                ForEach(this.guideInfo.attractions, (attraction: CityAttraction) => {
                  this.attractionItem(attraction)
                }, (attraction: CityAttraction) => attraction.name)
              }
              .width('100%')
              .padding({ top: 26, left: 16, right: 16, bottom: BarVM.instance.aiBarH + 20 })
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
        .edgeEffect(EdgeEffect.Spring)
        .scrollable(ScrollDirection.Vertical)

        Column() {
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
            .backgroundColor('rgba(255, 255, 255, 0.2)')
            .onClick(() => {
              phoneRouterControl.popPage()
            })
          }
          .width('100%')
          .height(40)
          .padding({ left: 16, right: 16 })
        }
        .width('100%')
        .padding({ top: BarVM.instance.staBarH + 8, bottom: 8 })
        .zIndex(100)
      }
      .width('100%')
      .height('100%')
    }
  }

  @Builder
  attractionItem(attraction: CityAttraction) {
    Column({ space: 10 }) {
      Text(attraction.name)
        .fontSize(14)
        .fontWeight(700)
        .fontColor('#000')
        .width('100%')

      Image(attraction.image)
        .width('100%')
        .height(136)
        .borderRadius(12)
        .objectFit(ImageFit.Cover)

      Text(attraction.description)
        .fontSize(14)
        .fontColor('#000')
        .lineHeight(22)
        .fontWeight(300)
        .width('100%')
    }
    .width('100%')
  }
}

