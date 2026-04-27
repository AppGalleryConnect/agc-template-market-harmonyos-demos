import { Callback } from '@kit.BasicServicesKit';
import { common, Want } from '@kit.AbilityKit';

/**
 * 聊天窗口工具类
 */
export class ChatUtil {

  /**
   * 正则分割超链接
   */
  static splitUrls(str: string, callback: Callback<string[][]>) {
    let urlPattern = /(https?:\/\/|www.)[a-zA-Z_0-9\-@]+(\.\w[a-zA-Z_0-9\-:]+)+(\/[\(\)~#&\-=?\+\%/\.\w]+)?/g;
    let urlsArr = str.match(urlPattern) as string[];
    let strArr: string[] = [];
    let urlArr: string[] = [];
    if (urlsArr && urlsArr.length > 0) {

      strArr = ChatUtil.splitString(str, urlsArr);
      urlArr = urlsArr;
    } else {
      strArr = [str];
    }

    callback([strArr, urlArr]);
  }

  static splitString(str: string, separators: Array<string>) {
    const escaped = separators.map(s => s.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'));
    return str.split(new RegExp(escaped.join('|'), 'g'));
  }

  /**
   * 打开系统浏览器
   */
  static openUrlToWeb(context: common.UIAbilityContext, url: string) {
    let want: Want = {
      action: 'ohos.want.action.viewData',
      entities: ['entity.system.browsable'],
      uri: url,
    };

    context.startAbility(want)
  }
}