import { CommonConstants, PopViewUtils, RouterMap, RouterModule } from 'utils'

export class BookSuccessParam {
  title: string = '';
}

@Builder
export function DialogBookSuccessBuilder(param: BookSuccessParam) {
  Column() {
    Column({ space: 10 }) {
      Image($r('app.media.ic_public_success')).width(50).height(50)

      Text($r('app.string.dialog_book_success_title'))
        .fontSize(20)
        .fontColor('#212121')
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20 })
      Text($r('app.string.dialog_book_success_content'))
        .fontSize(15)
        .fontColor('#434343')
        .margin({ top: 12 })
        .textAlign(TextAlign.Center)
      Text($r('app.string.btn_common_know'))
        .fontSize(15)
        .fontColor($r('app.color.common_theme_color'))
        .borderWidth(1)
        .borderColor($r('app.color.common_theme_color'))
        .borderRadius(24)
        .padding({
          left: 70,
          right: 70,
          top: 15,
          bottom: 15,
        })
        .margin({ top: 17 })
        .onClick(() => {
          PopViewUtils.closePopView();
          RouterModule.popToName(RouterMap.MAIN);
        })
    }
    .width(CommonConstants.FULL_PERCENT)
    .padding({
      left: 23,
      right: 23,
      top: 20,
      bottom: 22,
    })
    .borderRadius(14)
    .backgroundColor($r('app.color.common_card_bg'))
  }
  .width(CommonConstants.FULL_PERCENT)
  .padding({ left: 10, right: 10 })
}