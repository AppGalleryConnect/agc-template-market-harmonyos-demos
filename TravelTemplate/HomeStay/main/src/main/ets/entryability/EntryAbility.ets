import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  async onWindowStageCreate(windowStage: window.WindowStage): Promise<void> {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');
    let windowClass: window.Window = windowStage.getMainWindowSync(); // 获取应用主窗口
    await windowClass.setWindowLayoutFullScreen(true);
    let type = window.AvoidAreaType.TYPE_SYSTEM; // 以状态栏避让为例
    let avoidArea = windowClass.getWindowAvoidArea(type);
    let windowTopHeight = px2vp(avoidArea.topRect.height);
    AppStorage.setOrCreate('windowTopHeight', windowTopHeight);
    type = window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR; // 以导航条避让为例
    avoidArea = windowClass.getWindowAvoidArea(type);
    let windowBottomHeight = px2vp(avoidArea.bottomRect.height);
    AppStorage.setOrCreate('windowBottomHeight', windowBottomHeight);

    windowStage.loadContent('pages/Main', (err) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }
};
