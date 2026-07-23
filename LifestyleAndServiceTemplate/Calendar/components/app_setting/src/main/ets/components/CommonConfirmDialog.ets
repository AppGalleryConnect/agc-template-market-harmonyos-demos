import { AppStorageV2 } from '@kit.ArkUI';
import { CommonConstants } from '../constants/CommonConstants';
import { CustomConfigModel } from '../models/CustomConfigModel';
import { GridRowColSetting } from '../common/GridRowColSetting';
import { PopViewUtils } from '../common/PopViewUtils';
import { FontModel } from '../models/FontModel';

/**
 * 通用确认弹窗
 */
export class CommonConfirmDialog {
  /**
   * 打开弹窗
   * @param param
   */
  public static show(param: IConfirmDialogParams) {
    PopViewUtils.showPopView<ConfirmDialogParams>(wrapBuilder(confirmDialogBuilder), {},
      new ConfirmDialogParams(param));
  }
}

@Builder
function confirmDialogBuilder(params: ConfirmDialogParams) {
  ConfirmDialog({
    data: params,
  })
}

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
  configInfo: CustomConfigModel = AppStorageV2.connect(CustomConfigModel, () => new CustomConfigModel())!
  primaryTitle: ResourceStr = '';
  secondaryTitle: ResourceStr = '';
  content: ResourceStr = '';
  priBtnV: ResourceStr = '取消';
  secBtnV: ResourceStr = '确定';
  priBtnFg: ResourceColor = this.configInfo.themeColor;
  secBtnFg: ResourceColor = this.configInfo.themeColor;
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

@ComponentV2
struct ConfirmDialog {
  @Require @Param data: ConfirmDialogParams;
  @Local fontModel: FontModel = AppStorageV2.connect(FontModel, () => new FontModel())!;

  build() {
    Column() {
      Column() {
        Column() {
          Text(this.data.primaryTitle)
            .fontSize(this.fontModel.getFg(20))
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Bold)
            .visibility(this.data.primaryTitle ? Visibility.Visible : Visibility.None)

          Text(this.data.secondaryTitle)
            .fontSize(this.fontModel.getFg(14))
            .fontColor($r('sys.color.font_secondary'))
            .fontWeight(FontWeight.Regular)
            .visibility(this.data.secondaryTitle ? Visibility.Visible : Visibility.None)
            .margin({
              top: CommonConstants.PADDING_S,
            })
        }
        .width(CommonConstants.FULL_PERCENT)
        .padding({
          left: CommonConstants.PADDING_XXL,
          right: CommonConstants.PADDING_XXL,
          top: CommonConstants.PADDING_L,
          bottom: CommonConstants.PADDING_L,
        })

        Scroll() {
          Text(this.data.content)
            .fontSize(this.fontModel.getFg(16))
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Regular)
            .padding({
              left: CommonConstants.PADDING_XXL,
              right: CommonConstants.PADDING_XXL,
              top: CommonConstants.PADDING_M,
              bottom: CommonConstants.PADDING_M,
            })
        }
        .scrollBar(BarState.Off)

        Row() {
          Button() {
            Text(this.data.priBtnV)
              .fontSize(this.fontModel.getFg(16))
              .fontColor(this.data.priBtnFg)
              .maxFontScale(3.2)
          }
          .buttonStyle(ButtonStyleMode.TEXTUAL)
          .layoutWeight(1)
          .padding({ top: CommonConstants.PADDING_M, bottom: CommonConstants.PADDING_M })
          .onClick(() => {
            PopViewUtils.closePopView();
            this.data.cancel();
          })

          Divider()
            .vertical(true)
            .height(24)
            .margin({ left: CommonConstants.PADDING_S, right: CommonConstants.PADDING_S })

          Button() {
            Text(this.data.secBtnV)
              .fontSize(this.fontModel.getFg(16))
              .fontColor(this.data.secBtnFg)
              .maxFontScale(3.2)
          }
          .buttonStyle(ButtonStyleMode.TEXTUAL)
          .layoutWeight(1)
          .padding({ top: CommonConstants.PADDING_M, bottom: CommonConstants.PADDING_M })
          .onClick(() => {
            PopViewUtils.closePopView();
            this.data.confirm();
          })
        }
        .width(CommonConstants.FULL_PERCENT)
        .padding({
          left: CommonConstants.PADDING_L,
          right: CommonConstants.PADDING_L,
          bottom: CommonConstants.PADDING_L,
        })
      }
      .width(CommonConstants.FULL_PERCENT)
      .borderRadius($r('app.float.xxl_radius'))
      .backgroundColor($r('sys.color.comp_background_primary'))
      .constraintSize({ maxWidth: GridRowColSetting.DIALOG_MAX_WIDTH })
      .clip(true)
    }
    .width(CommonConstants.FULL_PERCENT)
    .padding({
      left: CommonConstants.PADDING_L,
      right: CommonConstants.PADDING_L,
    })
  }
}
