import { ComponentContent, PromptAction, UIObserver, window } from '@kit.ArkUI'
import { Constants, GlobalContext, TCLogger } from 'common'

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
  confirmText?: ResourceStr = '确认'
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
  private async open(option: ToastOption) {
    try {
      let windowClass = await window.getLastWindow(GlobalContext.getUIAbilityContext())
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
    } catch {
    }

  }

  /**
   * 显示toast
   */
  public show(option: ToastOption) {
    this.open(option)
  }

  private async autoHide() {
    try {
      if (Toast._instance === null || Toast._instance.loadingDialog === null) {
        return
      }
      await Toast._instance.promptAction?.closeCustomDialog(Toast._instance.loadingDialog)
      Toast._instance.loadingDialog?.dispose()
    } catch (e) {
      TCLogger.error('draw_bord' + e)
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

@ComponentV2
struct defaultContent {
  @Require @Param option: ToastOption
  @BuilderParam messageBuilder: () => void

  build() {
    Column() {
      if (this.option.hasTitle) {
        Column() {
          Text(this.option.hasTitle)
            .fontColor($r('sys.color.font_primary'))
            .fontSize($r('sys.float.Title_S'))
            .fontWeight(FontWeight.Bold)
        }
        .padding({ top: 20 })
      }
      Column() {
        if (this.option.messageBuilder) {
          this.messageBuilder()
        } else {
          Column() {
            Text(this.option.message)
              .fontColor($r('sys.color.font_primary'))
              .fontSize($r('sys.float.Body_L'))
              .fontWeight(FontWeight.Regular)
          }
          .height(40)
          .justifyContent(FlexAlign.Center)
        }
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
      .padding({ left: 16, right: 16 })

      Divider()
        .strokeWidth('1px')
        .width(Constants.FULL_SIZE)
        .padding({ left: 16, right: 16 })
        .color($r('sys.color.comp_divider'))

      Row() {
        Text('取消')
          .fontColor(this.option.cancelColor ? this.option.cancelColor : $r('sys.color.font_emphasize'))
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .onClick(() => {
            baseToast.hideAll()
            this.option?.cancelAction?.()
          })
          .layoutWeight(1)
          .height(Constants.FULL_SIZE)
          .textAlign(TextAlign.Center)
        Divider()
          .strokeWidth('1px')
          .width(25)
          .color($r('sys.color.comp_divider'))
          .rotate({ angle: 90 })
        Text(this.option.confirmText || '确认')
          .fontColor(this.option.confirmColor ? this.option.confirmColor : $r('sys.color.font_emphasize'))
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .onClick(() => {
            this.option?.confirmAction?.()
          })
          .layoutWeight(1)
          .height(Constants.FULL_SIZE)
          .textAlign(TextAlign.Center)
      }
      .width(Constants.FULL_SIZE)
      .height(56)
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .height(this.option.hasTitle ? 160 : 120)
    .width(328)
    .backgroundColor($r('sys.color.background_primary'))
    .borderRadius($r('sys.float.corner_radius_level16'))
  }
}

const baseToast = new Toast()

export { baseToast }