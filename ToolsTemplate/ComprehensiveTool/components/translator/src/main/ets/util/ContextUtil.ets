class ContextUtil {
  private uiContext: UIContext | undefined = undefined;

  public setUiContext(ctx: UIContext) {
    this.uiContext = ctx;
  }

  public getUiContext() {
    return this.uiContext
  }

  public getContext() {
    return this.uiContext?.getHostContext()
  }
}

export const contextUtil = new ContextUtil()