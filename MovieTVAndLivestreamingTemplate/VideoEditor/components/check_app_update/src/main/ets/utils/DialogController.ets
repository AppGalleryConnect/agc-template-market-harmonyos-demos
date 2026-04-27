import { BusinessError } from '@kit.BasicServicesKit';
import { ComponentContent, promptAction } from '@kit.ArkUI';
import { UIContext } from '@ohos.arkui.UIContext';

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
        })
        .catch((error: BusinessError) => {
          let message = (error as BusinessError).message;
          let code = (error as BusinessError).code;
        })
    }
  }

  static closeDialog() {
    if (DialogController.contentNode !== null) {
      DialogController.ctx.getPromptAction().closeCustomDialog(DialogController.contentNode)
        .then(() => {
        })
        .catch((error: BusinessError) => {
          let message = (error as BusinessError).message;
          let code = (error as BusinessError).code;
        })
    }
  }

  static updateDialog(options: promptAction.BaseDialogOptions) {
    if (DialogController.contentNode !== null) {
      DialogController.ctx.getPromptAction().updateCustomDialog(DialogController.contentNode, options)
        .then(() => {
        })
        .catch((error: BusinessError) => {
          let message = (error as BusinessError).message;
          let code = (error as BusinessError).code;
        })
    }
  }
}