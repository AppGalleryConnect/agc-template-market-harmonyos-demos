import { BusinessError } from '@kit.BasicServicesKit';
import { ComponentContent, promptAction, UIContext } from '@kit.ArkUI';
import { UtilLog } from '@hw-agconnect/util-log';

export class PromptActionUtil {
  static ctx: UIContext;
  static contentNode: ComponentContent<Object>;
  static options: promptAction.BaseDialogOptions;

  static setContext(context: UIContext) {
    PromptActionUtil.ctx = context;
  }

  static setContentNode(node: ComponentContent<Object>) {
    PromptActionUtil.contentNode = node;
  }

  static setOptions(options: promptAction.BaseDialogOptions) {
    PromptActionUtil.options = options;
  }

  static openDialog() {
    if (PromptActionUtil.contentNode !== null) {
      PromptActionUtil.ctx.getPromptAction().openCustomDialog(PromptActionUtil.contentNode, PromptActionUtil.options)
        .then(() => {
          UtilLog.info(0xFF00, 'VideoClip', 'OpenCustomDialog complete');
        })
        .catch((error: BusinessError) => {
          let message = (error as BusinessError).message;
          let code = (error as BusinessError).code;
          UtilLog.info(0xFF00, 'VideoClip', `OpenCustomDialog args error code is ${code}, message is ${message}`);
        })
    }
  }

  static closeDialog(contentNode: ComponentContent<Object>) {
    if (PromptActionUtil.contentNode !== null) {
      PromptActionUtil.ctx.getPromptAction().closeCustomDialog(contentNode)
        .then(() => {
          UtilLog.info(0xFF00, 'VideoClip', 'CloseCustomDialog complete');
        })
        .catch((error: BusinessError) => {
          let message = (error as BusinessError).message;
          let code = (error as BusinessError).code;
          UtilLog.info(0xFF00, 'VideoClip', `CloseCustomDialog args error code is ${code}, message is ${message}`);
        })
    }
  }

  static updateDialog(options: promptAction.BaseDialogOptions) {
    if (PromptActionUtil.contentNode !== null) {
      PromptActionUtil.ctx.getPromptAction().updateCustomDialog(PromptActionUtil.contentNode, options)
        .then(() => {
          UtilLog.info(0xFF00, 'VideoClip', 'UpdateCustomDialog complete');
        })
        .catch((error: BusinessError) => {
          let message = (error as BusinessError).message;
          let code = (error as BusinessError).code;
          UtilLog.info(0xFF00, 'VideoClip', `UpdateCustomDialog args error code is ${code}, message is ${message}`);
        })
    }
  }
}