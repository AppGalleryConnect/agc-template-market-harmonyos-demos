import { AtomicServiceWebController } from '@kit.ArkUI';
import { Logger } from 'module_ui_base';
import { LOG_TAG } from '../constants/CommonConstants';
import { BaseViewModel } from '../models/BaseViewModel';
import { SettingPageEnum } from '../types/SettingType';

@ObservedV2
export class SettingH5VM extends BaseViewModel {
  // H5内容或者地址
  @Trace content: string = '';
  webViewController: AtomicServiceWebController = new AtomicServiceWebController();

  getParams() {
    const params = this.configInfo.pathStack.getParamByName(
      SettingPageEnum.SETTING_AGREEMENT,
    ) as string[];
    if (params.length && params[params.length - 1]) {
      this.content = params[params.length - 1];
    }
  }

  onControllerAttached() {
    try {
      this.webViewController.loadUrl(this.content);
    } catch (error) {
      Logger.error(LOG_TAG, 'load url failed. error: ' + JSON.stringify(error));
    }
  }

  isUrl(content: string) {
    return content.startsWith('http://') || content.startsWith('https://');
  }
}

