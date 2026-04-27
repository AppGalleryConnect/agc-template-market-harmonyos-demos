import { AppStorageV2, ComponentContent } from '@kit.ArkUI';
import { GlobalContext } from '../../basic/GlobalContext';
import { BreakpointModel } from '../../model/BreakpointModel';
import { CMPromptAction } from '../../util/CMPromptAction';
import { OHDialogModel } from './OHDialogModel';

const TAG: string = 'OHDialog';

/**
 * 选择弹框
 */
export class OHDialog {
  private constructor() {
  }

  static showPopup(model: Object) {
    if (CMPromptAction.contentNode === undefined) {
      let uiContext = GlobalContext.getUIContext();
      if (uiContext) {
        let contentNode = new ComponentContent(uiContext, wrapBuilder(buildPopupComponent), model);
        CMPromptAction.uiContext = uiContext;
        CMPromptAction.contentNode = contentNode;
        CMPromptAction.options = {
          alignment: DialogAlignment.Center,
          autoCancel: false,
          onWillDismiss: (_reason: DismissDialogAction) => {
            CMPromptAction.closeDialog();
            return true;
          }
        };
        CMPromptAction.openDialog();
      } else {
      }
    }
  }

  static closePopup() {
    CMPromptAction.closeDialog();
  }
}

@ComponentV2
struct popup {
  @Param @Require info: Object;
  @Local dialogVM: OHDialogModel = new OHDialogModel();
  /** 自定义Builder */
  @BuilderParam childBuilder?: (model: Object) => void
  @Local breakpointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;

  aboutToAppear(): void {
    try {
      this.dialogVM = this.info as OHDialogModel;
    } catch (err) {
    }
    this.childBuilder = this.dialogVM.childBuilder
  }

  build() {
    Column() {
      Blank().height($r('app.float.vp_34'))
      if (this.dialogVM.title) {
        Text(this.dialogVM.title)
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Regular)
          .fontColor(Color.Black)
          .width('100%')
          .height($r('app.float.vp_22'))
          .textAlign(TextAlign.Center)

        Blank().height($r('app.float.vp_30'))
      }

      if (this.childBuilder) {
        Column() {
          this.childBuilder?.(this.dialogVM)
        }
        .padding({
          left: this.dialogVM.childPadding,
          right: this.dialogVM.childPadding
        })

        Blank().height($r('app.float.vp_24'))
      }

      Row() {
        Button(this.dialogVM.cancelTitle)
          .type(ButtonType.Normal)
          .layoutWeight(1)
          .height('100%')
          .backgroundColor(Color.Transparent)
          .fontColor(this.dialogVM.cancelFontColor)
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .onClick(() => {
            OHDialog.closePopup();
            this.dialogVM?.onValueCancelClick?.(this.dialogVM)
          })

        Blank()
          .height($r('app.float.vp_22'))
          .width('1px')
          .color($r('sys.color.comp_divider'))

        Button(this.dialogVM.confirmTitle)
          .type(ButtonType.Normal)
          .layoutWeight(1)
          .height('100%')
          .backgroundColor(Color.Transparent)
          .fontSize($r('sys.float.Body_L'))
          .fontColor(this.dialogVM.confirmFontColor)
          .fontWeight(FontWeight.Medium)
          .onClick(() => {
            OHDialog.closePopup();
            this.dialogVM?.onValueConfirmClick?.(this.dialogVM)
          })
      }
      .width('100%')
      .height($r('app.float.vp_40'))

      Blank().height($r('app.float.vp_16'))
    }
    .backgroundColor(Color.White)
    .width(this.breakpointModel.currentDisplayWidth > 400 ? 376 : this.breakpointModel.currentDisplayWidth - 32)
    .borderRadius($r('sys.float.corner_radius_level12'))
  }
}

@Builder
function buildPopupComponent(info: Object) {
  popup({ info: info })
}