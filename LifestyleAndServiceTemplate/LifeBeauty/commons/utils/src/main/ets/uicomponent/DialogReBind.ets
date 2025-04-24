import { AlertDialog } from '@kit.ArkUI';
import { CommonConstants } from '../common/Constant';
import { PopViewUtils } from '../common/PopViewUtils'

export class RebindParams {
  cancelClose: () => void = () => {
  };
  confirmClose: () => void = () => {
  };

  constructor(confirmClose: () => void, cancelClose: () => void) {
    this.confirmClose = confirmClose;
    this.cancelClose = cancelClose;
  }
}

@Builder
export function DialogRebindBuilder(params: RebindParams) {
  Column() {
    Column() {
      AlertDialog({
        primaryTitle: '',
        secondaryTitle: '',
        content: $r('app.string.rebind_phone_title'),
        primaryButton: {
          value: $r('app.string.rebind_phone_other'),
          role: ButtonRole.NORMAL,
          action: () => {
            params.cancelClose();
            PopViewUtils.closePopView();
          },
        },
        secondaryButton: {
          value: $r('app.string.rebind_phone_yes'),
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