import { UtilLog } from '@hw-agconnect/util-log';
import { ComponentContent, PromptAction, UIObserver, window } from '@kit.ArkUI'

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
   * message builder
   */
  messageBuilder?: () => void = () => {
  }
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
  cancelColor?: ResourceStr | Color = $r('sys.color.font_emphasize')
  /**
   * 确认按钮颜色
   */
  confirmColor?: ResourceStr | Color = $r('sys.color.font_emphasize')
}


@Builder
function defaultBuilder(option: ToastOption) {
  defaultContent({
    option: option,
    messageBuilder: option.messageBuilder,
  })
}

class Toast {
  private static _instance: Toast = new Toast()
  private loadingDialogArray: ComponentContent<ToastOption>[] = []
  private loadingDialog: ComponentContent<ToastOption> | null = null
  private promptAction: PromptAction | null = null

  constructor() {
  }

  private static getInstance(loadingDialog: ComponentContent<ToastOption>,
    promptAction: PromptAction, uiObserver: UIObserver): Toast {
    if (!Toast._instance) {
      Toast._instance = new Toast()
    }
    Toast._instance.loadingDialog = loadingDialog
    Toast._instance.loadingDialogArray?.push(loadingDialog)
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
      UtilLog.error(`open dialog failed with error ${JSON.stringify(e)}`);
    }
  }

  /**
   * 显示toast
   */
  public show(option: ToastOption, uiContext: UIContext) {
    this.open(option, uiContext)
  }

  private async autoHide() {
    try {
      if (Toast._instance === null || Toast._instance.loadingDialog === null) {
        return
      }
      await Toast._instance.promptAction?.closeCustomDialog(Toast._instance.loadingDialog)
      Toast._instance.loadingDialog?.dispose()
    } catch (e) {
      console.error('draw_bord' + e)
    }
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

@Component
struct defaultContent {
  @Prop option: ToastOption
  @BuilderParam messageBuilder: () => void

  build() {
    Column() {
      if (this.option.hasTitle) {
        Column() {
          Text(this.option.hasTitle)
            .fontColor($r('sys.color.font_primary'))
            .fontSize($r('sys.float.Title_S'))
            .fontWeight(FontWeight.Medium)
        }
      }
      Column() {
        if (this.option.messageBuilder) {
          this.messageBuilder()
        } else {
          Row({ space: 10 }) {
            Text(this.option.message)
              .fontColor($r('sys.color.font_primary'))
              .fontSize($r('sys.float.Body_M'))
              .fontWeight(FontWeight.Regular)
          }
        }
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
      .margin({ top: 16 })
      .padding({ left: 16, right: 16 })

      Row() {
        Text('取消')
          .fontColor(this.option.cancelColor ? this.option.cancelColor : $r('sys.color.font_emphasize'))
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .onClick(() => {
            baseToast.hideAll()
          })
          .width('50%')
          .height('100%')
          .textAlign(TextAlign.Center)
        Text('确认')
          .fontColor(this.option.confirmColor ? this.option.confirmColor : $r('sys.color.font_emphasize'))
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .onClick(() => {
            this.option?.confirmAction?.()
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
}

const baseToast = new Toast()

export {
  baseToast }