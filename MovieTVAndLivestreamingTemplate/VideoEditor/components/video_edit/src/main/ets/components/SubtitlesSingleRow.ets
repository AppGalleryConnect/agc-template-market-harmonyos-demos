import { SubtitlesSingleModel } from '../model/SubtitlesSingleModel'

@ComponentV2
export struct SubtitlesSingleRow {
  @Event onDeleteClick?: () => void
  @Event onEditClick?: () => void
  @Param @Require subtitlesModel: SubtitlesSingleModel;

  build() {
    Column() {
      Column() {
        Text(this.subtitlesModel.content)
          .width('100%')
          .fontColor(Color.White)
          .maxLines(-1)
          .fontSize(14)
          .lineHeight(18)
      }
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Start)
      .width('100%')
      .backgroundColor(0x33ffffff)
      .borderRadius($r('sys.float.corner_radius_level4'))
      .padding({
        top: 10,
        left: 12,
        bottom: 10,
        right: 12
      })

      Blank().height(8)

      Row() {
        Text(this.subtitlesModel.startTime)
          .width(64)
          .height('100%')
          .fontColor(0x99ffffff)
          .borderColor(0x33ffffff)
          .textAlign(TextAlign.Center)
          .borderWidth(1)
          .fontSize(12)
          .borderRadius($r('sys.float.corner_radius_level2'))

        Blank().width(16)

        Blank()
          .height('1vp')
          .color(0x99ffffff)
          .width(6)
        Blank().width(16)

        Text(this.subtitlesModel.endTime)
          .width(64)
          .borderRadius($r('sys.float.corner_radius_level2'))
          .fontColor(0x99ffffff)
          .height('100%')
          .borderColor(0x33ffffff)
          .fontSize(12)
          .textAlign(TextAlign.Center)
          .borderWidth(1)

        Blank().layoutWeight(1)
        Image($r('app.media.subtitles_delete_icon'))
          .width(24)
          .aspectRatio(1)
          .onClick(() => this.onDeleteClick?.())
        Blank().width(8)

        Image($r('app.media.subtitles_edit_icon'))
          .aspectRatio(1)
          .width(24)
          .onClick(() => this.onEditClick?.())
      }
      .width('100%')
      .height(28)
    }
  }
}