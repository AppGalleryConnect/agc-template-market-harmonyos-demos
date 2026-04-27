import { window } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { UtilLog } from '@hw-agconnect/util-log';
import { WindowSizeVM } from '../viewmodels/WindowSizeVM';
import { FinalAvoidAreaVM } from '../viewmodels/FinalAvoidAreaVM';

export class WindowListener {
  public avoidArea: FinalAvoidAreaVM = new FinalAvoidAreaVM();
  public windowSize: WindowSizeVM = new WindowSizeVM();
  private mainWindow: window.Window;
  private onAvoidAreaChange: Callback<window.AvoidAreaOptions> = (options: window.AvoidAreaOptions) => {
    if (options.type === window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR) {
      this.avoidArea.setIndicatorAvoidArea(options.area);
    } else if (options.type === window.AvoidAreaType.TYPE_SYSTEM) {
      this.avoidArea.setSystemAvoidArea(options.area);
    } else if (options.type === window.AvoidAreaType.TYPE_CUTOUT) {
      this.avoidArea.setCutoutAvoidArea(options.area);
    }
  };
  private onWindowSizeChange: Callback<window.Size> = (size: window.Size) => {
    this.windowSize.width = size.width;
    this.windowSize.height = size.height;
    this.avoidArea.setWindowSize(this.windowSize);
  };

  public start(): void {
    this.loadAvoidAreaInfo([
      window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR,
      window.AvoidAreaType.TYPE_SYSTEM,
      window.AvoidAreaType.TYPE_CUTOUT
    ]);
    try {
      const windowRect: window.Rect = this.mainWindow.getWindowProperties().windowRect;
      this.onWindowSizeChange({ width: windowRect.width, height: windowRect.height });
      this.mainWindow.on('avoidAreaChange', this.onAvoidAreaChange);
      this.mainWindow.on('windowSizeChange', this.onWindowSizeChange);
    } catch (err) {
      UtilLog.error('[ModuleBaseWindow]',
        `Failed to get window properties. Code is ${err.code}, message is ${err.message}`);
    }
  }

  public stop(): void {
    this.mainWindow.off('avoidAreaChange', this.onAvoidAreaChange);
    this.mainWindow.off('windowSizeChange', this.onWindowSizeChange);
  }

  private loadAvoidAreaInfo(types: window.AvoidAreaType[]): void {
    for (const type of types) {
      try {
        this.onAvoidAreaChange({
          type: type,
          area: this.mainWindow.getWindowAvoidArea(type)
        });
      } catch (err) {
        UtilLog.error('[ModuleBaseWindow]',
          `Failed to get window avoid area. Code is ${err.code}, message is ${err.message}`);
      }
    }
  }

  constructor(ctx: common.UIAbilityContext) {
    this.mainWindow = ctx.windowStage.getMainWindowSync();
  }
}
