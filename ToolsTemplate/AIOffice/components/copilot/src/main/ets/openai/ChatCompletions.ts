/**
 * OpenAI Chat Completions API 接口定义
 * 基于 https://platform.openai.com/docs/api-reference/chat/create
 */

/**
 * 消息角色枚举
 */
export enum MessageRole {
  SYSTEM = "system",
  USER = "user", 
  ASSISTANT = "assistant",
  TOOL = "tool"
}

/**
 * 完成原因枚举
 */
export enum FinishReason {
  STOP = "stop",
  LENGTH = "length",
  TOOL_CALLS = "tool_calls",
  CONTENT_FILTER = "content_filter",
  FUNCTION_CALL = "function_call"
}

/**
 * 工具类型枚举
 */
export enum ToolType {
  FUNCTION = "function"
}

/**
 * 函数参数定义
 * 基于 JSON Schema 规范
 */
export interface FunctionParameters {
  type: string;
  properties: Record<string, any>;
  required?: string[];
  additionalProperties?: boolean;
  description?: string;
}

/**
 * 函数定义
 */
export interface FunctionDefinition {
  name: string;
  description?: string;
  parameters: FunctionParameters;
}

/**
 * 工具定义
 */
export interface Tool {
  type: ToolType;
  function: FunctionDefinition;
}

/**
 * 工具调用
 */
export interface ToolCall {
  id: string;
  type: ToolType;
  function: {
    name: string;
    arguments: string;
  };
}

/**
 * 消息内容
 */
export interface Message {
  role: MessageRole;
  content: ContentType;
  name?: NameType;
  tool_calls?: ToolCall[];
  tool_call_id?: string;
  refusal?: ContentType;
}

/**
 * 响应格式类型
 */
export interface ResponseFormat {
  type: ResponseFormatType;
  json_schema?: {
    name?: string;
    description?: string;
    schema?: Record<string, any>;
    strict?: boolean;
  };
}

/**
 * Chat Completions 创建参数基础接口
 */
export interface ChatCompletionCreateParams {
  /** 要使用的模型ID */
  model: string;
  
  /** 生成聊天完成的消息列表 */
  messages: Message[];

  /** 是否流式传输部分消息增量 */
  stream?: boolean;

  /** 使用什么采样温度，介于0和2之间 */
  temperature?: number;
  
  /** 核采样的替代方案，介于0和1之间 */
  top_p?: number;
  
  /** 为每个输入消息生成多少个聊天完成选择 */
  n?: number;
  
  /** 最多4个序列，API将停止生成进一步的标记 */
  stop?: StopSequence;
  
  /** 在聊天完成中生成的最大标记数 */
  max_tokens?: number;
  
  /** 介于-2.0和2.0之间的数字 */
  presence_penalty?: number;
  
  /** 介于-2.0和2.0之间的数字 */
  frequency_penalty?: number;
  
  /** 修改指定标记出现在完成中的可能性 */
  logit_bias?: LogitBias;
  
  /** 代表您的最终用户的唯一标识符 */
  user?: UserIdentifier;
  
  /** 模型可以调用的工具列表 */
  tools?: Tool[];
  
  /** 控制模型调用哪个（如果有）工具 */
  tool_choice?: ToolChoiceType;
  
  /** 指定模型必须输出的格式 */
  response_format?: ResponseFormat;
  
  /** 此功能处于测试阶段 */
  seed?: number;
  
  /** 是否并行处理工具调用 */
  parallel_tool_calls?: boolean;
}

/**
 * 使用统计信息
 */
export interface Usage {
  /** 提示标记数 */
  prompt_tokens: number;
  
  /** 完成标记数 */
  completion_tokens: number;
  
  /** 总标记数 */
  total_tokens: number;
  
  /** 完成标记详情 */
  completion_tokens_details?: {
    reasoning_tokens?: number;
  };
  
  /** 提示标记详情 */
  prompt_tokens_details?: {
    cached_tokens?: number;
  };
}

/**
 * 聊天完成选择
 */
export interface ChatCompletionChoice {
  /** 选择的索引 */
  index: number;
  
  /** 生成的消息 */
  message: ChatCompletionMessage;
  
  /** 模型停止生成标记的原因 */
  finish_reason: FinishReason | null;
  
  /** 选择的对数概率信息 */
  logprobs?: ChatCompletionTokenLogprob | null;
}

/**
 * 聊天完成消息
 */
export interface ChatCompletionMessage {
  /** 消息的内容 */
  content: ContentType;
  
  /** 消息的角色 */
  role: 'assistant';
  
  /** 工具调用列表 */
  tool_calls?: ChatCompletionMessageToolCall[];

