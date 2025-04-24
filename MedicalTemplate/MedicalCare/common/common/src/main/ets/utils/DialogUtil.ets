import { common } from '@kit.AbilityKit';
import { ComponentContent, promptAction } from '@kit.ArkUI';
import { LogUtil } from './LogUtil';

async function getUIContext() {
  return (await (getContext() as common.UIAbilityContext).windowStage.getMainWindow()).getUIContext()
}

@Builder
export function LoadingDialogBuilder() {
  Column({ space: 10 }) {
    LoadingProgress()
      .color($r('sys.color.icon_on_primary'))
      .width('72vp')
      .height('72vp')
    Text('加载中')
      .fontColor(Color.White)
      .textAlign(TextAlign.Center)
      .fontSize('16fp')
  }
  .justifyContent(FlexAlign.Center)
  .alignItems(HorizontalAlign.Center)
  .constraintSize({
    minWidth: '150vp'
  })
  .padding(12)
  .margin(30)
  .backgroundColor($r('sys.color.mask_primary'))
  .borderRadius(10)
}

/**
 * 展示加载中对话框
 */
export class LoadingDialogUtil {
  static uiContext: UIContext;
  static contentNode: ComponentContent<Object>;
  static options: Object;
  static isOpen: boolean = false;

  static async openLoadingDialog(): Promise<void> {
    if (LoadingDialogUtil.isOpen) {
      LogUtil.info('openLoadingDialog: dialog is already open')
      return
    }

    LoadingDialogUtil.isOpen = true

    try {
      if (!LoadingDialogUtil.uiContext) {
        LoadingDialogUtil.uiContext = await getUIContext()
        LoadingDialogUtil.contentNode =
          new ComponentContent(LoadingDialogUtil.uiContext, wrapBuilder(LoadingDialogBuilder))
      }

      let options: promptAction.BaseDialogOptions = {
        alignment: DialogAlignment.Center,
        autoCancel: true,
        offset: {
          dx: 0, dy: 0
        },
        maskColor: Color.Transparent,
        transition: undefined,
        showInSubWindow: false,
        keyboardAvoidMode: KeyboardAvoidMode.NONE,
        onWillDismiss: (action: DismissDialogAction) => {
          if (action.reason === DismissReason.PRESS_BACK) {
            action.dismiss()
          }
        }
      }

      const promptAction = LoadingDialogUtil.uiContext.getPromptAction()
      promptAction.openCustomDialog(LoadingDialogUtil.contentNode, options)
    } catch (error) {
      console.error('PromptActionUtils', ` closeCustomDialog error = ${JSON.stringify(error)}`)
    }
  }

  static async close(): Promise<void> {
    LoadingDialogUtil.isOpen = false

    try {
      const promptAction = LoadingDialogUtil.uiContext.getPromptAction()
      promptAction.closeCustomDialog(LoadingDialogUtil.contentNode)
    } catch (error) {
      console.error('PromptActionUtils', ` closeCustomDialog error = ${JSON.stringify(error)}`)
    }
  }
}

interface ConfirmDialogParam {
  title?: string,
  content?: string,
  confirmText?: string,
  cancelText?: string,
  onConfirm?: () => void,
  onCancel?: () => void
}

export class ConfirmDialogUtil {
  public static async showConfirmDialog(
    param: ConfirmDialogParam
  ) {
    (await getUIContext())
      .getPromptAction()
      .showDialog({
        title: param.title || '确认',
        message: param.content || '是否确认？',
        buttons: [
          {
            text: param.confirmText || '取消',
            color: $r('sys.color.ohos_id_color_text_hint')
          },
          {
            text: param.cancelText || '确认',
            color: $r('sys.color.ohos_id_color_text_primary_activated')

          }
        ]
      }, (err, data) => {
        if (err) {
          LogUtil.error('showDialog err: ' + err);
          return;
        }
        if (data.index === 0) {
          param.onCancel?.()
        }
        if (data.index === 1) {
          param.onConfirm?.()
        }
      });
  }
}
