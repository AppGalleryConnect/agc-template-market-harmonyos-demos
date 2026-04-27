import { TranslationBase } from './TranslationBase';
import {
  TranslationParam,
  TranslationResponse,
  TranslationConfig,
  TranslationResult
} from '../viewmodels/TranslationModel';
import { http } from '../utils/axiosClient';
import { MD5Util } from '../utils/md5';

// 百度翻译API响应接口
interface BaiduTranslateApiResponse {
  error_code?: string;
  error_msg?: string;
  from?: string;
  to?: string;
  trans_result?: TranslationResult[];
}

export class BaiduTranslation extends TranslationBase {
  private config: TranslationConfig;

  private async getApiUrl(): Promise<string> {
    try {
      const context = getContext();
      return await context.resourceManager.getStringValue($r('app.string.baidu_translate_api_url'));
    } catch (error) {
      // 如果获取资源失败，抛出错误
      throw new Error('Failed to get API URL from resources: ' + JSON.stringify(error));
    }
  }

  constructor(config: TranslationConfig) {
    super();
    this.config = config;
  }

  async translate(param: TranslationParam): Promise<TranslationResponse> {
    const salt = Date.now().toString();
    const signStr = this.config.appId + param.query + salt + this.config.secretKey;
    const sign = await MD5Util.md5(signStr);
    const apiUrl = await this.getApiUrl();

    try {
      const response = await http.request<Record<string, Object>>({
        url: apiUrl,
        method: 'GET',
        params: {
          q: param.query,
          from: param.from || 'auto',
          to: param.to,
          appid: this.config.appId,
          salt: salt,
          sign: sign
        }
      });

      // 解析响应数据
      const apiResponse = response.data as BaiduTranslateApiResponse;

      // 检查错误
      if (apiResponse.error_code) {
        throw new Error(`Baidu Translation Error: ${apiResponse.error_code} - ${apiResponse.error_msg}`);
      }

      // 返回响应
      const rawResults = apiResponse.trans_result || [];
      return {
        from: apiResponse.from || '',
        to: apiResponse.to || '',
        transResult: rawResults.map((item: TranslationResult): TranslationResult => ({
          src: item.src,
          dst: item.dst
        })),
        errorCode: apiResponse.error_code,
        errorMsg: apiResponse.error_msg
      };
    } catch (error) {
      throw new Error('Translation request failed: ' + JSON.stringify(error));
    }
  }

  async batchTranslate(queries: string[], from: string = 'auto', to: string = 'zh'): Promise<string[]> {
    const query = queries.join('\n');
    const param: TranslationParam = {
      query: query,
      from: from,
      to: to
    };
    const result = await this.translate(param);
    if (result.transResult) {
      return result.transResult.map(item => item.dst);
    }
    return [];
  }
}
