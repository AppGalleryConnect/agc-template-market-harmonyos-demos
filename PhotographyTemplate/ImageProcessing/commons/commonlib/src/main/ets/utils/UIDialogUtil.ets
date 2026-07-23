import { UIDialog } from '@hw-agconnect/ui-dialog';

export interface CommonDialogOption {
  content: string,
  confirmBtnFontColor?: ResourceColor,
  cancelBtnFontColor?: ResourceColor,
}

export class UIDialogUtil {

  public static open(options: CommonDialogOption, confirm: () => void) {
    UIDialog.open({
      content: options.content,
      showConfirmButton: true,
      showCancelButton: true,
      confirmButtonOptions: {
        buttonFontColor: options.confirmBtnFontColor || $r('sys.color.warning'),
        buttonFontSize: 16,
        buttonBgColor: Color.Transparent,
      },
      cancelButtonOptions: {
        buttonFontColor: options.cancelBtnFontColor || $r('sys.color.font_tertiary'),
        buttonFontSize: 16,
        buttonBgColor: Color.Transparent,
      },
      onConfirm: () => {
        confirm();
      },
      closeOnClickMask: false,
      closeOnBackPress: false,
    })
  }
}