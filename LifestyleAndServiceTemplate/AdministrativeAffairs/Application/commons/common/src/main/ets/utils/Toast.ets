import { ComponentContent, curves, PromptAction, UIObserver, window } from '@kit.ArkUI'
import { Constants } from '../constants/Constants'

class ToastOption {
  /**
   * toast类型
   */
  type: 'loading' | 'dialog' | 'pickerDialog' | 'sheetDialog' = 'loading'
  /**
   * dialog类型时提示语
   */
  message?: ResourceStr = ''
  /**
   * pickerDialog类型时数据源
   */
  dataList?: string[]
  /**
   * pickerDialog当前选择项索引
   */
  selectedIndex?: number | number [] = 0
  /**
   * 弹窗确认回调
   */
  confirmAction?: (selected?: number | number [] | string[]) => void = () => {
  }
  /**
   * 多选的选中值
   */
  sheetSelectList?: string[] = []
  /**
   * 弹窗取消回调
   */
  cancelAction?: () => void = () => {
  }
  hasTitle?: ResourceStr = ''
}


/**
 * loading builder
 */
@Builder
function loadingBuilder(option: ToastOption) {
  Column() {
    LoadingProgress().width($r('app.float.loading_progress_size')).height($r('app.float.loading_progress_size'))
    Text(option.message ?? $r('app.string.dialog_loading'))
  }
  .padding({
    top: $r('app.float.dialog_padding_tb'),
    bottom: $r('app.float.dialog_padding_tb'),
    left: $r('app.float.dialog_padding_lr'),
    right: $r('app.float.dialog_padding_lr'),
  })
  .backgroundColor($r('sys.color.background_primary'))
  .borderRadius(Constants.RADIUS_TEN)
}

/**
 * dialog builder
 */
@Builder
function dialogBuilder(option: ToastOption) {
  Column() {
    if (option.hasTitle) {
      Column() {
        Text(option.hasTitle).fontColor($r('sys.color.font_primary'))
          .fontSize($r('sys.float.Title_S')).fontWeight(FontWeight.Medium)
      }
    }
    Column() {
      Row({ space: Constants.CONTAINER_SPACE_TEN }) {
        Text(option.message).fontColor($r('sys.color.font_primary'))
          .fontSize($r('sys.float.Body_M')).fontWeight(FontWeight.Regular)
      }
    }.layoutWeight(1).justifyContent(FlexAlign.Center).margin({ top: $r('app.float.common_margin_sixty') })

    Row() {
      Text($r('app.string.dialog_cancel'))
        .fontColor($r('sys.color.font_emphasize'))
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
        .onClick(() => {
          commonToast.hideAll()
        })
        .width(Constants.HALF_PERCENT_WIDTH)
        .height(Constants.FULL_PERCENT_HEIGHT)
        .textAlign(TextAlign.Center)
      Text($r('app.string.dialog_confirm'))
        .fontColor($r('sys.color.font_emphasize'))
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
        .onClick(() => {
          option?.confirmAction?.()
        })
        .width(Constants.HALF_PERCENT_WIDTH)
        .height(Constants.FULL_PERCENT_HEIGHT)
        .textAlign(TextAlign.Center)
    }
    .width(Constants.FULL_PERCENT_WIDTH)
    .height($r('app.float.dialog_content_size'))
    .margin({ top: $r('app.float.common_margin_nineteen') })
    .justifyContent(FlexAlign.SpaceBetween)
  }
  .padding({ top: $r('app.float.dialog_content_padding') })
  .justifyContent(FlexAlign.SpaceBetween)
  .height(139)
  .width(328)
  .backgroundColor($r('sys.color.background_primary'))
  .borderRadius(32)
}

/**
 * pickerDialog builder
 */
