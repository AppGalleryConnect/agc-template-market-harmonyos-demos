import { AppStorageV2 } from '@kit.ArkUI';
import { CommonConstants, CommonHeader, WindowUtil } from 'lib_foundation';
import { BreakpointModel } from 'module_weather_core';
import { VoiceList } from 'module_voice_broadcast';

@ComponentV2
export struct BroadcastPage {
  @Local breakpointModel: BreakpointModel =
    AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;

  @Computed
  get bodyPadding(): number {
    if (this.breakpointModel.isMiddleWindow) {
      return 24;
    }
    return this.breakpointModel.isLargeWindow ? 32 : 0;
  }

  build() {
    NavDestination() {
      CommonHeader({
        title: '语音播报',
        bgColor: $r('sys.color.background_primary'),
        leftPadding: this.breakpointModel.pagePadding,
      })
        .margin({ bottom: CommonConstants.SPACE_8 })

      VoiceList()
        .layoutWeight(1)
        .margin({ left: this.bodyPadding, right: this.bodyPadding })
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
    .padding({ bottom: WindowUtil.getAvoidArea().bottom })
  }
}


@Builder
export function broadcastPageBuilder() {
  BroadcastPage()
}
