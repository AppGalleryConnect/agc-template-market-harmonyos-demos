import { AlertDialog } from '@kit.ArkUI';
import { CommonConstants } from '../common/Constant';
import { PopViewUtils } from '../common/PopViewUtils';

export class CancelBindParams {
  confirmClose: () => void = () => {
  };

  constructor(confirmClose: () => void) {
    this.confirmClose = confirmClose;
  }
}


@Builder
export function DialogCancelBindBuilder(params: CancelBindParams) {
  Column() {
    Column() {
      AlertDialog({
        primaryTitle: '',
        secondaryTitle: '',
        content: $r('app.string.cancel_relate_phone_title'),
        primaryButton: {
          value: $r('app.string.btn_common_cancel'),
          role: ButtonRole.NORMAL,
          action: () => {
            PopViewUtils.closePopView();
          },
        },
        secondaryButton: {
          value: $r('app.string.btn_common_confirm'),
          role: ButtonRole.ERROR,
          action: () => {
            PopViewUtils.closePopView();
            params.confirmClose();
          },
        },
      })
    }
    .width(CommonConstants.FULL_PERCENT)
    .borderRadius(32)
    .backgroundColor($r('app.color.common_card_bg'))
  }
  .width(CommonConstants.FULL_PERCENT)
  .padding({ left: 10, right: 10 })
}