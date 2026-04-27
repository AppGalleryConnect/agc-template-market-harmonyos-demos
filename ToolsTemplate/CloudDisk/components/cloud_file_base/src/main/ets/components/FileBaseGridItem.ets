import { FileBaseInfo, FileBaseType } from '../model/FileBaseInfo';
import { FileBaseCheckViewModel } from '../viewmodel/FileBaseCheckViewModel';

// 文件cell-网格模式
@ComponentV2
export struct FileBaseGridItem {
  @Param @Require fileInfo: FileBaseInfo;
  @Param isSelected: boolean = false
  @Event checkAction: () => void = () => {
  }

  build() {
    RelativeContainer() {
      Image(this.fileInfo.thumbnailUrl ?? '')
        .alt(FileBaseCheckViewModel.getImageSource(this.fileInfo.fileType, this.fileInfo.name, true))
        .width(72)
        .height(72)
        .objectFit(ImageFit.Contain)
        .alignRules({
          top: { anchor: '__container__', align: VerticalAlign.Top },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
        .margin({ top: 24 })
        .id('topImg')

      Image(this.isSelected ? $r('app.media.base_file_selected_icon') : $r('app.media.base_file_unselected_icon'))
        .width(24)
        .height(24)
        .objectFit(ImageFit.Contain)
        .alignRules({
          top: { anchor: 'topImg', align: VerticalAlign.Top },
          right: { anchor: 'topImg', align: HorizontalAlign.End }
        })
        .visibility(this.fileInfo.fileType === FileBaseType.PRIVATESPACE ? Visibility.None : Visibility.Visible)
        .margin({ top: -4, right: -4 })
        .onClick(() => {
          this.checkAction()
        })

      Text(this.fileInfo.name)
        .fontSize(11)
        .fontColor(Color.Black)
        .fontWeight(FontWeight.Medium)
        .alignRules({
          top: { anchor: 'topImg', align: VerticalAlign.Bottom },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
        .margin({ top: 4 })
    }
    .width('100%')
    .height(122)
  }
}