@Builder
function pickerDialogBuilder(option: ToastOption) {
  Column() {
    Row() {
      Text($r('app.string.dialog_cancel'))
        .onClick(() => {
          commonToast.hideAll()
        })
        .width(Constants.HALF_PERCENT_WIDTH)
        .height(Constants.FULL_PERCENT_HEIGHT)
        .textAlign(TextAlign.Center)
        .fontSize(Constants.FONT_SIZE_SMALL)
      Image($r('app.media.vertical_line'))
        .width($r('app.float.dialog_line_width'))
        .height($r('app.float.dialog_line_height'))
      Text($r('app.string.dialog_confirm'))
        .onClick(() => {
          option?.confirmAction?.(option.selectedIndex)
        })
        .width(Constants.HALF_PERCENT_WIDTH)
        .height(Constants.FULL_PERCENT_HEIGHT)
        .textAlign(TextAlign.Center)
        .fontSize(Constants.FONT_SIZE_SMALL)
        .fontColor($r('app.color.dialog_color'))
    }
    .width(Constants.FULL_PERCENT_WIDTH)
    .height($r('app.float.dialog_content_height'))
    .justifyContent(FlexAlign.SpaceBetween)

    TextPicker({ range: option.dataList, selected: option.selectedIndex })
      .canLoop(false)
      .disappearTextStyle({ font: { size: Constants.FONT_SIZE_SMALL } })
      .onChange((value: string | string[], index: number | number[]) => {
        option.selectedIndex = index
        console.info('Picker item changed, value: ' + value + ', index: ' + index)
      })
  }
  .padding({ top: $r('app.float.dialog_content_padding_top'), bottom: $r('app.float.dialog_content_padding_bottom') })
  .justifyContent(FlexAlign.SpaceBetween)
  .backgroundColor($r('sys.color.background_primary'))
  .borderRadius(Constants.RADIUS_TWENTY)
}

/**
 * sheetDialog builder
 */
@ComponentV2
struct sheetDialog {
  @Param option: ToastOption = new ToastOption()
  /**
   * 多选的选中值
   */
  @Local sheetSelectList: string[] = []

  aboutToAppear(): void {
    if (this.option.sheetSelectList && this.option.sheetSelectList.length > 0) {
      this.sheetSelectList = this.option?.sheetSelectList
    }
  }

  build() {
    Column() {
      Row() {
        Text($r('app.string.dialog_cancel'))
          .onClick(() => {
            commonToast.hideAll()
          })
          .width(Constants.HALF_PERCENT_WIDTH)
          .height(Constants.FULL_PERCENT_HEIGHT)
          .textAlign(TextAlign.Center)
          .fontSize(Constants.FONT_SIZE_SMALL)
        Image($r('app.media.vertical_line'))
          .width($r('app.float.dialog_line_width'))
          .height($r('app.float.dialog_line_height'))
        Text($r('app.string.dialog_confirm'))
          .onClick(() => {
            this.option?.confirmAction?.(this.sheetSelectList)
          })
          .fontSize(Constants.FONT_SIZE_SMALL)
          .width(Constants.HALF_PERCENT_WIDTH)
          .height(Constants.FULL_PERCENT_HEIGHT)
          .textAlign(TextAlign.Center)
          .fontColor($r('app.color.cancel_color'))
      }
      .width(Constants.FULL_PERCENT_WIDTH)
      .height($r('app.float.dialog_content_height'))
      .justifyContent(FlexAlign.SpaceBetween)

      Column() {
        Text($r('app.string.convenience_service'))
          .fontWeight(Constants.FONT_WEIGHT_MEDIUM)
          .margin($r('app.float.dialog_content_margin'))
        Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
          ForEach(this.option.dataList, (item: string, index: number) => {
            Text(item)
              .padding($r('app.float.dialog_content_padding_top'))
              .fontColor(this.sheetSelectList.includes(item) ? Color.White : Color.Black)
              .backgroundColor(this.sheetSelectList.includes(item) ? $r('app.color.dialog_sheet_color') :
              $r('app.color.color_grey'))
              .borderRadius(Constants.RADIUS_TEN)
              .fontSize(Constants.FONT_SIZE_SMALL)
              .onClick(() => {
                //   修改
                this.sheetSelectList.includes(item) ? this.sheetSelectList.splice(index, 1) :
                this.sheetSelectList.push(item)
              })
          }, (item: string) => item)
        }
      }.width(Constants.FULL_PERCENT_WIDTH).alignItems(HorizontalAlign.Start)
    }
    .padding({ top: $r('app.float.dialog_content_padding'), bottom: $r('app.float.dialog_padding_bottom') })
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor(Color.White)
    .borderRadius(Constants.RADIUS_TWENTY)
  }
}

