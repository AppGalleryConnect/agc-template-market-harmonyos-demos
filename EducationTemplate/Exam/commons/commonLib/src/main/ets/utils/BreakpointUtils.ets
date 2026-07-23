import { AppStorageV2, window } from '@kit.ArkUI';
import { BreakpointModel, BreakpointNameEnum } from '../models/BreakpointModel';
import { UtilLog } from '@hw-agconnect/util-log';

const TAG = '[BreakpointUtils]';

/**
 * 断点类
 */
export class BreakpointUtils {
  public uiContext?: UIContext;
  public mainWindow?: window.Window;
  private breakpointModel: BreakpointModel = new BreakpointModel();

  constructor(mainWindow: window.Window) {
    try {
      this.mainWindow = mainWindow;
      this.uiContext = mainWindow.getUIContext();
      this.breakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
    } catch (e) {
      UtilLog.error(TAG, 'Failed to constructor: ', JSON.stringify(e));
    }
  }

  private updateBreakpoint: (value: number) => void = (value: number) => {
    UtilLog.info(TAG, `updateBreakpoint: ${value}`);
    let breakPoint = this.transformBreakpointNameEnum(value);
    this.breakpointModel.currentBreakpoint = breakPoint as BreakpointNameEnum;
  };

  register() {
    UtilLog.info(TAG, 'register breakpoint listener.');
    try {
      const handleBreakpoint = (widthBp: WidthBreakpoint) => {
        // 保存到AppStorage中
        UtilLog.info(TAG, 'register breakpoint listener.',);
        this.updateBreakpoint(widthBp);
      };
      // 初始化赋值
      handleBreakpoint(this.uiContext!.getWindowWidthBreakpoint());
      // 窗口变化时更新
      this.mainWindow!.on('windowSizeChange', () => {
        handleBreakpoint(this.uiContext!.getWindowWidthBreakpoint());
      });
    } catch (e) {
      UtilLog.error(TAG, 'Failed to register breakpoint: ', JSON.stringify(e));
    }
  }

  unRegister() {
    UtilLog.info(TAG, 'unregister breakpoint listener.');
    try {
      this.mainWindow?.off('windowSizeChange');
    } catch (err) {
      UtilLog.error(`listenSizeChange fail, error code: ${err.code}, error mesage: ${err.message}`);
    }
  }

  transformBreakpointNameEnum(value: number): string {
    let valueStr = 'sm';
    switch (value) {
      case 0:
        // 穿戴设备未配置
        valueStr = 'sm';
        break;
      case 1:
        valueStr = 'sm';
        break;
      case 2:
        valueStr = 'md';
        break;
      case 3:
        valueStr = 'lg';
        break;
      case 4:
        valueStr = 'xl';
        break;
      default:
        valueStr = 'sm';
        break;
    }
    return valueStr;
  }
}