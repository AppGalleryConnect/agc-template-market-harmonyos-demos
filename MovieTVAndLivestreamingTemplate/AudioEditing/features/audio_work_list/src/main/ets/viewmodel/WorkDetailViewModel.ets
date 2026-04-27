import { AudioPlayerManager } from '../util/AudioPlayerManager'
import { FileSaveManager } from '../util/FileSaveManager'
import { AudioInfo } from '../model/AudioInfo'
import { PlayMode, getPlayModeText } from '../model/PlayMode'
import { MusicListViewModel } from 'common_view/src/main/ets/viewModel/MusicListViewModel'
import { BusinessError } from '@kit.BasicServicesKit'
import { common } from '@kit.AbilityKit'

const TAG = 'WorkDetailViewModel'

/**
 * 作品详情页ViewModel
 * 负责业务逻辑处理和数据管理
 */
export class WorkDetailViewModel {
  // 音频播放器管理器
  private playerManager: AudioPlayerManager = new AudioPlayerManager()
  
  // 文件保存管理器
  private fileSaveManager?: FileSaveManager
  
  // 音频列表ViewModel
  private workListVM: MusicListViewModel = new MusicListViewModel()
  
  // 当前音频信息
  private currentAudio: AudioInfo = new AudioInfo()
  
  // 当前播放索引
  private currentIndex: number = -1
  
  // 播放模式
  private playMode: PlayMode = PlayMode.LIST_LOOP
  
  // 是否正在播放
  private isPlaying: boolean = false
  
  // 当前播放时间
  private currentTime: number = 0
  
  // 是否正在拖动进度条
  private isSliderChanging: boolean = false
  
  // 是否正在保存
  private isSaving: boolean = false

  // UI回调
  private onPlayStateChanged?: (isPlaying: boolean) => void
  private onTimeChanged?: (time: number) => void
  private onDurationChanged?: (duration: number) => void
  private onAudioChanged?: (audio: AudioInfo) => void
  private onError?: (message: string) => void
  private onToast?: (message: string) => void
  private onSaveStateChanged?: (isSaving: boolean) => void
  private onPlayModeChanged?: (playMode: PlayMode) => void

  /**
   * 初始化
   */
  async init(context?: common.UIAbilityContext): Promise<void> {
    // 加载作品列表
    this.workListVM.loadData('work')
    
    // 初始化播放器
    await this.playerManager.init()
    
    // 初始化文件保存管理器
    if (context) {
      this.fileSaveManager = new FileSaveManager(context)
    }
    
    // 设置播放器回调
    this.setupPlayerCallbacks()
  }

  /**
   * 设置播放器回调
   */
  private setupPlayerCallbacks(): void {
    this.playerManager.setOnStateChange((state: string) => {
      switch (state) {
        case 'prepared':
          const duration = this.playerManager.getDuration()
          this.currentAudio.duration = duration
          this.onDurationChanged?.(duration)
          break
        case 'playing':
          this.isPlaying = true
          this.onPlayStateChanged?.(true)
          break
        case 'paused':
          this.isPlaying = false
          this.onPlayStateChanged?.(false)
          break
        case 'completed':
          this.isPlaying = false
          this.onPlayStateChanged?.(false)
          this.handlePlayCompleted()
          break
      }
    })

    this.playerManager.setOnTimeUpdate((time: number) => {
      if (!this.isSliderChanging) {
        this.currentTime = time
        this.onTimeChanged?.(time)
      }
    })

    this.playerManager.setOnError((error: BusinessError) => {
      this.onError?.(`播放出错: ${error.code}`)
    })
  }

  /**
   * 加载音频信息
   */
  loadAudioInfo(uri: string, title: string, duration: number, size: string, format: string, path: string): void {
    this.currentAudio = new AudioInfo(uri, title, duration, size, format, path)
    this.currentIndex = this.findAudioIndex(path)
    this.onAudioChanged?.(this.currentAudio)
    
    // 自动开始播放
    if (path) {
      this.loadAndPlay(path)
    }
  }

  /**
   * 加载并播放音频
   */
  private async loadAndPlay(path: string): Promise<void> {
    try {
      await this.playerManager.loadAudio(path)
    } catch (error) {
      this.onError?.('加载音频失败，请检查文件')
    }
  }

  /**
   * 播放完成处理
   */
  private handlePlayCompleted(): void {
    if (this.playMode === PlayMode.SINGLE_LOOP) {
      // 单曲循环
      this.playCurrentAudio()
    } else {
      // 列表循环，播放下一首
      this.playNext()
    }
  }

  /**
   * 播放当前音频
   */
  private playCurrentAudio(): void {
    if (this.currentAudio.path) {
      this.loadAndPlay(this.currentAudio.path)
    }
  }

  /**
   * 切换播放/暂停
   */
  async togglePlay(): Promise<void> {
    try {
      if (this.isPlaying) {
        await this.playerManager.pause()
      } else {
        if (this.playerManager.isReady()) {
          await this.playerManager.play()
        } else {
          this.playCurrentAudio()
        }
      }
    } catch (error) {
      this.onError?.('播放控制失败')
    }
  }

