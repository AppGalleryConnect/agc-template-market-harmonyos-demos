/**
 * 录音与播放工具：基于 AudioCapturer + AudioRenderer 播放 PCM
 * 封装  AudioCapturer / AudioRendererManager
 */
import { common, abilityAccessCtrl } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { AudioCapturer } from './AudioCapturer';
import { AudioRendererManager } from './AudioRendererManager';

export class AudioRecordHelper {
  private context: common.UIAbilityContext | null = null;
  private capturer: AudioCapturer | null = null;
  private renderer: AudioRendererManager | null = null;
  private recordFileName: string = '';

  /**
   * 初始化并设置上下文（用于获取 filesDir 和权限）
   */
  setContext(context: common.UIAbilityContext): void {
    this.context = context;
  }

  /**
   * 申请麦克风权限
   */
  async requestMicrophonePermission(): Promise<boolean> {
    if (!this.context) {
      return false;
    }
    const atManager = abilityAccessCtrl.createAtManager();
    try {
      const data = await atManager.requestPermissionsFromUser(this.context,
        ['ohos.permission.MICROPHONE']);
      const granted = data.authResults && data.authResults.length > 0 && data.authResults[0] === 0;
      return granted;
    } catch (e) {
      hilog.error(0x0000, 'AudioRecordHelper', `request microphone permission failed: ${JSON.stringify(e)}`);
      return false;
    }
  }

  /**
   * 获取本次录音保存的路径（供笔记保存 audioUri 使用）
   */
  getRecordFilePath(): string {
    return this.recordFileName;
  }

  /**
   * 开始录音，返回保存路径；失败返回空字符串
   */
  async startRecord(): Promise<string> {
    if (!this.context) {
      return '';
    }
    try {
      // 生成本次录音文件名（不含路径与后缀）
      this.recordFileName = `voice_note_${Date.now()}`;
      this.capturer = new AudioCapturer();
      this.capturer.createOn(this.recordFileName, this.context);
      return this.recordFileName;
    } catch (e) {
      hilog.error(0x0000, 'AudioRecordHelper', `startRecord failed: ${JSON.stringify(e)}`);
      this.recordFileName = '';
      return '';
    }
  }

  /**
   * 停止录音
   */
  async stopRecord(): Promise<void> {
    try {
      if (this.capturer) {
        await this.capturer.stopAndRelease();
      }
    } catch (e) {
      hilog.error(0x0000, 'AudioRecordHelper', `stopRecord failed: ${JSON.stringify(e)}`);
    }
  }

  /**
   * 播放本地音频路径（沙箱 path）
   */
  async playByPath(path: string,
    onTimeUpdate?: (current: number, duration: number) => void,
    onFinish?: () => void): Promise<boolean> {
    if (!path) {
      hilog.error(0x0000, 'AudioRecordHelper', 'playByPath: empty path');
      return false;
    }
    if (!this.context) {
      hilog.error(0x0000, 'AudioRecordHelper', 'playByPath: context is null');
      return false;
    }
    try {
      await this.stopPlay();
      this.renderer = new AudioRendererManager();
      await this.renderer.initRenderer();
      // 这里的 path 实际上传入的是文件名（不包含后缀），与录音时保持一致
      await this.renderer.startRenderer(path, this.context);
      // 目前 AudioRendererManager 不提供时长与进度回调，这里仅在开始播放时设置一次
      if (onTimeUpdate) {
        onTimeUpdate(0, 0);
      }
      return true;
    } catch (e) {
      hilog.error(0x0000, 'AudioRecordHelper', `playByPath failed: ${JSON.stringify(e)}`);
      return false;
    }
  }

  /**
   * 暂停播放
   */
  async pausePlay(): Promise<void> {
    try {
      if (this.renderer) {
        await this.renderer.pauseRenderer();
      }
    } catch (e) {
      hilog.error(0x0000, 'AudioRecordHelper', `pausePlay failed: ${JSON.stringify(e)}`);
    }
  }

  /**
   * 继续播放
   */
  async resumePlay(): Promise<void> {
    try {
      if (this.renderer && this.context && this.recordFileName) {
        await this.renderer.startRenderer(this.recordFileName, this.context);
      }
    } catch (e) {
      hilog.error(0x0000, 'AudioRecordHelper', `resumePlay failed: ${JSON.stringify(e)}`);
    }
  }

  /**
   * 停止并释放播放器
   */
  async stopPlay(): Promise<void> {
    try {
      if (this.renderer) {
        await this.renderer.stopRenderer();
        await this.renderer.releaseRenderer();
        this.renderer = null;
      }
    } catch (e) {
      hilog.error(0x0000, 'AudioRecordHelper', `stopPlay failed: ${JSON.stringify(e)}`);
    }
  }

  /**
   * 是否正在录音
   */
  isRecording(): boolean {
    return this.capturer !== null;
  }

  /**
   * 是否正在播放
   */
  isPlaying(): boolean {
    return this.renderer !== null;
  }

  /**
   * 是否已暂停
   */
  isPaused(): boolean {
    // AudioRendererManager 暂未暴露精确状态，这里简单返回 false
    return false;
  }
}

