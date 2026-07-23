/**
 * OpenAI Chat Completions 服务类
 * 提供与OpenAI Chat Completions API交互的功能
 */

import http from '@ohos.net.http';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { Observable } from 'rxjs';
import EventSource, { EventSourceEvent } from './sse/EventSource';
import { ChatCompletion, ChatCompletionChunk, ChatCompletionCreateParams, OpenAIError } from './ChatCompletions';

/**
 * Chat Completions 服务配置
 */
export interface ChatCompletionsConfig {
  /** API密钥 */
  apiKey: string;

  /** API基础URL */
  baseUrl?: string;

  /** 组织ID（可选） */
  organization?: string;

  /** 项目ID（可选） */
  project?: string;

  /** 请求超时时间（毫秒） */
  timeout?: number;
}

/**
 * Chat Completions 服务类
 */
export class ChatCompletionsService {
  private config: ChatCompletionsConfig;
  private readonly DEFAULT_BASE_URL = '';
  private readonly DEFAULT_TIMEOUT = 30000;

  constructor(config: ChatCompletionsConfig) {
    this.config = {
      baseUrl: this.DEFAULT_BASE_URL,
      timeout: this.DEFAULT_TIMEOUT,
      ...config
    };
  }

  /**
   * 创建聊天完成（非流式）
   */
  async createChatCompletion(request: ChatCompletionCreateParams): Promise<ChatCompletion> {
    try {
      // 确保stream为false或未设置
      const requestData = { ...request, stream: false };

      const httpRequest = http.createHttp();

      const response = await httpRequest.request(
        `${this.config.baseUrl}/chat/completions`,
        {
          method: http.RequestMethod.POST,
          header: this.buildHeaders(),
          extraData: JSON.stringify(requestData),
          expectDataType: http.HttpDataType.STRING,
          usingCache: false,
          priority: 1,
          connectTimeout: this.config.timeout,
          readTimeout: this.config.timeout
        }
      );

      httpRequest.destroy();

      if (response.responseCode !== 200) {
        const errorData: OpenAIError = JSON.parse(response.result as string);
        throw new Error(`API Error: ${errorData.error.message}`);
      }

      return JSON.parse(response.result as string) as ChatCompletion;

    } catch (error) {
      hilog.error(1, 'ChatCompletionsService', `创建聊天完成失败: ${error.message}`);
      throw error;
    }
  }

  /**
   * 创建流式聊天完成（回调方式）
   */
  createStreamChatCompletion(
    request: ChatCompletionCreateParams,
    onMessage?: (chunk: ChatCompletionChunk) => void,
    onError?: (error: Error) => void,
    onComplete?: () => void
  ): EventSource {
    try {
      // 确保stream为true
      const requestData = { ...request, stream: true };

      const eventSource = new EventSource(
        `${this.config.baseUrl}/chat/completions`,
        {
          method: http.RequestMethod.POST,
          headers: this.buildHeaders(),
          body: JSON.stringify(requestData)
        }
      );

      eventSource.onMessage = (event: EventSourceEvent) => {
        try {
          if (event.data === '[DONE]') {
            onComplete?.();
            return;
          }

          const parsedData = JSON.parse(event.data);
          
          // 检查是否为错误响应
          if (parsedData.error) {
            const errorInfo: OpenAIError = parsedData;
            const errorMessage = `API Error: ${errorInfo.error.message} (${errorInfo.error.code})`;
            hilog.error(1, 'ChatCompletionsService', errorMessage);
            onError?.(new Error(errorMessage));
            eventSource.close();
            return;
          }

          const chunk: ChatCompletionChunk = parsedData;
          onMessage?.(chunk);

        } catch (parseError) {
          hilog.error(1, 'ChatCompletionsService', `解析流式响应失败: ${parseError.message}`);
          onError?.(parseError);
        }
      };

      eventSource.onError = (error) => {
        hilog.error(1, 'ChatCompletionsService', `流式请求错误: ${JSON.stringify(error)}`);
        onError?.(new Error('流式连接错误'));
      };

      return eventSource;

    } catch (error) {
      hilog.error(1, 'ChatCompletionsService', `创建流式聊天完成失败: ${error.message}`);
      throw error;
    }
  }

  /**
   * 创建流式聊天完成（Observable方式）
   */
  createStreamChatCompletionObservable(
    request: ChatCompletionCreateParams
  ): Observable<ChatCompletionChunk> {
    return new Observable<ChatCompletionChunk>(subscriber => {
      try {
        // 确保stream为true
        const requestData = { ...request, stream: true };

        const eventSource = new EventSource(
          `${this.config.baseUrl}/chat/completions`,
          {
            method: http.RequestMethod.POST,
            headers: this.buildHeaders(),
            body: JSON.stringify(requestData)
          }
        );

        eventSource.onMessage = (event: EventSourceEvent) => {
          try {
            if (event.data === '[DONE]') {
              subscriber.complete();
              return;
            }

            const parsedData = JSON.parse(event.data);
            
            // 检查是否为错误响应
            if (parsedData.error) {
              const errorInfo: OpenAIError = parsedData;
              const errorMessage = `API Error: ${errorInfo.error.message} (${errorInfo.error.code})`;
              hilog.error(1, 'ChatCompletionsService', errorMessage);
              subscriber.error(new Error(errorMessage));
              eventSource.close();
              return;
            }

            const chunk: ChatCompletionChunk = parsedData;
            subscriber.next(chunk);

          } catch (parseError) {
            hilog.error(1, 'ChatCompletionsService', `解析流式响应失败: ${parseError.message}`);
            subscriber.error(parseError);
          }
        };

        eventSource.onError = (error) => {
          hilog.error(1, 'ChatCompletionsService', `流式请求错误: ${JSON.stringify(error)}`);
          subscriber.error(new Error('流式连接错误'));
        };

        // 返回清理函数，用于取消订阅时关闭EventSource
        return () => {
          eventSource.close();
        };

      } catch (error) {
        hilog.error(1, 'ChatCompletionsService', `创建流式聊天完成失败: ${error.message}`);
        subscriber.error(error);
      }
    });
  }

  /**
   * 构建请求头
   */
  private buildHeaders(): Record<string, string> {
    const headers: Record<string, string> = {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${this.config.apiKey}`
    };

    if (this.config.organization) {
      headers['OpenAI-Organization'] = this.config.organization;
    }

    if (this.config.project) {
      headers['OpenAI-Project'] = this.config.project;
    }

    return headers;
  }

  /**
   * 更新配置
   */
  updateConfig(newConfig: Partial<ChatCompletionsConfig>): void {
    this.config = { ...this.config, ...newConfig };
  }

  /**
   * 获取当前配置
   */
  getConfig(): ChatCompletionsConfig {
    return { ...this.config };
  }
}

/**
 * 创建Chat Completions服务实例的工厂函数
 */
export function createChatCompletionsService(config: ChatCompletionsConfig): ChatCompletionsService {
  return new ChatCompletionsService(config);
}
