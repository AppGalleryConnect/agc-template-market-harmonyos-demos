import { ForwardedParametersInput } from '../client/CopilotClient';

export interface LLMOptions {
  baseUrl: string;
  model: string;
  apiKey: string;
  headers?: Record<string, string>;
  forwardedParameters?: ForwardedParametersInput;
  thinkingEnabled?: boolean;
}

export interface AgentKitOptions {
  agentId: string;
}

export interface AgentUIProtocolOptions {
  baseUrl: string;
}

export interface CopilotControllerOptions {
  llm?: LLMOptions;
  agent?: AgentKitOptions;
  ag_ui?: AgentUIProtocolOptions;
  threadId?: string;
  title?: string;
  storeId?: string;
  systemPrompt?: string | (() => string);
}