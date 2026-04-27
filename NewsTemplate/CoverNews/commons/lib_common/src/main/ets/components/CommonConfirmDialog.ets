import { UIDialog } from '@hw-agconnect/ui-dialog';

export interface IConfirmDialogParams {
  primaryTitle?: ResourceStr;
  secondaryTitle?: ResourceStr;
  content?: ResourceStr;
  contentBuilder?: () => void;
  confirmButton?: ResourceStr;
  cancelButton?: ResourceStr;
  confirmButtonColor?: ResourceColor;
  cancelButtonColor?: ResourceColor;
  confirm?: () => void;
  cancel?: () => void;
}

/**
 * 通用确认弹窗
 */
export class CommonConfirmDialog {
  public static show(param?: IConfirmDialogParams) {
    UIDialog.open({
      titleOptions: {
        primaryTitle: param?.primaryTitle,
      },
      contentOptions: {
        content: param?.content ?? '',
        contentTextAlign: TextAlign.Center,
        contentFontSize: 14,
        contentFontColor: $r('sys.color.font_secondary'),
      },
      contentBuilder: param?.contentBuilder,
      confirmButtonOptions: {
        button: param?.confirmButton,
        buttonFontColor: param?.confirmButtonColor ?? $r('sys.color.warning'),
      },
      cancelButtonOptions: {
        button: param?.cancelButton,
        buttonFontColor: param?.cancelButtonColor ?? $r('sys.color.font_emphasize'),
      },
      showConfirmButton: true,
      showCancelButton: true,
      closeOnClickMask: true,
      closeOnBackPress: true,
      onConfirm: () => {
        UIDialog.closeLast();
        param?.confirm?.()
      },
      onCancel: () => {
        UIDialog.closeLast();
        param?.cancel?.()
      },
    })
  }
}