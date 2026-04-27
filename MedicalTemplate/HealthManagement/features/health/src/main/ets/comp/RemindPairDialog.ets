import { AppStorageV2, ComponentContent } from '@kit.ArkUI';
import { emitter } from '@kit.BasicServicesKit';
import { BreakpointModel, Constants, GlobalContext, HMPromptAction, TCLogger } from 'common';

const TAG: string = 'RemindPairDialog';

export class RemindPairDialog {
  private constructor() {
  }

  static ShowPopup(dialogVM: RemindPairModel) {
    if (HMPromptAction.contentNode === undefined) {
      let uiContext = GlobalContext.getUIContext();
      if (uiContext) {
        let contentNode = new ComponentContent(uiContext, wrapBuilder(buildPopupComponent), dialogVM);
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

  static ClosePopup() {
    HMPromptAction.closeDialog();
  }
}

@ComponentV2
struct popup {
  @Param @Require dialogVM: RemindPairModel;
  @Local breakpointModel: BreakpointModel =
    AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;

  build() {
    Column() {
      Blank().height($r('app.float.vp_36'))
      Text(this.dialogVM.message)
        .fontSize($r('sys.float.Body_L'))
        .fontColor(Color.Black)
        .lineHeight($r('app.float.vp_22'))
        .maxLines(-1)
        .padding({ left: $r('app.float.vp_24'), right: $r('app.float.vp_24') })
      Blank().height($r('app.float.vp_30'))

      Row() {
        Button(this.dialogVM.cancelTitle)
          .type(ButtonType.Normal)
          .layoutWeight(1)
          .height('100%')
          .backgroundColor(Color.Transparent)
          .fontColor($r('sys.color.font_tertiary'))
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .onClick(() => {
            TCLogger.info(TAG, `on cancle`);
            HMPromptAction.closeDialog();
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
          .fontColor($r('sys.color.font_emphasize'))
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .onClick(() => {
            try {
              TCLogger.info(TAG, `on confirm`);
              emitter.emit(Constants.onGotoDeviceTabChange);
              HMPromptAction.closeDialog();
            } catch (err) {
            }
          })
      }
      .width('100%')
      .height($r('app.float.vp_40'))
      .padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16') })

      Blank().height($r('app.float.vp_16'))
    }
    .backgroundColor(Color.White)
    .alignItems(HorizontalAlign.Center)
    .width(this.breakpointModel.currentDisplayWidth > 400 ?
      376 :
      this.breakpointModel.currentDisplayWidth - 32)
    .borderRadius($r('sys.float.corner_radius_level12'))
  }
}

@Builder
function buildPopupComponent(dialogVM: RemindPairModel) {
  popup({ dialogVM: dialogVM })
}

@ObservedV2
export class RemindPairModel {
  @Trace message: ResourceStr = '您当前暂未连接设备，请检查设备型号及连接状态。';
  @Trace cancelTitle: ResourceStr = '取消';
  @Trace confirmTitle: ResourceStr = '去连接';
  onValueConfirmClick = (_model: RemindPairModel) => {
  };
}