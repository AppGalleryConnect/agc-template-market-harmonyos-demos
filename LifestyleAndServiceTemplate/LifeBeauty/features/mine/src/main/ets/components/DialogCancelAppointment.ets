import { AlertDialog } from '@kit.ArkUI';
import { CommonConstants, PopViewUtils } from 'utils'

export class CancelAppointmentParams {
  confirmClose: () => void = () => {
  };

  constructor(confirmClose: () => void) {
    this.confirmClose = confirmClose;
  }
}

@Builder
export function DialogCancelAppointmentBuilder(params: CancelAppointmentParams) {
  Column() {
    Column() {
      AlertDialog({
        primaryTitle: '',
        secondaryTitle: '',
        content: $r('app.string.dialog_cancel_appoint_title'),
        primaryButton: {
          value: $r('app.string.dialog_cancel_appoint_no'),
          role: ButtonRole.NORMAL,
          action: () => {
            PopViewUtils.closePopView();
          },
        },
        secondaryButton: {
          value: $r('app.string.dialog_cancel_appoint_yes'),
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