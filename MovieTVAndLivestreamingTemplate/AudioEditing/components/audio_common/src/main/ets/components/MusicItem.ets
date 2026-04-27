import { formatDuration } from '../util/CommonUtil'
import { MusicViewModel } from '../viewModel/MusicViewModel'

export type LISTMODE = 'click' | 'checkBox' | 'change' | 'move'

const TAG = 'MusicItem'

@ComponentV2
export struct MusicItem {
  @Param @Require item: MusicViewModel
  @Param listMode: LISTMODE = 'click'
  @Param musicItemOnclick: (item: MusicViewModel) => void = (item: MusicViewModel) => {
  }
  @Param musicItemOnChange: (item: MusicViewModel, checkBoxStatus: boolean) => void =
    (item: MusicViewModel, checkBoxStatus: boolean) => {
    }

  build() {
    Row() {
      if (this.listMode === 'checkBox') {
        Image(this.item.checkBoxStatus ? $r('app.media.ic_checked') : $r('app.media.ic_uncheck'))
          .width(18)
          .height(18)
          .margin({ right: 16 })
      }

      if (this.listMode === 'move') {
        Image($r('app.media.ic_move'))
          .width(18)
          .height(18)
          .margin({ right: 16 })
      }

      Row() {
        Image($r('app.media.ic_music')).width(24).height(24)
      }.width(40).height(40).backgroundColor('#33FFFFFF')
      .justifyContent(FlexAlign.Center)

      Column() {
        Text(this.item.title)
          .fontSize(14)
          .fontColor(Color.White)
          .width('100%')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.MARQUEE })
        Text() {
          Span(`时长：${formatDuration(this.item.duration)}  大小：${this.item.size}  格式：${this.item.format}`)
        }.fontSize(12).fontColor('#99FFFFFF').margin({ top: 14 })
      }.layoutWeight(1).margin({ left: 12 }).alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height(70)
    .borderRadius(16)
    .padding({ left: 16 })
    .justifyContent(FlexAlign.Start)
    .alignItems(VerticalAlign.Center)
    .backgroundColor('#19FFFFFF')
    .onClick(() => {
      if (this.listMode === 'click') {
        this.musicItemOnclick(this.item)
      }
      if (this.listMode === 'checkBox') {
        this.item.checkBoxStatus = !this.item.checkBoxStatus
        this.musicItemOnChange(this.item, this.item.checkBoxStatus)
      }

    })
  }
}