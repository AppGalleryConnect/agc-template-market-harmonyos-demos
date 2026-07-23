import { CopilotContext } from './CopilotContext';
import { CopilotClient, CopilotResponse } from '../client/CopilotClient';
import {
  ActionExecutionMessage,
  Message,
  MessageRole,
  MessageStatusCode,
  ResultMessage,
  TextMessage
} from '../model/Messages';
import { FrontendAction, processActionsForRuntimeRequest } from '../model/FrontendAction';
import { CopilotStore, StoreManager } from '../store/StoreManager';
import { OpenAIClient } from '../client/OpenAIClient';
import { CopilotControllerOptions } from './CopilotControllerOptions';
import { Subscription } from 'rxjs';
import { generateTitle } from '../utils/GenerateTitle';

interface PendingAppendsMsg {
  message: Message,
  followUp: boolean
}

export class CopilotController {
  options: CopilotControllerOptions;
  context: CopilotContext;
  latestCallback?: (content: string) => void;
  private store: CopilotStore;
  private client: CopilotClient;
  private currentStreamSubscription?: Subscription;
  private pendingAppendsMessage: PendingAppendsMsg[] = []

  constructor(options: CopilotControllerOptions) {
    this.options = options;
    this.context = new CopilotContext(options);
    if (options.llm) {
      this.client = new OpenAIClient(options.llm);
    } else {
      throw new Error('must config `llm` or `agent` or `ag_ui`');
    }

    this.store = StoreManager.getStore(options.storeId);
    if (options.threadId) {
      this.store.loadMessages(options.threadId).then((store) => {
        this.context.title = store.title;
        this.context.createTime = store.createTime;
        this.context.visibleMessages = store.messages ?? [];
      })
    }
  }

  reset() {
    this.currentStreamSubscription?.unsubscribe();
    this.context.reset();
  }

  retry(message: TextMessage) {
    if (message.role === MessageRole.ASSISTANT) {
      let index = this.context.visibleMessages.findIndex((msg) => msg.id === message.id);
      if (index !== -1) {
        this.runChatCompletionAndHandleFunctionCall(this.context.visibleMessages.slice(0, index));
      }
    }
  }

  reload(threadId: string) {
    this.store.loadMessages(threadId).then((store) => {
      this.context.threadId = threadId;
      this.context.title = store.title;
      this.context.createTime = store.createTime;
      this.context.visibleMessages = store.messages ?? [];
    }).catch(() => {
      this.context.reset();
      this.context.threadId = threadId;
    })
  }

  registerAction(action: FrontendAction) {
    this.context.registerAction(action);
  }

  async addMessage(message: Message, followUp: boolean = true) {
    if (this.context.isLoading) {
      this.pendingAppendsMessage.push({
        message: message,
        followUp: followUp
      })
      return;
    }

    let newMessages: Message[] = [];
    let filterMessages = this.context.visibleMessages.filter((msg) => {
      return msg.id !== message.id;
    })
    newMessages = [...filterMessages, message];

    this.setMessages(newMessages);
    if (followUp) {
      await this.runChatCompletionAndHandleFunctionCall([...newMessages]);
    }
  }

  setMessages(messages: Message[]) {
    // 需要进一步过滤相同message时，不进行全量刷新
    let visibleLength = this.context.visibleMessages.length;
    if (visibleLength === 0 || messages.length === 0) {
      this.context.visibleMessages = messages;
    } else if (this.context.isLoading ||
      messages[messages.length - 1].id !== this.context.visibleMessages[visibleLength - 1].id) {
      this.context.visibleMessages = messages;
    }
  }

  /**
   * 取消当前正在进行的流式请求
   */
  cancel(): void {
    if (this.currentStreamSubscription) {
      this.currentStreamSubscription.unsubscribe();
      this.currentStreamSubscription = undefined;
    }
    this.context.isLoading = false;
    // 将所有处于 Pending 的流式消息标记为失败(取消)
    try {
      this.context.visibleMessages?.forEach((msg: Message) => {
        // 仅更新流生成的临时消息（通常为 Pending）
        if (msg.status && msg.status.code === MessageStatusCode.Pending) {
          msg.status = { code: MessageStatusCode.Failed, reason: '已取消' };
        }
      });
      this.setMessages(this.context.visibleMessages);
    } catch {
    }
  }

