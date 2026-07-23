import { Observable } from 'rxjs';
import { CopilotClient, CopilotRequest, CopilotResponse } from './CopilotClient';
import {
  ChatCompletion,
  ChatCompletionChunk,
  ChatCompletionCreateParams,
  FinishReason,
  OpenAI,
  Message as OpenAIMessage,
  MessageRole as OpenAIMessageRole,
  Tool as OpenAITool,
  ToolType
} from '../openai/Index';
import {
  ActionExecutionMessage,
  Message,
  MessageRole,
  MessageStatus,
  MessageStatusCode,
  ResultMessage,
  TextMessage
} from '../model/Messages';
import { LLMOptions } from '../controller/CopilotControllerOptions';

export class OpenAIClient extends CopilotClient {
  private openai: OpenAI;
  private options: LLMOptions;
  private thinkingEnabled: boolean;

  constructor(options: LLMOptions) {
    super();
    this.openai = new OpenAI({
      baseURL: options.baseUrl,
      apiKey: options.apiKey
    });
    this.options = options;
    this.thinkingEnabled = options.thinkingEnabled ?? false;
  }

  async chat(request: CopilotRequest): Promise<CopilotResponse> {
    try {
      // 转换 CopilotRequest 到 OpenAI ChatCompletionCreateParams
      const openaiRequest = this.convertToOpenAIRequest(request);

      // 调用 OpenAI API
      const openaiResponse = await this.openai.createChatCompletion(openaiRequest);

      // 转换 OpenAI 响应到 CopilotResponse
      return this.convertToCopilotResponse(openaiResponse);
    } catch (error) {
      throw new Error(`OpenAI chat completion failed: ${error.message}`);
    }
  }

  stream(request: CopilotRequest): Observable<CopilotResponse> {
    try {
      // 转换 CopilotRequest 到 OpenAI ChatCompletionCreateParams
      const openaiRequest = this.convertToOpenAIRequest(request);

      // 在外部创建Message列表来管理流式响应的消息
      let streamMessages: Message[] = [];

      // 调用 OpenAI 流式 API
      return new Observable<CopilotResponse>(subscriber => {
        const streamSubscription = this.openai.createStreamChatCompletion(openaiRequest).subscribe({
          next: (chunk: ChatCompletionChunk) => {
            try {
              streamMessages = this.processStreamChunk(chunk, streamMessages);
              if (streamMessages.length > 0) {
                subscriber.next({ messages: streamMessages });
              }
            } catch (error) {
              subscriber.error(error);
            }
          },
          error: (error: Error) => {
            // 将所有未完成的消息标记为失败
            this.markMessagesFailed(streamMessages, error.message);
            subscriber.error(error);
          },
          complete: () => {
            subscriber.complete();
          }
        });

        // 返回清理函数
        return () => {
          streamSubscription.unsubscribe();
        };
      });
    } catch (error) {
      throw new Error(`OpenAI stream chat completion failed: ${error.message}`);
    }
  }

