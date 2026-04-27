import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { AppStorageV2, promptAction, window } from '@kit.ArkUI';
import fs from '@ohos.file.fs';
import media from '@ohos.multimedia.media';
import audio from '@ohos.multimedia.audio';
import { CacheListener, HttpProxyCacheServer, HttpProxyCacheServerBuilder } from '@ohos/video-cache';
import { VideoModel } from 'video_common'
import { CommonConstants, VideoInfo } from '../CommonConstants';
import MediaLibraryUtils from '../MediaLibraryUtils';
import GlobalProxyServer from '../GlobalProxyServer';
import { MyRowModifier } from '../util/VideoUtil';

class MyCacheListener implements CacheListener {
  self: VideoDownloadVM

  constructor(self: VideoDownloadVM) {
    this.self = self
  }

  onCacheAvailable(cacheFilePath: string, url: string, percentsAvailable: number) {
    const timestamp = new Date().toLocaleTimeString();
    try {
      // 只更新当前视频的缓存进度
      if (url === this.self.videoName) {
        const oldPercent = this.self.videoInfo?.currentCachePercent;
        if (this.self.videoInfo) {
          this.self.videoInfo.currentCachePercent = percentsAvailable;
        }
        if (this.self.videoInfo) {
          this.self.videoInfo.sizeCurrent =
            Math.round(percentsAvailable * 0.01 * parseFloat(this.self.videoSize.replace('M', ''))) + 'M'
        }
        try {
          let fileInfo = fs.statSync(cacheFilePath);
          const fileSizeMB = (fileInfo.size / 1024 / 1024).toFixed(2);
        } catch (err) {
        }
      }
    } catch (err) {
    }
  }
}

@ObservedV2
export class VideoDownloadVM {
  @Trace videoState: VideoModel = AppStorageV2.connect<VideoModel>(VideoModel, () => new VideoModel())!;
  @Trace ratio: number = 2.0;
  @Trace mediaLibUtils: MediaLibraryUtils = new MediaLibraryUtils();
  @Trace isPlaying: boolean = true; //只负责列表视频是否下载逻辑
  @Trace currentTime: string = '0';
  @Trace durationTimeText: string = '100';
  @Trace setValue: number = 0;
  @Trace isLoop: boolean = false;
  @Trace videoName: string = '';
  @Trace videoDuration: string = '';
  @Trace videoSize: string = '';
  @Trace isSpeed: boolean = false;
  @Trace videoInfo: VideoInfo = new VideoInfo('', '', $r('app.string.page_show'), 0, 0, '');
  @Trace descriptionValue: string = '';
  @Trace isBuffering: boolean = false;
  @Trace speedTag: number = 1;
  @Trace scaleTag: number = 0;
  @Trace downloadSpeed: string = '0 KB/s';
  @Trace lastCachePercent: number = 0;
  @Trace lastUpdateTime: number = 0;
  @Trace avPlayer: media.AVPlayer | undefined = undefined;
  @Trace currentCacheListener: CacheListener | null = null;
  @Trace duration: number = -1;
  @Trace fdPath: string = '';
  @Trace surfaceID: string = '';
  @Trace cacheFileHandle: fs.File | null = null; // 保存缓存文件句柄
  @Trace isPrepare: boolean = false;
  @Trace isNext = false;
  @Trace index: number = -1;
  @Trace mXcomponentController: XComponentController = new XComponentController();
  @Trace SRC_LIST: Array<VideoInfo> = [];
  @Trace isLandscape: boolean = false;
  @Trace modifier: MyRowModifier = new MyRowModifier()
  @Trace componentHeight: number = 300
  @Trace xComponentWidth: number = 0
  @Trace xComponentHeight: number = 0
  @Trace videoWidth: number | string = 0
  @Trace videoHeight: number = 0
  @Trace windowClass: window.Window;

  constructor(uiContext: UIContext) {
    const abilityContext = uiContext.getHostContext() as common.UIAbilityContext
    this.windowClass = abilityContext.windowStage.getMainWindowSync();
  }

  @Monitor('videoInfo.currentCachePercent')
  async onStrChange(monitor: IMonitor) {
    const isCached = monitor.value()?.now === 100 ? true : false;
    if (this.videoInfo) {
      this.videoInfo.isCached = isCached;
    }
    this.calculateDownloadSpeed(monitor.value()?.now as number || 0);
  }

