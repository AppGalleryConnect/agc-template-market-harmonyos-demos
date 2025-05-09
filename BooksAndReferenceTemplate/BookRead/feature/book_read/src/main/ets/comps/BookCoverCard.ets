import { BookInfo, Constants, NavHeaderBar } from 'common';


@ComponentV2
export struct BookCoverCard {
  @Param @Require book: BookInfo;

  build() {
    Column() {
      NavHeaderBar({
        title: $r('app.string.read'),
        hasBackButton: false,
        hasBgColor: false,
        isMainPage: true,
      })

      Stack() {
        Image($r('app.media.book_image_1'))
          .objectFit(ImageFit.Auto)
          .borderRadius(10)
      }.width(168)
      .height(232)

      .margin({ top: 10 })


      Column() {
        // 黑色加粗
        Text(this.book.name)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('sys.color.font_primary'))
          .textAlign(TextAlign.Start)
          .width(Constants.FULL_SIZE)
          .height(50)

        // 灰色
        Text(this.book.author)
          .fontSize($r('sys.float.Body_M'))
          .fontColor($r('sys.color.font_secondary'))
          .textAlign(TextAlign.Start)
          .width(Constants.FULL_SIZE)
          .height(20)

        Row({ space: 50 }) {
          Column({ space: 5 }) {
            Row() {
              Text(this.book.rate)
                .fontSize(15)
                .fontColor($r('sys.color.font_primary'))
              Text(' ')
              Text($r('app.string.rating_point'))
                .fontSize(12)
                .fontColor($r('sys.color.font_secondary'))
            }

            Text($r('app.string.popular'))
              .fontSize(12)
              .fontColor($r('sys.color.font_secondary'))
          }

          Column({ space: 5 }) {
            Row() {
              Text(this.book.count)
                .fontSize(15)
                .fontColor($r('sys.color.font_primary'))
              Text(' ')
              Text($r('app.string.ten_thousand_words'))
                .fontSize(12)
                .fontColor($r('sys.color.font_secondary'))
            }

            Text($r('app.string.publishing_house'))
              .fontSize(12)
              .fontColor($r('sys.color.font_secondary'))
          }

          Column({ space: 5 }) {
            Row() {
              Text(this.book.popular)
                .fontSize(15)
                .fontColor($r('sys.color.font_primary'))
              Text(' ')
                .fontSize(12)
                .fontColor($r('sys.color.font_secondary'))
              Text($r('app.string.ten_thousand'))
                .fontSize(12)
                .fontColor($r('sys.color.font_secondary'))
            }

            Text($r('app.string.popular'))
              .fontSize(12)
              .fontColor($r('sys.color.font_secondary'))
          }
        }
        .width(Constants.FULL_SIZE)
        .justifyContent(FlexAlign.Center)
        .padding({ top: 25 })
      }
      .width(Constants.FULL_SIZE)
      .height(200)
      .padding({ top: 20, left: 30, right: 30 })

      Blank()
        .height(200)
      Text($r('app.string.start_reading'))
    }.width(Constants.FULL_SIZE)
    .height(Constants.FULL_SIZE)
  }
}