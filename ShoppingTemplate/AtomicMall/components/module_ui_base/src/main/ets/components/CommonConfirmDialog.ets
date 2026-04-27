import { AlertDialog } from '@kit.ArkUI';
import { PopViewUtil } from '../utils/PopViewUtil';

export interface IConfirmDialogParams {
  primaryTitle?: ResourceStr;
  secondaryTitle?: ResourceStr;
  content: ResourceStr;
  priBtnV?: ResourceStr;
  secBtnV?: ResourceStr;
  priBtnFg?: ResourceColor;
  secBtnFg?: ResourceColor;
  confirm?: () => void;
  cancel?: () => void;
}

class ConfirmDialogParams implements IConfirmDialogParams {
  primaryTitle: ResourceStr = '';
  secondaryTitle: ResourceStr = '';
  content: ResourceStr = '';
  priBtnV: ResourceStr = '取消';
  secBtnV: ResourceStr = '确定';
  priBtnFg: ResourceColor = $r('app.color.font_color_level2');
  secBtnFg: ResourceColor = $r('app.color.theme_color');
  confirm: () => void = () => {
  };
  cancel: () => void = () => {
  };

  constructor(item: IConfirmDialogParams) {
    this.content = item.content;
    if (item.primaryTitle) {
      this.primaryTitle = item.primaryTitle;
    }
    if (item.secondaryTitle) {
      this.secondaryTitle = item.secondaryTitle;
    }
    if (item.priBtnV) {
      this.priBtnV = item.priBtnV;
    }
    if (item.secBtnV) {
      this.secBtnV = item.secBtnV;
    }
    if (item.priBtnFg) {
      this.priBtnFg = item.priBtnFg;
    }
    if (item.secBtnFg) {
      this.secBtnFg = item.secBtnFg;
    }
    if (item.confirm) {
      this.confirm = item.confirm;
    }
    if (item.cancel) {
      this.cancel = item.cancel;
    }
  }
}

@Builder
function confirmDialogView(params: ConfirmDialogParams) {
  Column() {
    Column() {
      AlertDialog({
        primaryTitle: params.primaryTitle,
        secondaryTitle: params.secondaryTitle,
        content: params.content,
        primaryButton: {
          value: params.priBtnV,
          fontColor: params.priBtnFg || $r('app.color.theme_color'),
          background: Color.Transparent,
          action: () => {
            PopViewUtil.closeDialog();
            params.cancel();
          },
        },
        secondaryButton: {
          value: params.secBtnV,
          fontColor: params.secBtnFg || $r('app.color.font_color_level2'),
          background: Color.Transparent,
          action: () => {
            PopViewUtil.closeDialog();
            params.confirm();
          },
        },
      })
    }
    .width($r('app.string.size_percent_full'))
    .borderRadius($r('app.float.border_radius_xl'))
    .backgroundColor($r('sys.color.comp_background_primary'))
    .constraintSize({ maxWidth: 400 })
  }
  .width($r('app.string.size_percent_full'))
  .padding({
    left: $r('app.float.space_l'),
    right: $r('app.float.space_l'),
  })
}

/**
 * 通用确认弹窗
 */
export class CommonConfirmDialog {
  /**
   * 打开弹窗
   * @param param
   */
  public static show(param: IConfirmDialogParams) {
    PopViewUtil.openDialog<ConfirmDialogParams>(wrapBuilder(confirmDialogView), {}, new ConfirmDialogParams(param));
  }
}