  /**
   * 转换 CopilotRequest 到 OpenAI ChatCompletionCreateParams
   */
  private convertToOpenAIRequest(request: CopilotRequest): ChatCompletionCreateParams {
    // 转换消息格式
    const messages: OpenAIMessage[] = request.messages.map(msg => {
      if (msg.isTextMessage()) {
        const textMsg = msg as TextMessage;
        return {
          role: this.convertToOpenAIRole(textMsg.role),
          content: textMsg.content
        } as OpenAIMessage;
      } else if (msg.isActionExecutionMessage()) {
        const actionMsg = msg as ActionExecutionMessage;
        // 对于动作执行消息，转换为工具调用格式
        return {
          role: OpenAIMessageRole.ASSISTANT,
          content: null,
          tool_calls: [{
            id: actionMsg.callId,
            type: 'function',
            function: {
              name: actionMsg.name,
              arguments: JSON.stringify(actionMsg.args)
            }
          }]
        } as OpenAIMessage;
      } else if (msg.isResultMessage()) {
        const resultMsg = msg as ResultMessage;
        // 对于结果消息，转换为工具响应格式
        return {
          role: OpenAIMessageRole.TOOL,
          content: typeof resultMsg.result === 'string' 
            ? resultMsg.result 
            : JSON.stringify(resultMsg.result),
          tool_call_id: resultMsg.actionCallId
        } as OpenAIMessage;
      } else {
        // 默认处理其他消息类型
        return {
          role: 'user',
          content: 'Unsupported message type'
        } as OpenAIMessage;
      }
    });

    // 构建 OpenAI 请求参数
    const openaiRequest: ChatCompletionCreateParams = {
      model: this.options.model || '',
      messages: messages,
      temperature: request.forwardedParameters?.temperature,
      max_tokens: request.forwardedParameters?.maxTokens,
      stop: request.forwardedParameters?.stop,
    };

    // 如果有可用的动作，添加工具定义
    if (request.actions && request.actions.length > 0) {
      openaiRequest.tools = request.actions.map(action => ({
        type: ToolType.FUNCTION,
        function: {
          name: action.name,
          description: action.description,
          parameters: JSON.parse(action.jsonSchema)
        }
      } as OpenAITool));

      // 设置工具选择策略
      if (request.forwardedParameters?.toolChoice) {
        if (request.forwardedParameters.toolChoice === 'auto' ||
          request.forwardedParameters.toolChoice === 'none' ||
          request.forwardedParameters.toolChoice === 'required') {
          openaiRequest.tool_choice = request.forwardedParameters.toolChoice;
        } else if (request.forwardedParameters.toolChoiceFunctionName) {
          openaiRequest.tool_choice = {
            type: ToolType.FUNCTION,
            function: { name: request.forwardedParameters.toolChoiceFunctionName }
          };
        }
      }
    }

    return openaiRequest;
  }

  /**
   * 转换 OpenAI 响应到 CopilotResponse
   */
  private convertToCopilotResponse(openaiResponse: ChatCompletion): CopilotResponse {
    const messages: Message[] = [];

    for (const choice of openaiResponse.choices) {
      const message = choice.message;

      if (message.content || message.reasoning_content) {
        // 文本消息
        const textMessage = new TextMessage({
          role: MessageRole.ASSISTANT,
          content: message.content ?? '',
          thinkingContent: this.thinkingEnabled ? (message.reasoning_content ?? '') : undefined,
          id: openaiResponse.id,
        });
        messages.push(textMessage);
      }

      if (message.tool_calls && message.tool_calls.length > 0) {
        // 工具调用消息
        for (const toolCall of message.tool_calls) {
          const actionMessage = new ActionExecutionMessage({
            name: toolCall.function.name,
            args: JSON.parse(toolCall.function.arguments),
            id: toolCall.id,
            callId: toolCall.id,
          });
          messages.push(actionMessage);
        }
      }
    }

    return { messages };
  }

  /**
   * 将消息列表中所有未完成的消息标记为失败
   */
  private markMessagesFailed(messages: Message[], errorReason: string): void {
    messages.forEach(message => {
      if (message.status.code === MessageStatusCode.Pending) {
        message.status = { code: MessageStatusCode.Failed, reason: errorReason };
      }
    });
  }

