import { AppStorageV2 } from '@kit.ArkUI';
import { WindowModel } from 'lib_common';
import { VideoSwiperPage } from './VideoSwiperPage';

@ComponentV2
export struct FeaturedPage {
  // tab页面的index
  @Param index: number = 1
  // 视频页里面的头部tabIndex
  @Param currentTabIndex: number = 1;
  @Local isShown: boolean = false;
  @Local windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!;

  build() {
    Column() {
      VideoSwiperPage({
        index: this.index,
        currentTabIndex: this.currentTabIndex,
        isShown: this.isShown
      })
    }
    .padding({ bottom: this.windowModel.windowBottomPadding })
    .backgroundColor(Color.Black)
    .width('100%')
    .layoutWeight(1)
    .onVisibleAreaChange([0.0, 1.0], (isExpanding: boolean, currentRatio: number) => {
      if (isExpanding && currentRatio >= 1.0) {
        this.isShown = true;
      }
      if (!isExpanding && currentRatio <= 0.0) {
        this.isShown = false;
      }
    })
  }
}