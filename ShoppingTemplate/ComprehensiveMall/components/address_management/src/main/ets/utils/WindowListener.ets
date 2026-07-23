import { common } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { UtilLog } from '@hw-agconnect/util-log';
import { LOG_TAG } from '../common/Constants';
import { FinalAvoidAreaVM } from '../viewmodels/FinalAvoidAreaVM';

export class WindowListener {
  public avoidArea: FinalAvoidAreaVM = new FinalAvoidAreaVM();
  private mainWindow?: window.Window;
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

  public start(): void {
    this.loadAvoidAreaInfo([
      window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR,
      window.AvoidAreaType.TYPE_CUTOUT,
    ]);
    try {
      const windowRect = this.mainWindow?.getWindowProperties()?.windowRect;
      if (windowRect) {
        this.onWindowSizeChange({ width: windowRect.width, height: windowRect.height });
      }
      this.mainWindow?.on('avoidAreaChange', this.onAvoidAreaChange);
      this.mainWindow?.on('windowSizeChange', this.onWindowSizeChange);
    } catch (err) {
      UtilLog.error(LOG_TAG, 'get window properties failed. error: ' + JSON.stringify(err));
    }
  }

  public stop(): void {
    try {
      this.mainWindow?.off('avoidAreaChange', this.onAvoidAreaChange);
      this.mainWindow?.off('windowSizeChange', this.onWindowSizeChange);
    } catch (err) {
      UtilLog.error(LOG_TAG, 'stop failed. error: ' + JSON.stringify(err));
    }
  }

  private loadAvoidAreaInfo(types: window.AvoidAreaType[]): void {
    try {
      for (const type of types) {
        this.onAvoidAreaChange({
          type: type,
          area: this.mainWindow?.getWindowAvoidArea(type),
        });
      }
    } catch (err) {
      UtilLog.error(LOG_TAG, 'get window avoid areas failed. error: ' + JSON.stringify(err));
    }
  }

  constructor(ctx: common.UIAbilityContext) {
    try {
      this.mainWindow = ctx.windowStage.getMainWindowSync();
    } catch (err) {
      UtilLog.error(LOG_TAG, 'get main window failed. error: ' + JSON.stringify(err));
    }
  }
}
