import { CommonConstants, PopViewUtils } from 'utils';

export class QRCodeParams {
  qrcode: string = '';

  constructor(qrcode?: string) {
    this.qrcode = qrcode ?? '';
  }
}

@Builder
export function DialogQRCodeBuilder(params: QRCodeParams) {
  Column() {
    Column({ space: 10 }) {
      Image($r('app.media.ic_public_close_sheet'))
        .width(40)
        .height(40)
        .alignSelf(ItemAlign.End)
        .onClick(() => {
          PopViewUtils.closePopView();
        })

      QRCode(params.qrcode).width(150).height(150).margin({ top: 24, bottom: 24 })
      Text(params.qrcode).fontSize(16)
    }
    .width(CommonConstants.FULL_PERCENT)
    .padding({
      left: 20,
      right: 20,
      top: 12,
      bottom: 33,
    })
    .borderRadius(32)
    .backgroundColor(Color.White)
  }
  .padding({ left: 10, right: 10 })

}