import { CopilotChatOptions } from '../CopilotChatOptions';

@ComponentV2
export struct UserMessageCard {
  @Param options: CopilotChatOptions = {};
  @Param content?: string = '';
  @BuilderParam subComponent?: () => void;

  build() {
    if (this.content && this.content.length > 0) {
      RelativeContainer() {
        Text(this.content)
          .alignRules({
            end:{anchor:'__container__', align:HorizontalAlign.End}
          })
          .fontColor($r('sys.color.white'))
          .borderRadius(6)
          .backgroundColor('#2576F4')
          .margin({ bottom:16 })
          .padding(8)
      }
      .width('100%')
      .height('auto')
    } else if (this.subComponent) {
      this.subComponent()
    }
  }
}