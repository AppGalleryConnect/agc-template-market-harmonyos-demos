import { AlertDialog } from '@kit.ArkUI';
import { Constants } from '../constants/Constants';
import { GridRowColSetting } from '../constants/GridRowColSetting';
import { PopViewUtils } from '../utils/PopViewUtils';

export interface ITipDialogParams {
  primaryTitle?: ResourceStr;
  secondaryTitle?: ResourceStr;
  content: ResourceStr;
  priBtnV?: ResourceStr;
  confirm?: () => void;
}

class TipDialogParams implements ITipDialogParams {
  primaryTitle: ResourceStr = '';
  secondaryTitle: ResourceStr = '';
  content: ResourceStr = '';
  priBtnV: ResourceStr = '确认';
  confirm: () => void = () => {
  };

  constructor(item: ITipDialogParams) {
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
    if (item.confirm) {
      this.confirm = item.confirm;
    }
  }
}

@Builder
function commonTipView(params: TipDialogParams) {
  Column() {
    Column() {
      AlertDialog({
        primaryTitle: params.primaryTitle,
        secondaryTitle: params.secondaryTitle,
        content: params.content,
        primaryButton: {
          value: params.priBtnV,
          background: Color.Transparent,
          action: () => {
            PopViewUtils.closePopView();
            params.confirm();
          },
        },
        secondaryButton: {
          value: '取消',
          fontColor: '#EB5544',
          background: Color.Transparent,
          action: () => {
            PopViewUtils.closePopView();
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
 * 通用通知弹窗
 */
export class CommonTipDialog {
  /**
   * 打开弹窗
   * @param param
   */
  public static show(param: ITipDialogParams) {
    PopViewUtils.showPopView<TipDialogParams>(wrapBuilder(commonTipView), {}, new TipDialogParams(param));
  }
}