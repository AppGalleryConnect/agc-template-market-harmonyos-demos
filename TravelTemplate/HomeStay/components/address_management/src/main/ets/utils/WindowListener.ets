import { window } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { UtilLog } from '@hw-agconnect/util-log';
import { FinalAvoidAreaVM } from '../viewmodels/FinalAvoidAreaVM';

const TAG = '[WindowListener]';

export class WindowListener {
  public avoidArea: FinalAvoidAreaVM = new FinalAvoidAreaVM();
  private mainWindow: window.Window | undefined = undefined;

  constructor(ctx: common.UIAbilityContext) {
    try {
      this.mainWindow = ctx.windowStage.getMainWindowSync();
    } catch (e) {
      UtilLog.error(TAG, 'Fail to getMainWindowSync, error: ' + JSON.stringify(e));
    }
  }

  public start(): void {
    this.loadAvoidAreaInfo([
      window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR,
      window.AvoidAreaType.TYPE_CUTOUT,
    ]);
    if (!this.mainWindow) {
      return;
    }
    try {
      const windowRect: window.Rect = this.mainWindow.getWindowProperties().windowRect;
      this.onWindowSizeChange({ width: windowRect.width, height: windowRect.height });
      this.mainWindow.on('avoidAreaChange', this.onAvoidAreaChange);
      this.mainWindow.on('windowSizeChange', this.onWindowSizeChange);
    } catch (err) {
      UtilLog.error(TAG, `Failed to get window properties. Code is ${err.code}, message is ${err.message}`);
    }
  }

  public stop(): void {
    if (!this.mainWindow) {
      return;
    }
    try {
      this.mainWindow.off('avoidAreaChange', this.onAvoidAreaChange);
      this.mainWindow.off('windowSizeChange', this.onWindowSizeChange);
    } catch (e) {
      UtilLog.error(TAG, 'Fail to stop, error: ' + JSON.stringify(e));
    }
  }

  private onAvoidAreaChange: Callback<window.AvoidAreaOptions> = (options: window.AvoidAreaOptions) => {
    if (options.type === window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR) {
      this.avoidArea.setIndicatorAvoidArea(options.area);
    } else if (options.type === window.AvoidAreaType.TYPE_CUTOUT) {
      this.avoidArea.setCutoutAvoidArea(options.area);
    }
  };
  private onWindowSizeChange: Callback<window.Size> = (size: window.Size) => {
    this.avoidArea.setWindowSize(size);
  };

  private loadAvoidAreaInfo(types: window.AvoidAreaType[]): void {
    if (!this.mainWindow) {
      return;
    }
    for (const type of types) {
      try {
        this.onAvoidAreaChange({
          type: type,
          area: this.mainWindow.getWindowAvoidArea(type),
        });
      } catch (err) {
        UtilLog.error(TAG, `Failed to get window avoid area. Code is ${err.code}, message is ${err.message}`);
      }
    }
  }
}
