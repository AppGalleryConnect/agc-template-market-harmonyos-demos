/**
 * @usage: 旅游热点页面，展示热门旅游目的地列表，支持查看热点详情
 * @layout: 页面整体采用Stack布局，顶部是大图背景，下方是可滚动的热点卡片列表，导航栏固定在顶部
 * @constraints: travelHotspotList数据来源于vm；点击卡片跳转到景点详情页
 * @isGen: true
 * @fileType: page
 * @zhName: 旅游热点
 * @domain: 旅游
 * @image: screenshots/homepage/TravelHotspot.jpg
 * @subPage: AttractionDetailPage
 */
import { BarVM, RouterMap } from 'common'
import { phoneRouterControl } from 'oh_router'
import { TravelHotspotItem } from '../common/mock/TravelHotspotMockData'
import { TravelHotspotPageVM } from '../viewmodel/TravelHotspotPageVM'
import { ReputationItem } from '../common/mock/ReputationMockData'
import { AttractionDetailPageBuilder } from './AttractionDetailPage'

@Builder
export function TravelHotspotPageBuilder() {
  TravelHotspotPage()
}

@ComponentV2
export struct TravelHotspotPage {
  vm: TravelHotspotPageVM = new TravelHotspotPageVM()
  logTag: string = 'TravelHotspotPage'

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
    Stack({ alignContent: Alignment.Top }) {
      Scroll() {
        Column() {
          // 顶部大图
          Image($r('app.media.ic_travel_hotspot_header'))
            .width('100%')
            .height(216)
            .objectFit(ImageFit.Cover)

          // 内容区域
          Column() {
            Column({ space: 8 }) {
              ForEach(this.vm.travelHotspotList, (item: TravelHotspotItem, index: number) => {
                this.travelHotspotCard(item)
              }, (item: TravelHotspotItem, index: number) => `travel_${index}_${item.id}`)
            }
            .width('100%')
            .padding({ top: 10, left: 16, right: 16, bottom: BarVM.instance.aiBarH + 20 })
          }
          .width('100%')
          .backgroundColor('#FFFFFF')
          .borderRadius({ topLeft: 16, topRight: 16 })
          .margin({ top: -10 })
        }
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.None)

      // 导航栏（覆盖在背景图上，固定在顶部）
      Column() {
        Row() {
          Image($r('app.media.ic_back_white'))
            .width(40)
            .height(40)
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

  // 将 TravelHotspotItem 转换为 ReputationItem
  convertToReputationItem(item: TravelHotspotItem): ReputationItem {
    return {
      id: item.id,
      rank: 0,
      image: item.image,
      name: item.title,
      reviewCount: item.viewCount,
      travelHotspot: item.title,
      date: item.date || '',
      annualList: '',
      location: item.distance || item.location || ''
    }
  }

  @Builder
  travelHotspotCard(item: TravelHotspotItem) {
    Row() {
      // 左侧图片
      Image(item.image)
        .width(96)
        .height(120)
        .objectFit(ImageFit.Cover)
        .borderRadius(12)
        .margin({ right: 10 })

      // 右侧文字信息区域
      Column() {
        // 标题
        Text(item.title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#000000')
          .fontWeight(700)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ bottom: 8 })

        // 观看人数
        Text(`${item.viewCount}人在看`)
          .fontSize(12)
          .fontColor('#FF9229')
          .width('100%')
          .maxLines(1)

        // 日期（如果有）
        if (item.date) {
          Text(item.date)
            .fontSize(12)
            .fontColor('#717376')
            .width('100%')
            .maxLines(1)
            .margin({ top: 5, bottom: 16 })
        }

        // 位置信息（如果有）
        if (item.location) {
          Row() {
            Row() {
              Image($r('app.media.ic_location_new'))
                .width(12)
                .height(12)
              Text(item.location)
                .fontSize(12)
                .fontColor('#999999')
            }
            .alignItems(VerticalAlign.Center)

            if (item.distance) {
              Text(item.distance)
                .fontSize(12)
                .fontColor('#999999')
            }
          }
          .padding({ top: 6, bottom: 6, left: 6, right: 4 })
          .justifyContent(FlexAlign.SpaceBetween)
          .backgroundColor('#08000000')
          .borderRadius(4)
          .width('100%')
          .alignItems(VerticalAlign.Center)
        }
      }
      .layoutWeight(1)
      .alignSelf(ItemAlign.Start)
      .padding({ top: 6, bottom: 6 })
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .onClick(() => {
      const reputationItem = this.convertToReputationItem(item)
      phoneRouterControl.jumpPage({
        pageName: RouterMap.ATTRACTION_DETAIL_PAGE,
        builder: wrapBuilder(AttractionDetailPageBuilder),
        param: reputationItem
      })
    })
  }
}