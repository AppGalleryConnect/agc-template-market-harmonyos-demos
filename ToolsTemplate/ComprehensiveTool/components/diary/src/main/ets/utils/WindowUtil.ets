@ObservedV2
export class WindowUtil {
  @Trace private static _context: Context | undefined;
  @Trace private static _uiContext: UIContext;

  public static get context(): Context | undefined {
    return WindowUtil._context;
  }

  public static get uiContext(): UIContext {
    return WindowUtil._uiContext;
  }

  public static async init(uiContext: UIContext) {
    if (WindowUtil._uiContext) {
      return;
    }
    WindowUtil._uiContext = uiContext;
    WindowUtil._context = WindowUtil._uiContext.getHostContext();
  }
}
