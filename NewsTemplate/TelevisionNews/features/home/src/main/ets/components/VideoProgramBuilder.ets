import { emitter } from '@kit.BasicServicesKit'
import { ValueType } from '@kit.ArkData'
import { Constants, PopViewUtils, RouterMap, RouterUtils } from 'lib_common'
import { HomeServiceApi, VideoProgramResponse } from 'lib_tv_apis'
import { secondToTime } from 'module_swipeplayer'
import { VideoPipViewModel } from 'lib_tv_details'

@Builder
export function videoProgramBuilder(videoId: string) {
  videoProgramList({ videoId })
}

@ComponentV2
struct videoProgramList {
  @Param videoId: string = ''
  @Local videoProgramList: VideoProgramResponse[] = []
  @Local videoPipViewModel: VideoPipViewModel = new VideoPipViewModel()

  async aboutToAppear() {
    this.videoProgramList = await HomeServiceApi.queryHomeTelevisionProgram(this.videoId)
  }

  formatDuration(duration: number) {
    const durationTime = duration / 1000
    return secondToTime(Math.floor(durationTime));
  }

  build() {
    Column() {
      List({ space: 16 }) {
        ForEach(this.videoProgramList, (item: VideoProgramResponse) => {
          ListItem() {
            Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
              Text(`${this.formatDuration(item.duration)}:${item.title}`)
                .fontColor(item.isEnd ? $r('sys.color.font_primary') : $r('sys.color.font_tertiary'))
                .fontWeight(FontWeight.Medium)
                .fontSize(16)
              Column() {
                Text('回看')
                  .fontColor('#EB5544')
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
              }
              .padding({
                left: 16,
                right: 16,
                top: 8,
                bottom: 8,
              })
              .visibility(item.isEnd ? Visibility.Visible : Visibility.Hidden)
              .backgroundColor($r('sys.color.comp_background_tertiary'))
              .borderRadius(14)
              .onClick(async () => {
                PopViewUtils.closeSheet()
                let params: Record<string, ValueType> = {
                  'avId': this.videoId,
                  'seek': item.duration,
                }
                emitter.emit('stop_video_play')
                RouterUtils.pushPathByName(RouterMap.VIDEO_PROGRAM_DETAILS, params)
              })
            }
            .padding({ top: Constants.PADDING_S, bottom: Constants.PADDING_S })
          }
        }, (item: VideoProgramResponse) => item.programId + item.title)
      }
      .divider({
        strokeWidth: 0.5,
        color: $r('sys.color.comp_divider'),
      })
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
      .scrollBar(BarState.Off)
      .layoutWeight(1)
    }
    .padding(Constants.PADDING_L)
  }
}