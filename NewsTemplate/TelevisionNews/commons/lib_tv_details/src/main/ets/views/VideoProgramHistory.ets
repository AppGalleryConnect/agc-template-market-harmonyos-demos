import { ValueType } from '@kit.ArkData';
import { AppStorageV2 } from '@kit.ArkUI';
import { BreakpointModel, Constants, NavHeaderTitleBar, RouterMap, RouterUtils, WindowModel } from 'lib_common';
import { AvResponse, AvSection, HomeServiceApi } from 'lib_tv_apis';
import { VideoAxisList } from '../components/VideoAxisList';

@Builder
export function VideoProgramHistoryBuilder() {
  VideoProgramHistory()
}

@ComponentV2
export struct VideoProgramHistory {
  @Local videoDetails: AvResponse | undefined
  @Local windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!;
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Local sectionIndex: number = -1

  build() {
    NavDestination() {
      Column() {
        NavHeaderTitleBar({ title: '往期节目', fontSize: 20 })
        VideoAxisList({
          videoDetails: this.videoDetails,
          sectionIndex: this.sectionIndex!!,
          onVideoChange: (item: AvSection) => {
            RouterUtils.popToName(RouterMap.VIDEO_PROGRAM_DETAILS, item)
          },
        })
      }
      .layoutWeight(1)
      .padding({ left: Constants.PADDING_L, right: Constants.PADDING_L })
    }
    .onReady(async (context) => {
      let params = context.pathStack.getParamByName('VideoProgramHistory')[0] as Record<string, ValueType>
      let videoId = params.videoId as string
      this.sectionIndex = params.sectionIndex as number
      this.videoDetails = await HomeServiceApi.queryHomeTelevisionDetails(videoId) as AvResponse
    })
    .hideTitleBar(true)
  }
}