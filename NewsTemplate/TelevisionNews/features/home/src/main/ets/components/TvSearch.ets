import { AppStorageV2 } from '@kit.ArkUI';
import { Constants, RouterMap, RouterUtils, WindowModel } from 'lib_common'
import { VideoCardPlayerController } from 'module_swipeplayer';

@ComponentV2
export struct TvSearch {
  @Local breakpoint: string = '';
  @Require @Param videoCardPlayerController: VideoCardPlayerController
  @Param windowTopHeight: number = AppStorageV2.connect(WindowModel)?.getWindowTopHeight() || 38.77

  build() {
    Row({ space: 10 }) {
      Search({ placeholder: '搜索' })
        .width(Constants.FULL_PERCENT)
        .focusable(false)
        .onClick(() => {
          RouterUtils.pushPathByName(RouterMap.NEWS_SEARCH, null, (popInfo:PopInfo) => {
            this.videoCardPlayerController.play()
          })
          this.videoCardPlayerController.pause()
        })
    }
    .padding({ bottom: Constants.PADDING_M })
  }
}