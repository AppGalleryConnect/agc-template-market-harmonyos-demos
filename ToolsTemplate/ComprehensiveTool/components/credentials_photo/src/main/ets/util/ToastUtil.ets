
class ToastUtil {
  private uiContext: UIContext | undefined = undefined;

  public setUiContext(ctx: UIContext) {
    this.uiContext = ctx;
  }

  public showToast(text: string) {
    if (this.uiContext) {
      this.uiContext.getPromptAction().showToast({ message: text });
    }
  }
}

export const toastUtil = new ToastUtil();