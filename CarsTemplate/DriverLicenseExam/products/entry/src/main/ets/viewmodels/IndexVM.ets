import { BreakpointUtils, BaseViewModel } from '@ohos_agcit/driver_license_exam_commonlib';

@ObservedV2
export class IndexVM extends BaseViewModel {
  breakpoint: BreakpointUtils | null = null;

  /**
   * 注册断点监听器
   * @param context UIContext
   */
  registerBreakpointListener(context: UIContext) {
    this.breakpoint = new BreakpointUtils(context.getMediaQuery());
    this.breakpoint?.register();
  }

  /**
   * 取消注册断点监听器
   */
  unregisterBreakpointListener() {
    this.breakpoint?.unRegister();
  }
}