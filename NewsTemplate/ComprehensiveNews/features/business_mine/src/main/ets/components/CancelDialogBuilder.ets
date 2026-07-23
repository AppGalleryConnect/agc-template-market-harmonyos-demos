import { CommonConstants, GridRowColSetting, PopViewUtils } from 'lib_common';
import { Constants } from '../constants/Constants';

export class CancelDialogParams {
  public btnText: string = ''
  public onCancel: () => void = () => {
    PopViewUtils.closePopView();
  }
}

@Builder
export function cancelDialogBuilder(params: CancelDialogParams) {
  Column() {
    Column({ space: CommonConstants.SPACE_XS }) {
      Button(params.btnText)
        .width(CommonConstants.FULL_PERCENT)
        .height(Constants.NORMAL_BTN_H)
        .buttonStyle(ButtonStyleMode.TEXTUAL)
        .fontSize($r('sys.float.Body_L'))
        .fontColor($r('sys.color.warning'))
        .onClick(() => {
          params.onCancel();
        })

      Button('取消')
        .width(CommonConstants.FULL_PERCENT)
        .height(Constants.NORMAL_BTN_H)
        .buttonStyle(ButtonStyleMode.TEXTUAL)
        .fontSize($r('sys.float.Body_L'))
        .fontColor($r('sys.color.font_primary'))
        .onClick(() => {
          PopViewUtils.closePopView();
        })
    }
    .padding({
      top: CommonConstants.PADDING_L,
      bottom: CommonConstants.PADDING_L,
      left: CommonConstants.PADDING_XXL,
      right: CommonConstants.PADDING_XXL,
    })
    .width(CommonConstants.FULL_PERCENT)
    .backgroundColor($r('sys.color.comp_background_primary'))
    .borderRadius($r('app.float.xxl_radius'))
    .constraintSize({ maxWidth: GridRowColSetting.DIALOG_MAX_WIDTH })
  }
  .width(CommonConstants.FULL_PERCENT)
  .padding({
    left: CommonConstants.PADDING_L,
    right: CommonConstants.PADDING_L,
  })
}