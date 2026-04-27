import { contextUtil } from './ContextUtil'

class ToastUtil {
  public showToast(text: string) {
    const uiContext = contextUtil.getUiContext()
    if (uiContext) {
      uiContext.getPromptAction().showToast({ message: text });
    }
  }
}

export const toastUtil = new ToastUtil();