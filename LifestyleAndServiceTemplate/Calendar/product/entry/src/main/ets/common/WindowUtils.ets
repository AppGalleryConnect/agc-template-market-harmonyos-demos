import { ConfigurationConstant } from '@kit.AbilityKit';
import { createNWeb, IJavaScriptConfig, IResourceConfig, WebProperties } from '@hw-agconnect/fast-web';
import { UtilLog } from '@hw-agconnect/util-log';
import { window } from '@kit.ArkUI';
import { webview } from '@kit.ArkWeb';
import { PRIVACY_WEB } from '../pages/PrivacyPage';

const TAG = '[WindowUtils]';

/**
 * 窗口工具类
 */
export class WindowUtils {
  /**
   * 窗口设置
   * @param windowStage
   */
  public static async setWinConfig(windowStage: window.WindowStage) {
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

  public static initCreateNWeb(windowStage: window.WindowStage) {
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
  }

  // 屏蔽暗黑模式
  public static setColorModeLight(context: Context) {
    context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT);
  }
}