import { AppStorageV2, ComponentContent } from '@kit.ArkUI';
import { GlobalContext } from '../basic/GlobalContext';
import { TCLogger } from '../basic/TCLogger';
import { BreakpointModel } from '../model/BreakpointModel';
import { HMPromptAction } from '../util/HMPromptAction';
import { OHDialogModel } from './OHDialogModel';

const TAG: string = 'HMWeightDialog';

/**
 * 选择弹框
 */
export class OHDialog {
  private constructor() {
  }

  static ShowPopup(model: OHDialogModel) {
    if (HMPromptAction.contentNode === undefined) {
      let uiContext = GlobalContext.getUIContext();
      if (uiContext) {
        let contentNode = new ComponentContent(uiContext, wrapBuilder(buildWeightPopup), model);
        HMPromptAction.uiContext = uiContext;
        HMPromptAction.contentNode = contentNode;
        HMPromptAction.options = {
          alignment: DialogAlignment.Center,
          autoCancel: false,
          onWillDismiss: (reason: DismissDialogAction) => {
            if (reason.reason === DismissReason.PRESS_BACK) {
              return false;
            }
            return true;
          }
        };
        HMPromptAction.openDialog();
      } else {
        TCLogger.info(TAG, `GlobalContext uiContext is empty`);
      }
    }
  }

  static CloseWeightPopup() {
    HMPromptAction.closeDialog();
  }
}

@ComponentV2
struct popup {
  @Param @Require info: OHDialogModel;
  /** 自定义Builder */
  @BuilderParam childBuilder?: (model: OHDialogModel) => void
  @Local breakpointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;

  aboutToAppear(): void {
    this.childBuilder = this.info.childBuilder
  }
  build() {
    Column() {
      Text(this.info.title)
        .fontSize($r('sys.float.Title_S'))
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.Black)
        .width('100%')
        .height($r('app.float.vp_56'))
        .textAlign(TextAlign.Center)

      Blank().height($r('app.float.vp_8'))

      Column() {
        this.childBuilder?.(this.info)
      }

      Blank().height($r('app.float.vp_12'))

      Row() {
        Button('取消')
          .type(ButtonType.Normal)
          .layoutWeight(1)
          .height('100%')
          .backgroundColor(Color.Transparent)
          .fontColor($r('sys.color.font_tertiary'))
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .onClick(() => {
            OHDialog.CloseWeightPopup();
          })

        Blank()
          .height($r('app.float.vp_22'))
          .width('1px')
          .color($r('sys.color.comp_divider'))

        Button('确认')
          .type(ButtonType.Normal)
          .layoutWeight(1)
          .height('100%')
          .backgroundColor(Color.Transparent)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_emphasize'))
          .fontWeight(FontWeight.Medium)
          .onClick(() => {
            OHDialog.CloseWeightPopup();
            this.info?.onValueConfirmClick?.(this.info)
          })
      }
      .width('100%')
      .height($r('app.float.vp_40'))

      Blank().height($r('app.float.vp_16'))
    }
    .backgroundColor(Color.White)
    .width(this.breakpointModel.dialogWidth)
    .borderRadius($r('sys.float.corner_radius_level12'))
  }
}

@Builder
function buildWeightPopup(info: OHDialogModel) {
  popup({ info: info })
}