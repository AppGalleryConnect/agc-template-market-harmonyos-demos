import { AbilityConstant, common, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { BrightnessUtil, getTokenSyn, requestOAIDTrackingConsentPermissions } from 'common';

export default class EntryAbility extends UIAbility {
  async onCreate(want: Want, launchParam: AbilityConstant.LaunchParam) {
    let pushToken:string = await getTokenSyn()
    AppStorage.setOrCreate('pushToken', pushToken)
    console.log('pushToken', pushToken)
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  getSafeArea(windowStage: window.WindowStage) {
    let isLayoutFullScreen = true;
    let windowClass: window.Window = windowStage.getMainWindowSync(); // 获取应用主窗口
    let topAvoidArea = windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM)
    let bottomAvoidArea = windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR)
    let bottomRectHeight = px2vp(bottomAvoidArea.bottomRect.height)
    let topRectHeight = px2vp(topAvoidArea.topRect.height)
    AppStorage.setOrCreate('bottomRectHeight', bottomRectHeight)
    AppStorage.setOrCreate('topRectHeight', topRectHeight)
    windowClass.setWindowLayoutFullScreen(isLayoutFullScreen)
      .then(() => {
        console.info('Succeeded in setting the window layout to full-screen mode.');
      })
      .catch((err: BusinessError) => {
        console.error('Failed to set the window layout to full-screen mode. Cause:' + JSON.stringify(err));
      });
    BrightnessUtil.initWindow(windowClass);
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');
    this.getSafeArea(windowStage)
    windowStage.loadContent('pages/SplashPage', (err) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content.');
    });

    windowStage.getMainWindow((err, data) => {
      if (err.code) {
        console.error('Failed to obtain the main window. Cause: ' + JSON.stringify(err));
        return;
      }
    })
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
}