  /**
   * 播放上一首
   */
  playPrevious(): void {
    if (this.currentIndex > 0) {
      this.currentIndex--
      this.loadAudioByIndex(this.currentIndex)
    } else {
      this.onToast?.('已经是第一首了')
    }
  }

  /**
   * 播放下一首
   */
  playNext(): void {
    if (this.currentIndex < this.workListVM.list.length - 1) {
      this.currentIndex++
      this.loadAudioByIndex(this.currentIndex)
    } else if (this.playMode === PlayMode.LIST_LOOP) {
      // 列表循环，回到第一首
      this.currentIndex = 0
      this.loadAudioByIndex(this.currentIndex)
    } else {
      this.onToast?.('已经是最后一首了')
    }
  }

  /**
   * 切换播放模式
   */
  togglePlayMode(): void {
    this.playMode = (this.playMode + 1) % 2
    const modeText = getPlayModeText(this.playMode)
    this.onToast?.(modeText)
    this.onPlayModeChanged?.(this.playMode)
  }

  /**
   * 跳转到指定位置
   */
  async seekTo(time: number): Promise<void> {
    try {
      const seekMode = this.currentTime < time ? 0 : 1
      await this.playerManager.seek(time, seekMode)
    } catch (error) {
    }
  }

  /**
   * 根据索引加载音频
   */
  private loadAudioByIndex(index: number): void {
    if (index >= 0 && index < this.workListVM.list.length) {
      const item = this.workListVM.list[index]
      this.currentAudio = new AudioInfo(
        item.uri,
        item.title,
        item.duration,
        item.size,
        item.format,
        item.sourcePath
      )
      this.currentTime = 0
      this.isPlaying = false
      
      this.onAudioChanged?.(this.currentAudio)
      this.loadAndPlay(this.currentAudio.path)
    }
  }

  /**
   * 查找音频在列表中的索引
   */
  private findAudioIndex(path: string): number {
    return this.workListVM.list.findIndex(item => item.sourcePath === path)
  }

  /**
   * 设置进度条拖动状态
   */
  setSliderChanging(changing: boolean): void {
    this.isSliderChanging = changing
  }

  /**
   * 保存当前音频到手机
   */
  async saveCurrentAudio(): Promise<void> {
    if (!this.fileSaveManager) {
      this.onError?.('文件保存功能未初始化')
      return
    }

    if (this.isSaving) {
      this.onToast?.('正在保存中，请稍候')
      return
    }

    if (!this.currentAudio.path) {
      this.onError?.('当前没有可保存的音频')
      return
    }

    try {
      this.isSaving = true
      this.onSaveStateChanged?.(true)
      this.onToast?.('开始保存音频...')

      // 确保文件名包含扩展名
      let fileName = this.currentAudio.title
      if (!fileName.includes('.')) {
        // 如果标题不包含扩展名，从format或path中获取
        const extension = this.currentAudio.format || this.getFileExtension(this.currentAudio.path)
        fileName = `${fileName}.${extension}`
      }

      const success = await this.fileSaveManager.saveAudioToPhone(
        this.currentAudio.path,
        fileName
      )

      if (success) {
        this.onToast?.('保存成功')
      } else {
        this.onError?.('保存失败')
      }
    } catch (error) {
      this.onError?.('保存失败')
    } finally {
      this.isSaving = false
      this.onSaveStateChanged?.(false)
    }
  }

  /**
   * 从文件路径获取扩展名
   */
  private getFileExtension(filePath: string): string {
    const lastDotIndex = filePath.lastIndexOf('.')
    if (lastDotIndex === -1 || lastDotIndex === filePath.length - 1) {
      return 'mp3' // 默认扩展名
    }
    return filePath.substring(lastDotIndex + 1)
  }

  /**
   * 释放资源
   */
  async release(): Promise<void> {
    await this.playerManager.release()
  }

  // Getter方法
  getCurrentAudio(): AudioInfo {
    return this.currentAudio
  }

  getIsPlaying(): boolean {
    return this.isPlaying
  }

  getCurrentTime(): number {
    return this.currentTime
  }

  getPlayMode(): PlayMode {
    return this.playMode
  }

  getIsSaving(): boolean {
    return this.isSaving
  }

  // 设置UI回调
  setOnPlayStateChanged(callback: (isPlaying: boolean) => void): void {
    this.onPlayStateChanged = callback
  }

  setOnTimeChanged(callback: (time: number) => void): void {
    this.onTimeChanged = callback
  }

  setOnDurationChanged(callback: (duration: number) => void): void {
    this.onDurationChanged = callback
  }

  setOnAudioChanged(callback: (audio: AudioInfo) => void): void {
    this.onAudioChanged = callback
  }

  setOnError(callback: (message: string) => void): void {
    this.onError = callback
  }

  setOnToast(callback: (message: string) => void): void {
    this.onToast = callback
  }

  setOnSaveStateChanged(callback: (isSaving: boolean) => void): void {
    this.onSaveStateChanged = callback
  }

  setOnPlayModeChanged(callback: (playMode: PlayMode) => void): void {
    this.onPlayModeChanged = callback
  }
}
