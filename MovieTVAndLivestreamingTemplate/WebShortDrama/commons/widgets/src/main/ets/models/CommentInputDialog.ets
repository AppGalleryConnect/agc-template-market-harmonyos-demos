import { getMedia } from '@agctemplate/resources';
import { AppStorageV2 } from '@kit.ArkUI';
import { AppStorageKeys } from '../const/AppStorageKeys';
import { AiBarHeight, StatusBarHeight } from '../ui/avoid_area/AvoidArea';

const ID_TEXT_INPUT: string = 'id_image_comment_text_input';
const ID_TEXT_PUSH: string = 'id_image_comment_text_publish';

@Preview
@ComponentV2
export struct CommentInputDialog {
  @Local aiBarHeight: AiBarHeight = AppStorageV2.connect(AiBarHeight, AppStorageKeys.AI_BAR_HEIGHT,
    () => new AiBarHeight())!;
  @Local statusBarHeight: StatusBarHeight = AppStorageV2.connect(StatusBarHeight, AppStorageKeys.STATUS_BAR_HEIGHT,
    () => new StatusBarHeight())!;
  // 输入的文字
  @Local text: string | ResourceStr = '';
  @Local textInComment: string = '';
  // 发布接口，用于主页面更新评论数据
  @Event onPublish: Function = (textComment: string): void => {
  }

  build() {
    Column() {
      Row({ space: 8 }) {
        Stack({ alignContent: Alignment.End }) {
          TextInput({ text: this.textInComment })
            .onChange((value: string) => {
              this.textInComment = value;
            })
            .defaultFocus(true)
            .width('100%')
            .height(40)
            .backgroundColor('rgba(0, 0, 0, 0.05)')
            .placeholderColor($r('sys.color.font_secondary'))
            .placeholderFont({ size: 16 })
            .fontSize(16)
            .fontColor('#000')

          Image(getMedia('app.media.xmark'))
            .width(16)
            .height(16)
            .margin({ right: 12 })
        }
        .layoutWeight(1)
        .height(40)
        .borderRadius(24)

        Image(getMedia('app.media.icon_button_send'))
          .width(40)
          .height(40)
          .onClick(() => {
            this.text = this.textInComment;
            this.textInComment = '';
            this.onPublish(this.text);
          })
      }
      .width('100%')
      .height(40)
      .justifyContent(FlexAlign.SpaceBetween)

      Row()
        .width('100%')
        .height(20)
    }
    .width('100%')
    .height(76)
    .padding({ left: 16, right: 16, top: 8, bottom: 8 })
    .backgroundColor(Color.White)
    .offset({ y: 20 })
  }
}

@Builder
export function commentInputDialogBuilder(onPublishComment: Function) {
  CommentInputDialog({ onPublish: onPublishComment })
}
