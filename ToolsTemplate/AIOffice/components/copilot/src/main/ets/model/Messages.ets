import { util } from '@kit.ArkTS';

// 基础枚举定义
export enum MessageRole {
  SYSTEM = 'system',
  USER = 'user',
  ASSISTANT = 'assistant',
  TOOL = 'tool',
}

export enum MessageStatusCode {
  Failed = 'Failed',
  Pending = 'Pending',
  Success = 'Success'
}

export interface MessageStatus {
  code: MessageStatusCode
  reason?: string
}

// 消息类型定义
export enum MessageType {
  TextMessage = 'TextMessage',
  ActionExecutionMessage = 'ActionExecutionMessage',
  ResultMessage = 'ResultMessage',
  ImageMessage = 'ImageMessage'
}

// 基础消息类
@ObservedV2
export abstract class Message {
  type: MessageType;
  id: string; //Response消息才有的字段
  createdAt: number; //Response消息才有的字段
  @Trace status: MessageStatus; //Response消息才有的字段

  constructor(type: MessageType, id?: string, status?: MessageStatus, createdAt?: number) {
    this.type = type;
    this.id = id ??  util.generateRandomUUID();
    this.status = status ?? { code: MessageStatusCode.Success };
    this.createdAt = createdAt ?? Date.now();
  }

  // 类型守卫函数
  isTextMessage(): boolean {
    return this.type === MessageType.TextMessage;
  }

  isActionExecutionMessage(): boolean {
    return this.type === MessageType.ActionExecutionMessage;
  }

  isResultMessage(): boolean {
    return this.type === MessageType.ResultMessage;
  }

  isImageMessage(): boolean {
    return this.type === MessageType.ImageMessage;
  }
}

export interface TextMessageParam {
  role: MessageRole;
  content: string;
  id?: string;
  status?: MessageStatus;
  createdAt?: number;
  parentMessageId?: string;
  thinkingContent?: string;
}

// 文本消息类
@ObservedV2
export class TextMessage extends Message {
  @Trace content: string;
  @Trace thinkingContent?: string;
  role: MessageRole;
  parentMessageId?: string;

  constructor(param:TextMessageParam) {
    super(MessageType.TextMessage, param.id, param.status, param.createdAt,);
    this.content = param.content ?? '';
    this.thinkingContent = param.thinkingContent;
    this.role = param.role;
    this.parentMessageId = param.parentMessageId;
  }
}

export interface ActionExecutionMessageParam {
  name: string,
  callId:string,
  args: Record<string, ESObject>,
  argumentsDelta?: string,
  id?: string,
  status?: MessageStatus,
  createdAt?: number,
  parentMessageId?: string,
}

// 动作执行消息类
@ObservedV2
export class ActionExecutionMessage extends Message {
  name: string;
  callId: string;
  args: Record<string, ESObject>;
  argumentsDelta?: string;
  parentMessageId?: string;

  _waitPromiseResolve?:ESObject;
  _waitPromiseReject?:ESObject;

  constructor(param : ActionExecutionMessageParam) {
    super(MessageType.ActionExecutionMessage, param.id, param.status, param.createdAt);
    this.name = param.name;
    this.args = param.args;
    this.callId = param.callId;
    this.argumentsDelta = param.argumentsDelta;
    this.parentMessageId = param.parentMessageId;
  }
}

export interface ResultMessageParam {
  result: ESObject;
  actionCallId: string;
  actionName: string;
  id?: string;
  status?: MessageStatus;
  createdAt?: number;
  parentMessageId?: string;
}

// 结果消息类
@ObservedV2
export class ResultMessage extends Message {
  @Trace result: ESObject;
  actionCallId: string;
  actionName: string;
  parentMessageId?: string;

  constructor(param: ResultMessageParam) {
    super(MessageType.ResultMessage, param.id, param.status, param.createdAt);
    this.result = param.result;
    this.actionCallId = param.actionCallId;
    this.actionName = param.actionName;
    this.parentMessageId = param.parentMessageId;
  }
}

export interface ImageMessageParam {
  role: MessageRole;
  format: string;
  bytes: string;
  id?: string;
  status?: MessageStatus;
  createdAt?: number;
  parentMessageId?: string;
}

// 图片消息类
@ObservedV2
export class ImageMessage extends Message {
  format: string;
  bytes: string;
  role: MessageRole;
  parentMessageId?: string;

  constructor(param: ImageMessageParam) {
    super(MessageType.ImageMessage, param.id, param.status, param.createdAt);
    this.format = param.format;
    this.bytes = param.bytes;
    this.role = param.role;
    this.parentMessageId = param.parentMessageId;
  }
}