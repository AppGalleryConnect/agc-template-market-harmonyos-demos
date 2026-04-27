import { AppStorageV2 } from '@kit.ArkUI';
import { pushService } from '@kit.PushKit';
import { BusinessError } from '@kit.BasicServicesKit';
import axios, { AxiosError, AxiosResponse } from '@ohos/axios';
import { UtilLog as Logger } from '@hw-agconnect/util-log';
import { OpenId } from '../model/ObserveModel';
import { CurAppInfo } from './Constant';

interface TemplateParam {
  thing_1: string;
  time_2: string;
}

interface PushActionParams {
  msgId: string;
  appId: string;
  toOpenId: string;
  templateId: string;
  templateParams: TemplateParam;
}

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
  public static async pushMessage(title: string, appointTime: number) {
    /*
     * TODO 这里的url需要补充完整，Authorization需要开发者自行获取，详情见readme
     * */
    axios.post('https://',
      PushUtils.pushMessageParams(title, appointTime), {
        headers: {
          'Authorization': 'Bearer '
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
   * push kit 推送请求体
   * @param pushToken
   * @returns
   */
  public static pushMessageParams(title: string, appointTime: number) {
    const openId: OpenId = AppStorageV2.connect(OpenId, () => new OpenId())!;
    const date = new Date(appointTime);
    // 转换成年月日时分秒  xxxx年xx月xx日 xx:xx
    const formatTime: string = `${date.getFullYear()}年${date.getMonth() +
      1}月${date.getDate()}日 ${date.getHours().toString().padStart(2, '0')}:${date.getMinutes().toString().padStart(2, '0')}`
    const requestBody = {
      msgId: new Date().getTime().toString(),
      appId: CurAppInfo.CLIENT_ID,
      toOpenId: openId.openId,
      templateId: CurAppInfo.PUSH_TEMPLATE_ID,
      templateParams: {
        thing_1: title,
        time_2: formatTime,
      }
    } as PushActionParams
    return requestBody
  }
}