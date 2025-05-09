import { TitleBar } from '@components/titlebar';
import { IWaterFlow } from '@components/iwaterflow';
import { LoadingStatus } from '@common/customtypes';
import { Style } from '@common/const';
import { buildCategoryBrowser } from '@guis/browser';
import { buildSearchSuggestionCarousel } from '@guis/search';

import { HomePageLogic } from '../logic/HomePageLogic';
import { iResourceMgr } from '@common/resource';

@ComponentV2
export struct HomePage {
  private logic: HomePageLogic = new HomePageLogic();

  build(): void {
    /**
     * Column、Refresh、Scroll 需要取消安全区避让
     *
     * 1. 保证瀑布流中内容可以从屏幕最底部浮现
     *
     * 2. 底部页签实现了沉浸式并覆盖在了首页之上, 由于其针对首页带有专属模糊效果, 首页底部应
     *    同步保持沉浸式, 防止模糊取色时受到安全区颜色影响
     */
    Column() {
      /**
       * 在标题栏中嵌入搜索建议轮播组件
       *
       * 元服务胶囊距离屏幕右侧有一段距离, 因此轮播组件的 Padding 也使用这个距离, 保持视觉风格统一
       */
      TitleBar({
        hideBackButton: true,
        barPadding: {
          left: Style.MENU_BAR_MARGIN_RIGHT,
          right: Style.MENU_BAR_MARGIN_RIGHT,
        },
      }) {
        buildSearchSuggestionCarousel(this.logic.searchSuggestionCarouselLogic);
      };

      /**
       * Refresh 容器用于实现下拉刷新
       *
       * 注: 页面处于 LoadingStatus.SUCCESS 状态时才会允许下拉手势
       */
      Refresh({
        refreshing: $$this.logic.isRefreshing,
        builder: buildRefreshingContent(this.logic),
      }) {
        /**
         * Scroll 容器用于承载分类、瀑布流等组件
         *
         * 例如在瀑布流区域上划时, 通常希望页面整体移动, 而不仅仅是瀑布流中内容移动
         */
        Scroll() {
          Stack({ alignContent: Alignment.TopStart }) {
            /**
             * 由于外层 Stack 的高度设置了 'auto', 当前 Column 用于实现以下效果
             *
             * 1. 保证 Stack 的最小高度为 '100%'
             * 2. 保证 Stack 的前 '100%' 高度拥有一段渐变背景色
             */
            Column()
              .width('100%')
              .height('100%')
              .linearGradient({
                colors: [['#FFFFFFFF', 0.6], ['#00FFFFFF', 1.0]], // 从 30% 的位置开始渐变, 到 60% 的位置渐变完毕
              });
            /**
             * 页面首次尝试加载时的显示内容
             *
             * 仅用于 LOADING 状态, 后续可能出现的 RELOADING 状态不会再使用这个内容
             */
            if (this.logic.loadingStatus === LoadingStatus.LOADING) {
              Column() {
                LoadingProgress()
                  .width(37)
                  .height(37);
              }
              .width('100%')
              .height('45%')
              .alignItems(HorizontalAlign.Center)
              .justifyContent(FlexAlign.End);
            } else if (this.logic.loadingStatus === LoadingStatus.SUCCESS) {
              Column() {
                Swiper() {
                  Image(iResourceMgr.resolveUri('app://dev/media/banner/mock_homepage_banner2.jpg'))
                    .width('100%')
                    .height('100%')
                    .objectFit(ImageFit.Cover)
                    .draggable(false);
                  Image(iResourceMgr.resolveUri('app://dev/media/banner/mock_homepage_banner3.jpg'))
                    .width('100%')
                    .height('100%')
                    .objectFit(ImageFit.Cover)
                    .draggable(false);
                  Image(iResourceMgr.resolveUri('app://dev/media/banner/mock_homepage_banner4.jpg'))
                    .width('100%')
                    .height('100%')
                    .objectFit(ImageFit.Cover)
                    .draggable(false);
                }
                .width('100%')
                .indicator(false)
                .autoPlay(true)
                // .indicator(
                //   new DotIndicator()
                //     .selectedColor($r('sys.color.mask_fourth'))
                //     .color('#80FFFFFF')
                // )
                .aspectRatio(4 / 3) // height=width/aspectRatio
                //.borderRadius(16)
                .clip(true);

                buildCategoryBrowser(this.logic.categoryBrowserLogic);
                IWaterFlow({
                  logic: this.logic.iWaterFlowLogic,
                  footerPadding: { bottom: 48, top: (170 - 48) * 0.4 },
                })
                  .padding({ left: 10, right: 10 });
              };

              /**
               * 页面加载失败时的显示内容
               *
               * 注: 只要加载成功一次, 后续再发起的 '加载' 实际上是刷新操作, 刷新失败不会再使用这个内容
               */
            } else {
              Column() {
                Text('当前页面加载失败，请重新发起尝试')
                  .fontSize(13)
                  .margin({ bottom: 15 })
                  .fontColor($r('sys.color.mask_secondary'));
                Button() {
                  Row() {
                    Text('重新加载')
                      .fontSize(13)
                      .fontColor(Color.White);
                    if (this.logic.loadingStatus === LoadingStatus.RELOADING) {
                      LoadingProgress()
                        .width(18)
                        .height(18)
                        .margin({ left: 6 })
                        .color($r('sys.color.icon_on_primary'));
                    }
                  }
                  .alignItems(VerticalAlign.Center);
                }
                .width(100)
                .height(33)
                .type(ButtonType.Normal)
                .backgroundColor('#FFE64566')
                .borderRadius(14)
                .onClick(this.logic.onReloading);
              }
              .width('100%')
              .height('45%')
              .alignItems(HorizontalAlign.Center)
              .justifyContent(FlexAlign.End);
            }
          }
          .height('auto');
        }
        .height('100%')
        .scrollBar(BarState.Off)
        .backgroundColor('#FFF1F3F5')
        .borderRadius({ topLeft: 8, topRight: 8 })
        .edgeEffect(
          this.logic.iWaterFlowLogic.isEnd ||
            this.logic.loadingStatus !== LoadingStatus.SUCCESS
            ? EdgeEffect.None : EdgeEffect.Spring,
        )
        .expandSafeArea([SafeAreaType.SYSTEM, SafeAreaType.CUTOUT], [SafeAreaEdge.BOTTOM]);
      }
      .layoutWeight(1)
      .onStateChange(this.logic.onRefreshStateChange)
      .pullDownRatio(this.logic.loadingStatus === LoadingStatus.SUCCESS ? 1 : 0)
      .expandSafeArea([SafeAreaType.SYSTEM, SafeAreaType.CUTOUT], [SafeAreaEdge.BOTTOM]);
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Start)
    .backgroundColor('#FFE64566')
    .expandSafeArea([SafeAreaType.SYSTEM, SafeAreaType.CUTOUT], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);
  }
}

@Builder
function buildRefreshingContent(logic: HomePageLogic) {
  Stack() {
    if (logic.refreshStatus === RefreshStatus.Refresh) {
      LoadingProgress()
        .height(32)
        .color($r('sys.color.icon_on_primary'));
    } else if (logic.refreshStatus === RefreshStatus.OverDrag) {
      Text('释放可刷新页面')
        .fontColor(Color.White)
        .fontSize(13)
        .lineHeight(32)
        .halfLeading(true);
    } else if (logic.refreshStatus === RefreshStatus.Drag) {
      Text('下拉刷新')
        .fontColor(Color.White)
        .fontSize(13)
        .lineHeight(32)
        .halfLeading(true);
    }
  }
  .align(Alignment.Center)
  .clip(true)
  .constraintSize({ minHeight: 32 })
  .width('100%');
}

@Builder
export function buildHomePage() {
  HomePage();
}
