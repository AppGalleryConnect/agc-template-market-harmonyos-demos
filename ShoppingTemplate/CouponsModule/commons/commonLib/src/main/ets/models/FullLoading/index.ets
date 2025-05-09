import { ComponentContent, promptAction } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { Logger } from '../../utils/Logger';

const TAG = '[FullLoading]'

export class FullLoading {
  public static isLoading: boolean = false
  private static ctx: UIContext;
  private static contentNode: ComponentContent<Object>;
  private static options: promptAction.BaseDialogOptions;
  private static count: number = 0

  static init(ctx: UIContext) {
    FullLoading.ctx = ctx;
    FullLoading.contentNode = new ComponentContent(FullLoading.ctx, wrapBuilder(fullLoading))
    FullLoading.options = {
      alignment: DialogAlignment.Center,
      autoCancel: false,
    }
  }

  static showLoading(doNext?: () => void) {
    FullLoading.count++;
    if (FullLoading.isLoading || FullLoading.count > 1) {
      return;
    }
    if (FullLoading.contentNode !== null) {
      FullLoading.ctx.getPromptAction()
        .openCustomDialog(FullLoading.contentNode, FullLoading.options)
        .then(() => {
          FullLoading.isLoading = true;
          doNext?.()
        })
        .catch((error: BusinessError) => {
          Logger.error(TAG, `OpenCustomDialog args error code is ${error.code}, message is ${error.message}`);
        })
    }
  }

  static hideLoading(doNext?: () => void) {
    if (!FullLoading.isLoading) {
      return;
    }
    FullLoading.count--;
    if (FullLoading.contentNode !== null && FullLoading.isLoading && FullLoading.count === 0) {
      FullLoading.ctx.getPromptAction()
        .closeCustomDialog(FullLoading.contentNode)
        .then(() => {
          Logger.info(TAG, 'CloseCustomDialog complete.')
          FullLoading.isLoading = false;
          FullLoading.count = 0;
          doNext?.()
        })
        .catch((error: BusinessError) => {
          Logger.error(TAG, `CloseCustomDialog args error code is ${error.code}, message is ${error.message}`);
        })
    }
  }
}

@Builder
export function fullLoading() {
  Stack({ alignContent: Alignment.Center }) {
    Column() {
      LoadingProgress().width(32).height(32).color($r('sys.color.icon_on_primary'))
    }
    .justifyContent(FlexAlign.Center)
    .width(100)
    .height(100)
    .backgroundColor('#88000000')
    .borderRadius(8)
  }
  .width('100%')
  .height('100%')
  .backgroundColor(Color.Transparent)
}