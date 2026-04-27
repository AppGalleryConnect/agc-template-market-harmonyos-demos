import { ComponentContent } from '@kit.ArkUI'

class UnsavedDialogData {
  onConfirm: () => void = () => {
  }
  onCancel: () => void = () => {
  }

  constructor(params: UnsavedChangesDialogParams) {
    this.onConfirm = params.onConfirm
    this.onCancel = params.onCancel
  }
}

export interface UnsavedChangesDialogParams {
  onConfirm: () => void
  onCancel: () => void
}

@Builder
function unsavedDialogBuilder(data: UnsavedDialogData) {
  Column() {

    Text('是否放弃编辑？')
      .fontSize(16)
      .margin({ bottom: 24 })
      .fontColor($r('sys.color.black'))
      .fontWeight(FontWeight.Bold)


    Row() {
      Text('取消')
        .fontSize(16)
        .textAlign(TextAlign.Center)
        .fontColor('rgba(0,0,0,0.6)')
        .width('50%')
        .padding({ top: 12, bottom: 12 })
        .onClick(() => {
          data.onCancel()
          UnsavedChangesDialogController.closeDialog()
        })

      Row()
        .height(25)
        .width(0.5)
        .backgroundColor('#E5E5E5')

      Text('放弃')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Center)
        .fontColor($r('sys.color.black'))
        .padding({ top: 12, bottom: 12 })
        .width('50%')
        .onClick(() => {
          data.onConfirm()
          UnsavedChangesDialogController.closeDialog()
        })
    }
    .width('100%')
  }
  .padding({
    top:30,
    left:24,
    right:24,
    bottom:16
  })
  .width(328)
  .backgroundColor($r('sys.color.comp_background_list_card'))
  .borderRadius(32)
}

export class UnsavedChangesDialogController {
  private static ctx: UIContext
  private static contentNode: ComponentContent<UnsavedDialogData> | null = null

  static closeDialog() {
    if (UnsavedChangesDialogController.contentNode && UnsavedChangesDialogController.ctx) {
      UnsavedChangesDialogController.ctx.getPromptAction().closeCustomDialog(UnsavedChangesDialogController.contentNode)
      UnsavedChangesDialogController.contentNode = null
    }
  }

  static openDialog(uiContext: UIContext, params: UnsavedChangesDialogParams) {
    UnsavedChangesDialogController.ctx = uiContext
    const data = new UnsavedDialogData(params)
    UnsavedChangesDialogController.contentNode =
      new ComponentContent(uiContext, wrapBuilder(unsavedDialogBuilder), data)
    uiContext.getPromptAction().openCustomDialog(UnsavedChangesDialogController.contentNode, {
      alignment: DialogAlignment.Center,
      autoCancel: false
    })
  }
}

