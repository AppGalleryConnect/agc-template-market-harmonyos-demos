import { Constants, TimeUtils, UserInfo } from 'common';


@ComponentV2
export struct BorrowCard {
  @Local qrCodeValue: string = 'hello';
  @Param userInfo: UserInfo | undefined = undefined;

  build() {
    Column({ space: 20 }) {
      Image(this.userInfo?.avatarUrl ? this.userInfo?.avatarUrl : $r('app.media.ic_default_hd'))
        .height(64)
        .width(64)
      Text(`ID：${this.userInfo?.id}`)
        .fontSize($r('sys.float.Body_L'))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Bolder)
      Column() {
        QRCode(this.qrCodeValue)
          .width(250)
          .height(250)
          .padding({ top: 30 })
      }
      .width(300)
      .height(300)
      .shadow({ radius: 10, color: Color.Gray })
      .borderRadius(5)

      Column({ space: 30 }) {
        Text($r('app.string.borrow_book_flag'))
          .fontSize(12)
          .fontColor($r('sys.color.font_primary'))

        Column({ space: 5 }) {
          Text($r('app.string.borrow_card_expire'))
          Text(`${TimeUtils.timestamp2YMD(this.userInfo?.borrowCardStart)} - ${TimeUtils.timestamp2YMD(this.userInfo?.borrowCardEnd)}`)
            .fontSize(14)
            .maxLines(1)
            .fontColor($r('sys.color.font_primary'))
        }
        .padding({ top: 20, left: 25 })
      }
    }
    .backgroundColor(Color.White)
    .width(Constants.FULL_SIZE)
    .height(600)
    .padding({
      left: 16,
      right: 16,
      bottom: 30,
      top: 30
    })
  }
}