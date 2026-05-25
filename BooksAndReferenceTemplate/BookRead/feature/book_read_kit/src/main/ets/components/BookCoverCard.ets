import {
  BookApi,
  BookInfo,
  Constants,
  NavHeaderBar,
  TCRouter,
  GroupBook,
  BreakpointStorage,
  BreakpointSystem,
  BreakpointTypeEnum,
  FontModel
} from 'common';
import { ReviewDataUtil } from '../utils/ReviewDataUtil';
import { ReviewInfo } from '../model/ReviewModels';
import { AppStorageV2 } from '@kit.ArkUI';

@ComponentV2
export struct BookCoverCard {
  @Param @Require book: BookInfo;
  @Local isAddSuccess: boolean = false;
  @Local wonderfulReviews: ReviewInfo[] = [];
  @Local curBreakpoint: BreakpointStorage = BreakpointSystem.currentBreakpoint
  @Local fontModel: FontModel = AppStorageV2.connect(FontModel, () => new FontModel())!;

  async aboutToAppear(): Promise<void> {
    const rsp = await BookApi.getBooksShelfGroup('favBooks', Constants.API_GET_BOOK_FAVOURITE_PATH, '');
    let books: GroupBook[] = rsp.books;
    books.forEach((book) => {
      let index = book?.groupBooks?.findIndex(book => this.book.id === book.id)
      if (book?.singleBook?.id === this.book.id || index !== -1) {
        this.isAddSuccess = true;
        return;
      }
    });
    ReviewDataUtil.setCurrentBookInfo(this.book);
    this.wonderfulReviews = ReviewDataUtil.getWonderfulReviews().slice(0, 2);
  }

  // 获取付费状态文本
  getFreeText(isFree?: string): ResourceStr {
    switch (isFree) {
      case '0':
        return $r('app.string.free');
      case '1':
        return $r('app.string.member');
      case '2':
        return $r('app.string.paid');
      default:
        return $r('app.string.free');
    }
  }

  // 获取付费状态颜色
  getFreeColor(isFree?: string): ResourceStr {
    switch (isFree) {
      case '0':
        return $r('sys.color.ohos_id_color_palette4');
      case '1':
        return $r('sys.color.ohos_id_color_palette10');
      case '2':
        return $r('sys.color.ohos_id_color_badge_red');
      default:
        return $r('sys.color.ohos_id_color_palette4');
    }
  }

  // 获取书籍状态文本
  getStatusText(status?: string): ResourceStr {
    switch (status) {
      case '0':
        return $r('app.string.no_completed');
      case '1':
        return $r('app.string.completed');
      default:
        return $r('app.string.no_completed');
    }
  }

  // 构建星级评分组件
  @Builder
  buildStarRating(rating: number) {
    Row() {
      ForEach(Array.from<number, number>({ length: 5 }, (_, index) => index + 1), (star: number) => {
        Image($r('app.media.ic_public_star'))
          .width(12)
          .height(12)
          .margin({ right: 2 })
          .fillColor(star <= rating ? '#FFD700' : '#E0E0E0')
      }, (item: string) => JSON.stringify(item))
    }
  }