  @Monitor('videoState.isPlaying')
  async onPlayingChange(monitor: IMonitor) {
    if (this.avPlayer !== undefined) {
      if (monitor.value()?.now) {
        this.avPlayer.setMediaMuted(media.MediaType.MEDIA_TYPE_AUD, false);
      } else {
        this.avPlayer.setMediaMuted(media.MediaType.MEDIA_TYPE_AUD, true);
      }
    }
  }

  getVideoSize() {
    this.videoHeight = this.xComponentHeight
    if (this.videoWidth > this.xComponentWidth) {
      this.videoWidth = this.xComponentWidth - 32
    }
  }

  // 计算下载速度
  calculateDownloadSpeed(currentPercent: number) {
    const currentTime = Date.now();

    if (this.lastUpdateTime === 0) {
      this.lastUpdateTime = currentTime;
      this.lastCachePercent = currentPercent;
      return;
    }

    const timeDiff = (currentTime - this.lastUpdateTime) / 1000; // 转换为秒
    const percentDiff = currentPercent - this.lastCachePercent;

    if (timeDiff > 0 && percentDiff > 0) {
      // 计算每秒下载的数据量
      const totalSizeMB = parseFloat(this.videoSize.replace('M', '')) || 0;
      const downloadedMB = (percentDiff / 100) * totalSizeMB;
      const speedMBps = downloadedMB / timeDiff;

      // 格式化速度显示
      if (speedMBps >= 1) {
        this.downloadSpeed = `${speedMBps.toFixed(2)} MB/s`;
      } else {
        const speedKBps = speedMBps * 1024;
        this.downloadSpeed = `${speedKBps.toFixed(2)} KB/s`;
      }
    }

    // 更新记录
    this.lastUpdateTime = currentTime;
    this.lastCachePercent = currentPercent;

    // 如果下载完成，重置速度显示
    if (currentPercent >= 100) {
      this.downloadSpeed = '下载完成';
    }
  }

  // 重置下载速度相关数据
  resetDownloadSpeed() {
    this.downloadSpeed = '0 KB/s';
    this.lastCachePercent = 0;
    this.lastUpdateTime = 0;
  }

  // 获取格式化的下载速度显示
  getFormattedDownloadSpeed(): string {
    if (this.videoInfo?.isCached) {
      return '下载完成';
    }
    if (this.videoInfo?.currentCachePercent === 0) {
      return '准备下载';
    }
    return this.downloadSpeed;
  }

  getWindowSizeChange = (size: Size) => {
    let viewWidth = px2vp(size.width);
    let viewHeight = px2vp(size.height);
    if (this.isLandscape) {
      this.windowClass.setWindowSystemBarEnable([])
      this.xComponentHeight = viewHeight;
    } else {
      this.windowClass.setWindowSystemBarEnable(['navigation', 'status'])
      this.xComponentHeight = this.componentHeight;
    }
    this.xComponentWidth = viewWidth;
    if (this.isLandscape) {
      if (canIUse('SystemCapability.Window.SessionManager')) {
        this.windowClass.setSpecificSystemBarEnabled('navigationIndicator', false);
      }
    } else {
      if (canIUse('SystemCapability.Window.SessionManager')) {
        this.windowClass.setSpecificSystemBarEnabled('navigationIndicator', true);
      }
    }
    this.getVideoSize()
  }

  setOrientation(orientation: number) {
    this.windowClass.setPreferredOrientation(orientation).then(() => {
    }).catch((err: BusinessError) => {
    });
  }

  // 界面初始化函数
  public async init(video: VideoInfo) {
    this.videoInfo = video;
    // 获取资源字符串的实际值
    if (typeof video.url === 'string') {
      this.videoName = video.url;
    } else {
      // 如果是 Resource 类型，需要通过 resourceManager 获取实际字符串
      try {
        const resourceMgr = getContext().resourceManager;
        this.videoName = await resourceMgr.getStringValue(video.url as Resource);
      } catch (err) {
        this.videoName = '';
      }
    }
    this.SRC_LIST = CommonConstants.VIDEO_HTTPS_LISTS;
    this.videoDuration = video.getFormattedDuration()
    this.videoSize = video.getFormattedSize()
    this.index = CommonConstants.VIDEO_HTTPS_LISTS.findIndex(item => {
      // 比较时也需要处理 Resource 类型
      if (typeof item.url === 'string') {
        return item.url === this.videoName;
      }
      return false;
    });
    // 从 videoInfo 同步下载状态
    this.isPlaying = !(video.isDownloading ?? false);
    // 重置下载速度数据
    this.resetDownloadSpeed();
  }

