import { AppStorageV2, window } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { UtilLog } from '@hw-agconnect/util-log';
import { FinalAvoidAreaVM } from '../viewmodels/FinalAvoidAreaVM';

const TAG = '[WindowListener]';

export class WindowListener {
  public avoidArea: FinalAvoidAreaVM = AppStorageV2.connect(FinalAvoidAreaVM, () => new FinalAvoidAreaVM())!;
  private mainWindow: window.Window | undefined = undefined;
  private onAvoidAreaChange: Callback<window.AvoidAreaOptions> = (options: window.AvoidAreaOptions) => {
    if (options.type === window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR) {
      this.avoidArea.setIndicatorAvoidArea(options.area);
    } else if (options.type === window.AvoidAreaType.TYPE_CUTOUT) {
      this.avoidArea.setCutoutAvoidArea(options.area);
    } else if (options.type === window.AvoidAreaType.TYPE_SYSTEM) {
      this.avoidArea.setSystemAvoidArea(options.area);
    }
  };
  private onWindowSizeChange: Callback<window.Size> = (size: window.Size) => {
    this.avoidArea.setWindowSize(size);
  };

  public start(): void {
    this.loadAvoidAreaInfo([
      window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR,
      window.AvoidAreaType.TYPE_CUTOUT,
      window.AvoidAreaType.TYPE_SYSTEM,
    ]);
    if (!this.mainWindow) {
      return;
    }
    try {
      const windowRect: window.Rect = this.mainWindow.getWindowProperties().windowRect;
      this.onWindowSizeChange({ width: windowRect.width, height: windowRect.height });
      this.mainWindow.on('avoidAreaChange', this.onAvoidAreaChange);
      this.mainWindow.on('windowSizeChange', this.onWindowSizeChange);
    } catch (e) {
      UtilLog.error(TAG, 'getWindowProperties fail, error: ' + JSON.stringify(e));
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
      UtilLog.error(TAG, 'off mainWindow fail, error: ' + JSON.stringify(e));
    }
  }

  private loadAvoidAreaInfo(types: window.AvoidAreaType[]): void {
    if (!this.mainWindow) {
      return;
    }
    try {
      for (const type of types) {
        this.onAvoidAreaChange({
          type: type,
          area: this.mainWindow.getWindowAvoidArea(type),
        });
      }
    } catch (e) {
      UtilLog.error(TAG, 'getWindowAvoidArea fail, error: ' + JSON.stringify(e));
    }
  }

  constructor(ctx: common.UIAbilityContext) {
    try {
      this.mainWindow = ctx.windowStage.getMainWindowSync();
    } catch (e) {
      UtilLog.error(TAG, 'getMainWindowSync fail, error: ' + JSON.stringify(e));
    }
  }
}
