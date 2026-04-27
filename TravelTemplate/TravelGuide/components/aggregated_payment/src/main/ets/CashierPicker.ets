import { ComponentContent, LevelMode, PromptAction, UIContext } from '@kit.ArkUI';

import { CashierPickerContentVM } from './viewmodels/CashierPickerContentVM';
import { PaymentType } from './common/CustomTypes';
import { CashierPickerSheet } from './components/CashierPickerSheet';

export class CashierPicker {

  private uiContext: UIContext;

  private promptAction: PromptAction;

  private pickerContent: CashierPickerContentVM = new CashierPickerContentVM();

  private node: ComponentContent<CashierPickerContentVM> | null = null;

  /**
   * 重置收银台选择器内部状态
   *
   * 当前重置项：订单总金额、订单摘要、已选择的支付方式
   */
  public reset(): CashierPicker {
    this.pickerContent.reset();
    return this;
  }

  /**
   * 设置订单总金额
   *
   * @param value - 订单总金额（单位：分, 符号：¥）
   */
  public setAmount(value: number): CashierPicker {
    this.pickerContent.amount = value;
    return this;
  }

  /**
   * 设置订单摘要
   *
   * @param value - 摘要文本 (默认为空字符串, 不占用任何布局)
   */
  public setTradeSummary(value: string): CashierPicker {
    this.pickerContent.tradeSummary = value;
    return this;
  }

  /**
   * 监听支付发起事件
   *
   * @param callback - 支付发起回调函数
   */
  public onRealPayment(callback: (type: PaymentType) => void | Promise<void>): CashierPicker {
    this.pickerContent.payment = callback;
    return this;
  }

  /**
   * 监听交互式关闭事件
   *
   * @param callback - 交互式关闭回调函数，其中 reason 为交互类型，注册后可重写默认行为
   */
  public onWillDismiss(callback: (reason: DismissReason) => void): CashierPicker {
    this.pickerContent.willDismiss = callback;
    return this;
  }

  /**
   * 关闭收银台选择器
   */
  public close(): void {
    if (this.pickerContent.isOpen && this.node) {
      this.pickerContent.isOpen = false;
      // DISAPPEAR 动画结束后执行真正关闭
      setTimeout(() => {
        this.promptAction.closeCustomDialog(this.node).finally(() => this.node = null);
      }, this.pickerContent.durationForDisappear);
    }
  }

  /**
   * 打开收银台选择器
   *
   * @returns - true: 打开成功, false: 打开失败
   */
  public async open(): Promise<boolean> {
    if (this.pickerContent.isOpen || this.node) {
      return false;
    }
    try {
      this.pickerContent.isOpen = true;
      this.node = new ComponentContent(this.uiContext, wrapBuilder(buildCashierPickerSheet), this.pickerContent);
      await this.promptAction.openCustomDialog(this.node, {
        alignment: DialogAlignment.Bottom,
        isModal: true,
        showInSubWindow: false,
        onWillDismiss: (action: DismissDialogAction) => this.pickerContent.willDismiss(action.reason),
        autoCancel: false,
        transition: TransitionEffect.IDENTITY,
        maskColor: Color.Transparent,
        levelMode: LevelMode.EMBEDDED
      });
      return true;
    } catch {
      this.pickerContent.isOpen = false;
      this.node = null;
      return false;
    }
  }

  constructor(uiContext: UIContext) {
    this.uiContext = uiContext;
    this.promptAction = uiContext.getPromptAction();
    this.pickerContent.willDismiss = () => this.close();
  }
}

@Builder
function buildCashierPickerSheet(content: CashierPickerContentVM): void {
  CashierPickerSheet({ content: content })
}
