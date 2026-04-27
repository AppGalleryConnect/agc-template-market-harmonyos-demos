import { AlertDialog } from '@kit.ArkUI';
import { Constants } from '../constants/Constants';
import { GridRowColSetting } from '../constants/GridRowColSetting';
import { PopViewUtils } from '../utils/PopViewUtils';

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
  priBtnFg: ResourceColor = '#EB5544';
  secBtnFg: ResourceColor = '#EB5544';
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
          fontColor: params.priBtnFg || '#EB5544',
          background: Color.Transparent,
          action: () => {
            PopViewUtils.closePopView();
            params.cancel();
          },
        },
        secondaryButton: {
          value: params.secBtnV,
          fontColor: params.secBtnFg || '#EB5544',
          background: Color.Transparent,
          action: () => {
            PopViewUtils.closePopView();
            params.confirm();
          },
        },
      })
    }
    .width(Constants.FULL_PERCENT)
    .borderRadius(32)
    .backgroundColor($r('sys.color.comp_background_primary'))
    .constraintSize({ maxWidth: GridRowColSetting.DIALOG_MAX_WIDTH })
  }
  .width(Constants.FULL_PERCENT)
  .padding({
    left: Constants.PADDING_L,
    right: Constants.PADDING_L,
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
    PopViewUtils.showPopView<ConfirmDialogParams>(wrapBuilder(confirmDialogView), {}, new ConfirmDialogParams(param));
  }
}