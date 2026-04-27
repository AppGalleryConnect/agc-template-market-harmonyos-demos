import { GridRowColSetting } from 'lib_common'
import { BuilderParams } from '../model/Model'

@Builder
export function confirmDialogView(builderParams: BuilderParams) {
  Column() {
    Column() {
      Column() {
        Text('回复')
          .fontWeight(FontWeight.Medium)
          .fontSize(16 * builderParams.fontSizeRatio ?? 1)
          .fontColor($r('sys.color.font_primary'))
      }
      .width('100%')
      .height(48)
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        builderParams.reply()
      })

      Divider()

      Column() {
        Text('复制')
          .fontWeight(FontWeight.Medium)
          .fontSize(16 * builderParams.fontSizeRatio ?? 1)
          .fontColor($r('sys.color.font_primary'))
      }
      .width('100%')
      .height(48)
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        builderParams.copy()
      })

      Divider()

      Column() {
        Text('举报')
          .fontSize(16 * builderParams.fontSizeRatio ?? 1)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
      }
      .width('100%')
      .height(48)
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        builderParams.report()
      })
      .visibility(builderParams.isCommentOwner ? Visibility.None : Visibility.Visible)

      Divider()

      Column() {
        Text('删除')
          .fontSize(16 * builderParams.fontSizeRatio ?? 1)
          .fontWeight(FontWeight.Medium)
          .fontColor('#E63E24')
      }
      .width('100%')
      .height(48)
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        builderParams.delete()
      })
      .visibility(builderParams.isCommentOwner ? Visibility.Visible : Visibility.None)

      Divider()

      Column() {
        Text('取消')
          .fontSize(16 * builderParams.fontSizeRatio ?? 1)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
      }
      .width('100%')
      .height(48)
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        builderParams.cancel()
      })
    }
    .width('100%')
    .constraintSize({ maxWidth: GridRowColSetting.DIALOG_MAX_WIDTH })
    .borderRadius(32)
    .padding(24)
    .backgroundColor($r('sys.color.comp_background_primary'))
  }
  .width('100%')
  .padding({ left: 16, right: 16 })
}
