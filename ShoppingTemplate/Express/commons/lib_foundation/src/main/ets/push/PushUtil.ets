import { BusinessError } from '@kit.BasicServicesKit';
import { pushService } from '@kit.PushKit';
import axios, { AxiosError, AxiosResponse } from '@ohos/axios';
import { UtilLog as Logger } from '@hw-agconnect/util-log';
import { PushModel } from './Model';

export class PushUtil {
  private static token: string = '';

  /**
   * 获取push推送token
   **/
  public static async getTokenSyn() {
    try {
      const pushToken = await pushService.getToken();
      PushUtil.token = pushToken;
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      Logger.error('get token', 'Get push token catch error: %{public}d %{public}s');
    }
  }

  /**
   * 本地使用push rest api mock云端推送
   **/
  public static async pushMessageMock() {
    /*
     * todo: 如需调试Push能力，请自行替换[projectId]为工程项目ID，并获取Authorization，详情见README
     * */
    return new Promise<ESObject>((resolve, reject) => {
      axios.post('https://push-api.cloud.huawei.com/v3/[projectId]/messages:send',
        PushUtil.pushMessageParams(), {
          headers: {
            'Content-Type': 'application/json',
            'push-type': 0,
            'Authorization': 'Bearer '
          },
        })
        .then((resp: AxiosResponse) => {
          resolve(resp.status)
          Logger.info('push success', JSON.stringify(resp));
        })
        .catch((err: AxiosError) => {
          reject(err)
          Logger.info('push err' + err);
        });
    })
  }

  /**
   * push kit 推送请求体
   * @param pushToken
   * @returns
   */
  public static pushMessageParams(): PushModel {
    return {
      'payload': {
        'notification': {
          'category': 'MARKETING',
          'title': '快递物流模板',
          'image': '',
          'body': '订单创建成功',
          'clickAction': {
            'actionType': 0,
            'data': {},
          },
          'notifyId': 1234567,
          'badge': { 'addNum': 1 },
        },
      },
      target: {
        'token': [PushUtil.token],
      },
      pushOptions: {
        'testMessage': true,
      },
    };
  }
}