  /**
   * 处理流式响应块
   */
  private processStreamChunk(chunk: ChatCompletionChunk, streamMessages: Message[]): Message[] {
    const updatedMessages: Message[] = [...streamMessages];

    // 防御性检查：确保chunk有choices数组
    if (!chunk.choices || !Array.isArray(chunk.choices) || chunk.choices.length === 0) {
      console.warn('Received chunk without valid choices array:', JSON.stringify(chunk));
      return updatedMessages;
    }

    for (const choice of chunk.choices) {
      const delta = choice.delta;
      const finishReason = choice.finish_reason;

      // 处理文本消息
      if (delta.content !== null &&
        delta.content !== undefined ||
        delta.reasoning_content !== null &&
          delta.reasoning_content !== undefined) {
        const messageId = `${chunk.id}_text_${choice.index}`;
        let textMessage = updatedMessages.find(msg => msg.id === messageId) as TextMessage;

        if (!textMessage) {
          // 创建新的文本消息
          textMessage = new TextMessage({
            role: MessageRole.ASSISTANT,
            content: delta.content ?? '',
            thinkingContent: this.thinkingEnabled ? (delta.reasoning_content ?? '') : undefined,
            id: messageId,
            status: { code: MessageStatusCode.Pending }
          });
          updatedMessages.push(textMessage);
        } else {
          // 累积内容到现有消息
          if (delta.content) {
            textMessage.content += delta.content;
          }
          // 累积思考内容到现有消息
          if (this.thinkingEnabled && delta.reasoning_content) {
            textMessage.thinkingContent = (textMessage.thinkingContent ?? '') + delta.reasoning_content;
          }
        }
      }

      // 处理工具调用
      if (delta.tool_calls && delta.tool_calls.length > 0) {
        for (const toolCall of delta.tool_calls) {
          if (toolCall.function) {
            const messageId = `${chunk.id}_tool_${choice.index}_${toolCall.index}`;
            let actionMessage = updatedMessages.find(msg => msg.id === messageId) as ActionExecutionMessage;

            if (!actionMessage) {
              // 创建新的动作执行消息
              actionMessage = new ActionExecutionMessage({
                name: toolCall.function.name || '',
                args: {},
                argumentsDelta: toolCall.function.arguments || '',
                id: messageId,
                callId: toolCall.id || '',
                status: { code: MessageStatusCode.Pending }
              });
              updatedMessages.push(actionMessage);
            } else {
              // 累积参数到现有消息
              if (toolCall.function.name) {
                actionMessage.name = toolCall.function.name;
              }
              if (toolCall.function.arguments) {
                actionMessage.argumentsDelta += toolCall.function.arguments;
              }
            }
          }
        }
      }

      // 当收到finish_reason时，统一更新所有相关消息的状态
      if (finishReason) {
        // 获取与当前choice相关的所有待处理消息
        const pendingMessages = updatedMessages.filter(msg =>
        (msg.id.startsWith(`${chunk.id}_text_${choice.index}`) ||
        msg.id.startsWith(`${chunk.id}_tool_${choice.index}`)) &&
          msg.status.code === MessageStatusCode.Pending
        );

        // 统一更新消息状态
        const newStatus = this.getMessageStatusFromFinishReason(finishReason);
        for (const message of pendingMessages) {
          message.status = newStatus;

          // 如果是工具调用完成，需要特殊处理参数解析
          if (finishReason === FinishReason.TOOL_CALLS && message.isActionExecutionMessage()) {
            const actionMessage = message as ActionExecutionMessage;
            if (actionMessage.argumentsDelta) {
              try {
                actionMessage.args = JSON.parse(actionMessage.argumentsDelta);
              } catch (e) {
                // 如果解析失败，保持字符串格式
                console.warn(`Failed to parse tool call arguments: ${actionMessage.argumentsDelta}`);
              }
            }
          }
        }
      }
    }

    return updatedMessages;
  }

  /**
   * 根据完成原因获取消息状态
   */
  private getMessageStatusFromFinishReason(finishReason: string): MessageStatus {
    switch (finishReason) {
      case FinishReason.STOP:
      case FinishReason.TOOL_CALLS:
      case FinishReason.FUNCTION_CALL:
        return { code: MessageStatusCode.Success };
      case FinishReason.LENGTH:
        return { code: MessageStatusCode.Failed, reason: '达到最大token限制' };
      case FinishReason.CONTENT_FILTER:
        return { code: MessageStatusCode.Failed, reason: '内容被过滤器阻止' };
      default:
        return { code: MessageStatusCode.Failed, reason: `未知完成原因: ${finishReason}` };
    }
  }

  /**
   * 转换消息角色到 OpenAI 角色
   */
  private convertToOpenAIRole(role: MessageRole): OpenAIMessageRole {
    switch (role) {
      case MessageRole.SYSTEM:
        return OpenAIMessageRole.SYSTEM;
      case MessageRole.USER:
        return OpenAIMessageRole.USER;
      case MessageRole.ASSISTANT:
        return OpenAIMessageRole.ASSISTANT;
      case MessageRole.TOOL:
        return OpenAIMessageRole.TOOL;
      default:
        return OpenAIMessageRole.USER;
    }
  }
}