import {
  ActionExecutionMessage,
  ImageMessage,
  Message,
  MessageRole,
  MessageStatus,
  MessageType,
  ResultMessage,
  TextMessage
} from '../model/Messages';

interface MessageJson {
  id: string;
  type: MessageType;
  createdAt: number;
  status: MessageStatus;
  parentMessageId?: string;

  // TextMessage 和 ImageMessage 的字段
  role?: MessageRole;

  // TextMessage 的字段
  content?: string;
  thinkingContent?: string;

  // ImageMessage 的字段
  format?: string;
  bytes?: string;

  // ActionExecutionMessage 的字段
  name?: string;
  args?: Record<string, ESObject>;
  callId?: string;
  argumentsDelta?: string;

  // ResultMessage 的字段
  result?: ESObject;
  actionCallId?: string;
  actionName?: string;
}

// 将消息数组序列化为JSON字符串
export function messagesToJson(messages: Message[]): string {
  try {
    const serializableMessages = messages?.map((message): MessageJson => {
      const jsonObject: MessageJson = {
        id: message.id,
        type: message.type,
        createdAt: message.createdAt,
        status: message.status,
      };
      if (message instanceof TextMessage) {
        jsonObject.role = message.role;
        jsonObject.content = message.content;
        jsonObject.thinkingContent = message.thinkingContent;
        jsonObject.parentMessageId = message.parentMessageId;
      } else if (message instanceof ImageMessage) {
        jsonObject.role = message.role;
        jsonObject.format = message.format;
        jsonObject.bytes = message.bytes;
        jsonObject.parentMessageId = message.parentMessageId;
      } else if (message instanceof ActionExecutionMessage) {
        jsonObject.name = message.name;
        jsonObject.args = message.args;
        jsonObject.callId = message.callId;
        jsonObject.argumentsDelta = message.argumentsDelta;
        jsonObject.parentMessageId = message.parentMessageId;
      } else if (message instanceof ResultMessage) {
        jsonObject.result = message.result;
        jsonObject.actionCallId = message.actionCallId;
        jsonObject.actionName = message.actionName;
        jsonObject.parentMessageId = message.parentMessageId;
      }
      return jsonObject;
    });
    return JSON.stringify(serializableMessages);
  } catch (error) {
    console.error('序列化消息失败:', error);
    return '[]';
  }
}

// 从JSON字符串反序列化消息数组
export function jsonToMessages(jsonStr: string): Message[] {
  try {
    const messageData = JSON.parse(jsonStr) as MessageJson[];
    if (!Array.isArray(messageData)) {
      return [];
    }

    return messageData.map(data => {
      switch (data.type) {
        case MessageType.TextMessage:
          return new TextMessage({
            role: data.role!,
            content: data.content!,
            thinkingContent: data.thinkingContent,
            id: data.id,
            status: data.status,
            createdAt: data.createdAt,
            parentMessageId: data.parentMessageId
          });

        case MessageType.ImageMessage:
          return new ImageMessage({
            role: data.role!,
            format: data.format!,
            bytes: data.bytes!,
            id: data.id,
            status: data.status,
            createdAt: data.createdAt,
            parentMessageId: data.parentMessageId
          });

        case MessageType.ActionExecutionMessage:
          return new ActionExecutionMessage({
            name: data.name!,
            args: data.args!,
            argumentsDelta: data.argumentsDelta,
            id: data.id,
            callId: data.callId!,
            status: data.status,
            createdAt: data.createdAt,
            parentMessageId: data.parentMessageId
          });

        case MessageType.ResultMessage:
          return new ResultMessage({
            result: data.result,
            actionCallId: data.actionCallId!,
            actionName: data.actionName!,
            id: data.id,
            status: data.status,
            createdAt: data.createdAt,
            parentMessageId: data.parentMessageId
          });

        default:
          console.warn(`未知的消息类型: ${data.type}`);
          return null;
      }
    }).filter(message => message !== null) as Message[];
  } catch (error) {
    console.error('反序列化消息失败:', error);
    return [];
  }
}