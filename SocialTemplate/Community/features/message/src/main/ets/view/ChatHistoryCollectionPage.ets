import { AppStorageV2 } from '@kit.ArkUI';
import { audio } from '@kit.AudioKit';
import { BarVM, BreakpointModel, CommonHeader, RouterMap, TempBarHeight, TValueType } from 'common';
import { OHPage, OHPageConfig, phoneRouterControl } from 'oh_router';
import { ChatHistoryCollectionComponent } from 'chat_history_collection';
import { ChatContentSingleModel, ChatTypeEnum } from 'chat_window';
import { ViewLocationPageBuilder } from './ViewLocationPage';
import { ChatJumpManager } from '../utils/ChatJumpManager';
import { AudioRendererUtil } from '../utils/AudioRendererUtil';

@Builder
export function ChatHistoryCollectionPageBuilder() {
  ChatHistoryCollectionPage()
}

/**
 * @usage: 聊天收藏页 支持位置/视频/图片/语音打开
 * @layout: 采用纵向排列布局，从上到下依次是状态栏占位Blank、标题为"收藏"的CommonHeader组件（带左右页面内边距）
 * 和ChatHistoryCollectionComponent收藏消息列表组件，整体默认居中对齐
 * @constraints: 规范要求页面隐藏时必须停止语音播放，语音播放设备固定为听筒(EARPIECE)，点击不同类型消息气泡需跳转到对应页面
 * （位置/视频/图片/语音），且语音播放状态需根据当前播放URL判断是否停止或重新播放
 * @isGen: true
 * @fileType: page
 * @domain: 社交交友
 * @zhName: 聊天收藏页
 * @subPage: ViewLocationPage,VideoPageView,FullImagePage
 * @component: CommonHeader,ChatHistoryCollectionComponent
 * @image: screenshot/collection_page.png
 */

@ComponentV2
export struct ChatHistoryCollectionPage {
  @Local tempBarHeight: TempBarHeight = AppStorageV2.connect(TempBarHeight, () => new TempBarHeight())!;
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Local pageConfig: OHPageConfig = new OHPageConfig({
    onPageHide: () => {
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
      ChatHistoryCollectionComponent({
        onChatBubbleClick: this.onChatBubbleClick,
      })
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

  gotoViewLocation(chatVM: ChatContentSingleModel) {
    phoneRouterControl.jumpPage({
      pageName: RouterMap.VIEW_LOCATION_PAGE,
      builder: wrapBuilder(ViewLocationPageBuilder),
      param: chatVM as TValueType
    })
  }
}