  /** 拒绝内容 */
  refusal?: ContentType;

  /** 思考内容（DeepSeek 等模型） */
  reasoning_content?: ContentType;
}

/**
 * 聊天完成消息工具调用
 */
export interface ChatCompletionMessageToolCall {
  /** 工具调用的ID */
  id: string;
  
  /** 工具的类型 */
  type: 'function';
  
  /** 函数调用详情 */
  function: ChatCompletionMessageToolCall.Function;
}

export namespace ChatCompletionMessageToolCall {
  export interface Function {
    /** 函数参数 */
    arguments: string;
    
    /** 函数名称 */
    name: string;
  }
}

/**
 * Token对数概率信息
 */
export interface ChatCompletionTokenLogprob {
  /** Token列表 */
  content: Array<ChatCompletionTokenLogprob.Content> | null;
}

export namespace ChatCompletionTokenLogprob {
  export interface Content {
    /** Token字符串 */
    token: string;
    
    /** Token的对数概率 */
    logprob: number;
    
    /** Token的字节表示 */
    bytes: Array<number> | null;
    
    /** 前N个候选Token */
    top_logprobs: Array<TopLogprob>;
  }
  
  export interface TopLogprob {
    /** Token字符串 */
    token: string;
    
    /** Token的对数概率 */
    logprob: number;
    
    /** Token的字节表示 */
    bytes: Array<number> | null;
  }
}

/**
 * Chat Completions 响应
 */
export interface ChatCompletion {
  /** 唯一标识符 */
  id: string;
  
  /** 对象类型，始终为"chat.completion" */
  object: 'chat.completion';
  
  /** Unix时间戳（秒） */
  created: number;
  
  /** 使用的模型 */
  model: string;
  
  /** 聊天完成选择列表 */
  choices: ChatCompletionChoice[];
  
  /** 完成请求的使用统计信息 */
  usage?: Usage;

  /** 此指纹表示模型运行时使用的后端配置 */
  system_fingerprint?: SystemFingerprint;
}

/**
 * 流式响应的选择
 */
export interface ChatCompletionStreamChoice {
  index: number;
  delta: ChatCompletionStreamChoiceDelta;
  finish_reason: FinishReason | null;
  logprobs?: ChatCompletionTokenLogprob | null;
}

/**
 * 流式响应的增量消息
 */
export interface ChatCompletionStreamChoiceDelta {
  /** 消息内容的增量 */
  content?: ContentType;
  
  /** 消息角色（仅在第一个块中出现） */
  role?: 'assistant';
  
  /** 工具调用的增量 */
  tool_calls?: Array<ChatCompletionStreamChoiceDeltaToolCall>;

  /** 拒绝内容的增量 */
  refusal?: ContentType;

  /** 思考内容的增量（DeepSeek 等模型） */
  reasoning_content?: ContentType;
}

/**
 * 流式工具调用增量
 */
export interface ChatCompletionStreamChoiceDeltaToolCall {
  index: number;
  id?: string;
  type?: 'function';
  function?: ChatCompletionStreamChoiceDeltaToolCall.Function;
}

export namespace ChatCompletionStreamChoiceDeltaToolCall {
  export interface Function {
    arguments?: string;
    name?: string;
  }
}

/**
 * Chat Completions 流式响应块
 */
export interface ChatCompletionChunk {
  id: string;
  object: 'chat.completion.chunk';
  created: number;
  model: string;
  choices: ChatCompletionStreamChoice[];
  system_fingerprint?: SystemFingerprint;
  usage?: Usage;
}

/**
 * API错误响应
 */
export interface OpenAIError {
  error: {
    message: string;
    type: string;
    param?: string | null;
    code?: string | null;
  };
}

/**
 * 严格类型定义：所有可能的对象类型
 */
export type ObjectType = 'chat.completion' | 'chat.completion.chunk';

/**
 * 严格类型定义：工具选择类型
 */
export type ToolChoiceType = "none" | "auto" | "required" | { type: ToolType; function: { name: string } };

/**
 * 严格类型定义：响应格式类型联合
 */
export type ResponseFormatType = "text" | "json_object" | "json_schema";

/**
 * 严格类型定义：停止序列
 */
export type StopSequence = string | string[] | null;

/**
 * 严格类型定义：logit偏置
 */
export type LogitBias = Record<string, number> | null;

/**
 * 严格类型定义：用户标识符
 */
export type UserIdentifier = string | null;

/**
 * 严格类型定义：内容类型
 */
export type ContentType = string | null;

/**
 * 严格类型定义：名称字段
 */
export type NameType = string | undefined;

/**
 * 严格类型定义：系统指纹
 */
export type SystemFingerprint = string | undefined;
