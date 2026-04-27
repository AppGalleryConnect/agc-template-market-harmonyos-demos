/**
 * @usage: 景点详情页面，展示景点的详细信息，包括景点图片、名称、开放时间、位置信息、景点介绍、主题区域等
 * @layout: 页面整体采用Stack布局，顶部是景点大图，下方是可滚动的景点信息卡片
 * @constraints: detail为景点详情数据；themeZones为主题区域列表；点击地图可跳转到景点地图页面
 * @isGen: true
 * @fileType: page
 * @zhName: 景点详情
 * @domain: 旅游
 * @image: screenshots/homepage/AttractionDetail.jpg
 * @subPage: AttractionMapPage
 */
import { BarVM, TValueType, RouterMap } from 'common'
import { phoneRouterControl } from 'oh_router'
import { ReputationItem } from '../common/mock/ReputationMockData'
import { getAttractionDetailById, AttractionDetail, ThemeZone } from '../common/mock/AttractionDetailMockData'
import { AttractionMapPageBuilder } from './AttractionMapPage'

@Builder
export function AttractionDetailPageBuilder(params: TValueType) {
  AttractionDetailPage({
    item: params as ReputationItem
  })
}

@ComponentV2
export struct AttractionDetailPage {
  @Param item: ReputationItem = {
    id: 0,
    rank: 0,
    image: '',
    name: '',
    reviewCount: '',
    travelHotspot: '',
    date: '',
    annualList: '',
    location: ''
  }
  @Local detail: AttractionDetail | undefined = undefined
  private containerScroller: Scroller = new Scroller()

  aboutToAppear() {
    this.detail = getAttractionDetailById(this.item.id)
    // 如果没有找到详情数据，使用默认数据
    if (!this.detail) {
      this.detail = {
        id: this.item.id,
        name: this.item.name,
        headerImage: $r('app.media.ic_reputation_header'),
        openingHours: '今天10:00-22:00开放',
        location: this.item.location,
        locationDetail: '距市中心直线距离30km',
        distance: this.item.location,
        introduction: '这是一个著名的旅游景点，拥有丰富的历史文化和自然景观，是游客必去的打卡地。',
        themeZones: [
          {
            name: '主要景点',
            image: this.item.image,
            description: '这里是该景点的核心区域，展示了丰富的历史文化和自然景观。'
          }
        ]
      }
    }
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
  attractionHeader() {
    Stack({ alignContent: Alignment.TopStart }) {
      if (this.detail) {
        Image(this.detail.headerImage)
          .width('100%')
          .height(300)
          .objectFit(ImageFit.Cover)
      } else {
        Image($r('app.media.ic_reputation_header'))
          .width('100%')
          .height(300)
          .objectFit(ImageFit.Cover)
      }
      Row() {
        Image($r('app.media.ic_back_white')).height(40).width(40)
          .onClick(() => {
            phoneRouterControl.popPage()
          })
      }
      .margin({ top: BarVM.instance.staBarH })
      .padding({ top: 18, left: 16 })
    }
    .margin({ bottom: 8 })
  }

  @Builder
  render() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column() {
        // 滚动区域
        Scroll(this.containerScroller) {
          Column() {
            // 背景图和景点介绍
            this.attractionHeader()

            // 内容区域
            if (this.detail) {
              Column({ space: 20 }) {
                // 景点名称
                Text(this.detail.name)
                  .fontSize(20)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#000000')
                  .width('100%')

                // 开放时间
                Column({ space: 8 }) {
                  Text('开放时间')
                    .fontSize(14)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#333')
                    .alignSelf(ItemAlign.Start)
                  Text(this.detail.openingHours)
                    .fontSize(12)
                    .fontColor('#666666')
                }
                .alignSelf(ItemAlign.Start)
                .padding(8)
                .borderRadius(8)
                .backgroundColor('#F6F8F9')

                // 位置信息
                Stack({ alignContent: Alignment.Top }) {
                  Image($r('app.media.ic_map_bg'))
                    .width('100%')
                    .height('100%')
                    .objectFit(ImageFit.Contain)
                    .borderRadius(12)
                  
                  Row() {
                    Column() {
                      Text(this.detail.location)
                        .fontSize(12)
                        .fontColor('#333333')
                        .fontWeight(500)
                        .maxLines(2)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                      Text(this.detail.locationDetail)
                        .fontSize(10)
                        .fontColor('#717376')
                        .fontWeight(400)
                    }
                    .alignItems(HorizontalAlign.Start)
                    .justifyContent(FlexAlign.SpaceBetween)
                    .height('100%')
                    .width('80%')

                    Column() {
                      Image($r('app.media.ic_location_bg'))
                        .width(32)
                        .height(32)
                      Text('地图')
                        .fontSize(12)
                        .fontColor('#333333')
                        .fontWeight(400)
                    }
                    .justifyContent(FlexAlign.SpaceBetween)
                    .height('100%')
                    .onClick(() => {
                      phoneRouterControl.jumpPage({
                        pageName: RouterMap.ATTRACTION_MAP_PAGE,
                        builder: wrapBuilder(AttractionMapPageBuilder),
                        param: this.detail
                      })
                    })
                  }
                  .height('100%')
                  .width('100%')
                  .justifyContent(FlexAlign.SpaceBetween)
                  .padding({
                    left: 12,
                    right: 16,
                    top: 12,
                    bottom: 12
                  })
                }
                .margin({ top: 0, bottom: 0 })
                .height(79)
                .width('100%')

                // 景点介绍
                Column({ space: 8 }) {
                  Text('景点介绍')
                    .fontSize(18)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#000000')
                  Text(this.detail.introduction)
                    .fontSize(14)
                    .fontColor('#B3000000')
                    .lineHeight(22)
                    .width('100%')
                }
                .width('100%')
                .alignItems(HorizontalAlign.Start)

                // 景点详情
                if (this.detail.themeZones && this.detail.themeZones.length > 0) {
                  Column({ space: 16 }) {
                    ForEach(this.detail.themeZones, (zone: ThemeZone, index) => {
                      Column({ space: 8 }) {
                        Text(zone.name)
                          .fontSize(16)
                          .fontWeight(FontWeight.Medium)
                          .fontColor('#000000')
                          .width('100%')

                        // 景点图片
                        Image(zone.image)
                          .height(80)
                          .width(120)
                          .objectFit(ImageFit.Cover)
                          .borderRadius(12)

                        Text(zone.description)
                          .fontSize(14)
                          .fontColor('#333333')
                          .lineHeight(22)
                          .width('100%')
                      }
                      .width('100%')
                      .alignItems(HorizontalAlign.Start)
                    }, (zone: ThemeZone, index) => `${zone.name}_${index}`)
                  }
                  .width('100%')
                  .alignItems(HorizontalAlign.Start)
                }
              }
              .width('100%')
              .margin({ top: -20 })
              .borderRadius({ topLeft: 24, topRight: 24 })
              .padding({ top: 20, left: 16, right: 16, bottom: 20 })
              .backgroundColor($r('sys.color.background_primary'))
            }
          }
        }
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
      }
      .backgroundColor($r('sys.color.background_secondary'))
    }
  }
}

