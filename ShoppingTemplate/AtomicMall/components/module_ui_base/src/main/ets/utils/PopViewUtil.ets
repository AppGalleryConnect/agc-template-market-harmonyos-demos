import { ComponentContent, promptAction, window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { UtilLog as Logger } from '@hw-agconnect/util-log';
import { WindowUtil } from './WindowUtil';

const TAG: string = '[UIBase][PopViewUtil]';

export class PopViewUtil {
  private static _ctx: UIContext;
  private static _dialogNodes: ComponentContent<Object>[] = [];
  private static _sheetNode: ComponentContent<Object>[] = [];

  private static async _getUIContext() {
    if (!PopViewUtil._ctx) {
      PopViewUtil._ctx = WindowUtil.uiContext;
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
      PopViewUtil._dialogNodes.push(
        new ComponentContent(PopViewUtil._ctx, builder, args),
      );
    } else {
      PopViewUtil._dialogNodes.push(
        new ComponentContent(PopViewUtil._ctx, builder as WrappedBuilder<[]>),
      );
    }

    if (PopViewUtil._dialogNodes.length) {
      const latest =
        PopViewUtil._dialogNodes[PopViewUtil._dialogNodes.length - 1];
      try {
        if (!options.onWillDismiss) {
          options.onWillDismiss = () => {
            PopViewUtil.closeDialog();
          };
        }
        await PopViewUtil._ctx
          .getPromptAction()
          .openCustomDialog(latest, options);
        Logger.info(TAG, 'open custom dialog complete.');
      } catch (err) {
        Logger.error(
          TAG,
          `open custom dialog failed. error: ${JSON.stringify(err)}`,
        );
      }
    }
  }

  public static closeDialog() {
    if (PopViewUtil._dialogNodes.length) {
      const latest =
        PopViewUtil._dialogNodes[PopViewUtil._dialogNodes.length - 1];
      PopViewUtil._ctx
        .getPromptAction()
        .closeCustomDialog(latest)
        .then(() => {
          Logger.info(TAG, 'close custom dialog complete.');
          PopViewUtil._dialogNodes.pop();
        })
        .catch((error: BusinessError) => {
          Logger.error(
            TAG,
            `close custom dialog failed. error: ${JSON.stringify(error)}`,
          );
        });
    }
  }

  public static async openSheet<T extends Object>(
    builder: WrappedBuilder<[T]> | WrappedBuilder<[]>,
    options: SheetOptions,
    args?: T,
    uiContext?: UIContext,
  ) {
    if (uiContext) {
      PopViewUtil._ctx = uiContext;
    }
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
