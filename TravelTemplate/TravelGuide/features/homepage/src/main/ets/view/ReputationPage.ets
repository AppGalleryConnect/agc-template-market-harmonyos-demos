/**
 * @usage: 口碑榜页面，展示热门景点排行榜列表，支持查看景点详情
 * @layout: 页面整体采用Stack布局，顶部是大图背景，下方是可滚动的排行榜卡片列表，导航栏固定在顶部
 * @constraints: reputationList数据来源于vm；排名1-3使用金银铜图标，4-10使用普通图标；点击卡片跳转到景点详情页
 * @isGen: true
 * @fileType: page
 * @zhName: 口碑榜
 * @domain: 旅游
 * @image: screenshots/homepage/Reputation.jpg
 * @subPage: AttractionDetailPage
 */
import { BarVM, RouterMap, WindowUtils } from 'common'
import { phoneRouterControl } from 'oh_router'
import { ReputationItem } from '../common/mock/ReputationMockData'
import { ReputationPageVM } from '../viewmodel/ReputationPageVM'
import { AttractionDetailPageBuilder } from './AttractionDetailPage'
import { window } from '@kit.ArkUI';

@Builder
export function ReputationPageBuilder() {
  ReputationPage()
}

@ComponentV2
export struct ReputationPage {
  vm: ReputationPageVM = new ReputationPageVM()
  logTag: string = 'ReputationPage'

  // 根据排名获取图标
  getRankingIcon(rank: number): Resource {
    switch (rank) {
      case 1:
        return $r('app.media.ic_ranking_1')
      case 2:
        return $r('app.media.ic_ranking_2')
      case 3:
        return $r('app.media.ic_ranking_3')
      default:
        return $r('app.media.ic_ranking_4_10')
    }
  }

  build() {
    NavDestination() {
      this.render()
    }
    .hideTitleBar(true)
    .onAppear(() => {
      this.setStatusFontColor('#FFFFFFFF') // 状态栏文字改为白色
    })
    .onDisAppear(() => {
      this.setStatusFontColor('#E6000000') // 恢复默认深色
    })
    .onBackPressed(() => {
      phoneRouterControl.popPage()
      return true
    })
    .backgroundColor($r('sys.color.background_secondary'))
  }

  private setStatusFontColor(color: string) {
    try {
      const w: window.Window = WindowUtils.getMainWindow()
      const sysBarProps: window.SystemBarProperties = {
        statusBarContentColor: color
      }
      w.setWindowSystemBarProperties(sysBarProps)
    } catch (err) {
    }
  }

  @Builder
  render() {
    Stack({ alignContent: Alignment.Top }) {
      Scroll() {
        Column() {
          Image($r('app.media.ic_reputation_header'))
            .width('101%')
            .height(216)
            .objectFit(ImageFit.Cover)

          // 内容区域
          Column() {
            Column({ space: 12 }) {
              ForEach(this.vm.reputationList, (item: ReputationItem) => {
                this.reputationCard(item)
              }, (item: ReputationItem) => item.id.toString())
            }
            .width('100%')
            .padding({ top: 20, left: 16, right: 16, bottom: BarVM.instance.aiBarH + 20 })
          }
          .width('100%')
          .backgroundColor('#FFF')
          .margin({ top: -12 })
          .borderRadius({ topLeft: 16, topRight: 16 })
        }
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
      .scrollable(ScrollDirection.Vertical)

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

  @Builder
  reputationCard(item: ReputationItem) {
    Row({ space: 12 }) {
      // 左侧图片区域（带排名徽章）
      Stack({ alignContent: Alignment.TopStart }) {
        Image(item.image)
          .width(96)
          .height(130)
          .objectFit(ImageFit.Cover)
          .borderRadius(12)

        // 排名徽章（图标+数字，左上角）
        Stack({ alignContent: Alignment.Center }) {
          // 背景图标
          Image(this.getRankingIcon(item.rank))
            .width(30)
            .height(40)
            .objectFit(ImageFit.Contain)

          // 叠加显示数字
          Text(item.rank.toString())
            .fontSize(10)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .margin({ top: 4 })
        }
        .margin({ left: 2, top: -2})
      }
      .width(96)

      // 右侧文字信息区域
      Column({ space: 6 }) {
        // 景点名称
        Text(item.name)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .width('100%')
          .maxLines(1)
          .margin({ bottom: 3 })
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        // 评论数（灰色）
        Text(`${item.reviewCount}条评论`)
          .fontSize(13)
          .fontColor('#666666')
          .width('100%')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        // 旅行热点信息
        Text() {
          Span('旅行热点·')
            .fontColor('#E5800A')
          Span(item.travelHotspot)
            .fontColor('#333333')
        }
        .fontSize(12)
        .layoutWeight(1)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(item.date)
          .fontSize(12)
          .fontColor('#333333')
          .width('100%')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(item.annualList)
          .fontSize(12)
          .fontColor('#E5800A')
          .width('100%')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        // 位置信息
        Row({ space: 4 }) {
          Image($r('app.media.ic_location_new'))
            .width(12)
            .height(12)
          Text(item.location)
            .fontSize(12)
            .fontColor('#999999')
            .layoutWeight(1)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
      }
      .height(118)
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .backgroundColor('#FFF')
    .onClick(() => {
      phoneRouterControl.jumpPage({
        pageName: RouterMap.ATTRACTION_DETAIL_PAGE,
        builder: wrapBuilder(AttractionDetailPageBuilder),
        param: item
      })
    })
  }
}

