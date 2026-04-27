import { ComponentContent, PromptAction } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit'
import { UtilLog } from '@hw-agconnect/util-log';
import { LOG_TAG } from '../common/Constants';
import { SimpleDialogContentVM } from '../viewmodels/SimpleDialogContentVM';

export class SimpleDialog {

  private uiContext: UIContext;

  private promptAction: PromptAction;

  private node: ComponentContent<SimpleDialogContentVM> | null = null;

  private content: SimpleDialogContentVM = new SimpleDialogContentVM();

  public setMessage(msg: string): SimpleDialog {
    this.content.message = msg;
    return this;
  }

  public setConfirmButton(text: string, color: ResourceStr): SimpleDialog {
    this.content.confirmButtonText = text;
    this.content.confirmButtonTextColor = color;
    return this;
  }

  public setCancelButton(text: string, color: ResourceStr): SimpleDialog {
    this.content.cancelButtonText = text;
    this.content.cancelButtonTextColor = color;
    return this;
  }

  public onWillDismiss(callback: (reason: DismissReason) => void): SimpleDialog {
    this.content.onWillDismiss = callback;
    return this;
  }

  public onConfirm(callback: () => void): SimpleDialog {
    this.content.onConfirm = callback;
    return this;
  }

  public async open(): Promise<boolean> {
    if (this.node) {
      return false;
    }
    try {
      this.node = new ComponentContent(this.uiContext, wrapBuilder(buildSimpleDialog), this.content);
      await this.promptAction.openCustomDialog(this.node, {
        alignment: DialogAlignment.Center,
        isModal: true,
        showInSubWindow: false,
        onWillDismiss: (action: DismissSheetAction) => this.content.onWillDismiss(action.reason),
        autoCancel: false,
        transition: TransitionEffect.OPACITY
      });
      return true;
    } catch {
      this.node = null;
      return false;
    }
  }

  public close(): void {
    this.promptAction.closeCustomDialog(this.node).finally(() => this.node = null).catch((err: BusinessError) => {
      UtilLog.error(LOG_TAG, 'open custom dialog failed. error: ' + JSON.stringify(err))
    })
  }

  constructor(uiContext: UIContext) {
    this.uiContext = uiContext;
    this.promptAction = uiContext.getPromptAction();
    this.content.onWillDismiss = (reason: DismissReason) => {
      if (reason === DismissReason.PRESS_BACK || reason === DismissReason.CLOSE_BUTTON) {
        this.close();
      }
    };
  }
}

@Builder
export function buildSimpleDialog(content: SimpleDialogContentVM): void {
  Column() {
    Column() {
      Text(content.message)
        .constraintSize({ maxWidth: '100%' })
        .fontColor($r('sys.color.font_primary'))
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Regular)
        .padding({ left: 8, right: 8 })
        .margin({ bottom: 24, top: 8 })
      Row() {
        Button(content.cancelButtonText)
          .fontColor(content.cancelButtonTextColor)
          .type(ButtonType.ROUNDED_RECTANGLE)
          .backgroundColor(Color.Transparent)
          .layoutWeight(1)
          .onClick(() => content.onWillDismiss(DismissReason.CLOSE_BUTTON))
        Divider()
          .height(24)
          .vertical(true)
          .margin({ left: 8, right: 8 })
        Button(content.confirmButtonText)
          .fontColor(content.confirmButtonTextColor)
          .type(ButtonType.ROUNDED_RECTANGLE)
          .backgroundColor(Color.Transparent)
          .layoutWeight(1)
          .onClick(() => content.onConfirm())
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .constraintSize({ maxWidth: 480 })
    .borderRadius(32)
    .backgroundColor($r('sys.color.background_primary'))
  }
  .padding({ left: 16, right: 16 })
}
