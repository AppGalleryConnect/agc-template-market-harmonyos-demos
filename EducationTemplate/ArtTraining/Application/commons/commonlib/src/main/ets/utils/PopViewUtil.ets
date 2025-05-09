import { ComponentContent, promptAction } from '@kit.ArkUI';
import { Logger } from './Logger';
import { WindowUtil } from './WindowUtil';
import { BusinessError } from '@kit.BasicServicesKit';

const TAG: string = '[PopViewUtil]';

export class PopViewUtil {
  private static _ctx: UIContext;
  private static _contentNode: ComponentContent<Object> | null;

  public static setContentNode(node: ComponentContent<Object>) {
    PopViewUtil._contentNode = node;
  }

  public static openDialog<T extends Object>(builder: WrappedBuilder<[T]> | WrappedBuilder<[]>,
    options: promptAction.BaseDialogOptions,
    args?: T) {
    if (!PopViewUtil._ctx) {
      PopViewUtil._ctx = WindowUtil.uiContext;
    }
    if (args) {
      PopViewUtil._contentNode = new ComponentContent(PopViewUtil._ctx, builder, args);
    } else {
      PopViewUtil._contentNode = new ComponentContent(PopViewUtil._ctx, builder as WrappedBuilder<[]>);
    }

    if (PopViewUtil._contentNode !== null) {
      PopViewUtil._ctx.getPromptAction()
        .openCustomDialog(PopViewUtil._contentNode, options)
        .then(() => {
          Logger.info(TAG, 'OpenCustomDialog complete.');
        })
        .catch((error: BusinessError) => {
          let message = (error as BusinessError).message;
          let code = (error as BusinessError).code;
          Logger.error(TAG, `OpenCustomDialog args error code is ${code}, message is ${message}`);
        });
    }
  }

  public static closeDialog() {
    if (PopViewUtil._contentNode !== null) {
      PopViewUtil._ctx.getPromptAction()
        .closeCustomDialog(PopViewUtil._contentNode)
        .then(() => {
          Logger.info(TAG, 'CloseCustomDialog complete.');
          PopViewUtil._contentNode = null;
        })
        .catch((error: BusinessError) => {
          let message = (error as BusinessError).message;
          let code = (error as BusinessError).code;
          Logger.error(TAG, `CloseCustomDialog args error code is ${code}, message is ${message}`);
        });
    }
  }

  public static updateDialog(options: promptAction.BaseDialogOptions) {
    if (PopViewUtil._contentNode !== null) {
      PopViewUtil._ctx.getPromptAction()
        .updateCustomDialog(PopViewUtil._contentNode, options)
        .then(() => {
          Logger.info(TAG, 'UpdateCustomDialog complete.');
        })
        .catch((error: BusinessError) => {
          let message = (error as BusinessError).message;
          let code = (error as BusinessError).code;
          Logger.error(TAG, `UpdateCustomDialog args error code is ${code}, message is ${message}`);
        });
    }
  }
}
