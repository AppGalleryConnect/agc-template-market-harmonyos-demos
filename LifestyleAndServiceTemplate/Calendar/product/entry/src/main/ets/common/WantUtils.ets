import { Want } from '@kit.AbilityKit';
import { AppStorageV2 } from '@kit.ArkUI';
import { PushCardInfo, PushUtils } from 'common';
import { UserEventItem } from 'calendar_events';
import { FormCardRouter } from './Types';
import { SOURCE_FORM_CARD } from '../constants/Contants';

const TAG = '[WantUtils]';

/**
 * 应用want处理工具类
 */
export class WantUtils {
  /**
   * 获取pushToken
   * @param want
   */
  public static async getPushToken(want: Want) {
    let pushToken: string = await PushUtils.getTokenSyn();
    AppStorage.setOrCreate('pushToken', pushToken);
  }

  /**
   * 冷启动点击推送信息
   * @param want
   */
  public static handlePushCall(want: Want) {
    const target = want.parameters?.userEventInfo as Record<string, UserEventItem | string>
    if (!target) {
      return
    }
    const pushCardInfo: PushCardInfo =
      AppStorageV2.connect(PushCardInfo, () => new PushCardInfo())!;
    pushCardInfo.id = new Date().getTime();
    pushCardInfo.eventId = target.eventId as string;
  }

  /**
   * 服务卡片事件处理
   * @param want
   */
  public static handleFormCardCall(want: Want) {
    if (want?.parameters?.source === SOURCE_FORM_CARD) {
      const formCardRouter: FormCardRouter =
        AppStorageV2.connect(FormCardRouter, () => new FormCardRouter())!;
      formCardRouter.id = new Date().getTime();
      formCardRouter.params = want?.parameters?.params as string ?? '';
    }
  }
}