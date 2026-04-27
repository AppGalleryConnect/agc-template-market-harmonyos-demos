/**
 * @usage: 旅行足迹页面，展示用户的旅行足迹记录，支持按年份分组展示城市足迹卡片，并在地图上高亮可视化去过的城市区域
 * @layout: 页面整体采用垂直布局（Column），使用Footprint组件展示足迹列表和地图
 * @constraints: footPrints数据来源于postList，按发布时间的年份分组；支持添加新足迹和查看足迹详情
 * @isGen: true
 * @fileType: page
 * @zhName: 旅行足迹
 * @domain: 旅游
 * @image: screenshots/journey/JourneyFootprint.jpg
 * @subPage: PublishPostPage
 * @component: Footprint
 */
import { AppStorageV2, window } from '@kit.ArkUI';
import { RouterMap, WindowUtils } from 'common';
import { MyPostList } from 'common_travel_guide';
import { PostDetailPageBuilder } from 'homepage';
import { OHPage, OHPageConfig, phoneRouterControl } from 'oh_router'
import { PublishPostPageBuilder } from 'person';
import { PublishPageType } from 'person/src/main/ets/constants/PostPageType';
import { Footprint, FootPrintItem } from 'travel_footprint';

@Builder
export function JourneyFootprintPageBuilder() {
  JourneyFootprintPage();
}

@ComponentV2
export struct JourneyFootprintPage {
  @Local postList: MyPostList = AppStorageV2.connect(MyPostList, () => new MyPostList())!
  @Local footPrints: FootPrintItem[] = []

  @Monitor('postList.list.length')
  onDataChange() {
    this.initData()
  }

  aboutToAppear() {
    this.initData()
    this.setStatusFontColor()
  }

  initData() {
    if (!this.postList.list.length) {
      return
    }
    this.footPrints = this.postList.list.map(item => {
      return {
        year: item.publishTime.split('-')[0],
        city: item.publishLocation,
        img: item.coverImg,
        id: item.id
      } as FootPrintItem
    })
  }

  setStatusFontColor(color?: string) {
    try {
      let w: window.Window = WindowUtils.getMainWindow()
      let sysBarProps: window.SystemBarProperties = {
        statusBarContentColor: color ? color : '#E5FFFFFF',
      }
      w.setWindowSystemBarProperties(sysBarProps)
    } catch (err) {
    }
  }

  // 页面内容渲染
  @Builder
  render() {
    Column() {
      Footprint({
        footPrints: this.footPrints,
        returnClick: () => {
          phoneRouterControl.popPage()
        },
        addPostClick: () => {
          const params: PublishPageType = PublishPageType.FOOTPRINT
          phoneRouterControl.jumpPage({
            pageName: RouterMap.PUBLISH_POST_PAGE,
            builder: wrapBuilder(PublishPostPageBuilder),
            param: params
          })
        },
        jumpPostClick: (id) => {
          let item = this.postList.getDataById(id)
          phoneRouterControl.jumpPage({
            pageName: RouterMap.POST_DETAIL_PAGE,
            builder: wrapBuilder(PostDetailPageBuilder),
            param: item
          })
        }
      })
    }
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Start)
    .width('100%')
    .height('100%')
  }

  build() {
    OHPage({
      childBuilder: () => {
        this.render();
      },
      pageConfig: new OHPageConfig({
        onPageHide: () => {
          this.setStatusFontColor('#000000')
        },
        onPageShow: () => {
          this.setStatusFontColor()
        }
      }),
      linearGradientColor: [['#0A0B15', 0.0], ['#1B2C3A', 1.0]]
    })
  }
}
