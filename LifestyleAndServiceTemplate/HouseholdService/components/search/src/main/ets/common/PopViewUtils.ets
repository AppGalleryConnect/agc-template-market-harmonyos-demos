import { ComponentContent, promptAction } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { UtilLog } from '@hw-agconnect/util-log';


const TAG: string = '[PopViewUtil]'
const DOMAIN: number = 0x0000

export enum PopViewShowType {
  OPEN
}

interface PopViewModel {
  com: ComponentContent<object>;
  popType: PopViewShowType;
}

export class PopViewUtils {
  private static popShare: PopViewUtils;
  private static uiContext: UIContext;
  private infoList: PopViewModel[] = [];

  public static initPopViewUtil(uiContext: UIContext) {
    if (PopViewUtils.uiContext) {
      return;
    }
    PopViewUtils.uiContext = uiContext;
  }

  static shareInstance(): PopViewUtils {
    if (!PopViewUtils.popShare) {
      PopViewUtils.popShare = new PopViewUtils();
    }
    return PopViewUtils.popShare;
  }

  static async showDialog<T extends object>(type: PopViewShowType, contentView: WrappedBuilder<[T]>, args: T,
    options?: promptAction.BaseDialogOptions): Promise<void> {
    if (!PopViewUtils.uiContext) {
      return;
    }
    if (PopViewUtils.uiContext) {
      let prompt = PopViewUtils.uiContext.getPromptAction();
      let componentContent = new ComponentContent(PopViewUtils.uiContext, contentView, args);
      let customOptions: promptAction.BaseDialogOptions = {
        alignment: options?.alignment || DialogAlignment.Bottom,
        autoCancel: options?.autoCancel || false,
        onWillDismiss: (v: DismissDialogAction) => {
          if (options?.autoCancel) {
            v.dismiss();
          }
        },
      };
      prompt.openCustomDialog(componentContent, customOptions).catch((err: BusinessError) => {
        UtilLog.error(TAG, DOMAIN,
          `PoPViewUtils openCustomDialog failed. Code is ${err.code}, message is ${err.message}`);
      });
      let infoList = PopViewUtils.shareInstance().infoList;
      let info: PopViewModel = {
        com: componentContent,
        popType: type,
      };
      infoList[0] = info;
    }
  }

  static async closeDialog(type: PopViewShowType): Promise<void> {
    if (!PopViewUtils.uiContext) {
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
        prompt.closeCustomDialog(info.com).catch((err: BusinessError) => {
          UtilLog.error(TAG, DOMAIN,
            `PoPViewUtils closeCustomDialog failed. Code is ${err.code}, message is ${err.message}`);
        });
      }
    }
  }

  static showPopView<T extends object>(contentView: WrappedBuilder<[T]>, args: T,
    options?: promptAction.BaseDialogOptions): void {
    PopViewUtils.showDialog(PopViewShowType.OPEN, contentView, args, options);
  }

  static closePopView(): void {
    PopViewUtils.closeDialog(PopViewShowType.OPEN);
  }
}
