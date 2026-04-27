import { FileBaseInfo } from '../model/FileBaseInfo';
import { FileBaseCheckViewModel } from '../viewmodel/FileBaseCheckViewModel';

// 文件选择cell
@ComponentV2
export struct FileBaseCheckCell {
  @Param @Require fileInfo: FileBaseInfo;
  @Require @Param vm: FileBaseCheckViewModel
  @Require @Param backupDateTime: string
  @Param isSelected: boolean = false
  @Event checkAction: () => void = () => {
  }

  @Computed
  get expireTimeBaseColor() {
    return this.vm.rightbottomTextColor(this.fileInfo)
  }

  @Computed
  get expireBaseTime() {
    return this.vm.rightbottomText(this.fileInfo)
  }

  build() {
    Row() {
      Image(FileBaseCheckViewModel.getImageSource(this.fileInfo.fileType, this.fileInfo.name,
        this.vm.isListVisibleGridMode,this.fileInfo.thumbnailUrl))
        .objectFit(ImageFit.Contain)
        .width(40)
        .height(40)

      Column() {
        Row() {
          Text(this.fileInfo.name)
            .fontSize(14)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .fontWeight(FontWeight.Medium)
            .fontColor(Color.Black)

          Image($r('app.media.base_collect_icon'))
            .width(16)
            .height(16)
            .objectFit(ImageFit.Contain)
            .margin({ left: 6 })
            .visibility(this.fileInfo.isCollected ? Visibility.Visible : Visibility.Hidden)
        }
        .justifyContent(FlexAlign.Start)
        .alignItems(VerticalAlign.Center)

        Row() {
          Text(this.backupDateTime !== '' ? this.backupDateTime :
            this.fileInfo.fileSize === '0B' ? this.fileInfo.createTime :
              this.fileInfo.updateTime + '  ' + this.fileInfo.fileSize)
            .fontSize(11)
            .fontColor('#9DA3AA')

          Text(this.expireBaseTime)
            .fontColor(this.expireTimeBaseColor)
            .fontSize(11)
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(VerticalAlign.Center)
        .width('100%')
      }
      .layoutWeight(1)
      .height(40)
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(HorizontalAlign.Start)
      .padding({ left: 12 })

      Image(this.isSelected ? $r('app.media.base_file_selected_icon') : $r('app.media.base_file_unselected_icon'))
        .objectFit(ImageFit.Contain)
        .width(36)
        .height(48)
        .onClick(() => {
          this.checkAction()
        })
        .padding({ left: 12, top: 12, bottom: 12 })
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Start)
    .height(64)
  }
}
