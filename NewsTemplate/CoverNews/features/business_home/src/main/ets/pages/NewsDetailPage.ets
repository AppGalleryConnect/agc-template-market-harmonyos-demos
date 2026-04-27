import { AtomicServiceEnhancedWeb } from '@atomicservice/ascfapi';
import { CommonConstants, RouterUtils, TimeUtils } from 'lib_common';
import { NewsDetailPageVM } from '../viewmodels/NewsDetailPageVM';

@Builder
export function NewsDetailPageBuilder() {
  NewsDetailPage()
}

@ComponentV2
export struct NewsDetailPage {
  private vm: NewsDetailPageVM = new NewsDetailPageVM();

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Bottom }) {
        Scroll() {
          Column() {
            if (this.vm.initComplete) {
              AtomicServiceEnhancedWeb({
                src: `data:text/html;charset=utf-8,${this.vm.generateHtml()}`,
                controller: this.vm.atomicWebController,
                navPathStack: RouterUtils.getStack(),
                darkMode: WebDarkMode.Auto,
                forceDarkAccess: true,
                bgColor: $r('sys.color.background_primary'),
                nestedScroll: {
                  scrollUp: NestedScrollMode.PARENT_FIRST, //向上滚动父组件优先
                  scrollDown: NestedScrollMode.SELF_FIRST, //向下滚动子组件优先
                },
              })
                .width('100%')
                .height('100%')
            }
          }
        }
        .width('100%')
        .height('100%')
        .scrollBar(BarState.Off)

        this.likeButton()
      }
      .width('100%')
      .height('100%')
    }
    .title('新闻详情')
    .backgroundColor($r('sys.color.background_primary'))
    .onReady(async (context) => {
      const newsId = context.pathInfo.param as string;
      await this.vm.loadNewsDetail(newsId);
      this.vm.setShareParams();
    })
  }

  @Builder
  newsTitle() {
    Column({ space: CommonConstants.PADDING_S }) {
      Text(this.vm.newsInfo.title)
        .fontSize($r('sys.float.Title_S'))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Start)
      Row({ space: CommonConstants.PADDING_S }) {
        Text(this.vm.newsInfo.source)
          .fontSize($r('sys.float.Body_M'))
          .fontColor($r('sys.color.font_secondary'))
        Text(TimeUtils.formatDate(this.vm.newsInfo.time))
          .fontSize($r('sys.float.Body_M'))
          .fontColor($r('sys.color.font_secondary'))
          .visibility(this.vm.newsInfo.time ? Visibility.Visible : Visibility.None)
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .margin({ top: CommonConstants.PADDING_S })
  }

  @Builder
  likeButton() {
    Button() {
      Column({ space: 4 }) {
        SymbolGlyph($r('sys.symbol.heart_fill'))
          .fontSize(24)
          .fontColor([this.vm.newsInfo.isLiked ? $r('sys.color.warning') : $r('sys.color.font_secondary')])
        Text(this.vm.newsInfo.isLiked ? '2905' : '2904')
          .fontSize($r('sys.float.Body_S'))
          .fontColor(this.vm.newsInfo.isLiked ? $r('sys.color.warning') : $r('sys.color.font_secondary'))
      }
    }
    .width(168)
    .height(56)
    .position({ x: '50%', y: '100%' })
    .translate({ x: '-50%', y: -100 })
    .borderRadius(28)
    .backgroundColor($r('sys.color.comp_background_primary'))
    .shadow({
      offsetX: 0,
      offsetY: 8,
      radius: 48,
      color: '#14000000',
    })
    .onClick(() => {
      this.vm.handleLikeClick();
    })
  }
}