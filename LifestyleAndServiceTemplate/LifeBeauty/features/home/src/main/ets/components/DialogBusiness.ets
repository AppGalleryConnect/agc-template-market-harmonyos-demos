import { CommonConstants, CommonUtils, PopViewUtils } from 'utils';

export class BusinessParams {
  src: string = '';

  constructor(src: string) {
    this.src = src;
  }
}

@Builder
export function DialogBusinessBuilder(params: BusinessParams) {
  Column() {
    Column({ space: 4 }) {
      Image(CommonUtils.handleImgUrl(params.src)).width(CommonConstants.FULL_PERCENT).objectFit(ImageFit.Contain)
      Button($r('app.string.btn_common_know'))
        .buttonStyle(ButtonStyleMode.TEXTUAL)
        .onClick(() => {
          PopViewUtils.closePopView();
        })
    }
    .width(CommonConstants.FULL_PERCENT)
    .padding({
      left: 10,
      right: 10,
      top: 10,
      bottom: 4,
    })
    .backgroundColor($r('app.color.common_card_bg'))
    .borderRadius(14)
  }
  .width(CommonConstants.SIX_PERCENT)
  .padding({ left: 10, right: 10, top: 100 })
}