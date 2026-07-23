import { MessageRole, TextMessage } from '../../model/Messages';
import { CopilotChatOptions } from '../CopilotChatOptions';
import { AssistantMessageCard } from './AssistantMessageCard';
import { UserMessageCard } from './UserMessageCard';


@ComponentV2
export struct RenderTextMessage {
  @Param options: CopilotChatOptions = {};
  @Param @Require message: TextMessage;
  @Param isLoading: boolean = false;
  @Param isLast: boolean = false;
  @BuilderParam markdownRender?: (message: TextMessage) => void;

  // 按钮事件回调
  @Event onCopy?: () => void = undefined;
  @Event onRetry?: () => void = undefined;
  @Event onLastVisibleAreaApproximateChange?: (isExpanding: boolean, currentRatio: number) => void = undefined;

  build() {
    if (this.message.role === MessageRole.USER) {
      UserMessageCard({
        options: this.options,
        content: this.message.content
      })
    } else if (this.message.role === MessageRole.ASSISTANT) {
      AssistantMessageCard({
        options: this.options,
        message: this.message,
        isLast: this.isLast,
        isLoading: this.isLoading,
        markdownRender: this.markdownRender,
        onCopy: this.onCopy,
        onRetry: this.onRetry,
        onLastVisibleAreaApproximateChange: this.onLastVisibleAreaApproximateChange
      })
    }
  }
}