import { Message, MessageStatusCode, TextMessage } from '../../model/Messages';
import { CopilotChatOptions } from '../CopilotChatOptions';

@ComponentV2
export struct AssistantMessageCard {
  @Param options: CopilotChatOptions = {};
  @Param @Require message: Message;
  @Param isLoading: boolean = false;
  @Param isLast: boolean = false;
  @BuilderParam markdownRender?: (message: TextMessage) => void;
  @BuilderParam subComponent?: () => void;
  // 按钮事件回调
  @Event onCopy?: () => void = undefined;
  @Event onRetry?: () => void = undefined;
  @Event onLastVisibleAreaApproximateChange?: (isExpanding: boolean, currentRatio: number) => void = undefined;

  @Local thinkingExpanded: boolean = false;

  build() {
    Row() {
      if (this.options.icons?.assistantChatIcon) {
        Image(this.options.icons.assistantChatIcon)
          .margin({ top: 8, right: 8 })
          .width(24)
          .height(24)
      }

      if (this.message.isTextMessage()) {
        if (this.isLoading &&
          (this.message as TextMessage).content.length === 0 &&
          (!(this.message as TextMessage).thinkingContent ||
            (this.message as TextMessage).thinkingContent!.length === 0)) {
          this.loadingBuilder()
        } else {
          this.contentBuilder()
        }
      } else if (this.message.isActionExecutionMessage()) {
        if (this.subComponent) {
          Column() {
            this.subComponent()
          }
          .borderRadius(6)
          .margin({ bottom: 8 })
        }
      }
    }
    .width('100%')
    .alignItems(VerticalAlign.Top)
    .justifyContent(FlexAlign.Start)
  }

  @Builder
  loadingBuilder() {
    Text('加载中...')
      .margin(8)
      .fontColor('#666666')
  }

  @Builder
  contentBuilder() {
    Column() {
      if (this.message.isTextMessage()) {
        if ((this.message as TextMessage).thinkingContent &&
          (this.message as TextMessage).thinkingContent!.length > 0) {
          this.thinkingBuilder((this.message as TextMessage), this.isLoading && this.isLast);
        }
      }

      Column() {
        if (this.markdownRender) {
          this.markdownRender((this.message as TextMessage))
        } else {
          Text((this.message as TextMessage).content)
        }
      }
      .bindContextMenu(this.MenuBuilder, ResponseType.LongPress, {
        hapticFeedbackMode: HapticFeedbackMode.ENABLED
      })
      .borderRadius(6)
      .backgroundColor('#2200000c')
      .margin({ bottom: this.isLoading && this.isLast ? 0 : 8 }) //如果是最后一个使用footer来控制
      .padding(8)

      if (this.isLoading && this.isLast) {
        this.footerBuilder()
      }

      // 操作按钮栏
      if (this.message.status.code !== MessageStatusCode.Pending && !this.isLoading && this.isLast) {
        this.actionButtonsBuilder()
      }
    }
    .layoutWeight(1)
    .height('auto')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  thinkingBuilder(textMessage: TextMessage, isStreaming: boolean = false) {
    Column() {
      Row({ space: 4 }) {
        SymbolGlyph($r('sys.symbol.lightbulb'))
          .fontSize(14)
          .fontColor([$r('sys.color.icon_tertiary')])
        Text(this.options.labels?.thinkingLabel || '思考过程')
          .fontSize(12)
          .fontColor($r('sys.color.font_tertiary'))
        Blank()
        if (this.isThinkingVisible(textMessage.content.length > 0)) {
          SymbolGlyph($r('sys.symbol.chevron_down'))
            .fontSize(12)
            .fontColor([$r('sys.color.icon_tertiary')])
        } else {
          SymbolGlyph($r('sys.symbol.chevron_right'))
            .fontSize(12)
            .fontColor([$r('sys.color.icon_tertiary')])
        }
      }
      .width('100%')
      .padding({ left: 8, right: 8, top: 6, bottom: 6 })
      .backgroundColor('#0a000000')
      .borderRadius({ topLeft: 6, topRight: 6 })
      .onClick(() => {
        this.thinkingExpanded = !this.thinkingExpanded;
      })

      if (this.isThinkingVisible(textMessage.content.length > 0)) {
        Text(textMessage.thinkingContent)
          .fontSize(12)
          .fontColor($r('sys.color.font_secondary'))
          .width('100%')
          .padding(8)
          .backgroundColor('#0a000000')
          .borderRadius({ bottomLeft: 6, bottomRight: 6 })
      }
    }
    .margin({ bottom: 8 })
  }

  isThinkingVisible(hasContent: boolean): boolean {
    if (hasContent) {
      return this.thinkingExpanded;
    }
    return true;
  }

  @Builder
  actionButtonsBuilder() {
    Row({ space: 24 }) {
      // 复制按钮
      Column({ space: 2 }) {
        SymbolGlyph($r('sys.symbol.plus_square_on_square'))
          .width(24)
          .height(24)
          .fontSize($r('sys.float.Title_M'))
          .fontColor([$r('sys.color.icon_primary')])
        Text('复制')
          .fontSize($r('sys.float.Body_S'))
          .fontColor($r('sys.color.font_primary'))
      }.alignItems(HorizontalAlign.Center)
      .backgroundColor(Color.Transparent)
      .padding(4)
      .onClick(() => {
        if (this.onCopy && this.message.isTextMessage()) {
          this.onCopy();
        }
      })

      // 重试按钮
      Column({ space: 2 }) {
        SymbolGlyph($r('sys.symbol.arrow_clockwise'))
          .width(24)
          .height(24)
          .fontSize($r('sys.float.Title_M'))
          .fontColor([$r('sys.color.icon_primary')])
        Text('重试')
          .fontSize($r('sys.float.Body_S'))
          .fontColor($r('sys.color.font_primary'))
      }
      .alignItems(HorizontalAlign.Center)
      .backgroundColor(Color.Transparent)
      .padding(4)
      .onClick(() => {
        if (this.onRetry) {
          this.onRetry();
        }
      })
    }
    .justifyContent(FlexAlign.Start)
  }

  @Builder
  MenuBuilder() {
    Column({ space: 4 }) {
      Row({ space: 4 }) {
        SymbolGlyph($r('sys.symbol.plus_square_on_square'))
          .width(24)
          .height(24)
          .fontSize($r('sys.float.Title_M'))
          .fontColor([$r('sys.color.icon_primary')])
        Text('复制')
          .fontSize($r('sys.float.Body_S'))
          .fontColor($r('sys.color.font_primary'))
      }
      .height(40)
      .onClick(() => {
        if (this.onCopy && this.message.isTextMessage()) {
          this.onCopy();
        }
      })
    }.width(100)
  }

  @Builder
  footerBuilder() {
    Text()
      .height(16)
      .width(1)
      .onVisibleAreaApproximateChange({
        ratios: [0.5, 1],
        expectedUpdateInterval: 100
      }, (isExpanding, currentRatio) => {
        if (this.isLoading && this.isLast) {
          this.onLastVisibleAreaApproximateChange?.(isExpanding, currentRatio)
        }
      })
  }
}