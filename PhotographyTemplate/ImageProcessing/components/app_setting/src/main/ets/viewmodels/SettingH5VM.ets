import { webview } from '@kit.ArkWeb';
import { UtilLog } from '@hw-agconnect/util-log';
import { SettingPageEnum } from '../types/SettingType';
import { BaseViewModel } from '../models/BaseViewModel';

@ObservedV2
export class SettingH5VM extends BaseViewModel {
  // H5内容或者地址
  @Trace content: string = '';
  @Trace webViewController: webview.WebviewController = new webview.WebviewController();

  getParams() {
    const params = this.configInfo.pathStack.getParamByName(SettingPageEnum.SETTING_AGREEMENT) as string[];
    if (params.length && params[params.length - 1]) {
      this.content = params[params.length - 1];
    }
  }

  onControllerAttached() {
    try {
      if (this.isUrl(this.content)) {
        this.webViewController.loadUrl(this.content);
      } else {
        this.webViewController.loadData(
          this.content,
          'text/html',
          'UTF-8',
          '',
          '',
        );
      }
    } catch (error) {
      UtilLog.error(0x000F, '[SettingH5VM]',
        `Failed to load data, errCode: ${error.code}, errMessage: ${error.message}`);
    }
  }

  @Computed
  get getDefaultFontSize() {
    if (this.fontModel.followSystem) {
      return 16;
    }
    return 16 * this.fontModel.fontSizeRatio;
  }

  @Computed
  get getTextZoomRatio() {
    if (this.fontModel.followSystem) {
      return 100 * this.fontModel.sysFontSizeScale;
    }
    return 100;
  }

  isUrl(content: string) {
    return content.startsWith('http://') || content.startsWith('https://');
  }
}