/**
 * 集中处理插槽
 */
@Builder
function defaultBuilder(option: ToastOption) {
  if (option?.type === 'loading') {
    loadingBuilder(option)
  } else if (option?.type === 'pickerDialog') {
    pickerDialogBuilder(option)
  } else if (option?.type === 'sheetDialog') {
    sheetDialog({
      option: option,
    })
  } else {
    dialogBuilder(option)
  }
}

class Toast {
  private static _instance: Toast = new Toast()
  private loadingDialogArray: ComponentContent<ToastOption>[] = []
  private loadingDialog: ComponentContent<ToastOption> | null = null
  private promptAction: PromptAction | null = null
  private uiObserver: UIObserver | null = null

  constructor() {
  }

  private static getInstance(loadingDialog: ComponentContent<ToastOption>,
    promptAction: PromptAction, uiObserver: UIObserver): Toast {
    if (!Toast._instance) {
      Toast._instance = new Toast()
    }
    Toast._instance.loadingDialog = loadingDialog
    Toast._instance.loadingDialogArray?.push(loadingDialog)
    Toast._instance.uiObserver = uiObserver
    Toast._instance.promptAction = promptAction
    return Toast._instance
  }

  /**
   * 根据参数打开弹框
   */
  private async open(option: ToastOption) {
    let windowClass = await window.getLastWindow(getContext())
    let uiContext = windowClass.getUIContext()
    let loadingDialog = new ComponentContent(uiContext, wrapBuilder(defaultBuilder), option)
    let promptAction = uiContext.getPromptAction()
    let uiObserver = uiContext.getUIObserver()
    Toast._instance = Toast.getInstance(loadingDialog, promptAction, uiObserver)
    await promptAction.openCustomDialog(loadingDialog, {
      alignment: ['pickerDialog', 'sheetDialog'].includes(option.type) ? DialogAlignment.Bottom :
      DialogAlignment.Center,
      autoCancel: ['pickerDialog', 'sheetDialog'].includes(option.type),
      isModal: true,
      transition: TransitionEffect.IDENTITY,
      onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
        if (dismissDialogAction.reason === DismissReason.PRESS_BACK) {
          dismissDialogAction.dismiss()
        }
        if (dismissDialogAction.reason === DismissReason.TOUCH_OUTSIDE) {
          dismissDialogAction.dismiss()
        }
      },
    })
  }

  /**
   * 显示toast
   */
  public show(option: ToastOption) {
    this.open(option)
  }

  private async autoHide() {

    if (Toast._instance === null || Toast._instance.loadingDialog === null) {
      return
    }
    await Toast._instance.promptAction?.closeCustomDialog(Toast._instance.loadingDialog)
    Toast._instance.loadingDialog?.dispose()
  }

  /**
   * 关闭toast
   */
  public hide() {
    setTimeout(() => {
      this.autoHide()
    }, 1)
  }

  public hideAll() {
    setTimeout(() => {
      if (Toast._instance === null || Toast._instance.loadingDialogArray?.length <= 0) {
        return
      }
      Toast._instance.loadingDialogArray?.forEach(async (item: ComponentContent<ToastOption>) => {
        await Toast._instance.promptAction?.closeCustomDialog(item)
        item?.dispose()
      })
    }, 1)
  }
}

const commonToast = new Toast()

export {
  commonToast }