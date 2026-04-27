import { BusinessError } from '@kit.BasicServicesKit';
import { ComponentContent, promptAction } from '@kit.ArkUI';
import { UIContext } from '@ohos.arkui.UIContext';
import { TCLogger } from '../basic/TCLogger';

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
          TCLogger.info(TAG, 'OpenCustomDialog complete.')
        })
        .catch((error: BusinessError) => {
          TCLogger.error(TAG, `OpenCustomDialog error: ${JSON.stringify(error)}`);
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
          TCLogger.info(TAG, 'CloseCustomDialog complete.')
        })
        .catch((error: BusinessError) => {
          TCLogger.error(TAG, `CloseCustomDialog error: ${JSON.stringify(error)}`);
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
          TCLogger.info(TAG, 'UpdateCustomDialog complete.')
        })
        .catch((error: BusinessError) => {
          TCLogger.error(TAG, `UpdateCustomDialog error: ${JSON.stringify(error)}`);
        })
    }
  }
}