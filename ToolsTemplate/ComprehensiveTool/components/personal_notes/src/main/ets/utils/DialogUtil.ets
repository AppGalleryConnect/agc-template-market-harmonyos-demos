import { BusinessError } from '@kit.BasicServicesKit';
import { ComponentContent, promptAction } from '@kit.ArkUI';
import { UIContext } from '@ohos.arkui.UIContext';

export class DialogUtil {
  static ctx: UIContext;
  static contentNode: ComponentContent<Object>;
  static options: promptAction.BaseDialogOptions;

  static setContext(context: UIContext) {
    DialogUtil.ctx = context;
  }

  static setContentNode(node: ComponentContent<Object>) {
    DialogUtil.contentNode = node;
  }

  static setOptions(options: promptAction.BaseDialogOptions) {
    DialogUtil.options = options;
  }

  static openDialog(context:UIContext, contentNode :ComponentContent<object>) {
    DialogUtil.setContext(context);
    DialogUtil.setContentNode(contentNode);
    DialogUtil.setOptions({alignment:DialogAlignment.Center,offset:{dx:0, dy:0}})
    if (DialogUtil.contentNode !== null) {
      DialogUtil.ctx.getPromptAction().openCustomDialog(DialogUtil.contentNode, DialogUtil.options)
        .then(() => {
          console.info('OpenCustomDialog complete.')
        })
        .catch((error: BusinessError) => {
          let message = (error as BusinessError).message;
          let code = (error as BusinessError).code;
          console.error(`OpenCustomDialog args error code is ${code}, message is ${message}`);
        })
    }
  }

  static closeDialog() {
    if (DialogUtil.contentNode !== null) {
      DialogUtil.ctx.getPromptAction().closeCustomDialog(DialogUtil.contentNode)
        .then(() => {
          console.info('CloseCustomDialog complete.')
        })
        .catch((error: BusinessError) => {
          let message = (error as BusinessError).message;
          let code = (error as BusinessError).code;
          console.error(`CloseCustomDialog args error code is ${code}, message is ${message}`);
        })
    }
  }

  static updateDialog(options: promptAction.BaseDialogOptions) {
    if (DialogUtil.contentNode !== null) {
      DialogUtil.ctx.getPromptAction().updateCustomDialog(DialogUtil.contentNode, options)
        .then(() => {
          console.info('UpdateCustomDialog complete.')
        })
        .catch((error: BusinessError) => {
          let message = (error as BusinessError).message;
          let code = (error as BusinessError).code;
          console.error(`UpdateCustomDialog args error code is ${code}, message is ${message}`);
        })
    }
  }
}