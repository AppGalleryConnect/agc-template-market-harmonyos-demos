import { emitter } from '@kit.BasicServicesKit'
import { CommonConstants, NewsEnum, EventEnum } from 'lib_common'
import { AvModel } from 'lib_news_api'
import { AvRouter, VideoPipViewModel } from 'lib_av_details'
import { VideoCardPlayerController } from 'module_swipeplayer'
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
              .fontSize(14 * this.vm.settingInfo.fontSizeRatio)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_primary'))
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          .id('television_flow_tb' + item.id + index)
          .onClick(async () => {
            await this.videoPipViewModel.isRestPipController(item.id)
            emitter.emit(EventEnum.STOP_VIDEO_PLAY)
            const params:Record<string, string | NewsEnum> = {
              'id':item.id,
              'type': item.type
            }
            this.avRouter.pushToAvDetails(params,
              'television_flow_tb' + item.id + index)
          })
        }
        .padding({ bottom: index === this.vm.televisionExtraList.length - 1 ? 88 : 0})
      }, (item: AvModel) => item.id)
    }
    .scrollBar(BarState.Off)
    .lanes(this.vm.getTelevisionLanes(), 12)
    .nestedScroll({ scrollForward: NestedScrollMode.PARENT_FIRST, scrollBackward: NestedScrollMode.PARENT_FIRST })
    .padding({ bottom: CommonConstants.PADDING_XXL })
  }

  build() {
    Column({ space: 16 }) {
      Text(this.vm.title)
        .fontColor($r('sys.color.font_primary'))
        .fontSize(18 * this.vm.settingInfo.fontSizeRatio)
        .fontWeight(FontWeight.Bold)
      this.televisionLikeList()
    }
    .alignItems(HorizontalAlign.Start)
  }
}