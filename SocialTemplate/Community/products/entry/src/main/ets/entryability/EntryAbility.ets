import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { AppStorageV2, window } from '@kit.ArkUI';
import { ChatBreakpoint } from 'chat_window';
import {
  AiBarHeight,
  AppStorageKeys,
  GlobalContext,
  StatusBarHeight,
  TCLogger,
  TempBarHeight,
  WindowUtils
} from 'common';

const TAG = 'EntryAbility';

export default class EntryAbility extends UIAbility {
  aiBarHeight: AiBarHeight = AppStorageV2.connect(AiBarHeight, AppStorageKeys.AI_BAR_HEIGHT, () => new AiBarHeight())!;
  statusBarHeight: StatusBarHeight =
    AppStorageV2.connect(StatusBarHeight, AppStorageKeys.STATUS_BAR_HEIGHT, () => new StatusBarHeight())!;
  tempBarHeight: TempBarHeight = AppStorageV2.connect(TempBarHeight, () => new TempBarHeight())!;
  chatBreakpoint = AppStorageV2.connect(ChatBreakpoint, () => new ChatBreakpoint())!;

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    TCLogger.info(TAG, 'Ability onCreate');
    this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT);
    GlobalContext.initUIAbilityContext(this.context);
  }

  onDestroy(): void {
    TCLogger.info(TAG, 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    TCLogger.info(TAG, 'Ability onWindowStageCreate');

    WindowUtils.initWindowStage(windowStage);
    WindowUtils.init(windowStage.getMainWindowSync());
    WindowUtils.getMainWindow().on('avoidAreaChange', () => {
      let type = window.AvoidAreaType.TYPE_SYSTEM;
      let avoidArea = WindowUtils.getMainWindow().getWindowAvoidArea(type);
      this.statusBarHeight.value = px2vp(avoidArea.topRect.height);
      this.chatBreakpoint.topValue = px2vp(avoidArea.topRect.height);
      if (this.tempBarHeight.topTempValue === this.tempBarHeight.topValue) {
        this.tempBarHeight.topTempValue = px2vp(avoidArea.topRect.height);
        this.tempBarHeight.topValue = px2vp(avoidArea.topRect.height);
      } else {
        this.tempBarHeight.topTempValue = px2vp(avoidArea.topRect.height);
      }
      type = window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR;
      avoidArea = WindowUtils.getMainWindow().getWindowAvoidArea(type);
      this.aiBarHeight.value = px2vp(avoidArea.bottomRect.height);
      this.chatBreakpoint.bottomValue = px2vp(avoidArea.bottomRect.height);
      if (this.tempBarHeight.bottomTempValue === this.tempBarHeight.bottomValue) {
        this.tempBarHeight.bottomTempValue = px2vp(avoidArea.bottomRect.height);
        this.tempBarHeight.bottomValue = px2vp(avoidArea.bottomRect.height);
      } else {
        this.tempBarHeight.bottomTempValue = px2vp(avoidArea.bottomRect.height);
      }
    });

    // 设置沉浸式
    windowStage.getMainWindowSync().setWindowLayoutFullScreen(true);
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        TCLogger.info(TAG, 'Failed to load the content. Cause: ' + JSON.stringify(err));
        return;
      }
      GlobalContext.initUIContext(windowStage.getMainWindowSync().getUIContext());
      TCLogger.info(TAG, 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    TCLogger.info(TAG, 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    TCLogger.info(TAG, 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    TCLogger.info(TAG, 'Ability onBackground');
  }
}