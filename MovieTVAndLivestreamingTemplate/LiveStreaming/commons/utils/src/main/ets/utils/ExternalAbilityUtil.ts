
import call from '@ohos.telephony.call';
import { BusinessError } from '@ohos.base';
import { common, wantConstant } from '@kit.AbilityKit';
import { Logger } from "../logger/AppLogger";

/**
 * [跳转其他ability工具类]
 */
const TAG = "ExternalAbilityUtil"
export class ExternalAbilityUtil {

  /**
   * 打开应用的设置详情页面
   */
  public static startPermissionManager(context: common.UIAbilityContext): Promise<void> {
    let wantInfo = {
      bundleName: "com.huawei.hmos.settings",
      abilityName: "com.huawei.hmos.settings.MainAbility",
      uri: 'application_info_entry',
      parameters: {
        pushParams: "com.huawei.hmsapp.alliance"
      }
    }
    return context?.startAbility(wantInfo)
  }

  /**
   * 打开华为文件预览器
   */
  public static startPreview(context: common.UIAbilityContext, uri: string, mimeType: string): Promise<void> {
    let wantInfo = {
      bundleName: "com.huawei.hmos.hipreview",
      abilityName: "MainAbility",
      flags: wantConstant.Flags.FLAG_AUTH_READ_URI_PERMISSION,
      action: "ohos.want.action.viewData",
      uri: uri,
      type: mimeType
    }
    return context?.startAbility(wantInfo)
  }

  /**
   * 打开wifi管理页面
   */
  public static startWifiManager(context: common.UIAbilityContext): Promise<void> {
    let wantInfo = {
      bundleName: "com.huawei.hmos.settings",
      abilityName: "com.huawei.hmos.settings.MainAbility",
      uri: 'wifi_entry'
    }
    return context?.startAbility(wantInfo);
  }

  /**
   * 打开华为浏览器
   */
  public static startBrowser(context: common.UIAbilityContext, url: string): Promise<void> {
    let want = {
      "bundleName": "com.huawei.hmos.browser",
      "action": "ohos.want.action.viewData",
      "abilityName": 'MainAbility',
      "entities": ["entity.system.browsable"],
      "uri": url
    }
    return context?.startAbility(want);
  }

}
