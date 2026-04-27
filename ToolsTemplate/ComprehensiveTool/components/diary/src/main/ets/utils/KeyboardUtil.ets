import { UtilLog } from '@hw-agconnect/util-log';
import { window } from '@kit.ArkUI';

export class KeyboardUtil {
  uiContext: UIContext

  constructor(context: UIContext) {
    this.uiContext = context;
  }

  registerKeyboardListener(onKeyboardShow: () => void, onKeyboardHide: () => void) {
    try {
      window.getLastWindow(this.uiContext.getHostContext()).then(currentWindow => {
        currentWindow.on('keyboardHeightChange', (data: number) => {
          const keyboardHeight = this.uiContext.px2vp(data)
          if (keyboardHeight > 0) {
            onKeyboardShow()
          } else {
            onKeyboardHide()
          }
        })
      })
    } catch (e) {
      UtilLog.error(`registerKeyboardListener failed with error ${JSON.stringify(e)}`);
    }
  }

  unregisterKeyboardListener() {
    try {
      window.getLastWindow(this.uiContext.getHostContext()).then(currentWindow => {
        currentWindow.off('keyboardHeightChange')
      })
    } catch (e) {
      UtilLog.error(`unregisterKeyboardListener failed with error ${JSON.stringify(e)}`);
    }
  }

  hideKeyboard() {
    this.uiContext.getFocusController().clearFocus();
  }

  showKeyboard(focusId: string) {
    this.uiContext.getFocusController().requestFocus(focusId);
  }
}