import { media } from '@kit.MediaKit'
import { fileIo } from '@kit.CoreFileKit'
import { audio } from '@kit.AudioKit'
import { BusinessError } from '@kit.BasicServicesKit'

const TAG = 'AudioPlayerManager'

/**
 * 音频播放器管理类
 * 负责AVPlayer的创建、配置、播放控制和资源释放
 */
export class AudioPlayerManager {
  private avPlayer?: media.AVPlayer
  private currentFileDescriptor?: fileIo.File
  private isPlayerReady: boolean = false
  // 回调函数
  private onStateChangeCallback?: (state: string) => void
  private onTimeUpdateCallback?: (time: number) => void
  private onErrorCallback?: (error: BusinessError) => void

  /**
   * 初始化播放器
   */
  async init(): Promise<void> {
    try {
      // 先释放旧的播放器
      if (this.avPlayer) {
        this.removeCallbacks()
        await this.avPlayer.release()
      }
      this.avPlayer = await media.createAVPlayer()
      this.setupCallbacks()
    } catch (error) {
      throw new Error('Failed to create AVPlayer')
    }
  }

  /**
   * 移除播放器回调
   */
  private removeCallbacks(): void {
    if (!this.avPlayer) {
      return
    }

    try {
      this.avPlayer.off('stateChange')
      this.avPlayer.off('timeUpdate')
      this.avPlayer.off('error')
    } catch (error) {
    }
  }

  /**
   * 设置播放器回调
   */
  private setupCallbacks(): void {
    if (!this.avPlayer) {
      return
    }

    this.avPlayer.on('stateChange', async (state: string) => {

      switch (state) {
        case 'initialized':
          if (this.avPlayer) {
            this.avPlayer.audioRendererInfo = {
              usage: audio.StreamUsage.STREAM_USAGE_MUSIC,
              rendererFlags: 0
            }
            await this.avPlayer.prepare()
          }
          break
        case 'prepared':
          this.isPlayerReady = true
          if (this.avPlayer) {
            await this.avPlayer.play()
          }
          break
        case 'stopped':
        case 'released':
          this.isPlayerReady = false
          break
        default:
          break
      }

      this.onStateChangeCallback?.(state)
    })

    this.avPlayer.on('timeUpdate', (time: number) => {
      this.onTimeUpdateCallback?.(time)
    })

    this.avPlayer.on('error', (error: BusinessError) => {
      this.closeCurrentFile()
      this.onErrorCallback?.(error)
    })
  }

  /**
   * 加载音频文件
   */
  async loadAudio(path: string): Promise<void> {
    if (!path) {
      throw new Error('Invalid path')
    }

    try {
      // 关闭之前的文件
      this.closeCurrentFile()

      // 重新初始化播放器
      await this.init()

      if (!this.avPlayer) {
        throw new Error('AVPlayer not initialized')
      }

      this.isPlayerReady = false

      // 检查文件是否存在
      if (!fileIo.accessSync(path)) {
        throw new Error('File not found')
      }

      // 打开文件并保持文件描述符
      this.currentFileDescriptor = fileIo.openSync(path, fileIo.OpenMode.READ_ONLY)
      const fdPath = `fd://${this.currentFileDescriptor.fd}`

      this.avPlayer.url = fdPath
    } catch (error) {
      this.closeCurrentFile()
      throw new Error('Failed to load audio file')
    }
  }

  /**
   * 播放
   */
  async play(): Promise<void> {
    if (this.avPlayer && this.isPlayerReady) {
      await this.avPlayer.play()
    }
  }

  /**
   * 暂停
   */
  async pause(): Promise<void> {
    if (this.avPlayer && this.isPlayerReady) {
      await this.avPlayer.pause()
    }
  }

  /**
   * 停止
   */
  async stop(): Promise<void> {
    if (this.avPlayer) {
      await this.avPlayer.stop()
    }
  }

  /**
   * 跳转到指定位置
   */
  async seek(time: number, mode: number = 0): Promise<void> {
    if (this.avPlayer && this.isPlayerReady) {
      await this.avPlayer.seek(time, mode)
    }
  }

  /**
   * 获取播放时长
   */
  getDuration(): number {
    return this.avPlayer?.duration || 0
  }

  /**
   * 获取当前播放位置
   */
  getCurrentTime(): number {
    return this.avPlayer?.currentTime || 0
  }

  /**
   * 检查是否准备就绪
   */
  isReady(): boolean {
    return this.isPlayerReady
  }

  /**
   * 关闭当前文件
   */
  private closeCurrentFile(): void {
    if (this.currentFileDescriptor) {
      try {
        fileIo.closeSync(this.currentFileDescriptor)
        this.currentFileDescriptor = undefined
      } catch (error) {
      }
    }
  }

  /**
   * 释放资源
   */
  async release(): Promise<void> {
    if (this.avPlayer) {
      try {
        this.removeCallbacks()
        await this.avPlayer.stop()
        await this.avPlayer.release()
        this.avPlayer = undefined
      } catch (error) {
      }
    }
    this.closeCurrentFile()
  }

  /**
   * 设置状态变化回调
   */
  setOnStateChange(callback: (state: string) => void): void {
    this.onStateChangeCallback = callback
  }

  /**
   * 设置时间更新回调
   */
  setOnTimeUpdate(callback: (time: number) => void): void {
    this.onTimeUpdateCallback = callback
  }

  /**
   * 设置错误回调
   */
  setOnError(callback: (error: BusinessError) => void): void {
    this.onErrorCallback = callback
  }
}
