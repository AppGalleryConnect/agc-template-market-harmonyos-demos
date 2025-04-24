import {
  abilityAccessCtrl,
  AbilityConstant,
  common,
  PermissionRequestResult,
  Permissions,
  UIAbility,
  Want
} from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { BusinessError, emitter } from '@kit.BasicServicesKit';
import {
  BrightnessUtil,
  CloudFunction,
  CloudFunctionHomeResult,
  EmitterEventId,
  GlobalContext,
  HomeServiceList
} from 'common';
import { cloudFunction } from '@kit.CloudFoundationKit';
import { calendarManager } from '@kit.CalendarKit';
import { pushService } from '@kit.PushKit';


let calendarMgr: calendarManager.CalendarManager | null = null;

let mContext: common.UIAbilityContext | null = null;

export default class EntryAbility extends UIAbility {
  private widgetMessage: string = '';
  private currentWindowStage: window.WindowStage | null = null;
  /*
 * 使用预加载，极大的减小应用或元服务首屏的启动时间
 * link：https://developer.huawei.com/consumer/cn/doc/AppGallery-connect-Guides/agc-preload-implement-0000001834682914
 * */
  /*
    *再开元服务需要重新调用获取服务接口
    * 使用emitter
    * */
  private event: emitter.InnerEvent = {
    eventId: EmitterEventId.GET_SERVICE,
    priority: emitter.EventPriority.HIGH
  };

  functionPreload() {
    CloudFunction.getHomeServiceList(cloudFunction.LoadMode.PRELOAD).then((resp: cloudFunction.FunctionResult) => {
      if ((resp as CloudFunctionHomeResult).result.ret.code === 0) {
        let result: HomeServiceList = (resp as CloudFunctionHomeResult).result.result as HomeServiceList
        emitter.emit(this.event, {
          data: {
            homeServiceList: result
          }
        });
        AppStorage.setOrCreate('homeServiceList', result)
      }
    }).catch((err: Error) => {
      hilog.error(0x0000, 'testTag', 'fail to get preload cache: %{public}s', err.message);
      this.functionNormal()
    })
  }

  functionNormal() {
    CloudFunction.getHomeServiceList(cloudFunction.LoadMode.NORMAL).then((resp: cloudFunction.FunctionResult) => {
      if ((resp as CloudFunctionHomeResult).result.ret.code === 0) {
        let result: HomeServiceList = (resp as CloudFunctionHomeResult).result.result as HomeServiceList
        emitter.emit(this.event, {
          data: {
            homeServiceList: result
          }
        });
        AppStorage.setOrCreate('homeServiceList', result)
      }
    }).catch((err: Error) => {
      hilog.error(0x0000, 'testTag', 'fail to get preload cache: %{public}s', err.message);
      this.functionNormal()
    })

  };

  async onCreate(want: Want, launchParam: AbilityConstant.LaunchParam) {
    // 获取卡片router事件中传递的targetPage参数
    if (want?.parameters?.params) {
      // want.parameters.params 对应 postCardAction() 中 params 内容
      let params: Record<string, Object> = JSON.parse(want.parameters.params as string);
      this.widgetMessage = params.message as string;
    }
    /*
     * 获取pushToken用户mock本地化推送
     * 正常是上报Push Token并上报到您的服务端
     * */
    try {
      const pushToken: string = await pushService.getToken();
      AppStorage.setOrCreate('pushToken', pushToken)
      hilog.info(0x0000, 'testTag', 'Succeeded in getting push token');
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      hilog.error(0x0000, 'testTag', 'Failed to get push token: %{public}d %{public}s', e.code, e.message);
    }
    this.functionPreload(); // 在应用启动时调用函数获取应用数据
    GlobalContext.getInstance().setContext(getContext(this));
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

  // 如果UIAbility已在后台运行，在收到Router事件后会触发onNewWant生命周期回调
  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    if (want?.parameters?.params) {
      // want.parameters.params 对应 postCardAction() 中 params 内容
      let params: Record<string, Object> = JSON.parse(want.parameters.params as string);
      this.widgetMessage = params.message as string;
      AppStorage.setOrCreate('widget_router', this.widgetMessage)
    }
    if (this.currentWindowStage !== null) {
      this.onWindowStageCreate(this.currentWindowStage);
    }
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');
    AppStorage.setOrCreate('widget_router', this.widgetMessage)
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      this.getSafeArea(windowStage)
      mContext = this.context;
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
}
