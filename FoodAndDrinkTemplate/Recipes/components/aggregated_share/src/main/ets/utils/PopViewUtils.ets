import { ComponentContent } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { UtilLog } from '@hw-agconnect/util-log';

const TAG: string = '[SharePopViewUtil]'
const DOMAIN: number = 0x0000

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
  private static uiContext: UIContext;
  private sheetList: PopViewModel[] = [];

  private static shareInstance(): PopViewUtils {
    if (!PopViewUtils.popShare) {
      PopViewUtils.popShare = new PopViewUtils();
    }
    return PopViewUtils.popShare;
  }

  private static async showSheetView<T extends Object>(type: PopViewShowType,
    contentView: WrappedBuilder<[T]> | WrappedBuilder<[]>, args?: T,
    options?: SheetOptions): Promise<void> {
      let componentContent: ComponentContent<Object> | null = null;
      if (args) {
        componentContent = new ComponentContent(PopViewUtils.uiContext, contentView, args);
      } else {
        componentContent = new ComponentContent(PopViewUtils.uiContext, contentView as WrappedBuilder<[]>);
      }
    PopViewUtils.uiContext.openBindSheet(componentContent, options).then(() => {
        if (componentContent) {
          let sheetList = PopViewUtils.shareInstance().sheetList;
          let info: PopViewModel = {
            com: componentContent,
            popType: type,
          };
          sheetList[0] = info;
        };
        UtilLog.info(DOMAIN, TAG, 'sheet open, options: ' + JSON.stringify(options));
      }).catch((err: BusinessError) => {
        UtilLog.error(DOMAIN, TAG, `openBindSheet failed. Code is ${err.code}, message is ${err.message}`);
      });
  }

  private static async closeSheetView(type: PopViewShowType): Promise<void> {
    if (PopViewUtils.uiContext) {
      let sameTypeList = PopViewUtils.shareInstance().sheetList.filter((model) => {
        return model.popType === type;
      })
      let info = sameTypeList[sameTypeList.length - 1];
      if (info?.com) {
        PopViewUtils.shareInstance().sheetList = PopViewUtils.shareInstance().sheetList.filter((model) => {
          return model.com !== info.com;
        })
        PopViewUtils.uiContext.closeBindSheet(info.com).catch((err: BusinessError) => {
          UtilLog.error(DOMAIN, TAG, `closeBindSheet failed. Code is ${err.code}, message is ${err.message}`);
        });
        UtilLog.info(DOMAIN, TAG, 'sheet close');
      }
    }
  }

  public static setUiContext(uiContext: UIContext) {
    PopViewUtils.uiContext = uiContext;
  }

  /**
   * 打开半模态弹窗
   * @param contentView
   * @param args
   * @param options
   */
  public static showSheet<T extends Object>(contentView: WrappedBuilder<[T]> | WrappedBuilder<[]>, uiContext: UIContext,
    options?: SheetOptions, args?: T): void {
    PopViewUtils.setUiContext(uiContext);
    PopViewUtils.showSheetView(PopViewShowType.OPEN, contentView, args, options);
  }

  /**
   * 关闭半模态弹窗
   */
  public static closeSheet(): void {
    PopViewUtils.closeSheetView(PopViewShowType.OPEN);
  }
}