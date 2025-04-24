import { BusinessError } from '@kit.BasicServicesKit';
import { ComponentContent } from '@kit.ArkUI';
import { UIContext } from '@ohos.arkui.UIContext';
import { default as Logger } from '../utils/Logger'

export class DialogController {
  static context: UIContext;
  static contentNode: ComponentContent<Object>;
  static options: Object;

  static setContext(context: UIContext) {
    DialogController.context = context;
  }

  static setContentNode(node: ComponentContent<Object>) {
    DialogController.contentNode = node;
  }

  static setOptions(options: Object) {
    DialogController.options = options;
  }

  static openDialog() {
    if (DialogController.contentNode !== null) {
      DialogController.context.getPromptAction()
        .openCustomDialog(DialogController.contentNode, DialogController.options)
        .then(() => {
          Logger.info('OpenCustomDialog complete.')
        })
        .catch((error: BusinessError) => {
          let message = (error as BusinessError).message;
          let code = (error as BusinessError).code;
          Logger.error(`OpenCustomDialog args error code is ${code}, message is ${message}`);
        })
    }
  }

  static closeDialog() {
    if (DialogController.contentNode !== null) {
      DialogController.context.getPromptAction()
        .closeCustomDialog(DialogController.contentNode)
        .then(() => {
          Logger.info('CloseCustomDialog complete.')
        })
        .catch((error: BusinessError) => {
          let message = (error as BusinessError).message;
          let code = (error as BusinessError).code;
          Logger.error(`CloseCustomDialog args error code is ${code}, message is ${message}`);
        })
    }
  }

  static updateDialog(options: Object) {
    if (DialogController.contentNode !== null) {
      DialogController.context.getPromptAction()
        .updateCustomDialog(DialogController.contentNode, options)
        .then(() => {
          Logger.info('UpdateCustomDialog complete.')
        })
        .catch((error: BusinessError) => {
          let message = (error as BusinessError).message;
          let code = (error as BusinessError).code;
          Logger.error(`UpdateCustomDialog args error code is ${code}, message is ${message}`);
        })
    }
  }
}