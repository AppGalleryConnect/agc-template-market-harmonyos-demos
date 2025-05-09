import { TCRouter } from '../comp/TCRouter';
import { Constants } from '../constant/Constants';
import { BookInfo } from '../model/Book';
import { BookCover } from './CommonUI';

/**
 * 图书小卡，仅有图片+书名
 */
@ComponentV2
export struct BookLittleCard {
  @Param info: BookInfo | undefined = undefined;

  build() {
    Column() {
      BookCover(this.info?.coverUrl, this.info?.isFree);
      Text(this.info?.name)
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium)
        .maxLines(2)
        .padding({ top: 5 })
    }
    .onClick(() => {
      if (this.info) {
        TCRouter.push(Constants.READ_ROUTER, this.info);
      }
    })
  }
}

/**
 * 图书大卡，书名、介绍、评分
 */
@ComponentV2
export struct BookBigCard {
  @Param info: BookInfo | undefined = undefined;

  build() {
    Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceBetween }) {
      BookCover(this.info?.coverUrl, this.info?.isFree);

      Blank()
        .width(20)
      Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceAround }) {
        Column() {
          Row() {
            Text(this.info?.name)
              .fontSize($r('sys.float.Body_L'))
              .fontColor($r('sys.color.font_primary'))
            Row() {
              Image($r('app.media.ic_public_star'))
                .height(15)
                .width(20)
                .padding({ right: 4 })
              Text(`${this.info?.rate}`)
                .fontSize($r('sys.float.Body_M'))
                .fontColor($r('sys.color.font_secondary'))
            }
          }
          .width(Constants.FULL_SIZE)
          .justifyContent(FlexAlign.SpaceBetween)

          Text(this.info?.description)
            .maxLines(3)
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('sys.color.font_secondary'))
            .padding({ top: 10, bottom: 20 })
        }

        Column() {
          Text('作者：' + this.info?.author)
            .fontSize(12)
            .textAlign(TextAlign.Start)
            .width('100%')
        }
        .margin({ top: 20 })

        Divider()
      }
      .width('75%')
    }
    .height(150)
    .width(Constants.FULL_SIZE)
    .onClick(() => {
      if (this.info) {
        TCRouter.push(Constants.READ_ROUTER, this.info);
      }
    })
  }
}