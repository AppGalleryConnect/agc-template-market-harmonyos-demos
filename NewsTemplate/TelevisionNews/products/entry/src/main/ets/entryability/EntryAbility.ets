import { UtilLog } from '@hw-agconnect/util-log';
import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { AppStorageV2, window } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { deviceInfo } from '@kit.BasicServicesKit';
import { LoneTakeAnimationsTransition } from 'module_transition';
import { NetworkUtil, WindowModel } from 'lib_common';
import { PreloadUtils } from '../utils/PreloadUtils';
import { WantUtils } from '../utils/WantUtils';

const TAG = '[EntryAbility]'

export default class EntryAbility extends UIAbility {
  async onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): Promise<void> {
    hilog.info(0x0000, TAG, '%{public}s', 'Ability onCreate');
    UtilLog.setGlobalConfig({
      tag: 'televisionNews',
      domain: 0xff00,
      open: true,
      showStack: false,
    })
    // 在应用启动时调用函数获取应用数据
    PreloadUtils.functionPreload();
    WantUtils.handleFormCardCall(want);
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    WantUtils.handleFormCardCall(want);
  }

  onDestroy(): void {
    hilog.info(0x0000, TAG, '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    this.handleWindowStageCreateOrRestore(windowStage);
  }

  handleWindowStageCreateOrRestore(windowStage: window.WindowStage) {
    let windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!;
    windowStage.loadContent('pages/Index', async (err) => {
      if (err.code) {
        hilog.error(0x0000, TAG, 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, TAG, 'Succeeded in loading the content.');
      let windowClass: window.Window = windowStage.getMainWindowSync(); // 获取应用主窗口
      // 设置窗口全屏
      await windowClass.setWindowLayoutFullScreen(true);
      windowModel.fullScreen = true
      let type = window.AvoidAreaType.TYPE_SYSTEM; // 以状态栏避让为例
      let avoidArea = windowClass.getWindowAvoidArea(type);
      windowModel.windowTopHeight = windowClass.getUIContext().px2vp(avoidArea.topRect.height);
      type = window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR; // 以导航条避让为例
      avoidArea = windowClass.getWindowAvoidArea(type);
      LoneTakeAnimationsTransition.init(windowStage);
      windowModel.windowBottomHeight = windowClass.getUIContext().px2vp(avoidArea.bottomRect.height);
      // 判断是否是模拟器
      let productMode = deviceInfo.productModel;
      if (productMode !== 'emulator') {
        NetworkUtil.getInstance().init();
      }
    });
    windowModel.windowStage = windowStage
  }
};
