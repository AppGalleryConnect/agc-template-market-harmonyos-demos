import { CommonConstants } from 'lib_common';
import { MineLikePageVM } from '../viewmodels/MineLikePageVM';

@ComponentV2
export struct ToolBarBottom {
  @Require @Param vm: MineLikePageVM;

  build() {
    Row() {
      Column({ space: CommonConstants.SPACE_XS }) {
        Image($r('app.media.ic_public_eraser'))
          .width(24)
          .aspectRatio(1)
          .draggable(false)
          .fillColor($r('sys.color.font_primary'))
        Text('一键清空')
          .fontSize(10)
          .fontColor($r('sys.color.font_primary'))
      }
      .width(CommonConstants.HALF_PERCENT)
      .padding(CommonConstants.PADDING_XS)
      .accessibilityText('一键清空按钮')
      .onClick(() => {
        this.vm.deleteAllConfirm();
      })

      Column({ space: CommonConstants.SPACE_XS }) {
        Image($r('app.media.ic_public_delete'))
          .width(24)
          .aspectRatio(1)
          .draggable(false)
          .fillColor(this.vm.allowDelete ? $r('sys.color.font_primary') : $r('sys.color.font_secondary'))
        Text('删除')
          .fontSize(10)
          .fontColor(this.vm.allowDelete ? $r('sys.color.font_primary') : $r('sys.color.font_secondary'))
      }
      .width(CommonConstants.HALF_PERCENT)
      .padding(CommonConstants.PADDING_XS)
      .enabled(this.vm.allowDelete)
      .accessibilityText('删除按钮')
      .onClick(() => {
        this.vm.deleteConfirm();
      })
    }
    .width(CommonConstants.FULL_PERCENT)
  }
}