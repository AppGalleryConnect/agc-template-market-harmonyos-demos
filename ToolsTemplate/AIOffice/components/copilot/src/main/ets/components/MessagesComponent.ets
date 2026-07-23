import { CopilotContext } from '../controller/CopilotContext'
import { ActionExecutionMessage, ImageMessage, Message, ResultMessage, TextMessage } from '../model/Messages'
import { CopilotChatOptions } from './CopilotChatOptions'
import { RenderActionExecutionMessage } from './messages/RenderActionExecutionMessage'
import { RenderImageMessage } from './messages/RenderImageMessage'
import { RenderTextMessage } from './messages/RenderTextMessage'

@ComponentV2
export struct MessagesComponents {
  @Param @Require context: CopilotContext
  @Param options: CopilotChatOptions = {};
  @BuilderParam markdownRender?: (message: TextMessage) => void;
  // 按钮事件回调
  @Event onCopy?: (message: TextMessage) => void;
  @Event onRetry?: (message: TextMessage) => void;
  @Event onLike?: (message: TextMessage) => void;
  @Event onDislike?: (message: TextMessage) => void;
  @Local showToBottomButton: boolean = false;
  @Param scroller: Scroller = new Scroller();

  build() {
    RelativeContainer() {
      List({ scroller: this.scroller }) {
        ForEach(this.context.visibleMessages, (item: Message, index: number) => {
          if (item.isTextMessage()) {
            RenderTextMessage({
              options: this.options,
              message: item as TextMessage,
              isLast: index === this.context.visibleMessages.length - 1,
              isLoading: this.context.isLoading && index === this.context.visibleMessages.length - 1,
              markdownRender: this.markdownRender,
              onCopy: () => {
                this.onCopy?.(item as TextMessage);
              },
              onRetry: () => {
                this.onRetry?.(item as TextMessage);
              },
              onLastVisibleAreaApproximateChange:(isExpanding: boolean, currentRatio: number) => {
                if (this.context.isLoading && !isExpanding && currentRatio >= 0) {
                  this.scroller.scrollEdge(Edge.Bottom);
                }
              }
            }).padding({ left: 16, right: 16 })
          } else if (item.isImageMessage()) {
            RenderImageMessage({
              options: this.options,
              message: item as ImageMessage
            }).padding({ left: 16, right: 16 })
          } else if (item.isActionExecutionMessage()) {
            RenderActionExecutionMessage({
              options: this.options,
              message: item as ActionExecutionMessage,
              context: this.context,
              isCurrentMessage: index === this.context.visibleMessages.length - 1,
              inProgress: this.context.isLoading && index === this.context.visibleMessages.length - 1,
              result: this.getResultMessage(item as ActionExecutionMessage)?.result
            }).padding({ left: 16, right: 16 })
          }
        })
      }
      .onScrollStop(() => {
        if (!this.scroller.isAtEnd()) {
          this.showToBottomButton = true;
        }
      })
      .onReachEnd(() => {
        this.showToBottomButton = false;
      })
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
      .onAppear(() => {
        setTimeout(() => {
          this.scroller.scrollEdge(Edge.Bottom);
        }, 100);
      })
      .width('100%')
      .height('100%')

      SymbolGlyph($r('sys.symbol.chevron_down'))
        .fontSize($r('sys.float.Title_M'))
        .fontColor([$r('sys.color.icon_primary')])
        .padding(8)
        .borderRadius(40)
        .backgroundColor($r('sys.color.background_secondary'))
        .visibility(this.showToBottomButton ? Visibility.Visible : Visibility.Hidden)
        .onClick(() => {
          this.scroller.scrollEdge(Edge.Bottom);
          this.showToBottomButton = false;
        })
        .margin({
          right: 16,
          bottom: 50
        })
        .alignRules({
          end: { anchor: '__container__', align: HorizontalAlign.End },
          bottom: { anchor: '__container__', align: VerticalAlign.Bottom }
        })
    }
    .width('100%')
  }

  getResultMessage(message: ActionExecutionMessage): ResultMessage | undefined {
    return this.context.visibleMessages.find((msg) => {
      if (msg.isResultMessage()) {
        let resultMsg = msg as ResultMessage;
        if (resultMsg.actionCallId === message.callId) {
          return msg;
        }
      }
      return undefined;
    }) as ResultMessage;
  }
}