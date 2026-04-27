import { UtilLog } from '@hw-agconnect/util-log';
import { ComponentContent, promptAction } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { GlobalContextUtils } from './ContextUtils';

const TAG = '[PopViewUtils]'

enum PopViewShowType {
  OPEN
}

interface PopViewModel {
  com: ComponentContent<Object>;
  popType: PopViewShowType;
}

/**
 * 全局弹窗类
 */
export class PopViewUtils {
  private static popShare: PopViewUtils;
  private static uiContext: UIContext | undefined = undefined;
  private infoList: PopViewModel[] = [];
  private sheetList: PopViewModel[] = [];

  private static shareInstance(): PopViewUtils {
    if (!PopViewUtils.popShare) {
      PopViewUtils.popShare = new PopViewUtils();
    }
    return PopViewUtils.popShare;
  }

  private static async showDialog<T extends Object>(type: PopViewShowType,
    contentView: WrappedBuilder<[T]> | WrappedBuilder<[]>, args?: T,
    options?: promptAction.BaseDialogOptions): Promise<void> {
    if (!PopViewUtils.uiContext) {
      PopViewUtils.uiContext = GlobalContextUtils.globalUIContext;
    }
    if (PopViewUtils.uiContext) {
      let prompt = PopViewUtils.uiContext.getPromptAction();
      let componentContent: ComponentContent<Object> | null = null;
      if (args) {
        componentContent = new ComponentContent(PopViewUtils.uiContext, contentView, args);
      } else {
        componentContent = new ComponentContent(PopViewUtils.uiContext, contentView as WrappedBuilder<[]>);
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
      prompt.openCustomDialog(componentContent, customOptions)
        .then(() => {
          if (componentContent) {
            let infoList = PopViewUtils.shareInstance().infoList;
            let info: PopViewModel = {
              com: componentContent,
              popType: type,
            };
            infoList[0] = info;
            UtilLog.info(TAG, 'dialog open, options: ' + JSON.stringify(options));
          }
        })
        .catch((error: BusinessError) => {
          UtilLog.error(TAG, 'openCustomDialog fail, error: ' + JSON.stringify(error));
        });
    }
  }

  private static async closeDialog(type: PopViewShowType): Promise<void> {
    if (!PopViewUtils.uiContext) {
      PopViewUtils.uiContext = GlobalContextUtils.globalUIContext;
    }
    if (PopViewUtils.uiContext) {
      let prompt = PopViewUtils.uiContext.getPromptAction();
      let sameTypeList = PopViewUtils.shareInstance().infoList.filter((model) => {
        return model.popType === type;
      })
      let info = sameTypeList[sameTypeList.length - 1];
      if (info?.com) {
        PopViewUtils.shareInstance().infoList = PopViewUtils.shareInstance().infoList.filter((model) => {
          return model.com !== info.com;
        })
        prompt.closeCustomDialog(info.com).catch((error: BusinessError) => {
          UtilLog.error(TAG, 'closeCustomDialog fail, error: ' + JSON.stringify(error));
        });
      }
    }
  }

  private static async showSheetView<T extends Object>(type: PopViewShowType,
    contentView: WrappedBuilder<[T]> | WrappedBuilder<[]>, args?: T,
    options?: SheetOptions, targetId?: number): Promise<void> {
    if (!PopViewUtils.uiContext) {
      PopViewUtils.uiContext = GlobalContextUtils.globalUIContext;
    }
    if (PopViewUtils.uiContext) {
      let componentContent: ComponentContent<Object> | null = null;
      if (args) {
        componentContent = new ComponentContent(PopViewUtils.uiContext, contentView, args);
      } else {
        componentContent = new ComponentContent(PopViewUtils.uiContext, contentView as WrappedBuilder<[]>);
      }

      if (targetId) {
        PopViewUtils.uiContext.openBindSheet(componentContent, options, targetId)
          .catch((error: BusinessError) => {
            UtilLog.error(TAG, 'openBindSheet with targetId fail, error: ' + JSON.stringify(error));
          });
      } else {
        PopViewUtils.uiContext.openBindSheet(componentContent, options)
          .catch((error: BusinessError) => {
            UtilLog.error(TAG, 'openBindSheet fail, error: ' + JSON.stringify(error));
          });
      }

      let sheetList = PopViewUtils.shareInstance().sheetList;
      let info: PopViewModel = {
        com: componentContent,
        popType: type,
      };
      sheetList[0] = info;
      UtilLog.info(TAG, 'sheet open, options: ' + JSON.stringify(options));
    }
  }

  private static async closeSheetView(type: PopViewShowType): Promise<void> {
    if (!PopViewUtils.uiContext) {
      PopViewUtils.uiContext = GlobalContextUtils.globalUIContext;
    }
    if (PopViewUtils.uiContext) {
      let sameTypeList = PopViewUtils.shareInstance().sheetList.filter((model) => {
        return model.popType === type;
      })
      let info = sameTypeList[sameTypeList.length - 1];
      if (info?.com) {
        PopViewUtils.shareInstance().sheetList = PopViewUtils.shareInstance().sheetList.filter((model) => {
          return model.com !== info.com;
        })
        PopViewUtils.uiContext.closeBindSheet(info.com)
          .catch((error: BusinessError) => {
            UtilLog.error(TAG, 'closeBindSheet fail, error: ' + JSON.stringify(error));
          });
      }
    }
  }

  /**
   * 打开弹窗
   * @param contentView
   * @param args
   * @param options
   */
  public static showPopView<T extends Object>(contentView: WrappedBuilder<[T]> | WrappedBuilder<[]>,
    options?: promptAction.BaseDialogOptions, args?: T): void {
    PopViewUtils.showDialog(PopViewShowType.OPEN, contentView, args, options);
  }

  /**
   * 关闭弹窗
   */
  public static closePopView(): void {
    PopViewUtils.closeDialog(PopViewShowType.OPEN);
  }

  /**
   * 打开半模态弹窗
   * @param contentView
   * @param args
   * @param options
   */
  public static showSheet<T extends Object>(contentView: WrappedBuilder<[T]> | WrappedBuilder<[]>,
    options?: SheetOptions, args?: T, targetId?: number): void {
    PopViewUtils.showSheetView(PopViewShowType.OPEN, contentView, args, options, targetId);
  }

  /**
   * 关闭半模态弹窗
   */
  public static closeSheet(): void {
    PopViewUtils.closeSheetView(PopViewShowType.OPEN);
  }
}
