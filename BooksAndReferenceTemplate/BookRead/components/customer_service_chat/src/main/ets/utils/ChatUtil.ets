import { Want, common } from '@kit.AbilityKit';
import { BusinessError, Callback } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { MessageModel } from '../models/MessageModel';

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
   * 打开浏览器
   */
  static openUrlToWeb(context: common.UIAbilityContext, url: string) {
    let want: Want = {
      action: 'ohos.want.action.viewData',
      entities: ['entity.system.browsable'],
      uri: url,
      parameters: {
        'ohos.ability.params.showDefaultPicker': true
      }
    };

    context.startAbility(want).then(() => {
      hilog.info(0x0000, '[ChatUtil]', 'start browsableAbility successfully.');
    }).catch((err: BusinessError) => {
      hilog.error(0x0000, '[ChatUtil]', `startAbility failed, error code=${err.code}, message=${err.message}`);
    })
  }

  /**
   * 是否展示时间
   */
  static setDisplayTime(msg: MessageModel, messageList: MessageModel[]): boolean {
    if (messageList.length === 0) {
      return true;
    }

    const prevTimestamp = messageList[messageList.length-1].timestamp;
    const currentTimestamp = msg.timestamp;
    const timeDiff = currentTimestamp - prevTimestamp;

    // 如果时间差超过 60 秒
    return timeDiff > 60000;
  }
}