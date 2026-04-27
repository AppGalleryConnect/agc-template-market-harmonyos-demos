import { AvModel, AvSection } from 'lib_tv_apis'
import { VideoVM } from '../viewmodel/VideoViewModel'

@ComponentV2
export struct VideoAxisList {
  @Param videoDetails: AvModel | undefined = undefined
  @Param sectionIndex: number = 0
  @Param fontSizeRatio: number = 1
  @Param isTvDetails: boolean = false
  @Event $sectionIndex: (index: number) => void = () => {
  }
  videoVM: VideoVM = new VideoVM(this.getUIContext())
  @Event onVideoChange: (item: AvSection) => void = () => {
  }

  build() {
    List({ space: 12 }) {
      ForEach(this.videoDetails?.section, (item: AvSection, index: number) => {
        ListItem() {
          Column({ space: 4 }) {
            Stack() {
              Image(item.coverUrl)
                .objectFit(ImageFit.Cover)
                .borderRadius(8)
                .clip(true)
                .width('100%')
                .height(this.videoVM.geVideoHeight())
            }
            .alignContent(Alignment.TopEnd)

            Text(item.title)
              .fontSize(14 * this.fontSizeRatio)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.sectionIndex === index ? '#EB5544' : $r('sys.color.font_primary'))
              .maxLines(1)
              .textOverflow({ overflow: this.sectionIndex === index ? TextOverflow.MARQUEE : TextOverflow.Ellipsis })
          }
          .backgroundColor($r('sys.color.background_primary'))
          .onClick(() => {
            this.onVideoChange(item)
            this.$sectionIndex(index)
          })
        }
      }, (item: AvSection) => item.id)
    }
    .scrollBar(BarState.Off)
    .lanes(this.videoVM.getTelevisionLanes(this.isTvDetails), 12)
    .layoutWeight(1)
    .nestedScroll({
      scrollForward: NestedScrollMode.PARENT_FIRST,
      scrollBackward: NestedScrollMode.SELF_FIRST,
    })
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    .padding({ bottom: 32 })
  }
}