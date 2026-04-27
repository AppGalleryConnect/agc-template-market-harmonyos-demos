import { AppStorageV2 } from '@kit.ArkUI';
import { ChatMockService } from '../mocks/ChatMockService';
import { BaseChatService } from '../models/BaseChatModel';
import {
  MessageHistoryModel,
  MessageModel,
  MessageStatus,
  MessageType,
  SenderType,
} from '../models/MessageModel';
import { ChatWebSocketService } from '../services/ChatWebSocketService';

@ObservedV2
export class ChatVM {
  @Trace
  messageList: MessageModel[] = [];
  @Trace
  inputText: string = '';
  @Trace
  showImagePicker: boolean = false;
  currentService: BaseChatService;
  scrollController: Scroller = new Scroller();

  constructor(useMock: boolean) {
    this.currentService = useMock
      ? new ChatMockService()
      : new ChatWebSocketService();
  }

  // 初始化服务
  initializeService() {
    // 清除之前的回调
    this.messageList = [];
    this.currentService.disconnect();

    // 注册回调
    this.currentService.onMessageReceived((message: MessageModel) => {
      this.messageList.push(message);
      this.scrollToBottom();
    });

    // 连接服务
    this.currentService.connect();
    this.loadHistoryMessage();
  }

  // 发送文本消息
  sendTextMessage() {
    if (this.inputText.trim() === '') {
      return;
    }

    const userMessage = new MessageModel(
      this.inputText,
      MessageType.TEXT,
      SenderType.USER,
    );

    // 先添加到列表（乐观更新）
    this.messageList.push(userMessage);
    this.scrollToBottom();

    // 发送到服务
    this.currentService
      .sendMessage(this.inputText, MessageType.TEXT)
      .then((success: ESObject) => {
        if (!success) {
          // 发送失败，更新状态
          userMessage.status = MessageStatus.FAILED;
          this.messageList = [...this.messageList];
        }
      });

    // 清空输入框
    this.inputText = '';
  }

  // 滚动到底部
  scrollToBottom() {
    setTimeout(() => {
      this.scrollController.scrollEdge(Edge.Bottom);
    }, 100);
  }

  // 重新连接
  reconnect() {
    this.currentService.disconnect();
    this.initializeService();
  }

  loadHistoryMessage() {
    const history = AppStorageV2.connect(
      MessageHistoryModel,
      () => new MessageHistoryModel(),
    )!;
    if (history.list.length) {
      this.messageList.push(...history.list);
    }
  }

  // 存储本次聊天记录
  saveMessage() {
    const history = AppStorageV2.connect(
      MessageHistoryModel,
      () => new MessageHistoryModel(),
    )!;
    if (this.messageList.length > 1) {
      history.list.push(...this.messageList);
    }
  }
}
