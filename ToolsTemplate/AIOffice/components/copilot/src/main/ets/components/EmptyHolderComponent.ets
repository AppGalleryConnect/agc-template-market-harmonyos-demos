import { CopilotChatOptions } from './CopilotChatOptions';

const MAX_SUGGESTION_COUNT = 5;

@ComponentV2
export struct EmptyHolderComponent {
  @Param options: CopilotChatOptions = {};
  @Event onSuggestionClick?: (suggestion: string) => void;

  build() {
    Column({ space:  4}) {
      // AI图标
      if (this.options.icons?.assistant) {
        Image(this.options.icons.assistant)
          .width(72)
          .height(72)
      }

      Column({ space: 8 }) {
        // 标题 - 介绍文本
        if (this.options.labels?.introduce) {
          Text(this.options.labels.introduce)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('sys.color.font_primary'))
            .textAlign(TextAlign.Center)
        }

        // 描述文字 - 初始问候语
        if (this.options.labels?.initial) {
          Text(this.options.labels.initial)
            .fontSize(12)
            .fontColor($r('sys.color.font_tertiary'))
            .textAlign(TextAlign.Center)
            .lineHeight(20)
        }
      }

      // 建议问题卡片
      if (this.options.labels?.suggestions && this.options.labels.suggestions.length > 0) {
        Column({ space: 16 }) {
          ForEach(this.options.labels.suggestions, (suggestion: string, index: number) => {
            if (index < MAX_SUGGESTION_COUNT) {
              Column() {
                Text(suggestion)
                  .fontSize(16)
                  .fontColor($r('sys.color.font_secondary'))
                  .textAlign(TextAlign.Start)
                  .maxLines(2)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
              }
              .justifyContent(FlexAlign.Center)
              .width('100%')
              .height(56)
              .borderRadius(8)
              .backgroundColor($r('sys.color.comp_background_tertiary'))
              .onClick(() => {
                if (this.onSuggestionClick) {
                  this.onSuggestionClick(suggestion);
                }
              })
            }
          })
        }
        .width('100%')
        .padding({
          top: 30
        })
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}