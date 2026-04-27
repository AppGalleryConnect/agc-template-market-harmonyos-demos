import { http, AxiosHeaders } from '../utils/axiosClient';
import {
  TranslationConfig,
  DocumentTranslationRequest,
  DocumentTranslationResponse,
  TranslationProgressResponse
} from '../viewmodels/TranslationModel';
import { util } from '@kit.ArkTS';
import { cryptoFramework } from '@kit.CryptoArchitectureKit';

/**
 * 百度文档翻译 API
 */
export class BaiduDocumentTranslation {
  private config: TranslationConfig;

  constructor(config: TranslationConfig) {
    this.config = config;
  }

  /**
   * 获取翻译API URL
   */
  private async getTransApiUrl(): Promise<string> {
    try {
      const context = getContext();
      return await context.resourceManager.getStringValue($r('app.string.baidu_document_translate_api_url'));
    } catch (error) {
      throw new Error('Failed to get translation API URL from resources: ' + JSON.stringify(error));
    }
  }

  /**
   * 获取查询API URL
   */
  private async getQueryApiUrl(): Promise<string> {
    try {
      const context = getContext();
      return await context.resourceManager.getStringValue($r('app.string.baidu_document_query_api_url'));
    } catch (error) {
      throw new Error('Failed to get query API URL from resources: ' + JSON.stringify(error));
    }
  }

  /**
   * 提交文档翻译任务
   */
  async submitTranslation(request: DocumentTranslationRequest): Promise<DocumentTranslationResponse> {
    try {
      const timestamp = Math.floor(Date.now() / 1000);
      const requestBody = JSON.stringify(request);

      // 生成签名
      const sign = await this.generateSign(this.config.appId, timestamp, requestBody, this.config.secretKey);

      // 获取API URL
      const apiUrl = await this.getTransApiUrl();


      const headers = new AxiosHeaders({
        'Content-Type': 'application/json',
        'X-Appid': this.config.appId,
        'X-Timestamp': timestamp.toString(),
        'X-Sign': sign
      });

      const response = await http.request<DocumentTranslationResponse>({
        url: apiUrl,
        method: 'POST',
        headers: headers,
        data: requestBody
      });


      if (response.data.code !== 0) {
        throw new Error(`Document translation failed: ${response.data.msg}`);
      }

      return response.data;
    } catch (error) {
      if (error instanceof Error) {
        throw error;
      } else {
        throw new Error(`Submit translation failed: ${JSON.stringify(error)}`);
      }
    }
  }

  /**
   * 查询翻译进度
   */
  async queryProgress(requestId: number): Promise<TranslationProgressResponse> {
    try {
      const timestamp = Math.floor(Date.now() / 1000);
      const requestBody = JSON.stringify({ requestId });

      // 生成签名
      const sign = await this.generateSign(this.config.appId, timestamp, requestBody, this.config.secretKey);

      // 获取API URL
      const apiUrl = await this.getQueryApiUrl();

      const headers = new AxiosHeaders({
        'Content-Type': 'application/json',
        'X-Appid': this.config.appId,
        'X-Timestamp': timestamp.toString(),
        'X-Sign': sign
      });

      const response = await http.request<TranslationProgressResponse>({
        url: apiUrl,
        method: 'POST',
        headers: headers,
        data: requestBody
      });

      if (response.data.code !== 0) {
        const errorCode = response.data.code;
        // 转换为中文错误信息
        const errorMsg = this.getChineseErrorMessage(errorCode);
        throw new Error(errorMsg);
      }

      return response.data;
    } catch (error) {
      if (error instanceof Error) {
        throw error;
      } else {
        throw new Error(`Query progress failed: ${JSON.stringify(error)}`);
      }
    }
  }

  /**
   * 生成签名
   * Step1: body字符串
   * Step2: appId + timestamp + body
   * Step3: HMAC-SHA256加密
   * Step4: Base64编码
   */
  private async generateSign(appId: string, timestamp: number, body: string, secretKey: string): Promise<string> {
    try {
      // Step2: 拼接字符串
      const signStr = appId + timestamp.toString() + body;

      // Step3: HMAC-SHA256加密
      const hmacGenerator = cryptoFramework.createMac('SHA256');
      const keyData = this.stringToUint8Array(secretKey);
      const keyBlob: cryptoFramework.DataBlob = { data: keyData };
      const symKeyGenerator = cryptoFramework.createSymKeyGenerator('HMAC');
      const symKey = await symKeyGenerator.convertKey(keyBlob);
      await hmacGenerator.init(symKey);

      const messageData = this.stringToUint8Array(signStr);
      const messageBlob: cryptoFramework.DataBlob = { data: messageData };
      await hmacGenerator.update(messageBlob);
      const hmacResult = await hmacGenerator.doFinal();

      // Step4: Base64编码
      const base64Helper = new util.Base64Helper();
      const sign = base64Helper.encodeToStringSync(hmacResult.data);

      return sign;
    } catch (error) {
      throw new Error(`Generate sign failed: ${JSON.stringify(error)}`);
    }
  }

  /**
   * 字符串转 Uint8Array
   */
  private stringToUint8Array(str: string): Uint8Array {
    const textEncoder = new util.TextEncoder();
    return textEncoder.encodeInto(str);
  }

  /**
   * 获取中文错误信息
   */
  private getChineseErrorMessage(errorCode: number): string {
    const errorMessages: Record<number, string> = {
      70201: '文档翻译服务异常，请稍后重试',
      70202: '请求参数错误',
      70203: '文档大小超出限制',
      70204: '文档页数超出限制',
      70205: '余额不足',
      70206: '文档格式不支持',
      70207: '该文档为图片型PDF，暂不支持翻译',
      70208: '文档格式不支持，请上传doc、docx或文字型PDF',
      70209: '文档内容为空',
      70210: '文档解析失败',
      70211: '翻译任务不存在',
      70212: '翻译任务已过期'
    };
    return errorMessages[errorCode] || `翻译失败（错误码：${errorCode}）`;
  }

  /**
   * 轮询查询翻译结果
   * @param requestId 任务ID
   * @param maxAttempts 最大查询次数
   * @param interval 查询间隔（毫秒）
   */
  async pollTranslationResult(
    requestId: number,
    maxAttempts: number = 60,
    interval: number = 2000
  ): Promise<TranslationProgressResponse> {
    for (let i = 0; i < maxAttempts; i++) {
      const result = await this.queryProgress(requestId);

      if (result.data?.status === 1) {
        // 翻译成功
        return result;
      } else if (result.data?.status === 2) {
        // 翻译失败
        throw new Error(`翻译失败：${result.data.reason || '未知原因'}`);
      }

      // 翻译中，等待后继续查询
      await new Promise<void>((resolve) => setTimeout(resolve, interval));
    }

    throw new Error('翻译超时，请重试');
  }
}