  // 界面销毁监听
  async aboutToDisappear(): Promise<void> {
    // 先清理缓存监听器
    this.clearCacheListener();

    // 销毁当前视频连接
    this.destroyCurrentConnect();

    // 注销播放器回调
    this.setOffCallback();

    // 释放播放器
    try {
      if (this.avPlayer && this.avPlayer.state !== 'released') {
        if (this.avPlayer.state === 'playing' || this.avPlayer.state === 'paused') {
          await this.avPlayer.stop();
        }
        await this.avPlayer.release();
      }
    } catch (err) {
    }
    this.avPlayer = undefined;

    // 关闭缓存文件句柄
    if (this.cacheFileHandle) {
      try {
        fs.closeSync(this.cacheFileHandle);
      } catch (err) {
      }
      this.cacheFileHandle = null;
    }
  }

  // 设置播放时间上报监听
  timeUpdate(): void {
    this.avPlayer?.on('timeUpdate', (time: number) => {
      this.currentTime = this.mediaLibUtils.getShowTime(time);
      this.setValue = Math.round((time / this.duration) * 100);
    })
  }

  // 设置错误监听
  setErrorCallback(): void {
    this.avPlayer?.on('error', (error) => {
      const errorInfo = 'error happened,message is :' + error.message;
    })
  }

  playError(errorInfo: string) {
    promptAction.showToast({
      duration: 3000,
      message: errorInfo
    });
  }

  // 注销回调函数接口
  setOffCallback(): void {
    this.avPlayer?.off('volumeChange');
    this.avPlayer?.off('endOfStream');
    this.avPlayer?.off('seekDone');
    this.avPlayer?.off('durationUpdate');
    this.avPlayer?.off('speedDone');
    this.avPlayer?.off('bitrateDone');
    this.avPlayer?.off('bufferingUpdate');
    this.avPlayer?.off('startRenderFrame');
    this.avPlayer?.off('videoSizeChange');
    this.avPlayer?.off('audioInterrupt');
    this.avPlayer?.off('availableBitrates');
    this.avPlayer?.off('error');
    this.avPlayer?.off('stateChange');
  }

  //设置播放surfaceID，播放音频时无需设置
  setSurfaceID(): void {
    if (this.avPlayer !== undefined) {
      this.avPlayer.surfaceId = this.surfaceID;
    }
  }

  // 视频信息上报函数
  async setSourceInfo(): Promise<void> {
    // 音量变化回调函数
    this.avPlayer?.on('volumeChange', (vol: number) => {
    });
    // 视频播放结束触发回调
    this.avPlayer?.on('endOfStream', () => {
    });
    // seek操作回调函数
    this.avPlayer?.on('seekDone', (seekDoneTime: number) => {
    });
    // 视频总时长上报函数
    this.avPlayer?.on('durationUpdate', (duration: number) => {
    });
    // 设置倍速播放回调函数
    this.avPlayer?.on('speedDone', (speed: number) => {
    });
    // bitrate设置成功回调函数
    this.avPlayer?.on('bitrateDone', (bitrate: number) => {
    });
    // 缓冲上报回调函数
    this.avPlayer?.on('bufferingUpdate', (infoType: media.BufferingInfoType, value: number) => {
      switch (infoType) {
        case media.BufferingInfoType.BUFFERING_START:
          this.isBuffering = false;
          break;
        case media.BufferingInfoType.BUFFERING_END:
          this.isBuffering = true;
          break;
        case media.BufferingInfoType.BUFFERING_PERCENT:
          break;
        case media.BufferingInfoType.CACHED_DURATION:
          break;
        default:
          break;
      }
    });
    // 首帧上报回调函数
    this.avPlayer?.on('startRenderFrame', () => {
    });
    // 视频宽高上报回调函数
    this.avPlayer?.on('videoSizeChange', (width: number, height: number) => {
    });
    // 焦点上报回调函数
    this.avPlayer?.on('audioInterrupt', (info: audio.InterruptEvent) => {
      // 触发焦点上报后调用暂停接口暂停播放
      this.pause();
      // this.isPlaying = !this.isPlaying;
    });
    // HLS上报所有支持的比特率
    this.avPlayer?.on('availableBitrates', (bitrates: Array<number>) => {
    });
  }

