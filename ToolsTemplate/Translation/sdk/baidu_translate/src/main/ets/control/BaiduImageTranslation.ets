import { TranslationBase } from './TranslationBase';
import {
  ImageTranslationParam,
  ImageTranslationResponse,
  ImageTranslationData,
  TranslationConfig
} from '../viewmodels/TranslationModel';
import { http, AxiosHeaders, AxiosRequestHeaders } from '../utils/axiosClient';
import { MD5Util } from '../utils/md5';
import { util } from '@kit.ArkTS';

// 百度图片翻译API响应接口
interface BaiduImageApiResponse {
  error_code?: string;
  error_msg?: string;
  data?: ImageTranslationData;
}

/**
 * 百度图片翻译服务
 */
export class BaiduImageTranslation extends TranslationBase {
  private config: TranslationConfig;

  private async getApiUrl(): Promise<string> {
    try {
      const context = getContext();
      return await context.resourceManager.getStringValue($r('app.string.baidu_image_translate_api_url'));
    } catch (error) {
      // 如果获取资源失败，抛出错误
      throw new Error('Failed to get API URL from resources: ' + JSON.stringify(error));
    }
  }

  constructor(config: TranslationConfig) {
    super();
    this.config = config;
  }

  /**
   * 翻译图片
   * @param param 图片翻译参数
   * @returns 翻译结果
   */
  async translateImage(param: ImageTranslationParam): Promise<ImageTranslationResponse> {
    try {
      // 1. 生成随机盐值
      const salt = Date.now().toString();

      // 1.1 使用固定CUID和MAC (Baidu API要求)
      const cuid = 'APICUID';
      const mac = 'mac';

      // 2. 计算图片MD5
      const imageMD5 = await MD5Util.md5Buffer(param.imageData);

      // 3. 生成签名
      const signStr = `${this.config.appId}${imageMD5}${salt}${cuid}${mac}${this.config.secretKey}`;
      const sign = await MD5Util.md5(signStr);

      // 4. 手动构建 Multipart/form-data
      const boundary = `----BaiduTranslateBoundary${Date.now()}`;
      const lineBreak = '\r\n';
      const textEncoder = new util.TextEncoder();

      // 4.1 构建文本参数部分
      let textParams = '';
      const appendParam = (key: string, value: string) => {
        textParams += `--${boundary}${lineBreak}`;
        textParams += `Content-Disposition: form-data; name="${key}"${lineBreak}${lineBreak}`;
        textParams += `${value}${lineBreak}`;
      };

      appendParam('from', param.from);
      appendParam('to', param.to);
      appendParam('appid', this.config.appId);
      appendParam('salt', salt);
      appendParam('sign', sign);
      appendParam('cuid', cuid);
      appendParam('mac', mac);
      appendParam('version', '3');
      if (param.paste !== undefined) {
        appendParam('paste', param.paste.toString());
      }
      if (param.needIntervene !== undefined) {
        appendParam('needIntervene', param.needIntervene.toString());
      }

      // 4.2 构建图片头部
      let imageHeader = `--${boundary}${lineBreak}`;
      imageHeader += `Content-Disposition: form-data; name="image"; filename="image.jpg"${lineBreak}`;
      imageHeader += `Content-Type: image/jpeg${lineBreak}${lineBreak}`;

      // 4.3 构建结尾
      const footer = `${lineBreak}--${boundary}--${lineBreak}`;

      // 4.4 拼接所有数据
      const textData = textEncoder.encodeInto(textParams);
      const imageHeaderData = textEncoder.encodeInto(imageHeader);
      const footerData = textEncoder.encodeInto(footer);
      const imageData = new Uint8Array(param.imageData);

      const totalLength =
        textData.byteLength + imageHeaderData.byteLength + imageData.byteLength + footerData.byteLength;
      const fullBuffer = new Uint8Array(totalLength);

      let offset = 0;
      fullBuffer.set(textData, offset);
      offset += textData.byteLength;
      fullBuffer.set(imageHeaderData, offset);
      offset += imageHeaderData.byteLength;
      fullBuffer.set(imageData, offset);
      offset += imageData.byteLength;
      fullBuffer.set(footerData, offset);


      // 5. 发送POST请求
      const apiUrl = await this.getApiUrl();
      const response = await http.request<Record<string, Object>>({
        url: apiUrl,
        method: 'POST',
        headers: new AxiosHeaders({
          'Content-Type': `multipart/form-data; boundary=${boundary}`
        }) as AxiosRequestHeaders,
        data: fullBuffer.buffer, // 发送 ArrayBuffer
        timeout: 120 * 1000 // 图片翻译需要更长的超时时间
      });

      // 解析响应数据
      const apiResponse = response.data as BaiduImageApiResponse;

      // 检查错误
      if (apiResponse.error_code && apiResponse.error_code !== '0') {
        throw new Error(`Baidu Image Translation Error: ${apiResponse.error_code} - ${apiResponse.error_msg}`);
      }

      // 返回响应
      return {
        errorCode: apiResponse.error_code,
        errorMsg: apiResponse.error_msg,
        data: apiResponse.data
      };
    } catch (error) {
      throw new Error('Image translation request failed: ' + JSON.stringify(error));
    }
  }

  // 实现基类的抽象方法（图片翻译不使用此方法）
  async translate(): Promise<never> {
    throw new Error('Please use translateImage() method for image translation');
  }

  // 实现基类的抽象方法（图片翻译不支持批量翻译）
  async batchTranslate(): Promise<never> {
    throw new Error('Batch translation is not supported for image translation');
  }
}
