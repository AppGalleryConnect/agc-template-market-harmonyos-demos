import { MusicViewModel } from '../viewModel/MusicViewModel'
import { formatDuration } from 'audio_common'
import { throttle } from 'audio_common'

export type LISTMODE = 'click' | 'checkBox' | 'change' | 'move'

const TAG = 'MusicItem'

@ComponentV2
export struct MusicItem {
  @Param @Require item: MusicViewModel
  @Param index: number = -1
  @Param listMode: LISTMODE = 'click'
  @Param isEdit: boolean = false
  @Param musicItemOnclick: (item: MusicViewModel) => void = (item: MusicViewModel) => {
  }
  @Param musicItemOnChange: (item: MusicViewModel, checkBoxStatus: boolean) => void =
    (item: MusicViewModel, checkBoxStatus: boolean) => {
    }
  @Param musicItemEditOnclick: (index: number) => void = (index: number) => {
  }

  editClick() {
    this.musicItemEditOnclick(this.index)
  }

  build() {
    Row() {
      if (this.isEdit) {
        Image($r('app.media.ic_music_edit'))
          .width(17)
          .height(17)
          .position({ top: 12, right: 12 })
          .zIndex(1)
          .onClick(() => {
            this.editClick()
            return
          })
      }
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
        Image($r('app.media.ic_music')).width(40).height(40)
      }.width(40).height(40)
      .justifyContent(FlexAlign.Center)

      Column() {
        Text(this.item.title)
          .fontSize(14)
          .fontColor(Color.White)
          .width('100%')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .wordBreak(WordBreak.BREAK_ALL)
          .padding({ right: 20 })
        Text() {
          Span(`${formatDuration(this.item.duration)}  |  ${this.item.size}  |  ${this.item.format}`)
        }.fontSize(12).fontColor('#99FFFFFF').margin({ top: 8 })
      }.layoutWeight(1).margin({ left: 12 }).alignItems(HorizontalAlign.Start).padding({ right: 12 })
    }
    .width('100%')
    .height(70)
    .borderRadius(16)
    .padding({ left: 16 })
    .justifyContent(FlexAlign.Start)
    .alignItems(VerticalAlign.Center)
    .backgroundColor('#19FFFFFF')
    .onClick(throttle(() => {
      if (this.listMode === 'click') {
        this.musicItemOnclick(this.item)
      }
      if (this.listMode === 'checkBox') {
        this.item.checkBoxStatus = !this.item.checkBoxStatus
        this.musicItemOnChange(this.item, this.item.checkBoxStatus)
      }

    }, 1000))
  }
}