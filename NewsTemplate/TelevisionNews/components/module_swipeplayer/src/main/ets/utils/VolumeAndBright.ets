import { audio } from '@kit.AudioKit'
import { PlayerSliderModel } from '../models/PlayerSliderModel'

const TAG = '[VolumeAndBright]';

export class VolumeAndBright {
  audioManager: audio.AudioManager | undefined = undefined
  audioVolumeManager: audio.AudioVolumeManager | undefined = undefined
  audioVolumeGroupManager: audio.AudioVolumeGroupManager | undefined = undefined
  private hideTimer: number | null = null
  playerSliderModel: PlayerSliderModel = new PlayerSliderModel()

  // 清理资源
  public destroy() {
    // 清理定时器
    if (this.hideTimer) {
      clearTimeout(this.hideTimer);
      this.hideTimer = null;
    }
  }

  // 音量进度条的显隐
  handleVolumeProgressChange() {
    // 清除之前的计时器
    if (this.hideTimer) {
      clearTimeout(this.hideTimer)
    }
    this.playerSliderModel.showVolumeProgress = true;

    this.hideTimer = setTimeout(() => {
      this.playerSliderModel.showVolumeProgress = false;
      // 清除计时器
      if (this.hideTimer) {
        clearTimeout(this.hideTimer)
      }
    }, 3000);
  }
}