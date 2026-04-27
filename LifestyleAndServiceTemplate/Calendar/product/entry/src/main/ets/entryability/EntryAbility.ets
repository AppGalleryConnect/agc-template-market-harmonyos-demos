import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { webview } from '@kit.ArkWeb';
import { BusinessError, emitter } from '@kit.BasicServicesKit';
import { createNWeb, IJavaScriptConfig, IResourceConfig, WebProperties } from '@hw-agconnect/fast-web';
import { UtilLog } from '@hw-agconnect/util-log';
import { EMITTER_TYPE } from 'common';
import { PRIVACY_WEB } from '../pages/PrivacyPage';

const TAG = '[EntryAbility]'

export default class EntryAbility extends UIAbility {
  private widgetMessage: string = '';

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    // 获取卡片router事件中传递的targetPage参数
    if (want?.parameters?.params) {
      let params: Record<string, string> = {}
      // want.parameters.params 对应 postCardAction() 中 params 内容
      try {
        params = JSON.parse(want.parameters.params as string);
      } catch (e) {
        UtilLog.error(TAG, 'want parameters params error')
      }
      this.widgetMessage = params.message as string;
    }
    UtilLog.info(TAG, '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    UtilLog.info(TAG, '%{public}s', 'Ability onDestroy');
  }

  getSafeArea(windowStage: window.WindowStage) {
    let isLayoutFullScreen = true;
    try {
      let windowClass: window.Window = windowStage.getMainWindowSync(); // 获取应用主窗口
      const uiContext = windowClass.getUIContext();
      let topAvoidArea = windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM)
      let bottomAvoidArea = windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR)
      let bottomRectHeight = uiContext.px2vp(bottomAvoidArea.bottomRect.height)
      let topRectHeight = uiContext.px2vp(topAvoidArea.topRect.height)
      AppStorage.setOrCreate('bottomRectHeight', bottomRectHeight)
      AppStorage.setOrCreate('topRectHeight', topRectHeight)
      windowClass.setWindowLayoutFullScreen(isLayoutFullScreen)
        .then(() => {
          UtilLog.info(TAG, 'Succeeded in setting the window layout to full-screen mode.');
        })
        .catch((err: BusinessError) => {
          UtilLog.error(TAG, 'Failed to set the window layout to full-screen mode. Cause:' + JSON.stringify(err));
        });
    } catch (e) {
      UtilLog.error(TAG, 'Failed to get getMainWindowSync. Cause:' + JSON.stringify(e));
    }
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    UtilLog.info(TAG, '%{public}s', 'Ability onWindowStageCreate');
    AppStorage.setOrCreate('widget_router', this.widgetMessage)
    windowStage.loadContent('pages/SplashPage', (err) => {
      if (err.code) {
        UtilLog.error(TAG, 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      // 包括原生Web组件的WebOptions、属性和事件
      const webProperties = new WebProperties();
      webProperties.defaultFontSize = 30;
      // 预编译的JavaScript资源
      const javaScriptConfigs: IJavaScriptConfig[] = [
        {
          url: '',
          localPath: '',
        },
      ]
      // 免拦截注入的离线资源如图片、样式表和脚本资源
      const resourceConfigs: IResourceConfig[] = [
        {
          localPath: '',
          urlList: [
            '',
          ],
          type: webview.OfflineResourceType.IMAGE,
        },
      ];
      // 预先创建一个空的ArkWeb动态组件（需传入UIContext），拉起渲染进程
      createNWeb(PRIVACY_WEB, windowStage.getMainWindowSync().getUIContext(), webProperties, javaScriptConfigs,
        resourceConfigs);
      this.getSafeArea(windowStage)
      UtilLog.info(TAG, 'Succeeded in loading the content.');
    });
  }

  // 如果UIAbility已在后台运行，在收到Router事件后会触发onNewWant生命周期回调
  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    if (want?.parameters?.params) {
      let params: Record<string, string> = {}
      // want.parameters.params 对应 postCardAction() 中 params 内容
      try {
        params = JSON.parse(want.parameters.params as string);
      } catch (e) {
        UtilLog.error(TAG, 'want parameters params error')
      }
      this.widgetMessage = params.message as string;
      AppStorage.setOrCreate('widget_router', this.widgetMessage)
      let event: emitter.InnerEvent = {
        eventId: EMITTER_TYPE.WIDGET_ENTER,
      };
      try {
        emitter.emit(event);
      } catch (e) {
        UtilLog.error('emit error' + JSON.stringify(e))
      }
    }
  }


  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    UtilLog.info(TAG, '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    UtilLog.info(TAG, '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    UtilLog.info(TAG, '%{public}s', 'Ability onBackground');
  }
}