  // 状态机上报回调函数
  async setStateChangeCallback(): Promise<void> {
    this.avPlayer?.on('stateChange', async (state, reason) => {
      switch (state) {
        case 'idle':
          break;
        case 'initialized':
          if (this.isNext) {
            this.setSurfaceID();
            await this.avPlayer?.prepare();
          }
          break;
        case 'prepared':
          // 设置焦点上报类型
          if (this.avPlayer !== undefined) {
            this.avPlayer.audioInterruptMode = audio.InterruptMode.INDEPENDENT_MODE;
            this.duration = this.avPlayer?.duration;
            this.durationTimeText = this.mediaLibUtils.getShowTime(this.duration);
            this.play();
            if (this.isNext) {
              this.isNext = false;
            }
          }
          break;
        case 'playing':
          break;
        case 'paused':
          if (!this.isPlaying) {
            // this.isPlaying = !this.isPlaying;
          }
          break;
        case 'completed':
          this.isPlaying = !this.isPlaying;
          this.videoState.playStatus = false;
          break;
        case 'stopped':
          break;
        case 'released':
          break;
        case 'error':
          break;
        default:
          break;
      }
    });
  }

  // 创建AVPlayer实例对象
  async createAVPlayerAction1() {

    if (this.avPlayer !== undefined) {
      try {
        this.setOffCallback();
        if (this.avPlayer.state !== 'released') {
          if (this.avPlayer.state === 'playing' || this.avPlayer.state === 'paused') {
            await this.avPlayer.stop();
          }
          await this.avPlayer.release();
        }
      } catch (err) {
      }
      this.avPlayer = undefined;
    }
  }

  // 创建AVPlayer实例对象
  async createAVPlayerAction2() {

    // 关闭旧的文件句柄（如果存在）
    if (this.cacheFileHandle) {
      try {
        fs.closeSync(this.cacheFileHandle);
      } catch (err) {
      }
      this.cacheFileHandle = null;
    }

    // 重置准备状态
    this.isPrepare = false;
  }

  // 创建AVPlayer实例对象
  createAVPlayerAction3(server: HttpProxyCacheServer | undefined): HttpProxyCacheServer {
    if (!server) {
      server = new HttpProxyCacheServerBuilder(getContext()).build();
      GlobalProxyServer?.getInstance()?.setServer(server);
    }

    // 注册缓存监听器
    try {
      server.registerCacheListener(this.currentCacheListener, this.videoName);
    } catch (err) {
    }
    return server
  }

  // 创建AVPlayer实例对象
  async createAVPlayer(): Promise<boolean> {
    let ret = false
    let self = this;

    // 先销毁当前视频的连接
    this.destroyCurrentConnect();

    // 清理之前的监听器
    this.clearCacheListener();
    await this.createAVPlayerAction1()
    await this.createAVPlayerAction2()
    try {
      this.avPlayer = await media.createAVPlayer();
    } catch (error) {
      this.avPlayer = undefined
    }
    if (this.avPlayer !== undefined) {
      ret = true;
    }

    // 创建新的缓存监听器并保存引用
    this.currentCacheListener = new MyCacheListener(this);

    // 获取或复用代理服务器实例
    let server: HttpProxyCacheServer | undefined = GlobalProxyServer?.getInstance()?.getServer();
    server = this.createAVPlayerAction3(server)

    let proxyUrl: string | undefined;
    try {
      proxyUrl = await server?.getProxyUrl(this.videoName);
    } catch (err) {
    }

    let newUrl = proxyUrl ? proxyUrl : this.videoName;
    // 由于avplayer不支持直接加载本地文件路径 这里需要转化为fd的路径
    if (newUrl.startsWith(getContext().cacheDir)) {
      try {
        // 先关闭之前的文件句柄
        if (self.cacheFileHandle) {
          try {
            fs.closeSync(self.cacheFileHandle);
          } catch (err) {
          }
          self.cacheFileHandle = null;
        }

        // 打开缓存文件并保存句柄，不要在 finally 中关闭
        self.cacheFileHandle = fs.openSync(newUrl, fs.OpenMode.READ_ONLY);
        newUrl = 'fd://' + self.cacheFileHandle.fd;
        if (self.videoInfo) {
          self.videoInfo.currentCachePercent = 100;
        }
        self.downloadSpeed = '下载完成';
      } catch (error) {
        // 打开失败时回退到原始URL
        newUrl = this.videoName;
      }
    } else {
      // 开始下载时重置速度计算
      self.resetDownloadSpeed();
    }
    this.fdPath = newUrl;
    if (this.avPlayer && this.getState() === 'idle') {
      this.avPlayer.url = this.fdPath;
    }
    return ret;
  }

