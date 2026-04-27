import { BusinessError } from '@kit.BasicServicesKit';
import { ComponentContent, promptAction } from '@kit.ArkUI';
import { UIContext } from '@ohos.arkui.UIContext';
import { TCLogger } from '../basic/TCLogger';

const TAG: string = 'HMPromptAction';

export class HMPromptAction {
  static uiContext: UIContext;
  static contentNode: ComponentContent<Object> | undefined;
  static options: promptAction.BaseDialogOptions;

  static openDialog() {
    if (HMPromptAction.contentNode !== undefined) {
      HMPromptAction.uiContext.getPromptAction()
        .openCustomDialog(HMPromptAction.contentNode, HMPromptAction.options)
        .then(() => {
          TCLogger.info(TAG, 'OpenCustomDialog complete.')
        })
        .catch((error: BusinessError) => {
          TCLogger.error(TAG, `OpenCustomDialog error: ${JSON.stringify(error)}`);
        })
    }
  }

  static closeDialog() {
    if (HMPromptAction.contentNode !== undefined) {
      HMPromptAction.uiContext.getPromptAction()
        .closeCustomDialog(HMPromptAction.contentNode)
        .then(() => {
          // 释放contentNode
          if (HMPromptAction.contentNode !== undefined) {
            HMPromptAction.contentNode.dispose();
            HMPromptAction.contentNode = undefined
          }
          TCLogger.info(TAG, 'CloseCustomDialog complete.')
        })
        .catch((error: BusinessError) => {
          TCLogger.error(TAG, `CloseCustomDialog error: ${JSON.stringify(error)}`);
          if (HMPromptAction.contentNode !== undefined) {
            HMPromptAction.contentNode.dispose();
            HMPromptAction.contentNode = undefined
          }
        })
    }
  }

  static updateDialog(options: promptAction.BaseDialogOptions) {
    if (HMPromptAction.contentNode !== undefined) {
      HMPromptAction.uiContext.getPromptAction()
        .updateCustomDialog(HMPromptAction.contentNode, options)
        .then(() => {
          TCLogger.info(TAG, 'UpdateCustomDialog complete.')
        })
        .catch((error: BusinessError) => {
          TCLogger.error(TAG, `UpdateCustomDialog error: ${JSON.stringify(error)}`);
        })
    }
  }
}