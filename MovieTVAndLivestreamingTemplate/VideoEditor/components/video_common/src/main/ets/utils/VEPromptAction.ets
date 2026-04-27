import { BusinessError } from '@kit.BasicServicesKit';
import { ComponentContent, promptAction } from '@kit.ArkUI';
import { UIContext } from '@ohos.arkui.UIContext';

export class VEPromptAction {
  static uiContext: UIContext;
  static contentNode: ComponentContent<Object> | undefined;
  static options: promptAction.BaseDialogOptions;

  static openDialog() {
    if (VEPromptAction.contentNode !== undefined) {
      VEPromptAction.uiContext.getPromptAction()
        .openCustomDialog(VEPromptAction.contentNode, VEPromptAction.options)
        .then(() => {
        })
        .catch((error: BusinessError) => {
        })
    }
  }

  static closeDialog() {
    if (VEPromptAction.contentNode !== undefined) {
      VEPromptAction.uiContext.getPromptAction()
        .closeCustomDialog(VEPromptAction.contentNode)
        .then(() => {
          // 释放contentNode
          if (VEPromptAction.contentNode !== undefined) {
            VEPromptAction.contentNode.dispose();
            VEPromptAction.contentNode = undefined
          }
        })
        .catch((error: BusinessError) => {
          if (VEPromptAction.contentNode !== undefined) {
            VEPromptAction.contentNode.dispose();
            VEPromptAction.contentNode = undefined
          }
        })
    }
  }

  static updateDialog(options: promptAction.BaseDialogOptions) {
    if (VEPromptAction.contentNode !== undefined) {
      VEPromptAction.uiContext.getPromptAction()
        .updateCustomDialog(VEPromptAction.contentNode, options)
        .then(() => {
        })
        .catch((error: BusinessError) => {
        })
    }
  }
}