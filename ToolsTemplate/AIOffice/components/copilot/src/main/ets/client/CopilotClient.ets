import { Observable } from 'rxjs';
import { Message } from '../model/Messages';

// 动作输入
export interface ActionInput {
  available?: 'disabled' | 'enabled';
  description: string;
  jsonSchema: string;
  name: string;
}

// 转发参数输入
export interface ForwardedParametersInput {
  maxTokens?: number;
  model?: string;
  stop?: string[];
  temperature?: number;
  toolChoice?: string;
  toolChoiceFunctionName?: string;
}

// 请求和响应类型
export interface CopilotRequest {
  messages: Message[];
  actions?: ActionInput[];
  runId?: string;
  threadId?: string;
  forwardedParameters?: ForwardedParametersInput;
}

export interface CopilotResponse {
  messages: Message[];
}

export abstract class CopilotClient {
  chat(request:CopilotRequest):Promise<CopilotResponse> {
    throw new Error('Method not implemented.');
  }

  stream(request:CopilotRequest):Observable<CopilotResponse> {
    throw new Error('Method not implemented.');
  }
}