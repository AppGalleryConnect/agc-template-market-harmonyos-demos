import { ComponentContent, promptAction } from '@kit.ArkUI';
import { UtilLog } from '@hw-agconnect/util-log';
import { PreviewUtils } from './PreviewUtils';
import { ImagePreviewOptions } from '../models/ImagePreviewOptions';
import { PreviewCloseParam } from '../models/PreviewModel';
import { PromptActionBaseBean } from '../models/PromptActionBaseBean';

const TAG = '[PromptActionTool]';

export interface PromptActionOptions {
  builder: WrappedBuilder<[ImagePreviewOptions]>
  params: ImagePreviewOptions
}

interface PromptActionInfo {
  action: ImagePreviewOptions
  componentContent: ComponentContent<object>
}

let promptActionInfos: PromptActionInfo[] = [];
let statusBarContentColor: string = '#000000';

function getPromptActionInfoByDialogId(dialogId: string): PromptActionInfo | undefined {
  return promptActionInfos.find(item => dialogId === item.action.dialogId);
}

export class PromptActionTool {
  /**
   * 弹出自定义弹窗
   */
  static async openCustomDialog(uiContext: UIContext,
    value: PromptActionOptions): Promise<void> {
    try {
      const promptAction = uiContext.getPromptAction();
      const componentContent = new ComponentContent(uiContext, value.builder, value.params);

      let options: promptAction.BaseDialogOptions = {
        alignment: DialogAlignment.Center,
        autoCancel: false,
        maskColor: Color.Transparent,
        transition: TransitionEffect.IDENTITY,
        keyboardAvoidMode: KeyboardAvoidMode.NONE,
        onWillDismiss: (action: DismissDialogAction) => {
          if (!value.params.dismissOnSystemBack) {
            return;
          }
          if (action.reason === DismissReason.PRESS_BACK) {
            value.params.needDismiss = true;
          } else if (action.reason === DismissReason.TOUCH_OUTSIDE) {
            value.params.needDismiss = true;
          }
          PromptActionTool.updateCustomDialog<ImagePreviewOptions>(value.params);
        },
        onDidAppear: () => {
          PromptActionTool.setSystemBarProperty();
          value.params?.onOpenListener?.();
        },
        onWillDisappear: () => {
          const index = promptActionInfos.findIndex(item => item.action.dialogId === value.params.dialogId);
          if (index >= 0) {
            promptActionInfos.splice(index, 1);
          } else {
            promptActionInfos.shift();
          }
          PromptActionTool.resetSystemBarProperty();
          value.params.needDismiss = false;
        },
      };

      options.levelMode = value.params.levelMode;
      options.immersiveMode = value.params.immersiveMode;
      if (value.params.levelUniqueId && typeof value.params.levelUniqueId === 'string') {
        options.levelUniqueId = uiContext.getFrameNodeById(value.params.levelUniqueId)?.getUniqueId();
      } else if (value.params.levelUniqueId && typeof value.params.levelUniqueId === 'number') {
        options.levelUniqueId = value.params.levelUniqueId;
      }

      if (!PromptActionTool.existsCustomDialog(value.params.dialogId)) {
        promptActionInfos.unshift({
          action: value.params,
          componentContent: componentContent,
        });
        await promptAction.openCustomDialog(componentContent, options);
      }
    } catch (error) {
      UtilLog.error('PromptActionUtils', ` openCustomDialog error = ${error}`);
    }
  }

  /**
   * 关闭自定义弹窗
   */
  static async closeCustomDialog(uiContext: UIContext, dialogId?: string): Promise<void> {
    try {
      const promptAction = uiContext.getPromptAction();
      let info: PromptActionInfo | undefined = undefined;
      if (dialogId) {
        info = getPromptActionInfoByDialogId(dialogId);
      } else {
        info = promptActionInfos.length > 0 ? promptActionInfos[0] : undefined;
      }
      if (info) {
        await promptAction.closeCustomDialog(info.componentContent);
        info.componentContent.dispose();
      } else {
        UtilLog.error('PromptActionUtils', ` closeCustomDialog error = info is undefined`);
      }
    } catch (error) {
      UtilLog.error('PromptActionUtils', ` closeCustomDialog error = ${error}`);
    }
  }

  /**
   * 刷新自定义弹窗
   */
  static updateCustomDialog<T extends PromptActionBaseBean>(params: T) {
    let promptActionInfo: PromptActionInfo | undefined = getPromptActionInfoByDialogId(params.dialogId);
    if (promptActionInfo) {
      promptActionInfo.componentContent.update(params);
    }
  }

  /**
   * 关闭预览
   */
  static closePreview(params?: PreviewCloseParam) {
    let promptActionInfo: PromptActionInfo | undefined;
    if (params?.dialogId) {
      promptActionInfo = getPromptActionInfoByDialogId(params.dialogId);
    } else {
      promptActionInfo = promptActionInfos.length > 0 ? promptActionInfos[0] : undefined;
    }
    if (promptActionInfo) {
      promptActionInfo.action.needDismiss = true;
      promptActionInfo.action.dismissAnimation = params?.animated ?? true;
      PromptActionTool.updateCustomDialog(promptActionInfo.action);
    }
  }

  /**
   * 是否存在自定义弹窗
   */
  static existsCustomDialog(dialogId: string): boolean {
    let info = getPromptActionInfoByDialogId(dialogId);
    return info !== undefined;
  }

  /**
   * 设置系统状态栏为白色
   * */
  static async setSystemBarProperty() {
    try {
      const windowClass = PreviewUtils.windowStage?.getMainWindowSync();
      let systemBarProperty = windowClass?.getWindowSystemBarProperties();
      statusBarContentColor = systemBarProperty?.statusBarContentColor as string;
      await windowClass?.setWindowSystemBarProperties({
        statusBarContentColor: '#ffffff',
      });
    } catch (e) {
      UtilLog.error(TAG, 'setSystemBarProperty fail, error: ' + e);
    }
  }

  /**
   * 还原系统状态栏颜色
   * */
  static resetSystemBarProperty() {
    const windowClass = PreviewUtils.windowStage?.getMainWindowSync();
    windowClass?.setWindowSystemBarProperties({
      statusBarContentColor: statusBarContentColor ?? '#ffffff',
    }).catch((e: BusinessError) => {
      UtilLog.error(TAG, 'setWindowSystemBarProperties fail, error: ' + e.message);
    });
  }
}
