export enum VoiceInputStatus {
  IDLE,
  LISTENING,
  PROCESSING  // 处理中（识别完成但还在处理结果）
}

export interface VoiceInputListener {
  onResult(text: string): void;
  onClose(): void;
}

/**
 * 语音识别结果数据
 */
export class VoiceRecognitionResult {
  // 最终确认的文本
  generatedText: string = '';
  // 中间过程文本
  progressText: string = '';
  // 是否为最终结果
  isFinal: boolean = false;
}
