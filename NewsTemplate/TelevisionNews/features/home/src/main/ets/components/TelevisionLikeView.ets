import { emitter } from '@kit.BasicServicesKit'
import { Constants  } from 'lib_common'
import { VideoCardPlayerController } from 'module_swipeplayer'
import { AvModel } from 'lib_tv_apis'
import { VideoPipViewModel } from 'lib_tv_details'
import { AvRouter } from '../utils/AvRouter'
import { TelevisionViewModel } from '../viewmodels/TelevisionViewModel'

@ComponentV2
export struct TelevisionLikeView {
  @Local vm:TelevisionViewModel = new TelevisionViewModel(this.getUIContext())
  @Local isLivestream: boolean = false;
  videoCardPlayerController: VideoCardPlayerController = new VideoCardPlayerController();
  @Local videoPipViewModel: VideoPipViewModel = new VideoPipViewModel()
  private avRouter: AvRouter = new AvRouter(this.getUIContext())

  aboutToAppear(): void {
    this.vm.requestTelevisionLike()
  }

  @Builder
  televisionLikeList() {
    List({ space: 12 }) {
      ForEach(this.vm.televisionExtraList, (item: AvModel, index: number) => {
        ListItem() {
          Column({ space: 4 }) {
            Image(item.coverUrl)
              .objectFit(ImageFit.Cover)
              .borderRadius(8)
              .clip(true)
              .width('100%')
              .height(this.vm.geVideoHeight())
            Text(item.title)
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_primary'))
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          .id('television_flow_tb' + item.id + index)
          .onClick(async () => {
            emitter.emit('stop_video_play')
            const params:Record<string, string> = {
              'id':item.id,
            }
            this.avRouter.pushToAvDetails(params)
          })
        }
      }, (item: AvModel) => item.id)
    }
    .scrollBar(BarState.Off)
    .lanes(this.vm.getTelevisionLanes(), 12)
    .nestedScroll({ scrollForward: NestedScrollMode.PARENT_FIRST, scrollBackward: NestedScrollMode.PARENT_FIRST })
    .padding({ bottom: Constants.PHONE_BOTTOM_TAB_BAR_HEIGHT })
  }

  build() {
    Column({ space: 16 }) {
      Text(this.vm.title)
        .fontColor($r('sys.color.font_primary'))
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
      this.televisionLikeList()
    }
    .alignItems(HorizontalAlign.Start)
  }
}