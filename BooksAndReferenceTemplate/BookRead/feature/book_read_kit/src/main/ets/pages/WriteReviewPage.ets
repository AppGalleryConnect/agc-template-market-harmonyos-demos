import { Constants, NavHeaderBar, TCRouter, BookInfo } from 'common';
import { WriteReviewVM } from '../viewmodel/WriteReviewVM';
import { ReviewInfo, ReviewFilterType } from '../model/ReviewModels';
import { ReviewDataUtil } from '../utils/ReviewDataUtil';
import { ExpandableText } from '../components/ExpandableText';
import { emitter } from '@kit.BasicServicesKit';

interface RouteParams {
  bookName?: string;
}

@ComponentV2
@Preview
export struct WriteReviewPage {
  @Local bookName: string = '全部书评';
  vm: WriteReviewVM = new WriteReviewVM();
  @Local reviewList: ReviewInfo[] = [];

  aboutToAppear(): void {
    console.info('WriteReviewPage aboutToAppear');

    // 初始化评论系统，确保用户信息同步
    ReviewDataUtil.initialize();

    const params = TCRouter.getParams<RouteParams>(Constants.ALL_REVIEW_ROUTE);
    if (params && params.bookName) {
      this.bookName = params.bookName;
      console.info('获取到书名参数:', this.bookName);
    }
    this.loadReviews();
    try {
      // 监听用户信息变更事件
      emitter.on(Constants.LOGIN_CHANGE, () => {
        console.info('用户信息变更，更新评论用户信息');
        ReviewDataUtil.updateCurrentUserReviews();
        this.loadReviews();
      });
    } catch (e) {
      console.error('Failed to emitter on login change. Cause: ' + JSON.stringify(e));
    }
  }

  onPageShow(): void {
    this.loadReviews();
  }

  loadReviews(): void {
    this.reviewList = ReviewDataUtil.getAllReviews();
    this.filterReviews();
  }

  filterReviews(): void {
    if (this.vm.currentFilter === ReviewFilterType.LATEST) {
      this.reviewList.sort((a, b) => new Date(b.createTime).getTime() - new Date(a.createTime).getTime());
    } else {
      this.reviewList.sort((a, b) => b.rating - a.rating);
    }
  }

  toggleFilter(filterType: ReviewFilterType): void {
    this.vm.currentFilter = filterType;
    this.filterReviews();
  }

  // 构建星级评分组件
  @Builder
  buildStarRating(rating: number) {
    Row() {
      ForEach(Array.from<number, number>({ length: 5 }, (_, index) => index + 1), (star: number) => {
        Image($r('app.media.ic_public_star'))
          .width(16)
          .height(16)
          .margin({ right: 4 })
          .fillColor(star <= rating ? '#FFD700' : '#E0E0E0')
      }, (item: string) => JSON.stringify(item))
    }
  }

  // 构建筛选按钮
  @Builder
  buildFilterButtons() {
    Row({ space: 12 }) {
      Row() {
        Text($r('app.string.all'))
          .fontSize(14)
          .fontColor(this.vm.currentFilter === ReviewFilterType.ALL ?
            $r('sys.color.ohos_id_color_background') : $r('sys.color.font_primary'))
      }
      .width(72)
      .height(28)
      .backgroundColor(this.vm.currentFilter === ReviewFilterType.ALL ?
        $r('sys.color.multi_color_08') : $r('sys.color.comp_background_tertiary'))
      .borderRadius(16)
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        this.toggleFilter(ReviewFilterType.ALL);
      })

      Row({ space: 4 }) {
        Text($r('app.string.latest'))
          .fontSize(14)
          .fontColor(this.vm.currentFilter === ReviewFilterType.LATEST ?
            $r('sys.color.ohos_id_color_background') : $r('sys.color.font_primary'))

        Image($r('app.media.time_interval'))
          .width(12)
          .height(12)
      }
      .width(72)
      .height(28)
      .backgroundColor(this.vm.currentFilter === ReviewFilterType.LATEST ?
        $r('sys.color.multi_color_08') : $r('sys.color.comp_background_tertiary'))
      .borderRadius(16)
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        this.toggleFilter(ReviewFilterType.LATEST);
      })
    }
    .margin({ bottom: 16 })
  }

  // 构建单个评论项
  @Builder
  buildReviewItem(review: ReviewInfo, index: number) {
    Column() {
      Row() {
        Image(review.avatar)
          .width(40)
          .height(40)
          .borderRadius(20)
          .margin({ right: 12 })

        Column() {
          Row() {
            Text(review.username)
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.ohos_id_color_text_primary'))

            if (review.isVip && review.vipLevel) {
              Text(review.vipLevel)
                .fontSize(10)
                .fontColor(Color.White)
                .padding({
                  left: 6,
                  right: 6,
                  top: 2,
                  bottom: 2
                })
                .backgroundImage($r('app.media.lv_bg'))
                .backgroundImageSize(ImageSize.Contain)
                .margin({ left: 5 })
            }
          }
          .width('100%')
          .alignItems(VerticalAlign.Center)

          this.buildStarRating(review.rating)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)
      .margin({ bottom: 12 })

      ExpandableText({
        content: review.content.toString(),
        fontSize: 14,
        lineHeight: 20,
        fontColor: $r('sys.color.ohos_id_color_text_primary'),
        widthRatio: 0.85
      })
        .margin({ bottom: 8 })

      if (index < this.reviewList.length - 1) {
        Divider()
          .margin({ bottom: 16 })
      } else {
        Blank()
          .height(40)
      }
    }
    .width('100%')
    .margin({ top: 5 })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  buildReviewListSection() {
    Column() {
      this.buildFilterButtons()

      Column({ space: 0 }) {
        ForEach(this.reviewList, (review: ReviewInfo, index: number) => {
          this.buildReviewItem(review, index);
        }, (review: ReviewInfo) => review.id)
      }
    }
    .width('100%')
    .padding({
      left: 16,
      right: 16,
      top: 20,
      bottom: 20
    })
    .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
    .borderRadius(16)
    .alignItems(HorizontalAlign.Start)
  }

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: this.bookName,
          hasBackButton: true,
          hasBgColor: false,
          isMainPage: true,
        })

        Column() {
          Scroll() {
            this.buildReviewListSection()
          }
          .layoutWeight(1)
          .scrollable(ScrollDirection.Vertical)
          .edgeEffect(EdgeEffect.Spring)
          .scrollBar(BarState.Off)
          .padding({ left: 16, right: 16, bottom: 40 })

          Blank()
        }
        .width('100%')
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
    }
    .hideTitleBar(true)
  }
} 