import { ComponentContent, promptAction } from '@kit.ArkUI';

import { WindowUtil } from './WindowUtil';
import { BusinessError } from '@kit.BasicServicesKit';

export class PopViewUtils {
  private static ctx: UIContext;
  private static contentNode: ComponentContent<Object> | null;

  public static setContentNode(node: ComponentContent<Object>) {
    PopViewUtils.contentNode = node;
  }

  public static openDialog<T extends Object>(builder: WrappedBuilder<[T]> | WrappedBuilder<[]>,
    options: promptAction.BaseDialogOptions,
    args?: T) {
    if (!PopViewUtils.ctx) {
      PopViewUtils.ctx = WindowUtil.uiContext;
    }
    if (args) {
      PopViewUtils.contentNode = new ComponentContent(PopViewUtils.ctx, builder, args);
    } else {
      PopViewUtils.contentNode = new ComponentContent(PopViewUtils.ctx, builder as WrappedBuilder<[]>);
    }

    if (PopViewUtils.contentNode !== null) {
      PopViewUtils.ctx.getPromptAction()
        .openCustomDialog(PopViewUtils.contentNode, options)
        .then(() => {
          console.info('OpenCustomDialog complete.');
        })
        .catch((error: BusinessError) => {
          let message = (error as BusinessError).message;
          let code = (error as BusinessError).code;
          console.error(`OpenCustomDialog args error code is ${code}, message is ${message}`);
        });
    }
  }

  public static closeDialog() {
    if (PopViewUtils.contentNode !== null) {
      PopViewUtils.ctx.getPromptAction()
        .closeCustomDialog(PopViewUtils.contentNode)
        .then(() => {
          console.info('CloseCustomDialog complete.');
          PopViewUtils.contentNode = null;
        })
        .catch((error: BusinessError) => {
          let message = (error as BusinessError).message;
          let code = (error as BusinessError).code;
          console.error(`CloseCustomDialog args error code is ${code}, message is ${message}`);
        });
    }
  }

  public static updateDialog(options: promptAction.BaseDialogOptions) {
    if (PopViewUtils.contentNode !== null) {
      PopViewUtils.ctx.getPromptAction()
        .updateCustomDialog(PopViewUtils.contentNode, options)
        .then(() => {
          console.info('UpdateCustomDialog complete.');
        })
        .catch((error: BusinessError) => {
          let message = (error as BusinessError).message;
          let code = (error as BusinessError).code;
          console.error(`UpdateCustomDialog args error code is ${code}, message is ${message}`);
        });
    }
  }
}
