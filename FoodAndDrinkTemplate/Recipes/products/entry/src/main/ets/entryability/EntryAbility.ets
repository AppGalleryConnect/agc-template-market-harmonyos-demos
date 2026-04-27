import { AbilityConstant, Configuration, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { AppStorageV2, window } from '@kit.ArkUI';
import { BusinessError, emitter } from '@kit.BasicServicesKit';
import { FormCardJump } from '../types/Types';
import { WXLoginService } from 'aggregated_login';
import { UtilLog } from '@hw-agconnect/util-log';
import { LoneTakeAnimationsTransition } from 'module_transition';
import { url } from '@kit.ArkTS';
import { notificationManager } from '@kit.NotificationKit';
import { WindowModels } from '../models/WindowModels';

const TAG = '[EntryAbility]';

export default class EntryAbility extends UIAbility {
  // 实例化登录服务
  private loginServiceImpl: WXLoginService =
    WXLoginService.create()
    // todo 填写微信开放平台配置的应用AppID
      .initWX('wxc92d9d6570127a32')

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    UtilLog.setGlobalConfig({
      tag: 'ComprehensiveMall',
      domain: 0xff00,
      open: true,
      showStack: false,
    })
    UtilLog.info(TAG, 'Ability onCreate');
    this.loginServiceImpl.handleWant(want);
    this.handleAppLink(want);
    this.resolvePagePath(want);
  }

  onDestroy(): void {
    UtilLog.info(TAG, 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    UtilLog.info(TAG, 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        UtilLog.error(TAG, JSON.stringify(err));
        return;
      }
      this.setWinConfig(windowStage);
      LoneTakeAnimationsTransition.init(windowStage);
      UtilLog.info(TAG, 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    UtilLog.info(TAG, 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    UtilLog.info(TAG, 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    UtilLog.info(TAG, 'Ability onBackground');
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    this.loginServiceImpl.handleWant(want);
    this.handleAppLink(want)
    this.resolvePagePath(want);
    this.handleBadge(want)
  }

  onConfigurationUpdate(newConfig: Configuration): void {
    try {
      emitter.emit('colorModeChange', { data: { colorMode: newConfig.colorMode } })
    } catch (e) {
    }
  }

  resolvePagePath(want: Want) {
    let parameters = want?.parameters;
    if (parameters?.url) {
      let formCardJump: FormCardJump = AppStorageV2.connect(FormCardJump, () => new FormCardJump())!;
      formCardJump.form = JSON.parse(parameters?.params.toString() || '');
      formCardJump.form.id = new Date().getTime()
    }
  }

  handleAppLink(want: Want) {
    let uri = want?.uri
    if (uri) {
      // 从链接中(例：https://www.xxxxxx.com/recipes?action=recipesList)解析query参数，
      // 拿到参数后，开发者可根据自己的业务需求进行后续的处理。
      try {
        let urlObject = url.URL.parseURL(uri);
        let action = urlObject.params.get('action')
        UtilLog.info(TAG, 'app link jump to page: ' + action);
        // 例如，当action为recipesList时，跳转到菜谱列表页。
        if (action === 'recipesList') {
        }
      } catch (error) {
        UtilLog.error(TAG, 'Failed to parse url. error: ' + JSON.stringify(error));
      }
    }
  }

  handleBadge(want: Want) {
    if (want.parameters?.push_wantAgentInfo) {
      notificationManager.getActiveNotificationCount().then((data: number) => {
        const badgeNum = data > 0 ? data - 1 : 0;
        notificationManager.setBadgeNumber(badgeNum).then(() => {
          UtilLog.info(`Succeeded in setting badge number.`);
        }).catch((err: BusinessError) => {
          UtilLog.error(`Failed to set badge number. Code is ${err.code}, message is ${err.message}`);
        });
        UtilLog.info(`Succeeded in getting active notification count, data11 is ${JSON.stringify(data)}`);
      }).catch((err: BusinessError) => {
        UtilLog.error(`Failed to get active notification count. Code is ${err.code}, message is ${err.message}`);
      });
    } else {
      UtilLog.info(`Succeeded in Ability.`);
    }
  }

  async setWinConfig(windowStage: window.WindowStage) {
    AppStorage.setOrCreate('windowStage', windowStage);
    try {
      let windowClass: window.Window = windowStage.getMainWindowSync();
      await windowClass.setWindowLayoutFullScreen(true);
      this.setAvoidArea(windowClass);
      this.onAvoidAreaChange(windowStage);
      this.setWindowSize(windowStage);
    } catch (error) {
      UtilLog.error(TAG, 'setWinConfig fail, error: ' + JSON.stringify(error));
    }
  }

  /**
   * 存储避让区域
   * @param windowClass
   */
  setAvoidArea(windowClass: window.Window) {
    let windowModel: WindowModels = AppStorageV2.connect(WindowModels, () => new WindowModels())!;
    try {
      const uiContext = windowClass.getUIContext();
      let type = window.AvoidAreaType.TYPE_SYSTEM;
      let avoidArea = windowClass.getWindowAvoidArea(type);
      windowModel.windowTopPadding = uiContext.px2vp(avoidArea.topRect.height);
      type = window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR;
      avoidArea = windowClass.getWindowAvoidArea(type);
      windowModel.windowBottomPadding = uiContext.px2vp(avoidArea.bottomRect.height);
    } catch (error) {
      UtilLog.error(TAG, 'setAvoidArea fail, error: ' + JSON.stringify(error));
    }
  }

  /**
   * 存储窗口大小
   * @param windowStage
   */
  setWindowSize(windowStage: window.WindowStage) {
    try {
      let windowModel: WindowModels = AppStorageV2.connect(WindowModels, () => new WindowModels())!;
      let windowClass: window.Window = windowStage.getMainWindowSync();
      windowModel.windowWidth = windowClass.getWindowProperties().windowRect.width;
      windowModel.windowHeight = windowClass.getWindowProperties().windowRect.height;
    } catch (error) {
      UtilLog.error(TAG, 'setWindowSize fail, error: ' + JSON.stringify(error));
    }
  }

  /**
   * 窗口避让区域变化监听
   * @param windowStage
   */
  onAvoidAreaChange(windowStage: window.WindowStage) {
    try {
      let windowClass: window.Window = windowStage.getMainWindowSync();
      windowClass.on('avoidAreaChange', () => {
        this.setAvoidArea(windowClass);
      });
    } catch (e) {
      UtilLog.error(TAG, 'Failed to onAvoidAreaChange. Cause: ' + JSON.stringify(e));
    }
  }

  /**
   * 取消窗口避让区域变化监听
   */
  offAvoidAreaChange() {
    try {
      let windowStage = AppStorage.get('windowStage') as window.WindowStage;
      if (windowStage) {
        windowStage.getMainWindowSync().off('avoidAreaChange');
      }
    } catch (e) {
      UtilLog.error(TAG, 'Failed to offAvoidAreaChange. Cause: ' + JSON.stringify(e));
    }
  }
};
