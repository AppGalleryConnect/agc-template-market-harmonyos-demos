class ContextUtil {
  private uiContext: UIContext | undefined = undefined;

  public setUiContext(ctx: UIContext) {
    this.uiContext = ctx;
  }

  public getUiContext() {
    return this.uiContext;
  }

  public getContext() {
    return this.uiContext?.getHostContext();
  }

  public getPromptAction() {
    return this.uiContext?.getPromptAction();
  }
}

export const contextUtil = new ContextUtil()