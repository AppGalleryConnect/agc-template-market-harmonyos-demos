import { BreakpointModel, Constants, RouterMap } from 'common'
import { phoneRouterControl } from 'oh_router'
import { DrawingBoardBuilder } from './DrawingBoardPage'
import { AppStorageV2 } from '@kit.ArkUI'
import { DrawBoardListPageBuilder } from './DrawBoardListPage'

@Builder
export function HomeDrawingPageBuilder() {
  HomeDrawingPage()
}

/**
 * @usage: 绘画首页，展示创建新画板的横幅广告和"我的画本"入口，支持折叠屏适配。
 * @layout: 页面采用垂直布局(Column)，顶部为标题行(Row)，下方为可滚动列表(List)。列表包含两个 ListItem：
 * 第一项为横幅广告(Stack 布局，图片作为背景，文字和按钮叠加在左上角)，
 * 第二项为'我的画本'入口(Row 横向布局，左侧为图标和文字，右侧为箭头)。
 * @constraints: 横幅图片资源(home_banner、home_banner_fold)不可删除，横幅标题(home_banner_title)和
 * 描述(home_banner_description)可通过资源文件定制。'我的画本'入口不可删除，是访问画作列表的唯一入口。
 * @isGen: true
 * @fileType: page
 * @zhName: 绘画首页
 * @domain: 绘画
 * @subPage: DrawingBoardPage,DrawBoardListPage
 * @image: screenshots/home.jpg
 */
@ComponentV2
struct HomeDrawingPage {
  @Local breakpointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;

  build() {
    Column() {
      Row() {
        Text($r('app.string.home_tab'))
          .fontSize($r('app.float.vp_26'))
          .width(Constants.FULL_SIZE)
          .fontColor(Color.Black)
          .fontWeight(FontWeight.Medium)
          .textAlign(TextAlign.Start)
      }
      .padding({
        left: $r('app.float.vp_16'),
        right: $r('app.float.vp_16'),
        top: $r('app.float.vp_12'),
        bottom: $r('app.float.vp_12')
      })

      List() {
        ListItem() {
          this.bannerItem()
        }

        ListItem() {
          this.listEntryItem()
        }
      }
      .padding($r('app.float.vp_12'))
      .scrollBar(BarState.Off)
      .layoutWeight(1)
      .width(Constants.FULL_SIZE)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
      .friction(0.6)

    }
    .height(Constants.FULL_SIZE)
    .width(Constants.FULL_SIZE)
  }

  @Builder
  listEntryItem() {
    Row() {
      Row() {
        Image($r('app.media.sketchbook'))
          .width($r('app.float.vp_24'))
          .aspectRatio(1)
          .objectFit(ImageFit.Cover)

        Text($r('app.string.home_sketchbook'))
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
          .fontSize($r('app.float.vp_16'))
          .lineHeight($r('app.float.vp_16'))
          .margin({ left: $r('app.float.vp_12') })
      }
      .layoutWeight(1)

      Image($r('app.media.right_arrow'))
        .width($r('app.float.vp_12'))
        .height($r('app.float.vp_24'))
        .objectFit(ImageFit.Cover)
    }
    .width(Constants.FULL_SIZE)
    .padding($r('app.float.vp_12'))
    .height($r('app.float.vp_48'))
    .borderRadius($r('sys.float.corner_radius_level8'))
    .backgroundColor($r('app.color.home_sketchbook_column'))
    .onClick(() => {
      phoneRouterControl.jumpPage({
        pageName: RouterMap.DRAWING_BOARD_LIST,
        builder: wrapBuilder(DrawBoardListPageBuilder)
      })
    })
  }

  @Builder
  bannerItem() {
    Stack({ alignContent: Alignment.TopStart }) {
      Image(this.breakpointModel.currentDisplayWidth > 450 ? $r('app.media.home_banner_fold') :
      $r('app.media.home_banner'))
        .width(Constants.FULL_SIZE)
        .borderRadius($r('sys.float.corner_radius_level8'))
        .height(180)
        .objectFit(ImageFit.Auto)
      Text($r('app.string.home_banner_title'))
        .fontWeight(FontWeight.Bold)
        .fontSize($r('app.float.vp_20'))
        .lineHeight($r('app.float.vp_20'))
        .fontColor($r('app.color.mask_black'))
        .margin({ top: $r('app.float.vp_20'), left: $r('app.float.vp_20') })
      Row() {
        Text($r('app.string.home_banner_description'))
          .fontSize($r('app.float.vp_14'))
          .fontColor($r('app.color.mask_black'))
          .fontWeight(FontWeight.Medium)
          .lineHeight($r('app.float.vp_14'))
          .textAlign(TextAlign.Start)
          .margin({ top: $r('app.float.vp_3'), right: $r('app.float.vp_4') })
        Image($r('app.media.icon_right'))
          .width($r('app.float.vp_14'))
          .aspectRatio(1)
          .objectFit(ImageFit.Cover)
      }
      .backgroundColor($r('app.color.banner_button_background'))
      .padding({
        left: $r('app.float.vp_10'),
        right: $r('app.float.vp_10'),
      })
      .alignItems(VerticalAlign.Center)
      .borderRadius($r('app.float.vp_15'))
      .height($r('app.float.vp_30'))
      .margin({ top: $r('app.float.vp_130'), left: $r('app.float.vp_20') })
      .onClick(() => {
        phoneRouterControl.jumpPage({
          pageName: RouterMap.DRAWING_BOARD,
          builder: wrapBuilder(DrawingBoardBuilder)
        })
      })
    }
    .margin({ bottom: $r('app.float.vp_16') })
    .height($r('app.float.vp_180'))
    .borderRadius($r('sys.float.corner_radius_level8'))
  }
}