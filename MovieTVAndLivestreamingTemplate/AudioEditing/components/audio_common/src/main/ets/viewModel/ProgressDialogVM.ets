import { ComponentContent, PromptAction } from '@kit.ArkUI';
import { ExportStateVM } from '../model/ExportStateVM';
import { ProgressDialogInfo } from '../model/ProgressDialogModel';
import { ProgressDialog } from '../components/ProgressDialog';
import { common } from '@kit.AbilityKit';

@ObservedV2
export class ProgressDialogVM {
  context: UIContext | null = null

  constructor(context: UIContext) {
    this.context = context
  }

  @Trace uIAbilityContext: common.UIAbilityContext | null = null
  @Trace completeValue: number = 0;
  @Trace exportStateInfo: ExportStateVM = new ExportStateVM();
  static contentNode: ComponentContent<object> | null = null;
  static promptActionUI: PromptAction | null = null
  @Trace dialogState: ProgressDialogInfo = new ProgressDialogInfo(); //弹框双向绑定数据
  @Trace timer: number = 0
  static completeState: boolean = false

  closeDialog() {
    ProgressDialogVM.promptActionUI?.closeCustomDialog(ProgressDialogVM.contentNode)
      .then(() => {
        setTimeout(() => {
          ProgressDialogVM.completeState = false
          this.exportStateInfo.completeValue = 0
        }, 500)

      })
      .catch(() => {
      })
  }

  completeDialog() { //任务完成时主动调用
    ProgressDialogVM.completeState = true
    // 主动关闭弹窗
    this.closeDialog();
  }

  stopProgress() {
    if (this.timer) {
      clearInterval(this.timer);
      this.timer = 0;
    }
  }

  // 重置状态
  reset() {
    this.stopProgress();
    ProgressDialogVM.completeState = false;
    this.exportStateInfo.completeValue = 0;
    if (this.dialogState) {
      this.dialogState.completeValue = 0;
    }
  }

  getCompleteValue(duration: number = 7500000) { //单个/多个文件总时长 不传值默认一分钟
    let lastDuration = duration === 0 ? 7500000 : duration
    let delay = lastDuration / 5000
    // 如果计算出的 delay 太小，可能会导致 UI 线程卡顿，设置一个最小阈值
    if (delay < 10) {
      delay = 10;
    }

    this.stopProgress(); // 确保启动前清理旧的定时器
    this.exportStateInfo.completeValue = 0
    ProgressDialogVM.completeState = false // 重置完成状态

    this.timer = setInterval(() => {

      if (ProgressDialogVM.completeState) {
        clearInterval(this.timer)
        this.timer = 0; // 清理 timer 引用
        this.exportStateInfo.completeValue = 100
        ProgressDialogVM.completeState = false
        // 不在这里自动关闭弹窗，由外部业务逻辑决定何时关闭，
        // 或者如果需要自动关闭，应该有延迟，让用户看到 100%
        return
      }

      if (this.exportStateInfo.completeValue < 95) { // 修改为 < 95，防止在 95 时重复赋值
        this.exportStateInfo.completeValue += 1
      }
    }, delay)
  }

  openDialog(dialogState: ProgressDialogInfo) {

    ProgressDialogVM.promptActionUI = this.context!.getPromptAction();
    ProgressDialogVM.contentNode = new ComponentContent(this.context!, wrapBuilder(ProgressDialog), dialogState);

    try {
      ProgressDialogVM.promptActionUI?.openCustomDialog(ProgressDialogVM.contentNode, {
        isModal: true,
        autoCancel: false, // 禁止遮罩点击
        onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
          if ((dismissDialogAction.reason !== DismissReason.TOUCH_OUTSIDE) &&
            (dismissDialogAction.reason !== DismissReason.PRESS_BACK)) {
            dismissDialogAction.dismiss(); // 非蒙层点击则关闭弹窗
          }
          // 点击蒙层时不执行关闭操作
        }
      });
    } catch (error) {
    }
    this.dialogState.completeValue = 0
    ProgressDialogVM.contentNode?.update(this.dialogState);
  }

  toast(msg: string) {
    this.context?.getPromptAction().showToast({
      message: msg
    })
  }
}
