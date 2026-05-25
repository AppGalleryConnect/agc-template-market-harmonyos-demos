import { BusinessError } from '@kit.BasicServicesKit';
import { ComponentContent, promptAction } from '@kit.ArkUI';
import { UIContext } from '@ohos.arkui.UIContext';
import { hilog } from '@kit.PerformanceAnalysisKit';

export class DialogController {
  static ctx: UIContext;
  static contentNode: ComponentContent<Object>;
  static options: promptAction.BaseDialogOptions;

  static setContext(context: UIContext) {
    DialogController.ctx = context;
  }

  static setContentNode(node: ComponentContent<Object>) {
    DialogController.contentNode = node;
  }

  static setOptions(options: promptAction.BaseDialogOptions) {
    DialogController.options = options;
  }

  static openDialog() {
    if (DialogController.contentNode !== null) {
      DialogController.ctx.getPromptAction().openCustomDialog(DialogController.contentNode, DialogController.options)
        .then(() => {
          hilog.info(0x0000, 'DialogController', 'OpenCustomDialog complete.');
        })
        .catch((error: BusinessError) => {
          let message = (error as BusinessError).message;
          let code = (error as BusinessError).code;
          hilog.error(0x0000, 'DialogController', `OpenCustomDialog args error code is ${code}, message is ${message}`);
        })
    }
  }

  static closeDialog() {
    if (DialogController.contentNode !== null) {
      DialogController.ctx.getPromptAction().closeCustomDialog(DialogController.contentNode)
        .then(() => {
          hilog.info(0x0000, 'DialogController', 'CloseCustomDialog complete.');
        })
        .catch((error: BusinessError) => {
          let message = (error as BusinessError).message;
          let code = (error as BusinessError).code;
          hilog.error(0x0000, 'DialogController', `CloseCustomDialog args error code is ${code}, message is ${message}`);
        })
    }
  }

  static updateDialog(options: promptAction.BaseDialogOptions) {
    if (DialogController.contentNode !== null) {
      DialogController.ctx.getPromptAction().updateCustomDialog(DialogController.contentNode, options)
        .then(() => {
          hilog.info(0x0000, 'DialogController', 'UpdateCustomDialog complete.');
        })
        .catch((error: BusinessError) => {
          let message = (error as BusinessError).message;
          let code = (error as BusinessError).code;
          hilog.error(0x0000, 'DialogController', `UpdateCustomDialog args error code is ${code}, message is ${message}`);
        })
    }
  }
}