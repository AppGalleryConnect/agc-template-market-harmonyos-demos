import { ComponentContent, promptAction } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { Logger } from './Utils';


const TAG = '[Loading]';

export class Loading {
  private static _ctx: UIContext;
  private static _contentNode: ComponentContent<Object>;
  private static _options: promptAction.BaseDialogOptions;
  private static _hasInit: boolean;

  public static init(ctx: UIContext) {
    if (Loading._hasInit) {
      return;
    }
    Loading._ctx = ctx;
    Loading._contentNode = new ComponentContent(Loading._ctx, wrapBuilder(dialogView));
    Loading._options = {
      alignment: DialogAlignment.Center,
      transition: TransitionEffect.OPACITY,
      autoCancel: false,
    };
    Loading._hasInit = true;
  }

  public static open() {
    if (Loading._contentNode !== null) {
      Loading._ctx?.getPromptAction()
        .openCustomDialog(Loading._contentNode, Loading._options)
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

  public static close() {
    if (Loading._contentNode !== null) {
      Loading._ctx?.getPromptAction()
        .closeCustomDialog(Loading._contentNode)
        .then(() => {
          Logger.info(TAG, 'CloseCustomDialog complete.');
        })
        .catch((error: BusinessError) => {
          let message = (error as BusinessError).message;
          let code = (error as BusinessError).code;
          Logger.error(TAG, `CloseCustomDialog args error code is ${code}, message is ${message}`);
        });
    }
  }
}

@Builder
export function dialogView() {
  Column() {
    Column() {
      Text('自动定位')
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'))
        .fontSize($r('sys.float.Subtitle_M'))
      Divider().margin({ top: 6, bottom: 2 })
      LoadingProgress().size({ width: 40, height: 40 })
      Text('正在努力定位您的位置')
        .fontColor($r('sys.color.font_secondary'))
        .fontSize($r('sys.float.Caption_L'))
    }
    .borderRadius(10)
    .padding({ top: 12, bottom: 12 })
    .backgroundColor($r('sys.color.background_primary'))
    .width('60%')
  }
  .width('100%')
  .height('100%')
  .justifyContent(FlexAlign.Center)
  .alignItems(HorizontalAlign.Center)
  .backgroundColor($r('sys.color.mask_fourth'))
}
