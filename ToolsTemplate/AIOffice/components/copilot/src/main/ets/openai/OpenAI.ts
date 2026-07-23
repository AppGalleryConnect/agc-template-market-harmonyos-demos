import { Observable } from 'rxjs';
import {
  ChatCompletionsService, 
  createChatCompletionsService
} from './ChatCompletionsService';
import {
  ChatCompletionCreateParams,
  ChatCompletion,
  ChatCompletionChunk
} from './ChatCompletions';

/**
 * OpenAI客户端配置
 */
export interface ClientOptions {
  /** 
   * API密钥
   * 必需参数，用于身份验证
   */
  apiKey: string;
  
  /** 
   * 组织ID（可选）
   * 用于指定请求所属的组织
   */
  organization?: string;
  
  /** 
   * 项目ID（可选）
   * 用于指定请求所属的项目
   */
  project?: string;
  
  /** 
   * API基础URL
   */
  baseURL?: string;
  
  /** 
   * 请求超时时间（毫秒）
   * 默认: 600000 (10分钟)
   */
  timeout?: number;
  
  /** 
   * 最大重试次数
   * 默认: 2
   */
  maxRetries?: number;
  
  /** 
   * 默认请求头
   */
  defaultHeaders?: Record<string, string>;
  
  /** 
   * 默认查询参数
   */
  defaultQuery?: Record<string, unknown>;
}

/**
 * OpenAI客户端主类
 */
export class OpenAI {
  private chatCompletionsService: ChatCompletionsService;
  private _options: ClientOptions;

  constructor(options : ClientOptions) {
    if (!options.apiKey || options.apiKey.trim().length === 0) {
      throw new Error(
        'The apiKey parameter is required. Please provide it when instantiating the OpenAI client, like new OpenAI({ apiKey: "My API Key" }).'
      );
    }

    this._options = options;
    this.chatCompletionsService = createChatCompletionsService({
      apiKey: this._options.apiKey!,
      baseUrl: this._options.baseURL,
      organization: this._options.organization,
      project: this._options.project,
      timeout: this._options.timeout,
    });
  }

  /**
   * 创建非流式聊天完成
   */
  public async createChatCompletion(
    body: ChatCompletionCreateParams,
    options?: RequestOptions
  ): Promise<ChatCompletion> {
    return await this.chatCompletionsService.createChatCompletion(body);
  }

  /**
   * 创建流式聊天完成
   */
  public createStreamChatCompletion(
    body: ChatCompletionCreateParams,
    options?: RequestOptions
  ): Observable<ChatCompletionChunk> {
    return this.chatCompletionsService.createStreamChatCompletionObservable(body);
  }
}

/**
 * 请求选项接口
 */
export interface RequestOptions {
  headers?: Record<string, string>;
  timeout?: number;
}

