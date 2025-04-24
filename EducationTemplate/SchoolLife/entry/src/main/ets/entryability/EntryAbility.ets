import { UIBase } from '@hw-agconnect/ui-base';
import { UIAbility, Want } from '@kit.AbilityKit';
import { AppStorageV2, window } from '@kit.ArkUI';
import { FormCardRouteInfo, Logger, WindowConfig } from 'commonlib';

const TAG: string = '[EntryAbility]';

export default class EntryAbility extends UIAbility {
  public onCreate(want: Want): void {
    setTimeout(() => {
      this._resolvePagePath(want);
    }, 300);
  }

  public onWindowStageCreate(windowStage: window.WindowStage): void {
    Logger.info(TAG, '%{public}s', 'Ability onWindowStageCreate');
    UIBase.init(windowStage);

    windowStage.loadContent('pages/MainEntry', async (err) => {
      if (err.code) {
        Logger.error(TAG, 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      let windowClass: window.Window = windowStage.getMainWindowSync(); // 获取应用主窗口
      // 设置窗口全屏
      await windowClass.setWindowLayoutFullScreen(true);
      let type = window.AvoidAreaType.TYPE_SYSTEM; // 以状态栏避让为例
      let avoidArea = windowClass.getWindowAvoidArea(type);


      const windowConfig = AppStorageV2.connect(WindowConfig, 'windowConfig', () => new WindowConfig())!;
      windowConfig.windowTopHeight = px2vp(avoidArea.topRect.height);
      type = window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR; // 以导航条避让为例
      avoidArea = windowClass.getWindowAvoidArea(type);
      windowConfig.windowBottomHeight = px2vp(avoidArea.bottomRect.height);
      Logger.info(TAG, 'Succeeded in loading the content.');
    });
  }

  public onNewWant(want: Want): void {
    this._resolvePagePath(want);
  }

  private _resolvePagePath(want: Want) {
    // 从want中获取传入的路由信息
    let parameters = want?.parameters;
    if (parameters?.path) {
      console.log(`resolvePagePath path = ${parameters?.path}`);
      const formCardRouteInfo: FormCardRouteInfo = AppStorageV2.connect(FormCardRouteInfo, 'formCardRouteInfo', () => new FormCardRouteInfo())!;
      formCardRouteInfo.path = parameters?.path as string;
    }
  }
}
