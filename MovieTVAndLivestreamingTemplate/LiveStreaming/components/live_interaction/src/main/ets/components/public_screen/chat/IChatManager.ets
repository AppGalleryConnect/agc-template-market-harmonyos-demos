import { BaseChatMessage } from './BaseChatMesage';

export interface IChatManager {
  updateChatView(bufferList: BaseChatMessage[]): void;
  isAtBottom(): boolean;
  runToBottom(): void;
  showNewsView(): void;
  hideNewsView(): void;
  removeOverItems(): void;
  getDataSize(): number;
}