  /**
   * 执行指定的action
   */
  async executeAction<T>(actionMessage: ActionExecutionMessage) {
    const action = this.context.getAction(actionMessage.name);
    if (!action || actionMessage.status.code !== MessageStatusCode.Success) {
      return;
    }

    try {
      let result: ESObject;
      // 处理普通的handler类型Action
      if (action?.handler) {
        result = await action.handler(actionMessage.args);
      }
      // 创建ResultMessage
      const resultMessage = new ResultMessage({
        result: result,
        actionCallId: actionMessage.callId,
        actionName: actionMessage.name,
        parentMessageId: actionMessage.id
      });

      // 处理renderAndWaitForResponse类型的Action
      if (action?.renderAndWaitForResponse) {
        setTimeout(() => {
          this.addMessage(resultMessage, false);
        }, 20);
        // 为这种类型的Action创建一个Promise-based handler
        let actionResult: ESObject = await this.setupWaitForResponseAction(actionMessage, action);
        resultMessage.result = actionResult;
        setTimeout(() => {
          this.addMessage(resultMessage, true);
        }, 20);
      } else {
        setTimeout(() => {
          this.addMessage(resultMessage, action.followUp ?? true);
        }, 20);
      }

      // 如果需要follow up，则重新发送请求
      if (action.followUp ?? true) {

      }
    } catch (error) {
      console.error('执行action失败:', error);
    }
  }

  updateDataStore() {
    this.store.saveMessages({
      messages: this.context.visibleMessages,
      title: this.context.title,
      threadId: this.context.threadId,
      createTime: this.context.createTime
    });
  }

  private async runChatCompletionAndHandleFunctionCall(previousMessage: Message[]) {
    this.context.isLoading = true;

    let newMessages: Message[] = [];

    //可以触发assistant消息渲染
    newMessages.push(new TextMessage({
      content: '',
      role: MessageRole.ASSISTANT
    }));
    this.setMessages([...previousMessage, ...newMessages]);

    let systemMessage: Message | undefined;
    if (this.options.systemPrompt) {
      systemMessage = new TextMessage({
        role: MessageRole.SYSTEM,
        content: (typeof this.options.systemPrompt === 'string' ? this.options.systemPrompt :
          this.options.systemPrompt()),
      })
    }

    let messagesWithContext: Message[] = [];
    messagesWithContext = systemMessage ? [systemMessage, ...previousMessage] : [...previousMessage];

    let stream$ = this.client.stream({
      messages: messagesWithContext,
      actions: processActionsForRuntimeRequest(this.context.getAvailableActions())
    });
    // 取消已有流订阅
    this.currentStreamSubscription?.unsubscribe();
    this.currentStreamSubscription = stream$.subscribe({
      next: async (response: CopilotResponse) => {
        newMessages = []

        if (this.latestCallback) {
          let lastMessage = response.messages[response.messages.length - 1];
          if (lastMessage.isTextMessage()) {
            this.latestCallback((lastMessage as TextMessage).content);
          }
        }

        // 处理响应中的action执行消息
        const processedMessages = await this.processActionMessages(response.messages);

        this.setMessages([...previousMessage, ...processedMessages]);
      },
      error: (error: Error) => {
        this.context.isLoading = false;
        this.currentStreamSubscription = undefined;
      },
      complete: () => {
        this.context.isLoading = false;
        this.currentStreamSubscription = undefined;

        if (!this.context.title) {
          generateTitle(this.context.threadId, this.context.visibleMessages, new OpenAIClient(this.options.llm))
            .then((response) => {
              if (this.context.threadId === response.threadId) {
                this.context.title = response.content;
                this.updateDataStore();
              }
            });
          // fallback 使用默认用户问题
          this.context.title = (this.context.visibleMessages.find((message) => {
            return message.isTextMessage() && (message as TextMessage).role === MessageRole.USER
          }) as TextMessage).content;
        }
        this.updateDataStore();
      }
    });
  }

  /**
   * 处理响应中的action消息，执行相应的handler和render回调
   */
  private async processActionMessages(messages: Message[]): Promise<Message[]> {
    const processedMessages: Message[] = [];

    for (const message of messages) {
      processedMessages.push(message);

      // 如果是action执行消息，需要执行对应的handler
      if (message.isActionExecutionMessage()) {
        const actionMessage = message as ActionExecutionMessage;

        // 执行action handler（异步执行，不等待结果）
        this.executeAction<ESObject>(actionMessage);
      }
    }

    return processedMessages;
  }

  /**
   * 设置等待响应类型的Action
   */
  private async setupWaitForResponseAction(
    actionMessage: ActionExecutionMessage,
    action: FrontendAction
  ): Promise<ESObject> {
    // 创建一个Promise来等待用户响应
    return new Promise<ESObject>((resolve, reject) => {
      actionMessage._waitPromiseResolve = resolve;
      actionMessage._waitPromiseReject = reject;
    });
  }
}