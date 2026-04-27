import { ComponentContent, UIContext } from '@kit.ArkUI';
import { AsyncCallback, BusinessError } from '@kit.BasicServicesKit';
import { UtilLog } from '@hw-agconnect/util-log';
import { DialPanelContentVM } from './viewmodels/DialPanelContentVM';
import { DialPanelSheet } from './components/DialPanelSheet';

export class DialPanel {

  private uiContext: UIContext;

  private content: DialPanelContentVM = new DialPanelContentVM();

  private node: ComponentContent<DialPanelContentVM> | null = null;

  /**
   * 设置标题
   *
   * @param value - 拨号面板顶部标题
   */
  public setTitle(value: string): DialPanel {
    this.content.title = value;
    return this;
  }

  /**
   * 设置电话号码
   *
   * @param value - 电话号码
   */
  public setPhoneNumber(value: string): DialPanel {
    this.content.phoneNumber = value;
    return this;
  }

  /**
   * 设置拨号面板自动关闭
   *
   * @param value - 是否在成功前往拨号页面后自动关闭面板 (默认为 true)
   */
  public setAutoClosePanel(value: boolean): DialPanel {
    this.content.isAutoClosePanel = value;
    return this;
  }

  /**
   * 监听拨号页面跳转事件
   *
   * @param callback - 页面跳转回调函数
   * @throws { BusinessError } 0       - [custom] Success.
   * @throws { BusinessError } -1      - [custom] The SystemCapability.Applications.Contacts is not supported.
   * @throws { BusinessError } 8300001 - Invalid parameter value.
   * @throws { BusinessError } 8300002 - Operation failed. Cannot connect to service.
   * @throws { BusinessError } 8300003 - System internal error.
   * @throws { BusinessError } 8300999 - Unknown error code.
   * @see https://developer.huawei.com/consumer/cn/doc/harmonyos-references/errorcode-telephony
   */
  public onMakeCall(callback: AsyncCallback<void>): DialPanel {
    this.content.onMakeCall = callback;
    return this;
  }

  /**
   * 监听交互式关闭事件
   *
   * @param callback - 交互式关闭回调函数，其中 reason 为交互类型，回调注册后模态窗将不会自动关闭
   */
  public onWillDismiss(callback: (reason: DismissReason) => void): DialPanel {
    this.content.onWillDismiss = callback;
    return this;
  }

  /**
   * 监听模态窗关闭前回弹事件
   *
   * @param callback - 模态窗回弹回调函数，其中 action 用于主动触发回弹，回调注册后模态窗将不会自动回弹
   */
  public onWillSpringBackWhenDismiss(callback: (action: SpringBackAction) => void): DialPanel {
    this.content.onWillSpringBackWhenDismiss = callback;
    return this;
  }

  /**
   * 关闭拨号面板
   */
  public close(): void {
    if (this.content.isOpen && this.node) {
      this.content.isOpen = false;
      this.uiContext.closeBindSheet(this.node).catch((err: BusinessError) => {
        UtilLog.error('[DialPanel]', `Failed to close bind sheet. Code is ${err.code}, message is ${err.message}`);
      }).finally(() => this.node = null);
    }
  }

  /**
   * 打开拨号面板
   *
   * @returns - true: 打开成功, false: 打开失败
   */
  public async open(): Promise<boolean> {
    if (this.content.isOpen || this.node) {
      return false;
    }
    try {
      this.content.isOpen = true;
      this.node = new ComponentContent(this.uiContext, wrapBuilder(buildDialPanelSheet), this.content);
      await this.uiContext.openBindSheet(this.node, {
        height: SheetSize.FIT_CONTENT,
        showClose: false,
        preferType: SheetType.CENTER,
        enableOutsideInteractive: false,
        onWillDismiss: (action: DismissSheetAction) => this.content.onWillDismiss(action.reason),
        onWillSpringBackWhenDismiss: (action: SpringBackAction) => this.content.onWillSpringBackWhenDismiss(action),
        backgroundColor: $r('sys.color.comp_background_primary'),
        onTypeDidChange: (type: SheetType) => this.content.sheetType = type
      });
      return true;
    } catch {
      this.content.isOpen = false;
      this.node = null;
      return false;
    }
  }

  constructor(uiContext: UIContext) {
    this.uiContext = uiContext;
    this.content.onWillDismiss = () => this.close();
    this.content.close = () => this.close();
  }
}

@Builder
function buildDialPanelSheet(content: DialPanelContentVM): void {
  DialPanelSheet({ content: content })
}
