import { common } from '@kit.AbilityKit';
import { ComponentContent, promptAction } from '@kit.ArkUI';

async function getUIContext() {
  return (await (getContext() as common.UIAbilityContext).windowStage.getMainWindow()).getUIContext()
}

@Builder
export function LoadingDialogBuilder() {
  Column({ space: 10 }) {
    LoadingProgress()
      .color($r('sys.color.icon_on_primary'))
      .width(72)
      .height(72)
    Text($r('app.string.loading'))
      .fontColor($r('sys.color.font_primary'))
      .textAlign(TextAlign.Center)
      .fontSize(16)
  }
  .justifyContent(FlexAlign.Center)
  .alignItems(HorizontalAlign.Center)
  .constraintSize({
    minWidth: 150
  })
  .padding(12)
  .margin(30)
  .backgroundColor($r('sys.color.background_fourth'))
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
      console.info('openLoadingDialog: dialog is already open')
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
          dx: 0, dy: 0,
        },
        maskColor: Color.Transparent,
        transition: undefined,
        showInSubWindow: false,
        keyboardAvoidMode: KeyboardAvoidMode.NONE,
        onWillDismiss: (action: DismissDialogAction) => {
          if (action.reason === DismissReason.PRESS_BACK) {
            action.dismiss()
          }
        },
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