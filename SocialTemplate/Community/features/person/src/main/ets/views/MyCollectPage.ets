import { AppStorageV2 } from '@kit.ArkUI';
import { audio } from '@kit.AudioKit';
import { BarVM, BreakpointModel, CommonHeader, TempBarHeight } from 'common';
import { OHPage, OHPageConfig, phoneRouterControl } from 'oh_router';
import { ChatHistoryCollectionComponent } from 'chat_history_collection';
import { ChatContentSingleModel, ChatTypeEnum } from 'chat_base';
import { AudioRendererUtil } from 'message/src/main/ets/utils/AudioRendererUtil';
import { ChatJumpManager } from 'message';

// 我的收藏
@ComponentV2
export struct MyCollectPage {
  @Local tempBarHeight: TempBarHeight = AppStorageV2.connect(TempBarHeight, () => new TempBarHeight())!;
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Local pageConfig: OHPageConfig = new OHPageConfig({
    onPageShow: () => {
      this.tempBarHeight.topValue = 0;
      this.tempBarHeight.bottomValue = 0;
    },
    onPageHide: () => {
      this.tempBarHeight.topValue = this.tempBarHeight.topTempValue;
      this.tempBarHeight.bottomValue = this.tempBarHeight.bottomTempValue;
      this.audioRendererUtil.stop();
    }
  })
  @Local onReturnClick: () => void = () => {
    phoneRouterControl.popPage()
  }
  audioRendererUtil: AudioRendererUtil = AudioRendererUtil.getInstance()
  @Local soundStatus: boolean = false //语音播放状态（停止/暂停/播放中）
  @Local onChatBubbleClick: (chatVM: ChatContentSingleModel) => void =
    (chatVM: ChatContentSingleModel) => {
      if (chatVM.chatType === ChatTypeEnum.CHAT_TYPE_LOCATION) {
        ChatJumpManager.gotoViewLocation(chatVM);
      } else if (chatVM.chatType === ChatTypeEnum.CHAT_TYPE_VIDEO) {
        ChatJumpManager.gotoVideoPage(chatVM);
      } else if (chatVM.chatType === ChatTypeEnum.CHAT_TYPE_IMAGE) {
        ChatJumpManager.gotoFullImagePage(chatVM);
      } else if (chatVM.chatType === ChatTypeEnum.CHAT_TYPE_SOUND) {
        if (this.soundStatus && this.audioRendererUtil.url === chatVM.soundInfo?.url) {
          this.audioRendererUtil.stop()
        } else {
          this.soundStart(chatVM)
        }
      }
    };

  /*
  * 语音开始播放
  */
  async soundStart(chatVM: ChatContentSingleModel) {
    await this.audioRendererUtil.readySoundFile(chatVM.soundInfo?.url, this.getUIContext())
    this.audioRendererUtil.setOutDevice(audio.DeviceType.EARPIECE)
    this.audioRendererUtil.start(chatVM.soundInfo?.url || '')
  }

  aboutToAppear(): void {
    this.audioRendererUtil.init();
  }

  @Builder
  render() {
    Column() {
      Blank().height(BarVM.instance.staBarH);

      CommonHeader({
        title: '收藏',
        onReturnClick: this.onReturnClick
      })
        .padding({
          left: this.breakPointModel.pagePadding,
          right: this.breakPointModel.pagePadding
        })
      ChatHistoryCollectionComponent(
        { onChatBubbleClick: this.onChatBubbleClick, }
      );
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
}

@Builder
export function MyCollectPageBuilder() {
  MyCollectPage()
}