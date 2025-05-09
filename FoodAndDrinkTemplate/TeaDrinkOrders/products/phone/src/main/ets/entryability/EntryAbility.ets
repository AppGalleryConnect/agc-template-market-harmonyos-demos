import { AbilityConstant, bundleManager, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { AppStorageV2, window } from '@kit.ArkUI';
import { AppInfoModel, FormCard, FormCardJump, WindowModel } from 'common';

export default class EntryAbility extends UIAbility {
  async onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): Promise<void> {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
    // 获取应用id
    let bundleInfo = await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_HAP_MODULE |
    bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_ABILITY |
    bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_REQUESTED_PERMISSION);
    let appInfo: AppInfoModel = AppStorageV2.connect(AppInfoModel, () => new AppInfoModel())!;
    appInfo.packageName = bundleInfo.name;
    console.info(`packageName: ${JSON.stringify(bundleInfo.name)}.`);
    this.resolvePagePath(want);
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');
    let windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!;
    windowStage.loadContent('pages/Index', async (err) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content.');
      let windowClass: window.Window = windowStage.getMainWindowSync(); // 获取应用主窗口
      // 设置窗口全屏
      await windowClass.setWindowLayoutFullScreen(true);
      let type = window.AvoidAreaType.TYPE_SYSTEM; // 以状态栏避让为例
      let avoidArea = windowClass.getWindowAvoidArea(type);
      windowModel.windowTopHeight = px2vp(avoidArea.topRect.height);
      type = window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR; // 以导航条避让为例
      avoidArea = windowClass.getWindowAvoidArea(type);
      windowModel.windowBottomHeight = px2vp(avoidArea.bottomRect.height);
    });
    windowModel.windowStage = windowStage
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    this.resolvePagePath(want);
  }

  resolvePagePath(want: Want) {
    // 从want中获取传入的链接信息
    let parameters = want?.parameters;
    let formCardJump: FormCardJump = JSON.parse(parameters?.params?.toString() || '{}');
    let formCard: FormCard = AppStorageV2.connect(FormCard, () => new FormCard())!
    if (formCardJump?.params?.orderId) {
      formCard.id = new Date().getTime()
      formCard.orderId = formCardJump.params.orderId
      formCard.url = parameters?.url as string
    }
  }
};
