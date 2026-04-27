import { pasteboard } from '@kit.BasicServicesKit';
import { UtilLog as Logger } from '@hw-agconnect/util-log';
import { ToastDialog as promptAction } from '@hw-agconnect/ui-toast';
import { PopViewUtils } from './PopViewUtils';
import { WindowUtil } from '../common/WindowUtils';
import { fullLoading, FullLoadingParam } from '../uicomponent/UILoading';

const TAG = '[CommonUtils]';
const ONE_SECOND: number = 1000; // 1秒 = 1000毫秒
const ONE_MINUTE: number = 60 * ONE_SECOND; // 1分钟
const ONE_HOUR: number = 60 * ONE_MINUTE; // 1小时
const ONE_DAY: number = 24 * ONE_HOUR; // 1天

/**
 * 通用Utils
 */
export class CommonUtils {
  /**
   * 对象赋值
   * @param target
   * @param source
   * @returns
   */
  static assign(target: Object, ...source: Object[]) {
    for (let s of source) {
      for (let key of Object.keys(s)) {
        const value = Reflect.get(s, key) as Object;
        Reflect.set(target, key, value)
      }
    }
  }

  /**
   * 毫秒转时分秒
   * @param datetime
   */
  static convertMillisToTime(millis: number): string {
    const days = Math.floor(millis / ONE_DAY);
    const hours = Math.floor((millis % ONE_DAY) / ONE_HOUR);
    const minutes = Math.floor((millis % ONE_HOUR) / ONE_MINUTE);
    const seconds = Math.floor((millis % ONE_MINUTE) / ONE_SECOND);

    // 拼接为字符串（示例格式：05:30:45）
    return `${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}:${seconds.toString()
      .padStart(2, '0')}`;
  }

  /**
   * 时间戳转换年月日xxxx-xx-xx
   * @param datetime
   */
  static formatDate(datetime?: number): string {
    if (!datetime) {
      return '';
    }
    const date = new Date(datetime);
    return `${date.getFullYear()}-${CommonUtils.padZero(date.getMonth() + 1)}-${CommonUtils.padZero(date.getDate())}`;
  }

  /**
   * 时间戳转换成年月日时分秒xxxx-xx-xx xx:xx:xx
   * @param datetime
   */
  static formatDateTime(datetime?: number): string {
    if (!datetime) {
      return '';
    }
    const date = new Date(datetime);
    return `${date.getFullYear()}-${CommonUtils.padZero(date.getMonth() +
      1)}-${CommonUtils.padZero(date.getDate())} ${CommonUtils.padZero(date.getHours())}:${CommonUtils.padZero(date.getMinutes())}:${CommonUtils.padZero(date.getSeconds())}`;
  }

  /**
   * 不足的补零
   * @param input
   * @returns
   */
  static padZero(input: number): string {
    return input.toString().padStart(2, '0');
  }

  /**
   * 金钱取整策略
   * @param cash
   */
  static handleCash(cash: number): string {
    try {
      // 整数直接返回
      if (cash % 1 === 0) {
        return cash.toString();
      }

      // 小数保留2位小数
      return cash.toFixed(2);
    } catch (e) {
      Logger.error(TAG, 'handleCash fail, error: ' + JSON.stringify(e));
      return '';
    }
  }

  /**
   * 打开loading
   * @param param
   */
  static showLoading() {
    PopViewUtils.showPopView<FullLoadingParam>(wrapBuilder(fullLoading),
      new FullLoadingParam(),
      { alignment: DialogAlignment.Center, autoCancel: false });
  };

  /**
   * 关闭loading弹窗
   */
  static hideLoading() {
    PopViewUtils.closePopView();
  }

  static copy(str: string) {
    //构建一个指定类型的剪贴板内容对象
    try {
      let pasteData: pasteboard.PasteData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, str)
      //获取系统剪贴板对象
      let systemPasteboard: pasteboard.SystemPasteboard = pasteboard.getSystemPasteboard()
      //将数据写入系统剪贴板
      systemPasteboard.setData(pasteData, (err) => {
        if (err) {
          Logger.error(TAG, 'The copy operation failed');
          return;
        }
        promptAction.showToast({ message: '已复制至剪贴板' });
      })
    } catch (err) {
      Logger.error(TAG, `create data failed, Code is ${err.code}, message is ${err.message}`);
    }
  }

  /**
   * 处理图片url
   * @param url
   * @returns
   */
  static handleImgUrl(url: string): string {
    if (!url) {
      return '';
    }
    if (url.startsWith('https')) {
      return url;
    }
    // 处理mock图片资源
    if (url.startsWith('mockImage://')) {
      const resourceName = url.split('mockImage://')[1];
      const prefixUrl: string = 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/household-3urpx/';
      return `${prefixUrl}${resourceName}`;
    }
    // resources下的资源通过resourceImage://xxx表达
    if (url.startsWith('resourceImage://')) {
      const resourceName = url.split('//')[1];
      try {
        const resource = WindowUtil.context.resourceManager.getMediaBase64ByNameSync(resourceName);
        return resource;
      } catch (err) {
        Logger.error(TAG, `get image resource failed, ${err}, ${resourceName}`);
        return '';
      }
    }

    return url
  };
}
