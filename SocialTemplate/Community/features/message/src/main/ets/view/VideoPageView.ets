import { VideoPage } from 'chat_window';
import { BreakpointModel, TempBarHeight } from 'common';
import { OHPage, OHPageConfig, phoneRouterControl } from 'oh_router';
import { AppStorageV2 } from '@kit.ArkUI';

@ComponentV2
export struct VideoPageView {
  @Local videoUrl: string = ''
  @Local videoMutyStatus: boolean = true
  @Local tempBarHeight: TempBarHeight = AppStorageV2.connect(TempBarHeight, () => new TempBarHeight())!;
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Local pageConfig: OHPageConfig = new OHPageConfig({
    onPageShow: () => {
      this.tempBarHeight.topValue = 0;
      this.tempBarHeight.bottomValue = 0;
    }
  })
  @Local onReturnClick: () => void = () => {
    phoneRouterControl.popPage()
  }
  @Param @Require params?: object

  aboutToAppear(): void {
    const params = this.params as Record<string, string | boolean>
    try {
      this.videoUrl = params.videoChatSrc as string;
      this.videoMutyStatus = params.videoMutyStatus as boolean
    } catch (err) {
    }
  }

  build() {
    OHPage({
      childBuilder: () => {
        this.render();
      },
      pageConfig: this.pageConfig
    })
  }

  @Builder
  render() {
    VideoPage({
      videoChatSrc: this.videoUrl,
      videoStatus: this.videoMutyStatus,
      onReturnClick: this.onReturnClick
    })
  }
}

@Builder
export function VideoPageViewBuilder(param: object) {
  VideoPageView({ params: param })
}