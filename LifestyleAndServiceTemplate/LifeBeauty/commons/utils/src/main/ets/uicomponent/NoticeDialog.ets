import { AlertDialog } from '@kit.ArkUI';
import { PopViewUtils } from '../common/PopViewUtils';

export class NoticeDialogParams {
  content: ResourceStr = '';
  btnValue: ResourceStr = '好的';
  confirm: () => void = () => {
  };

  constructor(content: ResourceStr, btnValue?: ResourceStr, confirm?: () => void) {
    this.content = content;
    if (btnValue) {
      this.btnValue = btnValue;
    }
    if (confirm) {
      this.confirm = () => {
        confirm();
      };
    }
  }
}

@Builder
export function NoticeDialog(params: NoticeDialogParams) {
  Column() {
    Column() {
      AlertDialog({
        primaryTitle: '',
        secondaryTitle: '',
        content: params.content,
        primaryButton: {
          value: params.btnValue,
          role: ButtonRole.NORMAL,
          action: () => {
            PopViewUtils.closePopView();
            params.confirm();
          },
        },
      })
    }
    .width('100%')
    .borderRadius(32)
    .backgroundColor(Color.White)
  }
  .width('100%')
  .padding({ left: 10, right: 10 })
}