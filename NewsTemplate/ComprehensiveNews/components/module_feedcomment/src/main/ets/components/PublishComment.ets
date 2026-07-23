import { AppStorageV2 } from '@kit.ArkUI'
import { GlobalContextUtils, PopViewUtils, WindowModel } from 'lib_common'
import { FeedCommentVM } from '../viewmodel/FeedCommentVM'
import { CommentParams } from '../model/Model'

@Builder
export function publishCommentBuilder(commentParams: CommentParams) {
  PublishComment({
    commentParams,
  })
}

@ComponentV2
export struct PublishComment {
  @Require @Param commentParams: CommentParams
  @Local commendText: string = ''
  @Local emojiActive: boolean = false
  @Local keyBordHeight: number = 0
  @Local feedCommentVM: FeedCommentVM = FeedCommentVM.instance;
  @Local windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!;

  build() {
    Column() {
      Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        TextArea({
          text: this.commendText,
          placeholder: this.commentParams.reNickName ? `回复 ${this.commentParams.reNickName}` : '发表评论',
        })
          .fontColor($r('sys.color.font_primary'))
          .fontSize(14 * this.feedCommentVM.fontSizeRatio)
          .placeholderFont({
            size: 14 * this.feedCommentVM.fontSizeRatio,
          })
          .constraintSize({
            minHeight: 40,
          })
          .defaultFocus(true)
          .padding({ left: 16 })
          .borderRadius(24)
          .onChange((value) => {
            if (this.commendText.length > 500) {
              return
            }
            this.commendText = value
          })
          .width('85%')
        Column() {
          Image($r('app.media.publish')).width(19).height(19)
        }
        .height(40)
        .width(40)
        .accessibilityText('发送按钮')
        .onClick(() => {
          if (this.commendText.trim() === '') {
            GlobalContextUtils.showToast({ message: '发表内容不能为空' })
            return
          }
          this.commentParams?.callback?.(this.commendText)
          PopViewUtils.closeSheet()
          GlobalContextUtils.showToast({ message: '发表成功' })
        })
        .justifyContent(FlexAlign.Center)
        .borderRadius(40)
        .backgroundColor(this.commendText.trim() === '' ? '#BEC9F0' : '#5C79D9')
      }
    }.padding({
      top: 8,
      bottom: 8 + this.windowModel.windowBottomPadding,
      right: 16,
      left: 16
    })
  }
}