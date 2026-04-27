import { AppStorageV2, ComponentContent } from '@kit.ArkUI';
import { BreakpointModel, GlobalContext, HMPromptAction, TCLogger } from 'common';
import { HealthDataInputDialogModel } from '../viewmodel/HealthDataInputDialogModel';

const TAG: string = 'HealthDataInputDialog';

export class HealthDataInputDialog {
  private constructor() {
  }

  static ShowInputPopup(dataInputDialogModelVM: HealthDataInputDialogModel) {
    if (HMPromptAction.contentNode === undefined) {
      let uiContext = GlobalContext.getUIContext();
      if (uiContext) {
        let contentNode = new ComponentContent(uiContext, wrapBuilder(buildInputPopup), dataInputDialogModelVM);
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

  static CloseInputPopup() {
    HMPromptAction.closeDialog();
  }
}

@ComponentV2
struct popup {
  @Param @Require dataInputDialogModelVM: HealthDataInputDialogModel;
  @Local breakpointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;

  build() {
    Column() {
      Text(this.dataInputDialogModelVM.title)
        .fontSize($r('sys.float.Title_S'))
        .fontColor(Color.Black)
        .width('100%')
        .lineHeight($r('app.float.vp_28'))
        .textAlign(TextAlign.Center)

      Blank().height($r('app.float.vp_34'))

      Row() {
        TextInput({
          text: this.dataInputDialogModelVM.value.toString(),
          placeholder: '0'
        })
          .type(InputType.Normal)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.mask_secondary'))
          .placeholderFont({ size: $r('sys.float.Body_L') })
          .placeholderColor($r('sys.color.font_secondary'))
          .backgroundColor(Color.Transparent)
          .layoutWeight(1)
          .onChange((value: string) => {
            const isValidInput = /^(\d+|\d+\.\d*|\.\d+|\d*\.?)$/.test(value);
            if (isValidInput) {
              this.dataInputDialogModelVM.value = Number(value);
            } else {
              GlobalContext.getUIContext().getPromptAction().showToast({
                message: '请输入正确数据，不要包含其他字符',
              });
            }
          })

        Text(this.dataInputDialogModelVM.unit)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.mask_secondary'))
      }
      .width('100%')
      .height($r('app.float.vp_48'))

      Blank().height($r('app.float.vp_30'))

      Row() {
        Button($r('app.string.health_dialog_cancel'))
          .type(ButtonType.Normal)
          .layoutWeight(1)
          .height('100%')
          .backgroundColor(Color.Transparent)
          .fontColor($r('sys.color.font_tertiary'))
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .onClick(() => {
            HealthDataInputDialog.CloseInputPopup();
          })

        Blank()
          .height($r('app.float.vp_22'))
          .width('1px')
          .color($r('sys.color.comp_divider'))

        Button($r('app.string.health_dialog_confirm'))
          .type(ButtonType.Normal)
          .layoutWeight(1)
          .height('100%')
          .backgroundColor(Color.Transparent)
          .fontColor($r('sys.color.font_emphasize'))
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .onClick(() => {
            HealthDataInputDialog.CloseInputPopup();
            this.dataInputDialogModelVM.onValueConfirmClick(this.dataInputDialogModelVM);
          })
      }
      .width('100%')
      .height($r('app.float.vp_24'))
    }
    .backgroundColor(Color.White)
    .width(this.breakpointModel.dialogWidth)
    .borderRadius($r('sys.float.corner_radius_level16'))
    .padding($r('app.float.vp_24'))
  }
}

@Builder
function buildInputPopup(dataInputDialogModelVM: HealthDataInputDialogModel) {
  popup({ dataInputDialogModelVM: dataInputDialogModelVM })
}