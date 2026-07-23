import { pushService } from '@kit.PushKit';
import { BusinessError } from '@kit.BasicServicesKit';
import axios, { AxiosError, AxiosResponse } from '@ohos/axios'
import { PushModel } from './Model';
import { Logger } from '@agctemplate/utils/src/main/ets/logger/AppLogger';

const TAG = 'PushUtils'

export class PushUtils {
  /**
   * 获取push推送token
   **/
  public static async getTokenSyn(): Promise<string> {
    try {
      const pushToken = await pushService.getToken();
      return pushToken;
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      Logger.error('get token', 'Get push token catch error: %{public}d %{public}s');
      return '';
    }
  }

  /**
   * 本地使用push rest api mock云端推送
   **/
  public static async pushMessage(dramaList: ESObject) {
    /*
     * 这里的Authorization需要开发者自行获取，详情见readme
     * */
    axios.post('https://push-api.cloud.huawei.com/v3/461323198430147944/messages:send',
      PushUtils.pushMessageParams(dramaList), {
        headers: {
          'Content-Type': 'application/json',
          'push-type': 0,
          'Authorization': 'Bearer ',
        },
      })
      .then((resp: AxiosResponse) => {
        Logger.info(TAG,'push success', JSON.stringify(resp))
      })
      .catch((err: AxiosError) => {
        Logger.info(TAG,'push err' + err)
      })
  }

  /**
   * 本地使用mock 随机云端推送
   **/
  public static async randomPushMessage(dramaList: ESObject) {
    PushUtils.pushMessage(dramaList)
  }

  /**
   * push kit 推送请求体
   * @param pushToken
   * @returns
   */
  public static pushMessageParams(dramaList: ESObject): PushModel {
    const randomIndex = Math.floor(Math.random() * dramaList.totalCount());
    return {
      'payload': {
        'notification': {
          'category': 'MARKETING',
          'title': '最新好剧，尽在短剧模板',
          'image': dramaList.getData(randomIndex).getPic(),
          'body': `好剧来袭，最新好剧尽收眼底，近期上新好剧:《${dramaList.getData(randomIndex).getName()}》...`,
          'clickAction': {
            'actionType': 0,
            'data': {
              'id': dramaList.getData(randomIndex).getId()
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
}