  // 调用播放接口
  async play(state?: string): Promise<void> {
    if (this.getState() === 'paused') {
      this.avPlayer?.play();
      this.videoState.playStatus = true
      return
    }
    if (!this.isPrepare) {
      // 设置surfaceID，当播放的问题纯音频时，无需设置
      if (this.getState() === 'initialized') {
        this.setSurfaceID();
        if (state !== 'playing' && this.avPlayer !== undefined) {
          this.avPlayer.prepare().then(() => {
            if (this.avPlayer !== undefined) {
              this.avPlayer.setMediaMuted(media.MediaType.MEDIA_TYPE_AUD, true);
            }
          }, (err: BusinessError) => {
          });
        }
        await this.avPlayer?.prepare();
      }
      this.isPrepare = !this.isPrepare;
    }
    this.avPlayer?.play();
    this.videoState.playStatus = true
    if (state === 'playing') {
      this.zoomVideo('zoomIn')
      if (this.avPlayer !== undefined) {
        this.avPlayer.setMediaMuted(media.MediaType.MEDIA_TYPE_AUD, false);
      }
    }
  }

  // 暂停接口
  pause(): void {
    this.avPlayer?.pause();
    this.videoState.playStatus = false
  }

  // 获取当前播放时间函数
  getCurrentTime(): number {
    return this.avPlayer?.currentTime ? this.avPlayer?.currentTime : 0;
  }

  // 获取当前播放状态函数
  getState(): string {
    return this.avPlayer?.state ? this.avPlayer?.state : '';
  }

  // 初始化函数
  async initAVPlayer(): Promise<void> {
    this.fdPath = this.videoName;
    this.surfaceID = this.mXcomponentController.getXComponentSurfaceId();
    await this.createAVPlayer();
    this.setStateChangeCallback();
    this.setErrorCallback();
    this.timeUpdate();
    this.setSourceInfo();
  }

  // 在切换视频前，先销毁当前的连接
  destroyCurrentConnect() {
    try {
      if (this.videoName) {
        const server = GlobalProxyServer?.getInstance()?.getServer();
        if (server) {
          server.destroyCurrentSource(this.videoName);
        }
      }
    } catch (err) {
    }
  }

  // 清理缓存监听器
  private clearCacheListener() {
    try {
      if (this.currentCacheListener && this.videoName) {
        const server = GlobalProxyServer?.getInstance()?.getServer();
        if (server) {
          server.unregisterCacheListener(this.currentCacheListener, this.videoName);
        }
        this.currentCacheListener = null;
      }
    } catch (err) {
    }
  }

  // 视频缩放处理
  zoomVideo(operation: string) {
    if (operation === 'zoomIn') {
      //视频窗口横屏
      this.isLandscape = true
      this.modifier.isTop = true
      this.windowClass.setWindowSystemBarEnable([])
      this.setOrientation(window.Orientation.LANDSCAPE);
      this.videoState.isPlaying = true
      this.videoState.videoName = this.videoName
    } else if (operation === 'zoomOut') {
      //视频窗口竖屏
      this.isLandscape = false
      this.modifier.isTop = false
      this.windowClass.setWindowSystemBarEnable(['navigation', 'status'])
      this.setOrientation(window.Orientation.PORTRAIT);
    }
  }
}
