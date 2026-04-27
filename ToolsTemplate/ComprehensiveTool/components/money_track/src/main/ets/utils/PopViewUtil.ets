import { ComponentContent, promptAction, window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { contextUtil } from './ContextUtil';
import { Logger } from './Logger';

const TAG: string = '[PopViewUtil]';

export class PopViewUtil {
  private static _ctx: UIContext;
  private static _sheetNode: ComponentContent<Object>[] = [];
  private static _contentNode: ComponentContent<Object> | null;

  private static async _getUIContext() {
    if (!PopViewUtil._ctx) {
      try {
        const win = await window.getLastWindow(contextUtil.getContext()!);
        PopViewUtil._ctx = win.getUIContext();
      } catch (err) {
        Logger.error(TAG, 'get ui context failed.' + JSON.stringify(err));
      }
    }
  }

  public static async openDialog<T extends Object>(
    builder: WrappedBuilder<[T]> | WrappedBuilder<[]>,
    options: promptAction.BaseDialogOptions,
    args?: T,
  ) {
    await PopViewUtil._getUIContext();
    if (!PopViewUtil._ctx) {
      return;
    }
    if (args) {
      PopViewUtil._contentNode = new ComponentContent(
        PopViewUtil._ctx,
        builder,
        args,
      );
    } else {
      PopViewUtil._contentNode = new ComponentContent(
        PopViewUtil._ctx,
        builder as WrappedBuilder<[]>,
      );
    }

    if (PopViewUtil._contentNode !== null) {
      PopViewUtil._ctx
        .getPromptAction()
        .openCustomDialog(PopViewUtil._contentNode, options)
        .then(() => {
          Logger.info(TAG, 'OpenCustomDialog complete.');
        })
        .catch((error: BusinessError) => {
          let message = (error as BusinessError).message;
          let code = (error as BusinessError).code;
          Logger.error(
            TAG,
            `OpenCustomDialog args error code is ${code}, message is ${message}`,
          );
        });
    }
  }

  public static closeDialog() {
    if (PopViewUtil._contentNode !== null) {
      PopViewUtil._ctx
        .getPromptAction()
        .closeCustomDialog(PopViewUtil._contentNode)
        .then(() => {
          Logger.info(TAG, 'CloseCustomDialog complete.');
          PopViewUtil._contentNode = null;
        })
        .catch((error: BusinessError) => {
          let message = (error as BusinessError).message;
          let code = (error as BusinessError).code;
          Logger.error(
            TAG,
            `CloseCustomDialog args error code is ${code}, message is ${message}`,
          );
        });
    }
  }

  public static async openSheet<T extends Object>(
    builder: WrappedBuilder<[T]> | WrappedBuilder<[]>,
    options: SheetOptions,
    args: T,
  ) {
    await PopViewUtil._getUIContext();
    if (!PopViewUtil._ctx) {
      return;
    }
    if (args) {
      PopViewUtil._sheetNode.push(
        new ComponentContent(PopViewUtil._ctx, builder, args),
      );
    } else {
      PopViewUtil._sheetNode.push(
        new ComponentContent(PopViewUtil._ctx, builder as WrappedBuilder<[]>),
      );
    }
    if (PopViewUtil._sheetNode.length) {
      const latest = PopViewUtil._sheetNode[PopViewUtil._sheetNode.length - 1];
      try {
        if (!options.onWillDismiss) {
          options.onWillDismiss = () => {
            PopViewUtil.closeSheet();
          };
        }
        await PopViewUtil._ctx.openBindSheet(latest, options);
        Logger.info(TAG, 'open sheet complete.');
      } catch (err) {
        Logger.error(TAG, `open sheet failed. error: ${JSON.stringify(err)}`);
      }
    }
  }

  public static async closeSheet() {
    if (PopViewUtil._sheetNode.length) {
      const latest = PopViewUtil._sheetNode[PopViewUtil._sheetNode.length - 1];
      try {
        await PopViewUtil._ctx.closeBindSheet(latest);
        Logger.info(TAG, 'close sheet complete.');
        PopViewUtil._sheetNode.pop();
      } catch (err) {
        Logger.error(TAG, `close sheet failed. error: ${JSON.stringify(err)}`);
      }
    } else {
      Logger.error(TAG, 'sheet node is empty');
    }
  }

  public static async closeAllSheet() {
    if (PopViewUtil._sheetNode.length) {
      PopViewUtil._sheetNode.forEach(async (item) => {
        try {
          await PopViewUtil._ctx.closeBindSheet(item);
          Logger.info(TAG, 'close sheet complete.');
        } catch (err) {
          Logger.error(
            TAG,
            `close sheet failed. error: ${JSON.stringify(err)}`,
          );
        }
      });
      PopViewUtil._sheetNode = [];
    }
  }
}
