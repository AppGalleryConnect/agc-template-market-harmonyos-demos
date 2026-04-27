import { ComponentContent, promptAction } from '@kit.ArkUI';
import { UtilLog } from '@hw-agconnect/util-log';

export enum PopViewShowType {
  OPEN
}

interface PopViewModel {
  com: ComponentContent<object>;
  popType: PopViewShowType;
}

const TAG = '[PopViewUtils]'

export class PopViewUtils {
  private static popShare: PopViewUtils;
  private static uiContext: UIContext;
  private infoList: PopViewModel[] = [];

  static shareInstance(): PopViewUtils {
    if (!PopViewUtils.popShare) {
      PopViewUtils.popShare = new PopViewUtils();
    }
    return PopViewUtils.popShare;
  }

  static initContext(uiContext: UIContext) {
    PopViewUtils.uiContext = uiContext;
  }

  private static showDialog<T extends object>(type: PopViewShowType, contentView: WrappedBuilder<[T]>, args: T,
    options?: promptAction.BaseDialogOptions): void {
    if (!PopViewUtils.uiContext) {
      UtilLog.error(TAG, 'PopViewUtils uiContext is undefined, please init uiContext');
      return;
    }
    if (PopViewUtils.uiContext) {
      let prompt = PopViewUtils.uiContext.getPromptAction();
      let componentContent = new ComponentContent(PopViewUtils.uiContext, contentView, args);
      let customOptions: promptAction.BaseDialogOptions = {
        alignment: options?.alignment || DialogAlignment.Bottom,
        autoCancel: options?.autoCancel || false,
        maskColor: options?.maskColor,
        onWillDismiss: (v: DismissDialogAction) => {
          if (options?.autoCancel) {
            v.dismiss();
          }
        },
      };
      prompt.openCustomDialog(componentContent, customOptions);
      let infoList = PopViewUtils.shareInstance().infoList;
      let info: PopViewModel = {
        com: componentContent,
        popType: type,
      };
      infoList[0] = info;
    }
  }

  private static closeDialog(type: PopViewShowType): void {
    if (!PopViewUtils.uiContext) {
      UtilLog.error(TAG, 'PopViewUtils uiContext is undefined, please init uiContext');
      return;
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
        prompt.closeCustomDialog(info.com);
      }
    }
  }

  public static showPopView<T extends object>(contentView: WrappedBuilder<[T]>, args: T,
    options?: promptAction.BaseDialogOptions): void {
    PopViewUtils.showDialog(PopViewShowType.OPEN, contentView, args, options);
  }

  public static closePopView(): void {
    PopViewUtils.closeDialog(PopViewShowType.OPEN);
  }
}
