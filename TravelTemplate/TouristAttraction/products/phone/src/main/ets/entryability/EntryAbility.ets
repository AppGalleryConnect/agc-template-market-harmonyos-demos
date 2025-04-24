import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { AppStorageV2, window } from '@kit.ArkUI';
import { UIBase } from '@hw-agconnect/ui-base';
import { PlayInfo } from 'audio';
import { PageUtil } from 'common';

export default class EntryAbility extends UIAbility {
  private pageIndex: number = 0;
  private currentWindowStage: window.WindowStage | null = null;

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    AppStorage.setOrCreate('context', this.context);
    AppStorageV2.connect(PlayInfo, 'playInfo', () => new PlayInfo())!;
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
    if (want?.parameters?.params) {
      // want.parameters.params 对应 postCardAction() 中 params 内容
      let params: Record<string, Object> = JSON.parse(want.parameters.params as string);
      this.pageIndex = params.index as number;
      PageUtil.setPageInfo(this.pageIndex);
    }
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    if (want?.parameters?.params) {
      // want.parameters.params 对应 postCardAction() 中 params 内容
      let params: Record<string, Object> = JSON.parse(want.parameters.params as string);
      this.pageIndex = params.index as number;
      PageUtil.setPageInfo(this.pageIndex);
    }
    if (this.currentWindowStage !== null) {
      this.onWindowStageCreate(this.currentWindowStage);
    }
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  async onWindowStageCreate(windowStage: window.WindowStage): Promise<void> {
    // Main window is created, set main page for this ability
    UIBase.init(windowStage);
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
