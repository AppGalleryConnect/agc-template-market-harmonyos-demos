import { AxiosAdapter, AxiosRequestConfig, AxiosResponse } from '@ohos/axios';
import { deepEqual } from '../../../../../Index';

type MockRule = {
  requestData: RequestData;
  method?: string;
  response: (config: AxiosRequestConfig) => Promise<any>;
  delay?: number;
};

type RequestData = {
  url: string | RegExp;
  params?: any;
  data?: any;
}

export class MockAdapter {
  private static mockRules: MockRule[] = [];
  private static requestHistory: AxiosRequestConfig[] = [];

  // 核心 adapter 实现
  public static adapter: AxiosAdapter = async (config) => {
    this.requestHistory.push(config);

    const matchedRule = this.findMatchingRule(config);
    if (!matchedRule) {
      throw new Error(`No mock rule found for ${config.method?.toUpperCase()} ${config.url}`);
    }

    return this.createMockResponse(matchedRule, config);
  }

  // 添加模拟规则
  public static onGet(requestData: RequestData, response: any): typeof MockAdapter {
    this.addRule({ method: 'get', requestData, response });
    return this;
  }

  public static onPost(requestData: RequestData, response: any): typeof MockAdapter {
    this.addRule({ method: 'post', requestData, response });
    return this;
  }

  public static onPut(requestData: RequestData, response: any): typeof MockAdapter {
    this.addRule({ method: 'put', requestData, response });
    return this;
  }

  public static onDelete(requestData: RequestData, response: any): typeof MockAdapter {
    this.addRule({ method: 'delete', requestData, response });
    return this;
  }

  // 模拟网络延迟
  public static withDelay(delay: number): typeof MockAdapter {
    this.mockRules = this.mockRules.map(rule => ({
      ...rule,
      delay
    }));
    return this;
  }

  // 获取请求历史记录
  public static getHistory(): AxiosRequestConfig[] {
    return this.requestHistory;
  }

  // 重置 mock
  public static reset(): void {
    this.mockRules = [];
    this.requestHistory = [];
  }

  private static addRule(rule: Partial<MockRule>): void {
    this.mockRules.push({
      method: 'get',
      delay: 0,
      ...rule,
      response: typeof rule.response === 'function'
        ? rule.response
        : (): Promise<any> => Promise.resolve(rule.response)
    } as MockRule);
  }

  private static findMatchingRule(config: AxiosRequestConfig): MockRule {
    return this.mockRules.find(rule =>
    (rule.requestData.url instanceof RegExp ? rule.requestData.url.test(config.url!) :
      rule.requestData.url === config.url) &&
      rule.method?.toLowerCase() === config.method?.toLowerCase() &&
    deepEqual(rule.requestData.params, config.params)
    );
  }

  private static async createMockResponse(rule: MockRule, config: AxiosRequestConfig): Promise<AxiosResponse> {
    await new Promise(resolve => setTimeout(resolve, rule.delay));

    return {
      data: await rule.response(config),
      status: 200,
      statusText: 'OK',
      headers: {},
      config,
    } as AxiosResponse;
  }
}
