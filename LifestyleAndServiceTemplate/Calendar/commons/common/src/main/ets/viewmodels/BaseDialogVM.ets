import { promptAction } from '@kit.ArkUI'

class BaseDialogVM {
  customDialogId: number = 0

  open(options: promptAction.CustomDialogOptions) {
    this.customDialogId = 0;
    promptAction.openCustomDialog(options).then((dialogId: number) => {
      this.customDialogId = dialogId
    })
  }

  close() {
    if (this.customDialogId) {
      promptAction.closeCustomDialog(this.customDialogId)
      this.customDialogId = 0
    }

  }
}

let baseDialogVM = new BaseDialogVM()

export default baseDialogVM