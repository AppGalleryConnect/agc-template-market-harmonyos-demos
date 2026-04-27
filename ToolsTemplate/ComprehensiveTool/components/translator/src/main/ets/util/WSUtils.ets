import { webSocket } from '@kit.NetworkKit';
import CryptoJS from '@ohos/crypto-js';
import { url, util } from '@kit.ArkTS';
import { BusinessError } from '@kit.BasicServicesKit';
import { FormatUtil } from './FormatUtil';
import { IatParams, IResponse, IResponseText, KinshipDictionary } from '../model/Ws';
import { TranLogger } from './TranLogger';

export class WsParam {
  appId: string;
  apiKey: string;
  apiSecret: string;
  audioFile: string;
  iatParams: IatParams;

  constructor(appId: string, apiKey: string, apiSecret: string, audioFile: string) {
    this.appId = appId;
    this.apiKey = apiKey;
    this.apiSecret = apiSecret;
    this.audioFile = audioFile;
    this.iatParams = {
      domain: 'slm',
      language: 'mul_cn',
      accent: 'mandarin',
      result: {
        encoding: 'utf8',
        compress: 'raw',
        format: 'json'
      }
    }
  }

  createUrl(): string {
    let urlData = 'wss://iat.cn-huabei-1.xf-yun.com/v1';
    let now = new Date();
    let date = now.toUTCString();

    let signatureOrigin = `host: iat.cn-huabei-1.xf-yun.com\ndate: ${date}\nGET /v1 HTTP/1.1`;
    let signatureSha: string = CryptoJS.HmacSHA256(signatureOrigin, this.apiSecret).toString(CryptoJS.enc.Base64);
    let authorizationOrigin =
      `api_key="${this.apiKey}", algorithm="hmac-sha256", headers="host date request-line", signature="${signatureSha}"`;
    let authorization = FormatUtil.getBase64String(authorizationOrigin);

    let v: KinshipDictionary = {
      'authorization': authorization,
      'date': date,
      'host': 'iat.cn-huabei-1.xf-yun.com'
    };

    urlData += '?' + new url.URLParams(v).toString();
    return urlData;
  }
}

export const ws = webSocket.createWebSocket();

// TODO 添加文本翻译对应的Websocket服务接口认证信息(appid、apiSecret、apiKey)
export const wsParam =
  new WsParam('xxx', 'xxx', 'xxx', '');

export class WsUtil {
  static text: string = ''
  static path: string = ''
  static language: string = ''
  static onEnd: (text: string, language: string) => void = () => {
  }

  static webSend() {
    let wsUrl = wsParam.createUrl();
    ws.on('open', (err: BusinessError, value: Object) => {
      if (err) {
        TranLogger.error(`open fail. Code: ${err.code}, message: ${err.message}`)
      }
      TranLogger.info('open success')
    });
    ws.on('message', (err: BusinessError<void>, value: string | ArrayBuffer) => {
      const res = JSON.parse(value as string) as IResponse
      let base64 = new util.Base64Helper()
      if (res.payload && res.payload.result) {
        let array = base64.decodeSync(res.payload.result.text)
        let textDecoderOptions: util.TextDecoderOptions = {
          fatal: false,
          ignoreBOM: true
        }
        let decodeToStringOptions: util.DecodeToStringOptions = {
          stream: false
        }
        let textDecoder = util.TextDecoder.create('utf-8', textDecoderOptions);
        const base64Str2 = textDecoder.decodeToString(array, decodeToStringOptions);
        const textObj = JSON.parse(base64Str2) as IResponseText
        textObj.ws.forEach((wsChild) => {
          wsChild.cw.forEach((textChild) => {
            if (textChild.lg) {
              WsUtil.language = textChild.lg
            }
            WsUtil.text += textChild.w
          })
        })
        WsUtil.onEnd(WsUtil.text, WsUtil.language)
        TranLogger.info('on message, message:' + WsUtil.text)
      }
    });
    ws.on('error', (err) => {
      TranLogger.error('on error:' + JSON.stringify(err))
    });
    ws.on('close', (err: BusinessError, value: webSocket.CloseResult) => {
      TranLogger.info('on close, code is ' + value.code + ', reason is ' + value.reason)
      WsUtil.webSend()
    });
    ws.connect(wsUrl, { protocol: 'soup' }, (err: BusinessError, value: boolean) => {
      if (!err) {
        TranLogger.info('connect success')
      } else {
        TranLogger.error(`connect fail. Code: ${err.code}, message: ${err.message}`)
      }
    });
  }

  static close() {
    ws.close().then((value: boolean) => {
      TranLogger.info('close success')
    }).catch((err: string) => {
      TranLogger.error('close fail, error:' + JSON.stringify(err))
    });
  }
}