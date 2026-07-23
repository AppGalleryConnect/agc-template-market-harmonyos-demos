import { emitter } from '@kit.BasicServicesKit'
import { ValueType } from '@kit.ArkData'
import { CommonConstants, PopViewUtils, RouterMap, RouterUtils, EventEnum } from 'lib_common'
import { HomeServiceApi, VideoProgramResponse } from 'lib_news_api'
import { VideoPipViewModel } from 'lib_av_details'
import { secondToTime } from 'module_swipeplayer'
import { CardViewModel } from 'lib_native_components/src/main/ets/viewmodel/CardViewModel'

@Builder
export function videoProgramBuilder(videoId: string) {
  videoProgramList({ videoId })
}

@ComponentV2
struct videoProgramList {
  @Param videoId: string = ''
  @Local videoProgramList: VideoProgramResponse[] = []
  @Local videoPipViewModel: VideoPipViewModel = new VideoPipViewModel()
  @Local cardViewModel: CardViewModel = new CardViewModel(this.getUIContext())

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
                .fontSize(16 * this.cardViewModel.settingInfo.fontSizeRatio)
              Column() {
                Text('回看')
                  .fontColor('#5C79D9')
                  .fontSize(14 * this.cardViewModel.settingInfo.fontSizeRatio)
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
                await this.videoPipViewModel.isRestPipController(this.videoId)
                let params: Record<string, ValueType> = {
                  'avId': this.videoId,
                  'seek': item.duration,
                }
                emitter.emit(EventEnum.STOP_VIDEO_PLAY)
                RouterUtils.pushPathByName(RouterMap.VIDEO_PROGRAM_DETAILS, params)
              })
            }
            .padding({ top: CommonConstants.PADDING_S, bottom: CommonConstants.PADDING_S })
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
    .padding(CommonConstants.PADDING_L)
  }
}