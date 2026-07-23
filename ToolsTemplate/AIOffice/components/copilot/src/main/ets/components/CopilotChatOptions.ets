
export interface CopilotChatOptions {
  labels?: CopilotChatLabels;
  icons?:CopilotChatIcons;
  isShowDefaultActionCard?:boolean;
}

export interface CopilotChatLabels {
  introduce?: string;
  initial?: string;
  suggestions?: string[];
  placeholder?: string;
  thinkingLabel?: string;
}

export interface CopilotChatIcons {
  assistant?: Resource;
  assistantChatIcon?: Resource;
}