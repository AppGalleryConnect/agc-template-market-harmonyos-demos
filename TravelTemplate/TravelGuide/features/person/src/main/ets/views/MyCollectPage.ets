/**
 * @usage: 我的收藏页面，展示用户收藏的旅游产品列表，支持查看收藏详情
 * @layout: 页面整体采用垂直布局（Column），顶部是通用头部组件，下方是旅游产品网格列表或空状态提示
 * @constraints: tourCollectList为收藏数据源，从本地持久化存储获取；collectList为筛选后的收藏产品列表
 * @isGen: true
 * @fileType: page
 * @zhName: 我的收藏
 * @domain: 旅游
 * @image: screenshots/person/MyCollect.jpg
 * @subPage: TourDetailPage
 * @component: CommonHeader,TourGrid
 */
import { CommonHeader, RouterMap } from 'common';
import { MockTourListService, TourCollectListModel, TourGrid, TourModel } from 'common_travel_guide';
import { OHPage, phoneRouterControl } from 'oh_router';
import { PersistenceV2 } from '@kit.ArkUI';

@Builder
export function MyCollectPageBuilder() {
  MyCollectPage();
}

@ComponentV2
export struct MyCollectPage {
  // 收藏列表
  @Local tourCollectList: TourCollectListModel =
    PersistenceV2.connect(TourCollectListModel, 'tourCollectListArr', () => new TourCollectListModel())!;
  // 列表数据
  @Local mockTourList: TourModel[] = MockTourListService.tourResult
  @Local collectList: TourModel[] = []

  aboutToAppear(): void {
    let ids = this.tourCollectList.tourCollectList.map((item) => item.id)
    this.collectList = this.mockTourList.filter((item: TourModel) => ids.includes(item.id))
  }

  // 页面内容渲染
  @Builder
  render() {
    Column() {
      CommonHeader({
        title: '我的收藏',
        onReturnClick: () => {
          phoneRouterControl.popPage();
        },
      })

      //旅游列表
      if (this.collectList.length > 0) {
        TourGrid({
          tourList: this.collectList,
          jumpTourDetailPage: (listItem: TourModel) => {
            phoneRouterControl.jumpPage({
              pageName: RouterMap.TOUR_DETAIL_PAGE,
              param: listItem
            })
          }
        })
      } else {
        Column() {
          Image($r('app.media.ic_no_hotel')).height(106).objectFit(ImageFit.Contain).margin({ bottom: 20 })
          Text('暂无内容').fontSize(15).fontColor('rgba(0, 0, 0, 0.60)')
        }.width('100%').layoutWeight(1).alignItems(HorizontalAlign.Center).justifyContent(FlexAlign.Center)
      }

    }
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Start)
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.background_secondary'))
  }

  build() {
    OHPage({
      childBuilder: () => {
        this.render();
      },
      useSafePadding: true,
      isFullScreen: true,
    })
  }
}

