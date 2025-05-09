import { AbilityConstant, bundleManager, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { cloudFunction, cloudResPrefetch } from '@kit.CloudFoundationKit';
import { Constants, FormCardJump, PreloadResponse } from 'common';
import { pushService } from '@kit.PushKit';
import { BusinessError } from '@kit.BasicServicesKit';

export default class EntryAbility extends UIAbility {
  async onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): Promise<void> {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
    // 在应用启动时调用函数获取应用数据
    this.functionPreload();
    // 获取应用id
    let bundleInfo = await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_HAP_MODULE |
    bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_ABILITY |
    bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_REQUESTED_PERMISSION);
    let packageName = bundleInfo.name;
    AppStorage.setOrCreate('packageName', packageName);
    console.info(`packageName: ${JSON.stringify(packageName)}.`);
    // 元服务包名最后一段为appid
    let appId = packageName.substring(packageName.lastIndexOf('.') + 1);
    AppStorage.setOrCreate('appId', appId);
    console.info(`appId: ${JSON.stringify(appId)}.`);
    this.resolvePagePath(want);
    // 获取Push Token
    try {
      const pushToken: string = await pushService.getToken();
      hilog.info(0x0000, 'testTag', 'Succeeded in getting push token');
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      hilog.error(0x0000, 'testTag', 'Failed to get push token: %{public}d %{public}s', e.code, e.message);
    }
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

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
      let windowTopHeight = px2vp(avoidArea.topRect.height);
      AppStorage.setOrCreate('windowTopHeight', windowTopHeight);
      type = window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR; // 以导航条避让为例
      avoidArea = windowClass.getWindowAvoidArea(type);
      let windowBottomHeight = px2vp(avoidArea.bottomRect.height);
      AppStorage.setOrCreate('windowBottomHeight', windowBottomHeight);
      PersistentStorage.persistProp('userIconPath', 'userImage.jpg');
    });
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    this.resolvePagePath(want);
  }

  resolvePagePath(want: Want) {
    // 从want中获取传入的链接信息
    let uri = want?.uri;
    let parameters = want?.parameters;
    console.info(`uri is: ${uri}`);
    if (uri) {
      //解析通过router跳转的页面
      // 商户id
      let storeId = want.parameters?.sid as string;
      console.info(`storeId is: ${storeId}`);
      AppStorage.setOrCreate('storeId', storeId);
      // 桌号
      let tableId = want.parameters?.tid as string;
      console.info(`tableId is: ${tableId}`);
      AppStorage.setOrCreate('tableId', tableId);
      // 扫码进入清空购物车
      AppStorage.setOrCreate('qrCodeFlag', true);
    } else if (parameters?.url) {
      let formCardJump: FormCardJump = JSON.parse(parameters?.params.toString() || '');
      formCardJump.id = new Date().getTime()
      AppStorage.setOrCreate('formCardJump', formCardJump);
    }
  }

  functionPreload() {
    cloudResPrefetch.getPrefetchResult(cloudResPrefetch.PrefetchMode.INSTALL_PREFETCH)
      .then((data: cloudResPrefetch.PrefetchResult) => {
        hilog.info(0x0000, 'testTag', `Succeeded in getting install prefetch data, result: ${JSON.stringify(data.result)}`);
        this.initPreload(data.result as PreloadResponse); // data.result即是缓存的应用数据
      }).catch((err: BusinessError) => {
      hilog.error(0x0000, 'testTag', `Failed to get install prefetch data, code: ${err.code}, message: ${err.message}`);
      // 使用原有方式获取应用数据
      this.functionNormal();
    })
  }

  functionNormal() {
    hilog.info(0x0000, 'testTag', 'promise start');
    let promise = cloudFunction.call({
      name: 'preload',
      timeout: Constants.REQUEST_TIME_OUT,
      loadMode: cloudFunction.LoadMode.NORMAL, // 默认为NORMAL, 接口会调用云函数从云服务器获取应用数据
    });
    promise.then((data: cloudFunction.FunctionResult) => {
      hilog.info(0x0000, 'testTag', 'call function successfully');
      this.initPreload(data.result as PreloadResponse); // data.result即是缓存的应用数据
    }).catch((err: Error) => {
      hilog.info(0x0000, 'testTag', 'fail to call function: %{public}s', err.message);
    });
  }

  initPreload(result: PreloadResponse) {
    if (result.hmSystem) {
      AppStorage.setOrCreate('storeId', result.hmSystem.storeId);
      AppStorage.setOrCreate('storeType', result.hmSystem.storeType);
    }
    if (result.tableTitleArr) {
      AppStorage.setOrCreate('tableList', result.tableTitleArr);
    }
  }
};
