import { CopilotController } from '../controller/CopilotController';
import { MessageRole, TextMessage } from '../model/Messages';
import { CopilotChatOptions } from './CopilotChatOptions';
import { EmptyHolderComponent } from './EmptyHolderComponent';
import { InputComponents } from './InputComponent';
import { MessagesComponents } from './MessagesComponent';
import { pasteboard } from '@kit.BasicServicesKit';

@ComponentV2
export struct CopilotChat {
  @Param @Require controller: CopilotController;
  @Param options: CopilotChatOptions = {};
  @BuilderParam markdownRender?: (message: TextMessage) => void;
  scroller: Scroller = new Scroller();

  build() {
    Column() {
      Column() {
        if (this.controller.context.visibleMessages.length === 0) {
          EmptyHolderComponent({
            options: this.options,
            onSuggestionClick: (suggestion: string) => {
              const message = new TextMessage({
                role: MessageRole.USER,
                content: suggestion
              });
              this.controller.addMessage(message);
            }
          }).expandSafeArea([SafeAreaType.KEYBOARD])
            .padding({ left: 16, right: 16 })
        } else {
          MessagesComponents({
            context: this.controller.context,
            options: this.options,
            markdownRender: this.markdownRender,
            scroller: this.scroller,
            onCopy: (message: TextMessage) => {
              this.copyToClipboard(message.content);
            },
            onRetry: (message: TextMessage) => {
              this.controller.retry(message);
            }
          }).expandSafeArea([SafeAreaType.KEYBOARD])
        }
      }.layoutWeight(1)

      InputComponents({
        isProgress: this.controller.context.isLoading,
        options: this.options,
        scroller: this.scroller,
        onSend: async (input: string) => {
          const message = new TextMessage({
            role: MessageRole.USER,
            content: input
          });
          await this.controller.addMessage(message);
          this.scroller.scrollEdge(Edge.Bottom);
        },
        onStop: () => {
          this.controller.cancel();
        }
      }).backgroundColor($r('sys.color.background_primary'))
        .padding({ top: 8, left: 16, right: 16, bottom: 16 })
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .width('100%')
    .height('100%')
  }

  private async copyToClipboard(content: string): Promise<void> {
    try {
      const pasteboardData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, content);
      const systemPasteboard = pasteboard.getSystemPasteboard();
      await systemPasteboard.setData(pasteboardData);

      this.getUIContext().getPromptAction().showToast({
        message: '已复制到剪贴板',
        duration: 2000
      });
    } catch (error) {
      console.error('复制失败:', error);
      this.getUIContext().getPromptAction().showToast({
        message: '复制失败',
        duration: 2000
      });
    }
  }
}
