import { UtilLog } from '@hw-agconnect/util-log';
import { AppStorageV2, PiPWindow } from '@kit.ArkUI';
import { audio } from '@kit.AudioKit';
import { BusinessError } from '@kit.BasicServicesKit';
import {  BaseViewModel } from 'lib_common';
import { AVPlayerState, PiPWindowModel, VideoCardPlayerController } from 'module_swipeplayer';
import { PipUINodeController } from '../utils/PipUINodeController';

const TAG = '[VideoPipViewModel]'

@ObservedV2
export class VideoPipViewModel extends BaseViewModel {
  @Trace pipWindowModel: PiPWindowModel = AppStorageV2.connect(PiPWindowModel, () => new PiPWindowModel())!;
  context: Context | undefined = undefined
  videoCardPlayerController: VideoCardPlayerController = new VideoCardPlayerController();
  @Trace mXComponentController: XComponentController | undefined = undefined;
  @Trace curState: string = '';
  @Trace videoId: string = '';
  @Trace pipUINodeController: PipUINodeController = new PipUINodeController();

  @Monitor('pipWindowModel.isEnablePiP')
  onEnablePiPChange() {
    // 处理画中画控制面板控件功能状态  视频播放控制面板中播放/暂停控件。
    const controlType: PiPWindow.PiPControlType = PiPWindow.PiPControlType.VIDEO_PLAY_PAUSE;
    const status: PiPWindow.PiPControlStatus =
      this.pipWindowModel.videoPlayerStatus === AVPlayerState.PLAYING ? PiPWindow.PiPControlStatus.PLAY :
        PiPWindow.PiPControlStatus.PAUSE;
    this.pipWindowModel.pipController?.updatePiPControlStatus(controlType, status);

    if (this.pipWindowModel.isBackPiP || this.pipWindowModel.isBackgroundPip) {
      return;
    }
    // 播放状态时才能使用画中画，其他状态不展示画中画;
    this.pipWindowModel.pipController?.setAutoStartEnabled(this.pipWindowModel.isEnablePiP);
  }

  public setContext(context: Context) {
    this.context = context
  }

  public setMXComponentController(mXComponentController: XComponentController) {
    this.mXComponentController = mXComponentController
  }

  public getVideoCardPlayerController() {
    return this.videoCardPlayerController
  }

  /**
   * 监听拦截系统媒体打断事件
   */
  public audioInterrupt() {
    let avPlayer = this.videoCardPlayerController.getAvplayer()
    if (avPlayer) {
      avPlayer.on('audioInterrupt', (info: audio.InterruptEvent) => {
        if (info.forceType === audio.InterruptForceType.INTERRUPT_FORCE) {
          this.pipWindowModel.isBackPiP = false;
          this.pipWindowModel.pipController?.stopPiP().catch((e: BusinessError) => {
            UtilLog.error(TAG, `Failed to stopPiP. Code: ${e.code}, message: ${e.message}`);
          })
        }
      });
    }
  }

  /**
   * 取消监听拦截系统媒体打断事件
   */
  public cancelAudioInterrupt() {
    let avPlayer = this.videoCardPlayerController.getAvplayer()
    if (avPlayer) {
      avPlayer.off('audioInterrupt');
    }
  }
}