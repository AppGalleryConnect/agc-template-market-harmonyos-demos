import { common } from '@kit.AbilityKit';
import { pushService } from '@kit.PushKit';
import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI';
import { UtilLog } from '@hw-agconnect/util-log';
import { notificationManager } from '@kit.NotificationKit';
import axios, { AxiosError, AxiosResponse } from '@ohos/axios'
import dayjs from 'dayjs';
import { RouterModule } from 'router_module';
import { EVENT_TYPE, RdbInit, routerMap, UserEventItem } from 'calendar_events';
import { SettingState } from '../models/UserStateModel';
import { PushActionParams, PushCardInfo, PushMessageInfo, PushModel } from '../models/PushModel';
import { calculateNextEvents } from './CalculateDate';



const TAG = '[PushUtils]';


export class PushUtils {
  private static settingState: SettingState = PersistenceV2.connect(SettingState, () => new SettingState())!;

  public static sendPushNotice(context: common.UIAbilityContext, type = 'push') {
    notificationManager.requestEnableNotification(context).then(() => {
      PushUtils.sendPushMessage(type);
      UtilLog.info(TAG, 'requestEnableNotification success');
    }).catch((error: BusinessError) => {
      UtilLog.error(TAG, 'requestEnableNotification fail, error: ' + JSON.stringify(error));
    });
  }

  public static async interceptPushInfo() {
    /*
     * push消息进入，处理消息路由跳转
     * */
    const pushCardInfo: PushCardInfo =
      AppStorageV2.connect(PushCardInfo, () => new PushCardInfo())!;
    if (pushCardInfo && pushCardInfo.eventId) {
      let eventItem = await RdbInit.queryEventById(pushCardInfo.eventId)
      if (!eventItem) {
        UtilLog.error(TAG, 'interceptPushInfo: event not found, id=' + pushCardInfo.eventId)
        return
      }
      if ([EVENT_TYPE.BIRTHDAY, EVENT_TYPE.ANNIVERSARIES].includes(eventItem.eventType)) {
        const params: Record<string, UserEventItem | string> = {
          'userEventInfo': eventItem,
          'eventType': eventItem.eventType,
        }
        RouterModule.getStack()?.pushPathByName(routerMap[eventItem.eventType], params)
        return
      }
      RouterModule.getStack()?.pushPathByName(routerMap[eventItem.eventType], eventItem)
    }
  }

  static async sendPushMessage(type: string) {
    if (type === 'update') {
      PushUtils.randomPushMessage(new PushMessageInfo(), type)
      return
    }
    const events = await RdbInit.loadAllEvents()
    let pushEventInfo: PushMessageInfo = new PushMessageInfo()
    if (events.length > 0) {
      // 推送提醒
      const ues: UserEventItem = events[0]
      pushEventInfo.date = dayjs(ues.date[0].date).format('YYYY-MM-DD')
      pushEventInfo.content = events[0].content
      pushEventInfo.type = events[0].eventType
      pushEventInfo.id = events[0].id
    } else {
      // 推送节气
      pushEventInfo.date = PushUtils.getFestival().date
      pushEventInfo.content = PushUtils.getFestival().name
      pushEventInfo.type = 'solar'
    }
    PushUtils.randomPushMessage(pushEventInfo, type)
  }

  /**
   * 获取push推送token
   **/
  public static async getTokenSyn(): Promise<string> {
    try {
      const pushToken = await pushService.getToken();
      return pushToken;
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      UtilLog.error('get token', 'Get push token catch error: %{public}d %{public}s');
      return '';
    }
  }

  /**
   * 本地使用push rest api mock云端推送
   **/
  public static async pushMessage(userEventInfo: PushMessageInfo, type: string) {
    /**
     * todo:
     * 这里的Authorization需要开发者自行获取，详情见readme
     * projectId需要填入
     * */
    axios.post('https://push-api.cloud.huawei.com/v3/projectId/messages:send',
      PushUtils.pushMessageParams(userEventInfo), {
        headers: {
          'Content-Type': 'application/json',
          'push-type': 0,
          'Authorization': 'Bearer ',
        },
      })
      .then((resp: AxiosResponse) => {
        UtilLog.info('push success', JSON.stringify(resp))
      })
      .catch((err: AxiosError) => {
        UtilLog.info('push err' + err)
      })
  }

  /**
   * 本地使用mock 随机云端推送
   **/
  public static async randomPushMessage(userEventInfo: PushMessageInfo, type: string) {
    PushUtils.pushMessage(userEventInfo, type)
  }

  /**
   * push kit 推送请求体
   * @param pushToken
   * @returns
   */
  public static pushMessageParams(userEventInfo: PushMessageInfo): PushModel {
    return {
      'payload': {
        'notification': {
          'category': 'MARKETING',
          'title': '日历模板',
          'body': `距离${PushUtils.getType(
            userEventInfo.type)} <${userEventInfo.content}> 还剩 ${PushUtils.getRemainingDays(userEventInfo.date)} 天`,
          'clickAction': {
            'actionType': 0,
            'data': {
              'userEventInfo': {
                'eventId': userEventInfo.id,
              },
            },
          },
          'notifyId': 0,
          'badge': { 'addNum': 1 },
        },
      },
      target: {
        'token': [AppStorage.get('pushToken') ?? ''],
      },
      pushOptions: {
        'testMessage': true,
      },
    }
  }


  /**
   * push kit 推送请求体
   * @param pushToken
   * @returns
   */
  public static pushUpdateMessage(userEventInfo: PushMessageInfo): PushModel {
    return {
      'payload': {
        'notification': {
          'category': 'MARKETING',
          'title': '日历模板',
          'body': `您的应用有新的版本，点击更新`,
          'clickAction': {
            'actionType': 0,
            'data': {
              'userEventInfo': {
                'eventId': '-1',
              },
            },
          },
          'notifyId': 0,
          'badge': { 'addNum': 1 },
        },
      },
      target: {
        'token': [AppStorage.get('pushToken') ?? ''],
      },
      pushOptions: {
        'testMessage': true,
      },
    }
  }

  public static getType(type: string) {
    const eventType: Record<string, string> = {
      'schedule': '日程',
      'birthday': '生日',
      'anniversaries': '纪念日',
      'todo': 'todo',
      'solar': '节气',
    }
    return eventType[type]
  }

  public static getRemainingDays(date: string): number {
    if (!date) {
      return 0;
    }
    const targetDate = new Date(date + 'T00:00:00');
    targetDate.setHours(0, 0, 0, 0);
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const oneDayMs = 24 * 60 * 60 * 1000;
    const diffDays = Math.ceil((targetDate.getTime() - today.getTime()) / oneDayMs);
    return diffDays;
  }

  public static getFestival() {
    return calculateNextEvents(dayjs(new Date()).format('YYYY-MM-DD'))[0]
  }
}