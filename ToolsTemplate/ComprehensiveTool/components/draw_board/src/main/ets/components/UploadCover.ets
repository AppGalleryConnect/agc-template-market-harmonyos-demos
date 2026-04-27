import { PhotoUtils } from '../utils/PhotoUtils'
import { DrawBoardVM } from '../viewmodel/DrawVM'

@ComponentV2
export struct UploadCover {
  @Local maxSelectNumber: number = 1
  @Local drawBoardVM: DrawBoardVM = DrawBoardVM.instance

  build() {
    Column({ space: 16 }) {
      Text('选择图片')
        .fontWeight(FontWeight.Medium)
        .margin({ top: 16 })
      Column() {
        if (this.drawBoardVM.canvasBackgroundImage) {
          Stack() {
            Column() {
              Image(this.drawBoardVM.canvasBackgroundImage)
                .objectFit(ImageFit.Fill)
            }
            .clip(true)
            .borderRadius(8)

            Image($r('app.media.ic_public_close_circle'))
              .width(24)
              .height(24)
              .fillColor($r('sys.color.font_primary'))
              .position({ right: -8, top: -8 })
              .onClick(() => {
                this.drawBoardVM.canvasBackgroundImage = ''
              })
          }
        } else {
          Image($r('app.media.cover_plus'))
            .fillColor($r('sys.color.font_primary'))
            .width(20)
            .height(20)
        }
      }
      .onClick(async () => {
        if (!this.drawBoardVM.canvasBackgroundImage) {
          const uriList = await PhotoUtils.selectPhoto();
          this.drawBoardVM.canvasBackgroundImage = uriList[0]
        }
      })
      .justifyContent(FlexAlign.Center)
      .width('100%')
      .height(205)
      .aspectRatio(1)
      .borderRadius(8)
      .backgroundColor($r('sys.color.comp_background_tertiary'))
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}