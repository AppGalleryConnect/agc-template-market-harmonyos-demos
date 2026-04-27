import { ComponentContent, PromptAction } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit'
import { UtilLog } from '@hw-agconnect/util-log';
import { LOG_TAG } from '../common/Constants';

export class LoadingMask {

  private uiContext: UIContext;

  private promptAction: PromptAction;

  private node: ComponentContent<[]> | null = null;

  public async show(): Promise<boolean> {
    if (this.node) {
      return false;
    }
    try {
      this.node = new ComponentContent(this.uiContext, wrapBuilder(buildLoadingMask));
      await this.promptAction.openCustomDialog(this.node, {
        alignment: DialogAlignment.Center,
        isModal: true,
        showInSubWindow: false,
        onWillDismiss: () => {},
        autoCancel: false,
        transition: TransitionEffect.OPACITY,
        maskColor: Color.Transparent
      });
      return true;
    } catch {
      this.node = null;
      return false;
    }
  }

  public hide(): void {
    this.promptAction.closeCustomDialog(this.node).finally(() => this.node = null).catch((err: BusinessError) => {
      UtilLog.error(LOG_TAG, 'open custom dialog failed. error: ' + JSON.stringify(err))
    })
  }

  constructor(uiContext: UIContext) {
    this.uiContext = uiContext;
    this.promptAction = uiContext.getPromptAction();
  }
}

@Builder
export function buildLoadingMask(): void {
  Column() {
    LoadingProgress()
      .width(40)
      .height(40)
  }
  .width('100%')
  .height('100%')
  .justifyContent(FlexAlign.Center)
  .hitTestBehavior(HitTestMode.Block)
}
