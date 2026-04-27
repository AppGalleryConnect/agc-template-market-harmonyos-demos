import { ComponentContent, promptAction } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { Logger } from './Logger';
import { contextUtil } from './ContextUtil';

const TAG = '[PopViewUtils]';

enum PopViewShowType {
  OPEN,
}

async function getUIContext() {
  return (await (contextUtil.getContext() as common.UIAbilityContext).windowStage.getMainWindow()).getUIContext();
}

interface PopViewModel {
  com: ComponentContent<Object>;
  popType: PopViewShowType;
}

/**
 * 全局弹窗类
 */
export class PopViewUtils {
  private static _popShare: PopViewUtils;
  private static _uiContext: UIContext;
  private _infoList: PopViewModel[] = [];
  private _sheetList: PopViewModel[] = [];

  /**
   * 打开弹窗
   * @param contentView
   * @param args
   * @param options
   */
  public static showPopView<T extends Object>(contentView: WrappedBuilder<[T]> | WrappedBuilder<[]>,
    options?: promptAction.BaseDialogOptions, args?: T): void {
    PopViewUtils._showDialog(PopViewShowType.OPEN, contentView, args, options);
  }

  /**
   * 关闭弹窗
   */
  public static closePopView(): void {
    PopViewUtils._closeDialog(PopViewShowType.OPEN);
  }

  /**
   * 打开半模态弹窗
   * @param contentView
   * @param args
   * @param options
   */
  public static showSheet<T extends Object>(contentView: WrappedBuilder<[T]> | WrappedBuilder<[]>,
    options?: SheetOptions, args?: T): void {
    PopViewUtils._showSheetView(PopViewShowType.OPEN, contentView, args, options);
  }

  /**
   * 关闭半模态弹窗
   */
  public static closeSheet(): void {
    PopViewUtils._closeSheetView(PopViewShowType.OPEN);
  }

  private static _shareInstance(): PopViewUtils {
    if (!PopViewUtils._popShare) {
      PopViewUtils._popShare = new PopViewUtils();
    }
    return PopViewUtils._popShare;
  }

  private static async _showDialog<T extends Object>(type: PopViewShowType,
    contentView: WrappedBuilder<[T]> | WrappedBuilder<[]>, args?: T,
    options?: promptAction.BaseDialogOptions): Promise<void> {
    if (!PopViewUtils._uiContext) {
      PopViewUtils._uiContext = await getUIContext();
    }
    if (PopViewUtils._uiContext) {
      let prompt = PopViewUtils._uiContext.getPromptAction();
      let componentContent: ComponentContent<Object> | null = null;
      if (args) {
        componentContent = new ComponentContent(PopViewUtils._uiContext, contentView, args);
      } else {
        componentContent = new ComponentContent(PopViewUtils._uiContext, contentView as WrappedBuilder<[]>);
      }

      let customOptions: promptAction.BaseDialogOptions = {
        alignment: options?.alignment ?? DialogAlignment.Center,
        autoCancel: options?.autoCancel ?? true,
        maskColor: options?.maskColor,
        onWillDismiss: (v: DismissDialogAction) => {
          if (options?.autoCancel ?? true) {
            v.dismiss();
          }
        },
      };
      prompt.openCustomDialog(componentContent, customOptions);
      let infoList = PopViewUtils._shareInstance()._infoList;
      let info: PopViewModel = {
        com: componentContent,
        popType: type,
      };
      infoList[0] = info;
      Logger.info(TAG, 'dialog open, options: ' + JSON.stringify(options));
    }
  }

  private static async _closeDialog(type: PopViewShowType): Promise<void> {
    if (!PopViewUtils._uiContext) {
      PopViewUtils._uiContext = await getUIContext();
    }
    if (PopViewUtils._uiContext) {
      let prompt = PopViewUtils._uiContext.getPromptAction();
      let sameTypeList = PopViewUtils._shareInstance()._infoList.filter((model) => {
        return model.popType === type;
      });
      let info = sameTypeList[sameTypeList.length - 1];
      if (info?.com) {
        PopViewUtils._shareInstance()._infoList = PopViewUtils._shareInstance()._infoList.filter((model) => {
          return model.com !== info.com;
        });
        prompt.closeCustomDialog(info.com);
        Logger.info(TAG, 'dialog close');
      }
    }
  }

  private static async _showSheetView<T extends Object>(type: PopViewShowType,
    contentView: WrappedBuilder<[T]> | WrappedBuilder<[]>, args?: T,
    options?: SheetOptions): Promise<void> {
    if (!PopViewUtils._uiContext) {
      PopViewUtils._uiContext = await getUIContext();
    }
    if (PopViewUtils._uiContext) {
      let componentContent: ComponentContent<Object> | null = null;
      if (args) {
        componentContent = new ComponentContent(PopViewUtils._uiContext, contentView, args);
      } else {
        componentContent = new ComponentContent(PopViewUtils._uiContext, contentView as WrappedBuilder<[]>);
      }

      let sheetOptions: SheetOptions = {
        height: options?.height,
        dragBar: options?.dragBar,
        maskColor: options?.maskColor,
        detents: options?.detents,
        showClose: options?.showClose,
        title: options?.title,
      };
      PopViewUtils._uiContext.openBindSheet(componentContent, sheetOptions);
      let sheetList = PopViewUtils._shareInstance()._sheetList;
      let info: PopViewModel = {
        com: componentContent,
        popType: type,
      };
      sheetList[0] = info;
      Logger.info(TAG, 'sheet open, options: ' + JSON.stringify(sheetOptions));
    }
  }

  private static async _closeSheetView(type: PopViewShowType): Promise<void> {
    if (!PopViewUtils._uiContext) {
      PopViewUtils._uiContext = await getUIContext();
    }
    if (PopViewUtils._uiContext) {
      let sameTypeList = PopViewUtils._shareInstance()._sheetList.filter((model) => {
        return model.popType === type;
      });
      let info = sameTypeList[sameTypeList.length - 1];
      if (info?.com) {
        PopViewUtils._shareInstance()._sheetList = PopViewUtils._shareInstance()._sheetList.filter((model) => {
          return model.com !== info.com;
        });
        PopViewUtils._uiContext.closeBindSheet(info.com);
        Logger.info(TAG, 'sheet close');
      }
    }
  }
}