  // 书籍信息
  @Builder
  buildBookInfoCard() {
    Column() {
      Row() {
        Stack() {
          Image(typeof this.book.coverUrl === 'string' ? $r(this.book.coverUrl) : this.book.coverUrl)
            .width(104)
            .height(144)
            .objectFit(ImageFit.Cover)
            .borderRadius(8)

          Text(this.getFreeText(this.book.isFree))
            .fontSize(this.fontModel.getFg(10))
            .fontColor(Color.White)
            .textAlign(TextAlign.Center)
            .height(20)
            .width(35)
            .backgroundColor(this.getFreeColor(this.book.isFree))
            .borderRadius(10)
            .position({ x: 69, y: 0 })
        }
        .margin({ right: 16 })

        Column() {
          Text(this.book.name)
            .fontSize(this.fontModel.getFg(14))
            .lineHeight(19)
            .fontFamily('HarmonyHeiTi')
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')
            .textAlign(TextAlign.Start)

          Row({ space: 4 }) {
            Text(this.book.author + ' ' + '著')
              .fontSize(this.fontModel.getFg(12))
              .fontColor($r('sys.color.font_secondary'))
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          .margin({ top: 8 })
          .width('100%')
          .alignItems(VerticalAlign.Top)

          Row({ space: 4 }) {
            Text(this.getStatusText(this.book.status))
              .fontSize(this.fontModel.getFg(12))
              .fontColor($r('sys.color.font_secondary'))
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          .margin({ top: 4 })
          .width('100%')
          .alignItems(VerticalAlign.Top)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)

      Row({ space: 50 }) {
        Column({ space: 5 }) {
          Row() {
            Text(this.book.rate)
              .fontSize(this.fontModel.getFg(16))
              .fontColor($r('sys.color.font_primary'))
            Text(' ')
            Text($r('app.string.rating_point'))
              .fontSize(this.fontModel.getFg(12))
              .fontColor($r('sys.color.font_secondary'))
          }

          Text($r('app.string.rating'))
            .fontSize(this.fontModel.getFg(12))
            .fontColor($r('sys.color.font_secondary'))
        }

        Column({ space: 5 }) {
          Row() {
            Text(this.book.count)
              .fontSize(this.fontModel.getFg(16))
              .fontColor($r('sys.color.font_primary'))
            Text(' ')
            Text($r('app.string.ten_thousand_words'))
              .fontSize(this.fontModel.getFg(12))
              .fontColor($r('sys.color.font_secondary'))
          }

          Text($r('app.string.publishing_house'))
            .fontSize(this.fontModel.getFg(12))
            .fontColor($r('sys.color.font_secondary'))
        }

        Column({ space: 5 }) {
          Row() {
            Text(this.book.popular)
              .fontSize(this.fontModel.getFg(16))
              .fontColor($r('sys.color.font_primary'))
            Text(' ')
            Text($r('app.string.ten_thousand'))
              .fontSize(this.fontModel.getFg(12))
              .fontColor($r('sys.color.font_secondary'))
          }

          Text($r('app.string.popular'))
            .fontSize(this.fontModel.getFg(12))
            .fontColor($r('sys.color.font_secondary'))
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .margin({ top: 24 })
    }
    .width('100%')
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .borderRadius(16)
    .padding(16)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  buildBookDescriptionCard() {
    Column() {
      Text($r('app.string.briefly'))
        .fontSize(this.fontModel.getFg(16))
        .lineHeight(21)
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'))
        .margin({ bottom: 12 })
        .width('100%')
        .textAlign(TextAlign.Start)

      // 添加分割线
      Divider()
        .margin({ bottom: 12 })

      Text(this.book.description || $r('app.string.no_briefly'))
        .fontSize(this.fontModel.getFg(12))
        .lineHeight(20)
        .fontColor($r('sys.color.font_primary'))
        .maxLines(3)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')
        .margin({ bottom: 12 })

      Blank()
      // 书籍类别标签
      Row() {
        Text(this.book.category || $r('app.string.no_classify'))
          .fontSize(this.fontModel.getFg(14))
          .fontFamily('HarmonyHeiTi')
          .fontWeight(400)
          .letterSpacing(0)
          .textAlign(TextAlign.Center)
          .fontColor($r('sys.color.font_primary'))
          .padding({ left: 12, right: 12 })
      }
      .width(76)
      .height(28)
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .borderRadius(14)
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height(this.curBreakpoint.value === BreakpointTypeEnum.SM ? 'auto' : 233)
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .borderRadius(16)
    .padding(16)
    .alignItems(HorizontalAlign.Start)
  }

  // 精彩书评
  @Builder
  buildWonderfulReviewCard() {
    Column() {
      Row() {
        Text($r('app.string.wonderful_book_reviews'))
          .fontSize(this.fontModel.getFg(16))
          .lineHeight(21)
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))

        Blank()

        Row({ space: 4 }) {
          Text($r('app.string.more_book_reviews'))
            .fontSize(this.fontModel.getFg(12))
            .fontColor($r('sys.color.font_secondary'))

          Image($r('app.media.ic_public_right_arrow'))
            .width(16)
            .height(16)
            .fillColor($r('sys.color.font_secondary'))
        }
        .onClick(() => {
          TCRouter.push(Constants.WONDERFUL_REVIEW_ROUTE, {
            bookName: this.book.name,
            fromCompleted: false
          });
        })
      }
      .width('100%')
      .margin({ bottom: 16 })

      if (this.wonderfulReviews.length > 0) {
        Column() {
          ForEach(this.wonderfulReviews, (review: ReviewInfo, index: number) => {
            Column() {
              Row() {
                Image(review.avatar)
                  .width(32)
                  .height(32)
                  .borderRadius(16)
                  .margin({ right: 12 })

                Text(review.content.toString())
                  .fontSize(this.fontModel.getFg(12))
                  .lineHeight(18)
                  .fontColor($r('sys.color.font_primary'))
                  .maxLines(2)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .layoutWeight(1)
              }
              .width('100%')
              .alignItems(VerticalAlign.Top)

              if (index < this.wonderfulReviews.length - 1) {
                Divider()
                  .margin({ top: 12, bottom: 12 })
              }
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
          }, (review: ReviewInfo) => review.id)
        }
        .width('100%')
        .backgroundColor($r('sys.color.comp_background_list_card'))
        .borderRadius(16)
        .padding(16)
      } else {
        Column() {
          Text('暂无评论')
            .fontSize(this.fontModel.getFg(14))
            .fontColor($r('sys.color.font_secondary'))
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
        }
        .width('100%')
        .height(100)
        .backgroundColor($r('sys.color.comp_background_list_card'))
        .borderRadius(16)
        .padding(20)
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  build() {
    Column() {
      NavHeaderBar({
        title: $r('app.string.read'),
        hasBackButton: true,
        hasBgColor: false,
        isMainPage: true,
      })

      Scroll() {
        Column({ space: 16 }) {
          if (this.curBreakpoint.value === BreakpointTypeEnum.SM) {
            // 书籍信息
            this.buildBookInfoCard()
            // 书籍简介
            this.buildBookDescriptionCard()
            // 精彩书评
            this.buildWonderfulReviewCard()
          } else {
            Row({ space: 12 }) {
              Column() {
                this.buildBookInfoCard()
              }.layoutWeight(1)

              Column() {
                this.buildBookDescriptionCard()
              }.layoutWeight(1)
            }.width('100%')

            this.buildWonderfulReviewCard()
          }
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 20 })
      }
      .layoutWeight(1)
      .edgeEffect(EdgeEffect.Spring)
      .scrollBar(BarState.Off)
      .align(Alignment.Top)

      Text($r('app.string.start_reading'))
        .fontSize(this.fontModel.getFg(14))
        .fontColor($r('sys.color.font_secondary'))
        .margin({ top: 12, bottom: 24 })
        .textAlign(TextAlign.Center)
        .padding({
          left: 20,
          right: 20,
          top: 12,
          bottom: 12
        })
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .borderRadius(14)
    }
    .width(Constants.FULL_SIZE)
    .height(Constants.FULL_SIZE)
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
  }
}