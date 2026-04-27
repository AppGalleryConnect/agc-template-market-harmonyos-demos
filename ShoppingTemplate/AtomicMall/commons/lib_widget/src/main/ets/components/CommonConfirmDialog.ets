import { UIDialog } from '@hw-agconnect/ui-dialog';

export interface IConfirmDialogParams {
  primaryTitle?: ResourceStr;
  secondaryTitle?: ResourceStr;
  content: ResourceStr;
  confirm?: () => void;
  cancel?: () => void;
}

/**
 * 通用确认弹窗
 */
export class CommonConfirmDialog {
  public static show(param: IConfirmDialogParams) {
    UIDialog.open({
      titleOptions: {
        primaryTitle: param.primaryTitle,
        secondaryTitle:param.secondaryTitle,
      },
      contentOptions: {
        content: param.content,
        contentTextAlign: TextAlign.Center,
      },
      confirmButtonOptions: {
        buttonFontColor: $r('sys.color.multi_color_07'),
      },
      cancelButtonOptions: {
        buttonFontColor: $r('sys.color.font_secondary'),
      },
      showConfirmButton: true,
      showCancelButton: true,
      closeOnClickMask: true,
      closeOnBackPress: true,
      onConfirm: () => {
        UIDialog.closeLast();
        param.confirm?.();
      },
      onCancel: () => {
        UIDialog.closeLast();
        param.cancel?.();
      },
    });
  }
}