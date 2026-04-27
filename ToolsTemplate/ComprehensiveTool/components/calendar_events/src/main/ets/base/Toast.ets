import { UtilLog } from '@hw-agconnect/util-log';
import { ComponentContent, PromptAction, UIObserver, window } from '@kit.ArkUI'

/**
 * custom builder
 */
@ComponentV2
struct customBuilder {
  @Param @Require option: ToastOption
  @BuilderParam customContent: () => void
  @BuilderParam customFooter: () => void

  build() {
    Column() {
      Column() {
        Text(this.option.hasTitle)
          .fontColor($r('sys.color.font_primary'))
          .fontSize($r('sys.float.Title_S'))
          .fontWeight(FontWeight.Medium)
      }
      .alignItems(HorizontalAlign.Center)
      .margin({ bottom: 16 })

      Column() {
        this.customContent()
      }

      Row() {
        this.customFooter()
      }
      .width('100%')
      .height(60)
      .margin({ top: 19 })
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .padding({ top: 20, left: 16, right: 16 })
    .justifyContent(FlexAlign.SpaceBetween)
    .layoutWeight(1)
    .width(328)
    .backgroundColor($r('sys.color.background_primary'))
    .borderRadius(32)
  }
}

class ToastOption {
  /**
   * toast类型
   */
  type: 'loading' | 'dialog' | 'custom' = 'loading'
  /**
   * dialog类型时提示语
   */
  message?: ResourceStr = ''
  /**
   * 弹窗确认回调
   */
  confirmAction?: (selected?: number | number [] | string[]) => void = () => {
  }
  /**
   * 弹窗取消回调
   */
  cancelAction?: () => void = () => {
  }
  /**
   * 是否显示标题
   */
  hasTitle?: ResourceStr = ''
  /**
   * 自定义内容
   */
  customContent?: () => void = () => {
  }
  /**
   * 自定义底部内容
   */
  customFooter?: () => void = () => {
  }
  /**
   * 取消按钮颜色
   */
  cancelColor?:ResourceStr | Color = $r('sys.color.font_emphasize')

  /**
   * 确认按钮颜色
   */
  confirmColor?:ResourceStr | Color = $r('sys.color.font_emphasize')
}

/**
 * loading builder
 */
@Builder
function loadingBuilder(option: ToastOption) {
  Column() {
    LoadingProgress().width(40).height(40)
    Text(option.message ?? '加载中')
  }
  .padding({
    top: 20,
    bottom: 20,
    left: 25,
    right: 25,
  })
  .backgroundColor($r('sys.color.background_primary'))
  .borderRadius(12)
}

/**
 * dialog builder
 */
@Builder
function dialogBuilder(option: ToastOption) {
  Column() {
    if (option.hasTitle) {
      Column() {
        Text(option.hasTitle)
          .fontColor($r('sys.color.font_primary'))
          .fontSize($r('sys.float.Title_S'))
          .fontWeight(FontWeight.Medium)
      }
    }
    Column() {
      Row({ space: 10 }) {
        Text(option.message)
          .fontColor($r('sys.color.font_primary'))
          .fontSize($r('sys.float.Body_M'))
          .fontWeight(FontWeight.Regular)
      }
    }
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .margin({ top: 16 })
    .padding({ left: 16, right: 16 })

    Row() {
      Text('取消')
        .fontColor(option.cancelColor?option.cancelColor:$r('sys.color.font_emphasize'))
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
        .onClick(() => {
          baseToast.hideAll()
        })
        .width('50%')
        .height('100%')
        .textAlign(TextAlign.Center)
      Text('确认')
        .fontColor(option.confirmColor?option.confirmColor:$r('sys.color.font_emphasize'))
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
        .onClick(() => {
          option?.confirmAction?.()
        })
        .width('50%')
        .height('100%')
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .height(60)
    .margin({ top: 19 })
    .justifyContent(FlexAlign.SpaceBetween)
  }
  .padding({ top: 20 })
  .justifyContent(FlexAlign.SpaceBetween)
  .height(150)
  .width(328)
  .backgroundColor($r('sys.color.background_primary'))
  .borderRadius(32)
}


/**
 * 集中处理插槽
 */
@Builder
function defaultBuilder(option: ToastOption) {
  if (option?.type === 'loading') {
    loadingBuilder(option)
  } else if (option?.type === 'dialog') {
    dialogBuilder(option)
  } else if (option?.type === 'custom') {
    customBuilder({
      option: option,
      customContent: option.customContent,
      customFooter: option.customFooter,
    })
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
  private async open(option: ToastOption, uc: UIContext) {
    try {
      let windowClass = await window.getLastWindow(uc.getHostContext()!)
      let uiContext = windowClass.getUIContext()
      let loadingDialog = new ComponentContent(uiContext, wrapBuilder(defaultBuilder), option)
      let promptAction = uiContext.getPromptAction()
      let uiObserver = uiContext.getUIObserver()
      Toast._instance = Toast.getInstance(loadingDialog, promptAction, uiObserver)
      await promptAction.openCustomDialog(loadingDialog, {
        alignment: DialogAlignment.Center,
        autoCancel: false,
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
    } catch (e) {
      UtilLog.error(`session close failed: ${JSON.stringify(e)}`);
    }
  }

  /**
   * 显示toast
   */
  public show(option: ToastOption, uiContext: UIContext) {
    this.open(option, uiContext)
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
    this.autoHide()
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

const baseToast = new Toast()

export {
  baseToast }