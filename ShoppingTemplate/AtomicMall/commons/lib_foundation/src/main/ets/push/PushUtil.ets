import { BusinessError } from '@kit.BasicServicesKit';
import { pushService } from '@kit.PushKit';
import axios, { AxiosError, AxiosResponse } from '@ohos/axios';
import { UtilLog as Logger } from '@hw-agconnect/util-log';
import dayjs from 'dayjs';
import { iData } from '../utils/IData';

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
    axios.post('https://push-api.cloud.huawei.com/v1/[projectId]/service_notification/send',
      PushUtil.pushMessageParams(), {
        headers: {
          'Authorization': 'Bearer ',
        },
      })
      .then((resp: AxiosResponse) => {
        Logger.info('push success', JSON.stringify(resp));
      })
      .catch((err: AxiosError) => {
        Logger.error('push err: ' + err);
      });
  }

  /**
   * push kit 推送请求体
   * @param pushToken
   * @returns
   */
  public static pushMessageParams(): Record<string, string | Record<string, string>> {
    const curDate = dayjs();
    const requestDate = curDate.set('day', curDate.day() + 1).format('YYYY年MM月DD日')
    const requestBody: Record<string, string | Record<string, string>> = {
      'msgId': new Date().getTime() + '',
      // 元服务appId
      'appId': 'xxx',
      'toOpenId': iData.global.userInfo.openId!,
      // 服务通知模板id
      'templateId': 'xxx',
      // 根据模板参数填写templateParams
      'templateParams': {
        'thing_0': iData.global.userInfo.nickname ? iData.global.userInfo.nickname : '华为用户',
        'thing_3': '商品上新通知',
        'time_2': requestDate,
      } as Record<string, string>,
    }
    return requestBody
  }
}