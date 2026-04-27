import { BusinessError } from '@kit.BasicServicesKit';
import { ComponentContent, promptAction, UIContext } from '@kit.ArkUI';

const DOMAIN = 0x0000;

export class PromptActionClass {
  static ctx: UIContext;
  static contentNode: ComponentContent<Object>;
  static options: promptAction.BaseDialogOptions;

  static setContext(context: UIContext) {
    PromptActionClass.ctx = context;
  }

  static setContentNode(node: ComponentContent<Object>) {
    PromptActionClass.contentNode = node;
  }

  static setOptions(options: promptAction.BaseDialogOptions) {
    PromptActionClass.options = options;
  }

  static openDialog() {
    if (PromptActionClass.contentNode !== null) {
      PromptActionClass.ctx.getPromptAction()
        .openCustomDialog(PromptActionClass.contentNode, PromptActionClass.options)
        .then(() => {
        })
        .catch((error: BusinessError) => {
          let message = (error as BusinessError).message;
          let code = (error as BusinessError).code;
        })
    }
  }

  static closeDialog() {
    if (PromptActionClass.contentNode && PromptActionClass.contentNode !== null) {
      PromptActionClass.ctx.getPromptAction()
        .closeCustomDialog(PromptActionClass.contentNode)
        .then(() => {
        })
        .catch((error: BusinessError) => {
          let message = (error as BusinessError).message;
          let code = (error as BusinessError).code;
        })
    }
  }

  // ···

  static updateDialog(options: promptAction.BaseDialogOptions) {
    if (PromptActionClass.contentNode !== null) {
      PromptActionClass.ctx.getPromptAction()
        .updateCustomDialog(PromptActionClass.contentNode, options)
        .then(() => {
        })
        .catch((error: BusinessError) => {
          let message = (error as BusinessError).message;
          let code = (error as BusinessError).code;
        })
    }
  }
}