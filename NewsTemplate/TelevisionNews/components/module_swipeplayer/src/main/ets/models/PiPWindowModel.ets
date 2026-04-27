import { PiPWindow, uiObserver } from '@kit.ArkUI';
import { AVPlayerState } from '../type/Index';

@ObservedV2
export class PiPWindowModel {
  // 监听事件
  @Trace navDestinationUpdateListeners: Map<string, (info: uiObserver.NavDestinationInfo) => void> = new Map();
  // 画中画控制器
  @Trace pipController: PiPWindow.PiPController | undefined = undefined;
  // 当前画中画中的视频id
  @Trace currentPiPVideoId: string = ''
  // 是否是返回页面时出现的画中画
  @Trace isBackPiP: boolean = false;
  // 是否是后台时出现的画中画
  @Trace isBackgroundPip: boolean = false;
  // 是否销毁播放器对象
  @Trace isReleaseVideoPlayer: boolean = true;
  // 是否已结束画中画
  @Trace isPipStop: boolean = false;
  // 是否可以进行画中画
  @Trace isEnablePiP: boolean = true;
  // 当前画中画的视频状态
  @Trace videoPlayerStatus: string = AVPlayerState.IDLE;
}