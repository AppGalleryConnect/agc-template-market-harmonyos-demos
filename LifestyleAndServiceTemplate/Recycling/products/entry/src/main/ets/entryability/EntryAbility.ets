import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { AppStorageV2, window } from '@kit.ArkUI';
import { AiBarHeight, AppStorageKeys, GlobalContext, StatusBarHeight, WindowUtils } from 'common';

const TAG = 'EntryAbility';

export default class EntryAbility extends UIAbility {
  aiBarHeight: AiBarHeight = AppStorageV2.connect(AiBarHeight, AppStorageKeys.AI_BAR_HEIGHT, () => new AiBarHeight())!;
  statusBarHeight: StatusBarHeight =
    AppStorageV2.connect(StatusBarHeight, AppStorageKeys.STATUS_BAR_HEIGHT, () => new StatusBarHeight())!;

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT);
    GlobalContext.initUIAbilityContext(this.context);
  }

  onDestroy(): void {

  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability

    WindowUtils.initWindowStage(windowStage);
    WindowUtils.init(windowStage.getMainWindowSync());
    WindowUtils.getMainWindow().on('avoidAreaChange', () => {
      let type = window.AvoidAreaType.TYPE_SYSTEM;
      let avoidArea = WindowUtils.getMainWindow().getWindowAvoidArea(type);
      this.statusBarHeight.value = px2vp(avoidArea.topRect.height);
      type = window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR;
      avoidArea = WindowUtils.getMainWindow().getWindowAvoidArea(type);
      this.aiBarHeight.value = px2vp(avoidArea.bottomRect.height);
    });

    // 设置沉浸式
    windowStage.getMainWindowSync().setWindowLayoutFullScreen(true);
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        return;
      }
      GlobalContext.initUIContext(windowStage.getMainWindowSync().getUIContext());
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
  }

  onForeground(): void {
    // Ability has brought to foreground
  }

  onBackground(): void {
    // Ability has back to background
  }
}