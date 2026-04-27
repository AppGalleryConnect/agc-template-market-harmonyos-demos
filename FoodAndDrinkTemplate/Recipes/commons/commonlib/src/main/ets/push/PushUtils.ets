import { pushService } from '@kit.PushKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Logger } from '../utils/Logger';
import axios, { AxiosError, AxiosResponse } from '@ohos/axios'
import { PushModel } from './Model';
import config from './config.json';

export class PushUtils {
  private static token:string = '';
  /**
   * 获取push推送token
   **/
  public static async getTokenSyn() {
    try {
      const pushToken = await pushService.getToken();
      PushUtils.token = pushToken;
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      Logger.error('get token', 'Get push token catch error: %{public}d %{public}s');
    }
  }

  /**
   * 本地使用push rest api mock云端推送
   **/
  public static async pushMessage(recipesList: ESObject) {
    /*
     * 这里的Authorization需要开发者自行获取，详情见readme
     * */
    axios.post(config.url,
      PushUtils.pushMessageParams(recipesList), {
        headers: {
          'Content-Type': 'application/json',
          'push-type': 0,
          'Authorization': 'Bearer xxxxxx',
        },
      })
      .then((resp: AxiosResponse) => {
        Logger.info('push success', JSON.stringify(resp))
      })
      .catch((err: AxiosError) => {
        Logger.info('push err' + err)
      })
  }

  /**
   * 本地使用mock 随机云端推送
   **/
  public static async randomPushMessage(recipesList: ESObject) {
    PushUtils.pushMessage(recipesList)
  }

  /**
   * push kit 推送请求体
   * @param pushToken
   * @returns
   */
  public static pushMessageParams(recipesList: ESObject): PushModel {
    const randomIndex = Math.floor(Math.random() * recipesList.length);
    return {
      'payload': {
        'notification': {
          'category': 'MARKETING',
          'title': '菜谱模板',
          'image': '',
          'body': '您关注的美食新手更新了菜谱',
          'clickAction': {
            'actionType': 0,
            'data': {},
          },
          'notifyId': randomIndex,
          'badge': { 'addNum': 1 },
        },
      },
      target: {
        'token': [PushUtils.token],
      },
      pushOptions: {
        'testMessage': true,
      },
    }
  }
}