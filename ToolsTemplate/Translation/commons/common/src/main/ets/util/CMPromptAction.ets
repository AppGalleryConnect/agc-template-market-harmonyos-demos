import { BusinessError } from '@kit.BasicServicesKit';
import { ComponentContent, promptAction } from '@kit.ArkUI';
import { UIContext } from '@ohos.arkui.UIContext';

const TAG: string = 'CMPromptAction';

export class CMPromptAction {
  static uiContext: UIContext;
  static contentNode: ComponentContent<Object> | undefined;
  static options: promptAction.BaseDialogOptions;

  static openDialog() {
    if (CMPromptAction.contentNode !== undefined) {
      CMPromptAction.uiContext.getPromptAction()
        .openCustomDialog(CMPromptAction.contentNode, CMPromptAction.options)
        .then(() => {
        })
        .catch((error: BusinessError) => {
        })
    }
  }

  static closeDialog() {
    if (CMPromptAction.contentNode !== undefined) {
      CMPromptAction.uiContext.getPromptAction()
        .closeCustomDialog(CMPromptAction.contentNode)
        .then(() => {
          // 释放contentNode
          if (CMPromptAction.contentNode !== undefined) {
            CMPromptAction.contentNode.dispose();
            CMPromptAction.contentNode = undefined
          }
        })
        .catch((error: BusinessError) => {
          if (CMPromptAction.contentNode !== undefined) {
            CMPromptAction.contentNode.dispose();
            CMPromptAction.contentNode = undefined
          }
        })
    }
  }

  static updateDialog(options: promptAction.BaseDialogOptions) {
    if (CMPromptAction.contentNode !== undefined) {
      CMPromptAction.uiContext.getPromptAction()
        .updateCustomDialog(CMPromptAction.contentNode, options)
        .then(() => {
        })
        .catch((error: BusinessError) => {
        })
    }
  }
}