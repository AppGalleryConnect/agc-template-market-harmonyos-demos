
export class ShareEventDispatcher {
  static closeCallback?: () => void;

  static dispatchToClose() {
    if (ShareEventDispatcher.closeCallback) {
      ShareEventDispatcher.closeCallback();
    }
  }
}