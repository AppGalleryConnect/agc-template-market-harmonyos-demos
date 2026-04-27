import { BusinessError } from '@kit.BasicServicesKit';
import { ComponentContent, promptAction, UIContext } from '@kit.ArkUI';

export class PromptActionUtil {
  static ctx: UIContext;
  static dialogContentNode: ComponentContent<Object>;
  static dialogOptions: promptAction.BaseDialogOptions;

  static setContext(context: UIContext) {
    PromptActionUtil.ctx = context;
  }

  static setDialogContentNode(node: ComponentContent<Object>) {
    PromptActionUtil.dialogContentNode = node;
  }

  static setDialogOptions(dialogOptions: promptAction.BaseDialogOptions) {
    PromptActionUtil.dialogOptions = dialogOptions;
  }

  static openDialog() {
    if (PromptActionUtil.dialogContentNode !== null) {
      PromptActionUtil.ctx.getPromptAction()
        .openCustomDialog(PromptActionUtil.dialogContentNode, PromptActionUtil.dialogOptions)
        .then(() => {
        })
        .catch((error: BusinessError) => {

        })
    }
  }

  static closeDialog() {
    if (PromptActionUtil.dialogContentNode !== null) {
      PromptActionUtil.ctx.getPromptAction()
        .closeCustomDialog(PromptActionUtil.dialogContentNode)
        .then(() => {
        })
        .catch((error: BusinessError) => {
        })
    }
  }
}

@Builder
export function loadingReminder() {
  Column({ space: 5 }) {
    LoadingProgress()
      .color($r('sys.color.icon_secondary'))
      .layoutWeight(1)
  }
  .width('30%')
  .margin({ top: 5 })
}