import { fileIo, fileUri, fileIo as fs } from '@kit.CoreFileKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { media } from '@kit.MediaKit';
import { image } from '@kit.ImageKit';
import { common } from '@kit.AbilityKit';
import { HashMap } from '@kit.ArkTS';
import { BusinessError, systemDateTime } from '@kit.BasicServicesKit';
import { VideoSizeData } from '../model/VideoSizeData';
import ConstantsUtil from '../utils/ConstantsUtil';
import { DisplayUtil } from '../utils/DisplayUtil';
import {
  BasicVideoData,
  dataInfo,
  EditTextSnapModel,
  exportClipVideo,
  exportJoinVideo,
  exportPipVideo,
  exportSubTitle,
  exportVideo,
  frameListData,
  PipVideoData,
  VideoParam,
} from 'video_common';
import { getVideoData, initializeFolder,
  judgeVideoLegality,
  saveScreenshot } from '../utils/CommonUtils';
import { window } from '@kit.ArkUI';
import { PlayerState, VideoPlayerManager } from '../utils/VideoPlayerManager';
import { SubtitlesSingleModel } from '../model/SubtitlesSingleModel';
import { VELoading } from '../components/VELoading';
import { PrompterListVM } from './PrompterListVM';
import { EditTextVM } from './EditTextVM';

@ObservedV2
export class VideoEditDetailVM {
  private static _instance: VideoEditDetailVM;
  @Trace isVip: boolean = false
  @Trace allBasicList: frameListData[][] = []
  @Trace allPipList: frameListData[][] = []
  @Trace allBasicListDisplay: BasicVideoData[] = []
  @Trace temFrameList: frameListData[] = []
  @Trace allBasicEnableMap: HashMap<number, boolean> = new HashMap()
  @Trace allBasicListLeftXMap: HashMap<number, number> = new HashMap()
  @Trace basicListNumber: number = -1
  @Trace basicParentSelectIndex = -1
  @Trace basicChildSelectIndex = -1
  @Trace pipListNumber: number = -1
  @Trace pipWidth: number = 0; //画中画拉伸宽度
  @Trace pipHeight: number = 0; //画中画拉伸高度
  @Trace pipTempW: number = 0; //画中画宽度-临时变量
  @Trace pipTempH: number = 0; //画中画高度-临时变量
  @Trace isShape: boolean = false //画中画是否椭圆
  // 获取帧图
  @Trace pixelMapBasicList: image.PixelMap[] = [];
  @Trace pixelMapPipList: image.PixelMap[] = [];
  @Trace allPipListDisplay: PipVideoData[] = []
  @Trace pixelMapPipListLength: number = 0;
  @Trace showPip: boolean = false;
  @Trace showBasic: boolean = false;
  @Trace selectBasicOrPip: boolean = true; // true: 基本视频 false: 画中画
  @Trace basicVideoCover: frameListData = { index: 0, mPixelMap: undefined, url: '' }
  @Trace videoCover: frameListData = { index: 0, mPixelMap: undefined, url: '' }
  @Trace pipXOffset: number = 0
  @Trace pipXDistance: number = 0
  // 封面
  @Trace showCover: boolean = true;
  @Trace maxWidth: number = -1
  @Trace srcWidth: number = 0
  @Trace srcHeight: number = 0
  @Trace clipWidth: number = 0
  @Trace clipHeight: number = 0
  @Trace srcPipWidth: number = 0
  @Trace srcPipHeight: number = 0
  @Trace clipPipWidth: number = 0
  @Trace clipPipHeight: number = 0
  @Trace clipPipWidthT: number = 0
  @Trace clipPipHeightT: number = 0
  @Trace currentFrameWidth: number = 0
  @Trace currentFrameHeight: number = 0
  @Trace showBottomViewFlag: boolean = false
  @Trace selectedBottomBtn: number = 0
  @Trace basicDuration: number = 0
  @Trace durationLength: number[] = []
  @Trace pipDuration: number = 0
  @Trace selectBasicUri: string = '';
  @Trace selectPipUri: string = ''
  @Trace avImageGenerator: media.AVImageGenerator | undefined = undefined;
  @Trace videoSize: VideoSizeData = new VideoSizeData();
  @Trace childListRightWidth: number = 0
  @Trace childListLeftWidth: number = 0
  @Trace handlerOffsetX: number = 0
  @Trace leftWidthOrigin: number = 0
  @Trace basicThumbnailWidth: number = 50
  @Trace pipThumbnailWidth: number = 30
  @Trace leftHandleX: number = 0 // 左滑块实时位置（vp）
  @Trace rightHandleX: number = 0 // 右滑块实时位置（vp）
  @Trace currentBasicFrame: image.PixelMap | undefined = undefined
  @Trace currentPipFrame: image.PixelMap | undefined = undefined
  @Trace basicFileUriList: string[] = []
  @Trace pipFileUriList: string[] = []
  //视频数据
  @Trace currentWhiteLineIndex: number = 0
  @Trace currentWhiteLineParentIndex: number = 0
  @Trace isPlayedAll: boolean = false
  @Trace currentSeekTime: number = 0
  @Trace offsetPipX: number = 0;
  @Trace offsetPipY: number = 0;
  //导出视频相关
  @Trace exportClipVideos: exportClipVideo[] = []
  @Trace exportJoinVideos: exportJoinVideo[] = []
  @Trace exportPipVideos: exportPipVideo[] = []
  @Trace exportVideos: exportVideo[] = []
  @Trace exportSubTitle: exportSubTitle = {
    url: '',
    text: '',
    offsetX: 0,
    offsetY: 0,
    width: 0,
    height: 0
  }
  @Trace exportTextSnapList: EditTextSnapModel[] = []
  @Trace videoFormat: string = 'mp4'
  @Trace videoResolution: string = '1080'
  @Trace totalDuration: number = 0
  @Trace subtitlesValue: string = ''
  @Trace needDeleteFlag: boolean = false
  @Trace subTitleX: number = 0
  @Trace subTitleY: number = 0
  @Trace subTitleWidth: number = 0
  @Trace subTitleHeight: number = 0
  //记录每个手柄的信息
  @Trace videoParams: VideoParam[] = []
  @Trace listRightHandlerPosition: number[] = []
  @Trace isPlaying: boolean = false
  //记录下拉框的index
  @Trace videoResolutionIndex: number = 0
  @Trace videoFormatIndex: number = 0
  @Trace isSelectPip: boolean = false
  @Trace surfaceId: string = '';
  @Trace surfacePipId: string = '';
  @Trace avPlayerPip: media.AVPlayer | null = null
  @Trace status: string = '';
  @Trace currentTime: number = 0;
  @Trace currentScrollX: number = 0;
  @Trace fullCurrentTime: number = 0;
  @Trace currentPipTime: number = 0;
  @Trace clipIndex: number = 0; // 当前播到第几个片段
  @Trace isBasicSeeking: boolean = false
  @Trace pendingBasicSeek: number | null = null
  @Trace isPipSeeking: boolean = false // 锁
  @Trace pendingPipSeek: number | null = null // 缓存未完成的 seek
  //全屏播放
  @Trace isFullScreen: boolean = false
  @Trace windowClass?: window.Window = undefined
  @Trace commonWidth: number = 0
  @Trace videoPlayer: VideoPlayerManager | null = null
  @Trace currentState: PlayerState = {
    isPlaying: false,
    isLoading: false,
    currentIndex: -1,
    currentSegmentPlayed: 0,
    totalPlayDuration: 0,
    errorMessage: '',
    status: 'idle',
    width: 0,
    height: 0
  };
  //合成回调code
  @Trace resultCode: number = 0
  @Trace touchScroll: boolean = false
  @Trace touchVoice: boolean = false
  @Trace zoomInFlag: boolean = false
  @Trace isComposeLoading: boolean = false
  //抽帧进度标识位置
  @Trace isLoading: boolean = false
  @Trace isAbortFetch: boolean = false; //用于控制帧获取的控制器（可手动终止）
  btnGradientColor: LinearGradient = { angle: 225, colors: [['#01FCEA', 0.0], ['#01A8FE', 1.0]] }
  // 字幕数据
  @Trace subtitlesList: SubtitlesSingleModel[] = [];
  // 记录屏幕的宽度，用于下次计算提词器位置
  @Trace oldWidth: number = DisplayUtil.getWidth();
  // 记录屏幕的高度，用于下次计算提词器位置
  @Trace oldHeight: number = DisplayUtil.getHeight();
  // 记录屏幕尺寸变化前，是否是全屏模式播放
  oldIsFull: boolean = false;
  // 记录屏幕中播放器（裁剪后的部分）的宽度，用于下次计算提词器位置
  oldClipWidth: number = 0;
  // 记录屏幕中播放器（裁剪后的部分）的高度，用于下次计算提词器位置
  oldClipHeight: number = 0;
  @Trace loadingText: string = ''
  // 登录状态
  isLogin: boolean = false;

  public init(ctx: common.UIAbilityContext) {
    this.windowClass = ctx.windowStage.getMainWindowSync();
  }

  public static get instance() {
    if (!VideoEditDetailVM._instance) {
      VideoEditDetailVM._instance = new VideoEditDetailVM();
    }
    return VideoEditDetailVM._instance;
  }

  async initData(mContext: UIContext, jsonStr: string) {
    initializeFolder(mContext)
    // 只能调用一次添加窗口尺寸变化的监听
    this.onWindowChangeListener(mContext);
    if (jsonStr === '') {
      return;
    }
    if (jsonStr.includes('videoFormat')) {
      let exportData = JSON.parse(jsonStr) as exportVideo
      this.isVip = exportData.isVip
      this.videoFormat = exportData.videoFormat
      this.videoFormatIndex = exportData.videoFormatIndex
      this.videoResolution = exportData.videoResolution
      this.videoResolutionIndex = exportData.videoResolutionIndex
      this.basicDuration = exportData.totalDuration
      this.totalDuration = Math.max(this.basicDuration, this.pipDuration + this.pipXDistance * 1000)
      this.videoCover.url = exportData.keyFrame
      let basicListLength = 0
      exportData.basicVideoData.forEach((item) => {

        let basicVideoParam: BasicVideoData = {
          basicUrl: item.basicUrl,
          frameList: item.frameList,
          index: item.index,
          startTime: item.startTime,
          endTime: item.endTime,
          duration: item.duration,
          leftShort: item.leftShort,
          splitLeft: item.splitLeft,
          scroller: new Scroller(),
          keyId: systemDateTime.getTime(true).toString(),
          videoWidth: item.videoWidth,
          videoHeight: item.videoHeight
        }
        this.allBasicListDisplay.push(basicVideoParam)
        let listRightHandlerPostion: number = Number((item.duration / 1000).toFixed(3)) * this.basicThumbnailWidth
        this.listRightHandlerPosition.push(listRightHandlerPostion)
        basicListLength += Math.min(item.frameList?.length, listRightHandlerPostion / this.basicThumbnailWidth)
      })
      this.srcWidth = exportData.basicVideoData[0]?.videoWidth
      this.srcHeight = exportData.basicVideoData[0]?.videoHeight
      if (this.srcWidth > this.srcHeight) {
        this.clipWidth = mContext.px2vp(ConstantsUtil.BASIC_VIDEO_WIDTH)
        this.clipHeight = this.clipWidth * (this.srcHeight / this.srcWidth)
      } else {
        this.clipHeight = mContext.px2vp(ConstantsUtil.BASIC_VIDEO_HEIGHT)
        this.clipWidth = this.clipHeight * (this.srcWidth / this.srcHeight)
      }
      if (this.allBasicListDisplay && this.allBasicListDisplay.length > 0) {
        this.showBasic = true
        if (this.surfaceId !== '') {
          this.initBasicPlayer()
        }
      }
      exportData.exportPipVideo.forEach((item) => {
        let pipVideoParam: exportPipVideo = {
          isEdit: item.isEdit,
          isShape: item.isShape,
          uri: item.uri,
          pipFrameList: item.pipFrameList,
          startTime: item.startTime,
          endTime: item.endTime,
          duration: item.duration,
          keyFrame: item.keyFrame,
          width: item.width,
          height: item.height,
          offsetX: item.offsetX,
          offsetY: item.offsetY,
          offsetPipX: item.offsetPipX,
          offsetPipY: item.offsetPipY,
          radiusX: item.radiusX,
          radiusY: item.radiusY,
          srcWidth: item.srcWidth,
          srcHeight: item.srcHeight,
          xOffsetDistance: item.xOffsetDistance
        }
        this.offsetPipX = item.offsetPipX
        this.offsetPipY = item.offsetPipY
        this.pipXDistance = item.xOffsetDistance
        this.pipXOffset = item.xOffsetDistance * this.basicThumbnailWidth
        this.exportPipVideos.push(pipVideoParam)
      })
      if (this.exportPipVideos && this.exportPipVideos.length > 0) {
        if (this.pipXDistance !== 0) {
          this.showPip = false
        } else {
          this.showPip = true
        }
        this.isShape = this.exportPipVideos[0].isShape
        this.clipPipWidth = this.exportPipVideos[0].srcWidth
        this.clipPipHeight = this.exportPipVideos[0].srcHeight
        this.pixelMapPipListLength = Number((this.exportPipVideos[0].duration / 1000).toFixed(3))
        await this.initPipPlayer()
      }
      this.exportSubTitle.url = exportData.exportSubTitle.url
      this.exportSubTitle.text = exportData.exportSubTitle.text
      this.exportSubTitle.width = exportData.exportSubTitle.width
      this.exportSubTitle.height = exportData.exportSubTitle.height
      this.exportSubTitle.offsetX = exportData.exportSubTitle.offsetX
      this.exportSubTitle.offsetY = exportData.exportSubTitle.offsetY
      this.subtitlesValue = exportData.exportSubTitle.text ?? ''
      this.exportTextSnapList = exportData.editTextSnapList
      this.updateMaxWidth(mContext, basicListLength ?? 0, this.pixelMapPipListLength, this.pixelMapPipListLength)

    } else {
      let paramsInfo = JSON.parse(jsonStr) as dataInfo
      this.selectBasicUri = paramsInfo.url
      this.isVip = paramsInfo.isVip
      this.videoFormat = 'mp4'
      this.videoFormatIndex = 0
      this.videoResolution = '1080'
      this.videoResolutionIndex = 0
      this.videoSize = await getVideoData(this.selectBasicUri)
      this.basicDuration = this.videoSize.totalTime
      this.totalDuration = Math.max(this.basicDuration, this.pipDuration + this.pipXDistance * 1000)
      this.srcWidth = this.videoSize.photoSize.width ?? 0
      this.srcHeight = this.videoSize.photoSize.height ?? 0
      if (this.srcWidth > this.srcHeight) {
        this.clipWidth = mContext.px2vp(ConstantsUtil.BASIC_VIDEO_WIDTH)
        this.clipHeight = this.clipWidth * (this.srcHeight / this.srcWidth)
      } else {
        this.clipHeight = mContext.px2vp(ConstantsUtil.BASIC_VIDEO_HEIGHT)
        this.clipWidth = this.clipHeight * (this.srcWidth / this.srcHeight)
      }
      this.currentFrameWidth = this.clipWidth
      this.currentFrameHeight = this.clipHeight
      this.videoCover.mPixelMap = undefined
      this.videoCover.url = ''
      this.exportSubTitle = {
        url: '',
        text: '',
        offsetX: 0,
        offsetY: 0,
        width: 0,
        height: 0
      }
      this.subtitlesValue = ''
      this.exportTextSnapList = []
      await this.copyVideo(this.selectBasicUri, mContext)
      await this.onChange(mContext, this.selectBasicUri, this.basicDuration, true)
    }
  }

  public updateVideoSegments(list: BasicVideoData[]) {
    this.videoPlayer?.updateSegmentList(list)
  }

  public updateCoverData() {
    let coverData: frameListData = {
      index: 0,
      mPixelMap: this.allBasicListDisplay[0].frameList[0].mPixelMap,
      url: this.allBasicListDisplay[0].frameList[0].url
    }
    this.videoCover = coverData
    this.basicVideoCover = coverData
  }

  public async initPipPlayer() {
    if (!this.avPlayerPip) {
      try {
        this.avPlayerPip = await media.createAVPlayer();
        this.setPipPlayerCallback(this.avPlayerPip)
        const fd = await fileIo.open(this.exportPipVideos[0].uri, fileIo.OpenMode.READ_ONLY);
        const url = `fd://${fd.fd}`;
        this.avPlayerPip.url = url;
      }catch (error) {
      }
    }
  }

  //清空播放器
  public async clearPlayer(flag: number) {
    if (flag === 0) { //基本视频
      await this.videoPlayer?.destroy()
      this.videoPlayer = null
    } else { //画中画
      await this.avPlayerPip?.stop()
      await this.avPlayerPip?.reset()
      await this.avPlayerPip?.release()
      this.avPlayerPip = null
    }

  }

  public initBasicPlayer() {
    //创建播放器
    this.videoPlayer = new VideoPlayerManager(this.allBasicListDisplay, this.surfaceId);
    // 注册状态回调
    this.videoPlayer.registerStateChangeCallback((state) => {
      // 状态变化时更新状态
      this.currentState = state;
      if (state.width !== 0 && state.height !== 0) {
        this.srcWidth = state.width;
        this.srcHeight = state.height;
      }
    });
  }

  public playBasic(index: number, startTime: number) {
    this.videoPlayer?.startPlayback(index, startTime)
  }

  public pauseBasic() {
    this.videoPlayer?.pausePlayback()
  }

  //开启或者关闭原声
  openOrClose(flag: boolean) {
    this.videoPlayer?.setToMuteMode(!flag)
  }

  // 注册avplayer回调函数
  setPipPlayerCallback(avPlayer: media.AVPlayer) {
    // startRenderFrame首帧渲染回调函数
    avPlayer.on('startRenderFrame', () => {
      // 获取封面组件并隐藏
    })
    // seek操作结果回调函数
    avPlayer.on('seekDone', (_seekDoneTime: number) => {
      this.isPipSeeking = false
    })
    // error回调监听函数,当avPlayer在操作过程中出现错误时调用reset接口触发重置流程
    avPlayer.on('error', (_err: BusinessError) => {
      // 调用reset重置资源，触发idle状态
      avPlayer.reset();
    })
    avPlayer.on('timeUpdate', (time: number) => {
      this.currentPipTime = time;
      if (time - 100 > this.exportPipVideos[0].duration) {
        avPlayer.pause()
      }
    });
    avPlayer.on('durationUpdate', (_time: number) => {

    });
    // 状态机变化回调函数
    avPlayer.on('stateChange', async (state: string, _reason: media.StateChangeReason) => {
      switch (state) {
        case 'idle':
          break;
        case 'initialized':
          // 设置surfaceID
          avPlayer.surfaceId = this.surfacePipId;
          avPlayer.prepare();
          break;
        case 'prepared':
          avPlayer.seek(0)
          this.srcPipWidth = avPlayer.width
          this.srcPipHeight = avPlayer.height
          avPlayer.setMediaMuted(media.MediaType.MEDIA_TYPE_AUD, true);
          break;
        case 'playing':
          this.status = state;
          break;
        case 'paused':
          this.status = state;
          break;
        case 'completed':
          //调用播放结束接口
          avPlayer.stop();
          break;
        case 'stopped':
          avPlayer.prepare();
          break;
        case 'released':
          break;
        default:
          break;
      }
    })
  }

  // 播放
  playPip() {
    this.avPlayerPip?.play();
  }

  // 暂停
  pauseTogether() {
    this.isPlaying = false
    this.videoPlayer?.pausePlayback()
    this.avPlayerPip?.pause();
  }

  //跳转到指定时间
  seekToTime(time: number, index: number, direction: number) {
    let beforeTime = 0
    for (let i = 0; i < index; i++) {
      beforeTime += this.allBasicListDisplay[i].duration
    }
    if (time > this.basicDuration) {
      this.showBasic = false
    } else {
      this.showBasic = true
      this.videoPlayer?.seekTo(time, index, direction)
    }
    if (time >= this.pipXDistance * 1000 && time <= this.exportPipVideos[0]?.endTime + this.pipXDistance * 1000) {
      this.avPlayerPip?.seek(this.exportPipVideos[0].startTime + (time - this.pipXDistance * 1000), 2)
      this.isPipSeeking = true
    }
    this.currentSeekTime = time
  }

  async onChange(uiContext: UIContext, selectUri: string, duration: number, isBasic: boolean) {
    if (selectUri !== '' && duration !== 0) {
      await this.fetchFrameByTime(uiContext, duration, selectUri, isBasic);
    }
  }

  async copyVideo(selectedVideoUri: string, context: UIContext) {
    let file: fs.File | null = null;
    try {
      file = fs.openSync(selectedVideoUri);
      const DATE_STR = (new Date().getTime()).toString();
      let videoDir = context.getHostContext()?.cacheDir + ConstantsUtil.BASIC_VIDEO_URL
      let cacheVideoUri: string = fileUri.getUriFromPath(videoDir + `/${'basic_' + DATE_STR + '_' + file.name}`)
      await fs.copy(selectedVideoUri, cacheVideoUri);
      this.selectBasicUri = cacheVideoUri
      let basicVideoData: BasicVideoData = {
        basicUrl: this.selectBasicUri,
        frameList: [],
        index: this.basicListNumber,
        startTime: 0,
        endTime: this.basicDuration,
        duration: this.basicDuration,
        leftShort: 0,
        splitLeft: 0,
        scroller: new Scroller(),
        keyId: systemDateTime.getTime(true).toString(),
        videoWidth: this.srcWidth,
        videoHeight: this.srcHeight
      }
      this.allBasicListDisplay.push(basicVideoData)
      this.needDeleteFlag = true
      this.basicFileUriList.push(cacheVideoUri)
      this.initBasicPlayer()
    } finally {
      if (file) {
        fs.closeSync(file);
      }
    }
  }

  /**
   * 非阻塞获取帧 + 实时更新UI
   * 异步并发获取，每帧完成立即更新数据，不等待全量完成
   */
  async fetchFrameByTime(uiContext: UIContext, duration: number, filePath: string, isBasic: boolean) {
    this.isLoading = true
    VELoading.show('抽帧中')
    this.isAbortFetch = false
    let avImageGenerator: media.AVImageGenerator | undefined = undefined;
    let file: fs.File | undefined;
    this.temFrameList = [];
    try {
      avImageGenerator = await media.createAVImageGenerator();
      file = fs.openSync(filePath, fs.OpenMode.READ_ONLY);
      avImageGenerator.fdSrc = { fd: file.fd };

      const queryOption = media.AVImageQueryOptions.AV_IMAGE_QUERY_NEXT_SYNC;
      const param: media.PixelMapParams = {
        width: this.currentFrameWidth,
        height: this.currentFrameHeight,
      };

      if (isBasic) {
        this.fetchFrameInBasic(filePath,duration)
      }else {
        this.fetchFrameInPip()
      }
      // 非阻塞逐帧获取（异步并发，每帧完成立即更新UI）
      const fetchFrameTasks: Promise<void>[] = [];
      for (let timeUs = 0; timeUs < duration * 1000; timeUs += 1000000) {
        if (this.isAbortFetch) {
          break;
        }
        // 封装单帧获取任务（异步执行，不阻塞循环）
        const task = (async (currentTimeUs: number) => {
          try {
            if (this.isAbortFetch || !avImageGenerator) {
              return;
            }
            const frame = await avImageGenerator.fetchFrameByTime(currentTimeUs, queryOption, param);
            const frameData: frameListData = {
              index: currentTimeUs / 1000000,
              mPixelMap: frame,
              url: ''
            };

            // 实时更新 temFrameList（basicVideoData.frameList 同步变化）
            this.temFrameList.push(frameData);

            // 处理截图（异步，不阻塞帧显示）
            if (isBasic) {
              this.pixelMapBasicList.push(frame);
              this.showBasic = true;
              saveScreenshot(uiContext, frame, 0, '').then(url => {
                frameData.url = url;
                // 截图完成后刷新UI
                this.updateVideoSegments(this.allBasicListDisplay);
              });
            } else {
              this.pixelMapPipList.push(frame);
              this.showPip = true;
              saveScreenshot(uiContext, frame, 1, '').then(url => {
                if(!this.isAbortFetch){
                  frameData.url = url;
                }
              });
            }

            // 核心：每获取一帧就立即刷新UI（让UI感知到frameList变化）
            if (isBasic) {
              // 可选：更新封面（仅第一帧）
              if (currentTimeUs === 0) {
                this.currentBasicFrame = frame;
              }
            } else if (currentTimeUs === 0) {
              this.currentPipFrame = frame;
            }

          } catch (frameErr) {
          }
        })(timeUs);
        fetchFrameTasks.push(task);
        if (fetchFrameTasks.length >= 30) {
          await Promise.race(fetchFrameTasks); // 等待任一任务完成，再继续添加
          fetchFrameTasks.shift(); // 移除已完成的任务
        }
      }
      // 等待所有帧任务完成（非阻塞主线程，仅保证资源释放时机）
      if(!this.isAbortFetch){
        await Promise.allSettled(fetchFrameTasks);
      }
      this.isLoading = false
      VELoading.close();
      this.afterFetchFrame(uiContext,isBasic)
    } catch (error) {
    } finally {
      // 释放资源（所有帧任务完成后）
      if (avImageGenerator) {
        avImageGenerator.release();
      }
      if (file) {
        fs.closeSync(file);
      }
      // 重置终止标记 + 清空临时列表
      this.isAbortFetch = false;
      this.temFrameList = [];
    }
  }

  //基本视频获取帧图
  fetchFrameInBasic(filePath: string, duration: number){
    let basicVideoData: BasicVideoData | undefined;
    this.basicListNumber++;
    this.basicParentSelectIndex++;
    basicVideoData = {
      basicUrl: filePath,
      frameList: this.temFrameList, // 引用关联，实时更新
      index: this.basicListNumber,
      startTime: 0,
      endTime: duration,
      duration: duration,
      leftShort: 0,
      splitLeft: 0,
      scroller: new Scroller(),
      keyId: systemDateTime.getTime(true).toString(),
      videoWidth: this.srcWidth,
      videoHeight: this.srcHeight
    };

    if (this.needDeleteFlag && this.allBasicListDisplay?.length === 1) {
      this.allBasicListDisplay.pop();
      this.needDeleteFlag = false;
    }
    this.allBasicListDisplay.push(basicVideoData);

    // 初始化基础配置（同步执行，不阻塞）
    const listRightHandlerPostion = duration / 1000 * this.basicThumbnailWidth;
    this.listRightHandlerPosition.push(listRightHandlerPostion);
    this.videoParams.forEach(item => item.showHandler = false);
    this.videoParams.push({
      showHandler: true,
      leftHandler: 0,
      rightHandler: this.childListRightWidth,
      width: this.childListRightWidth
    });
    this.allBasicEnableMap.set(this.basicListNumber, true);
    this.allBasicListLeftXMap.set(this.basicListNumber, 0);
    this.allBasicEnableMap.forEach((_, key) => {
      key !== this.basicListNumber && this.allBasicEnableMap.set(key, false);
    });
  }

  //画中画视频获取帧图
  fetchFrameInPip(){
    this.initPipPlayer();
    let exportPipVideo: exportPipVideo = {
      isEdit: true,
      isShape: false,
      uri: this.selectPipUri,
      pipFrameList: this.temFrameList,
      startTime: 0,
      endTime: this.pipDuration,
      duration: this.pipDuration,
      keyFrame: this.currentPipFrame,
      width: 0,
      height: 0,
      offsetX: 0,
      offsetY: 0,
      offsetPipX: 0,
      offsetPipY: 0,
      radiusX: 1,
      radiusY: 1,
      srcWidth: 0,
      srcHeight: 0,
      xOffsetDistance: this.pipXDistance
    }
    this.exportPipVideos.push(exportPipVideo)
    this.pixelMapPipListLength = Number((this.pipDuration / 1000).toFixed(3))
  }

  // 所有帧完成后的收尾逻辑
  afterFetchFrame(uiContext: UIContext, isBasic: boolean){
    if (isBasic) {
      this.allBasicList.push(this.temFrameList);
      this.updateCoverData()
      this.updateVideoSegments(this.allBasicListDisplay);  //更新视频片段源
    } else {
      this.pipListNumber++;
      this.allPipList.push(this.temFrameList);
    }
    // 更新最大宽度
    const basicLength = this.listRightHandlerPosition.reduce(
      (sum, item) => sum + Number((item / this.basicThumbnailWidth).toFixed(3)),
      0
    );
    this.updateMaxWidth(
      uiContext,
      basicLength,
      this.pixelMapPipListLength + this.pipXDistance,
      this.pixelMapPipListLength
    );
  }

  //根据当前白线位置所对应的帧，确定在哪个子项里面
  findTargetInParent(parent: BasicVideoData[], target: number): number {
    let currentStart = 0;
    for (let i = 0; i < parent.length; i++) {
      const child = parent[i];
      const childLength = Number((child.duration / 1000).toFixed(3));
      const currentEnd = currentStart + childLength;
      if (target >= currentStart && target <= currentEnd) {
        return i; // 检查目标是否在当前子项范围内
      }
      currentStart += childLength;
    }
    return -1; // 未找到匹配的子项
  }

  //切割子项并更新整个列表
  splitChildAndUpdate(parent: BasicVideoData[], childIndex: number, target: number): BasicVideoData[] {
    const newParent = [...parent];
    const targetItem = newParent[childIndex];
    if (!targetItem || target * 1000 >= targetItem.endTime) {
      return newParent;
    }
    // 计算target在子项内的相对位置（子项内部的索引）
    let currentStart = 0;
    let currentStartLength = 0
    for (let i = 0; i < childIndex; i++) {
      currentStart += parent[i].frameList.length - 1;
      currentStartLength += Number((this.listRightHandlerPosition[i] / this.basicThumbnailWidth).toFixed(3))
    }
    const relativeTarget = Math.ceil(target)
    const relativeIndex = relativeTarget - currentStart; // 相对位置
    // 切割子项为两部分（前半部分不包含target所在位置，后半部分包含）
    const originalFrameList = targetItem.frameList;
    const firstFramePart = originalFrameList.slice(0, relativeIndex);
    const secondFramePart = originalFrameList.slice(relativeIndex - 1);
    // 前半部分子项
    const firstPart: BasicVideoData = {
      basicUrl: targetItem.basicUrl,
      frameList: firstFramePart, // 替换为切割后的前半部分frameList
      index: targetItem.index,
      startTime: targetItem.startTime,
      endTime: targetItem.startTime + 1000 * (target - currentStartLength),
      duration: 1000 * (target - currentStartLength),
      leftShort: targetItem.leftShort,
      splitLeft: targetItem.splitLeft,
      scroller: new Scroller(),
      keyId: systemDateTime.getTime(true).toString(),
      videoWidth: targetItem.videoWidth,
      videoHeight: targetItem.videoHeight
    };
    // 后半部分子项
    const secondPart: BasicVideoData = {
      basicUrl: targetItem.basicUrl,
      frameList: secondFramePart,
      index: targetItem.index,
      startTime: firstPart.endTime, // 后半部分的开始时间 = 前半部分的结束时间
      endTime: targetItem.endTime,
      duration: targetItem.endTime -firstPart.endTime,
      leftShort: targetItem.leftShort,
      splitLeft: (target - Math.floor(target)),
      scroller: new Scroller(),
      keyId: systemDateTime.getTime(true).toString(),
      videoWidth: targetItem.videoWidth,
      videoHeight: targetItem.videoHeight
    };
    //handler手柄也添加新的信息
    let leftPartHandler = (firstPart.endTime - firstPart.startTime) / 1000 * this.basicThumbnailWidth
    let rightPartHandler = (secondPart.endTime - secondPart.startTime) / 1000 * this.basicThumbnailWidth
    this.listRightHandlerPosition[childIndex] = leftPartHandler
    this.listRightHandlerPosition.splice(childIndex, 1, leftPartHandler, rightPartHandler)
    newParent.splice(childIndex, 1, firstPart, secondPart);
    this.updateVideoSegments(newParent)
    return newParent;
  }

  //计算单个子List的总宽度
  calculateListWidth(uiContext: UIContext, itemWidth: number, headWidth: number,
    dataListLength: number): number {
    // 尾项宽度：原逻辑是"屏幕宽度 - 首项宽度"，保留原逻辑但需转为vp
    const screenWidthVp = uiContext.px2vp(DisplayUtil.getWidth())
    const tailWidth = screenWidthVp - headWidth
    // 总宽度 = 首项宽度 + 中间项总宽度（项数×每项宽度） + 尾项宽度
    return headWidth + dataListLength * itemWidth + tailWidth
  }

  //计算并更新三个子List的最大宽度
  updateMaxWidth(uiContext: UIContext, listLength1: number, listLength2: number, listLength3: number) {
    // 分别计算三个子List的宽度
    const width1 = this.calculateListWidth(uiContext, 50, 95, listLength1) // 第一个子List
    const width2 = this.calculateListWidth(uiContext, 50, 135, listLength2) // 第二个子List
    const width3 = this.calculateListWidth(uiContext, 50, 135, listLength3) // 第三个子List
    // 取最大值作为外层容器宽度
    this.maxWidth = Math.max(width1, width2, width3)
  }

  // 选择图库里的视频，保存到cache目录中
  async photoPick(uiContext: UIContext, selectFlag: boolean, pipXDistance: number) {
    let context = uiContext.getHostContext() as common.UIAbilityContext;
    let photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
    photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.VIDEO_TYPE;
    photoSelectOptions.maxSelectNumber = 1;
    let photoPicker = new photoAccessHelper.PhotoViewPicker();
    photoPicker.select(photoSelectOptions).then(async (photoSelectResult: photoAccessHelper.PhotoSelectResult) => {
      const DATE_STR = (new Date().getTime()).toString();
      let file: fs.File | null = null
      try {
        file = fs.openSync(photoSelectResult.photoUris[0]);
        let videoSize: VideoSizeData = await getVideoData(photoSelectResult.photoUris[0])
        let currentVideoDuration = videoSize.totalTime
        let currentVideoWidth = videoSize.photoSize.width ?? 0
        let currentVideoHeight = videoSize.photoSize.height ?? 0
        if (currentVideoWidth > currentVideoHeight) {
          this.currentFrameWidth = uiContext.px2vp(ConstantsUtil.BASIC_VIDEO_WIDTH)
          this.currentFrameHeight = this.currentFrameWidth * (currentVideoHeight / currentVideoWidth)
        } else {
          this.currentFrameHeight = uiContext.px2vp(ConstantsUtil.BASIC_VIDEO_HEIGHT)
          this.currentFrameWidth = this.currentFrameHeight * (currentVideoWidth / currentVideoHeight)
        }
        if(judgeVideoLegality(videoSize, 1)){
          if (selectFlag) {
            this.selectBasicUri =
              context.cacheDir + ConstantsUtil.BASIC_VIDEO_URL + `/${'basic_' + DATE_STR + file.name}`;
            fs.copyFileSync(file.fd, this.selectBasicUri)
            this.basicDuration = this.basicDuration + currentVideoDuration
            this.totalDuration = Math.max(this.basicDuration, this.pipDuration + this.pipXDistance * 1000)
            await this.onChange(uiContext, this.selectBasicUri, currentVideoDuration, true)
            this.basicFileUriList.push(this.selectBasicUri)
            let exportJoinVideo: exportJoinVideo = {
              uri: this.selectBasicUri,
              duration: this.basicDuration
            }
            this.exportJoinVideos.push(exportJoinVideo)
          } else {
            if(pipXDistance + currentVideoDuration > this.basicDuration){
              uiContext.getPromptAction().showToast({
                message: '当前指针位置添加的画中画视频不能超过主视频时长，请调整指针位置或者添加时长短一点的画中画视频'})
              return
            }
            this.selectPipUri = context.cacheDir + ConstantsUtil.PIP_VIDEO_URL + `/${'pip_' + DATE_STR + file.name}`;
            fs.copyFileSync(file.fd, this.selectPipUri)
            this.pipDuration = this.pipDuration + currentVideoDuration
            this.totalDuration = Math.max(this.basicDuration, this.pipDuration + this.pipXDistance * 1000)
            await this.onChange(uiContext, this.selectPipUri, currentVideoDuration, false)
            this.pipFileUriList.push(this.selectPipUri)
          }
        }else {
          uiContext.getPromptAction().showToast({message: '暂不支持4K或时长超过1分钟的视频'})
        }

      } catch (_error) {
      } finally {
        fs.closeSync(file);
      }
    }).catch((_err: BusinessError) => {
    });
  }

  // 视频缩放处理
  zoomVideo(operation: string, uiContext: UIContext) {
    if (operation === 'zoomOut') {
      //视频窗口横屏
      this.isFullScreen = true
      ConstantsUtil.isFullScreen = true;
      this.windowClass?.setWindowSystemBarEnable([])
      this.setOrientation(window.Orientation.LANDSCAPE, uiContext);
    } else if (operation === 'zoomIn') {
      //视频窗口竖屏
      this.isFullScreen = false
      ConstantsUtil.isFullScreen = false;
      this.windowClass?.setWindowSystemBarEnable(['navigation', 'status'])
      this.setOrientation(window.Orientation.PORTRAIT, uiContext);
    }
  }

  setOrientation(orientation: number, _uiContext: UIContext) {
    this.windowClass?.setPreferredOrientation(orientation).then(() => {
    }).catch((_err: BusinessError) => {
    });
  }

  /**
   * 屏幕尺寸变化监听
   */
  onWindowChangeListener(uiContext: UIContext) {
    this.windowClass?.on('windowSizeChange', (data) => {
      ConstantsUtil.currentDisplayWidth = data.width;
      ConstantsUtil.currentDisplayHeight = data.height;
      if (this.oldClipWidth === 0 && this.oldClipHeight === 0) {
        this.oldClipWidth = this.clipWidth;
        this.oldClipHeight = this.clipHeight;
      }
      this.commonWidth = uiContext.px2vp(data.width / 2)
      this.setClipSize(data);

      // 屏幕尺寸有变动
      if (this.oldWidth !== data.width) {
        // 提词器能移动区域的宽
        const beforeWidth = uiContext.px2vp(this.oldWidth);
        let beforeHeight = uiContext.px2vp(this.oldHeight);
        let scaleX = this.clipWidth / this.oldClipWidth;
        let scaleY = this.clipHeight / this.oldClipHeight;
        let displayHeight = px2vp(data.height);
        const displayWidth = px2vp(data.width);
        if (!this.isFullScreen) {
          displayHeight = displayHeight * 0.515;
        }
        if (!this.oldIsFull) {
          beforeHeight = beforeHeight * 0.515;
        }
        PrompterListVM.instance.editTexts.forEach((item: EditTextVM) => {
          // 上一步提词器距离播放器的宽高
          const distanceX = item.x - (beforeWidth - this.oldClipWidth) / 2;
          const distanceY = item.y - (beforeHeight - this.oldClipHeight) / 2;
          // 当前提词器的位置
          item.x = distanceX * scaleX + (displayWidth - this.clipWidth) / 2;
          item.y = distanceY * scaleY + (displayHeight - this.clipHeight) / 2;
          item.x = Math.min(item.x, displayWidth - item.width);
        })
      }

      this.oldWidth = data.width;
      this.oldHeight = data.height;
      this.oldIsFull = this.isFullScreen;
      this.oldClipWidth = this.clipWidth;
      this.oldClipHeight = this.clipHeight;
    })
  }

  setClipSize(data: Size) {
    const srcScale = this.srcHeight / this.srcWidth;
    let displayHeight = px2vp(data.height);
    const displayWidth = px2vp(data.width);
    if (!this.isFullScreen) {
      displayHeight = displayHeight * 0.515;
    }
    const displayScale = displayHeight / displayWidth;

    if (srcScale > displayScale) {
      // 图片高宽比大于坑位高宽比，图片填充时，高度撑满，宽度自适应
      this.clipHeight = displayHeight;
      this.clipWidth = this.clipHeight / srcScale;
    } else {
      // 图片高宽比小于等于坑位高宽比，图片填充时，宽度撑满，高度自适应
      this.clipWidth = displayWidth;
      this.clipHeight = this.clipWidth * srcScale;
    }
  }

  /**
   * 移除屏幕尺寸变化的监听
   */
  offWindowChangeListener() {
    this.windowClass?.off('windowSizeChange');
  }

  async clearAll() {
    this.clearPlayer(0)
    this.clearPlayer(1)
    this.avImageGenerator?.release();
    this.allBasicListDisplay = []
    this.basicFileUriList = []
    this.pipFileUriList = []
    this.exportPipVideos = []
    this.pixelMapBasicList = []
    this.pixelMapPipList = []
    this.listRightHandlerPosition = []
    this.subtitlesValue = ''
    this.exportSubTitle.url = ''
    this.selectBasicUri = ''
    this.selectPipUri = ''
    this.surfaceId = ''
    this.surfacePipId = ''
    this.videoCover.mPixelMap = undefined
    this.videoCover.url = ''
    this.showBasic = false
    this.showPip = false
    this.pipXOffset = 0
    this.pipXDistance = 0
    this.currentScrollX = 0
    this.currentTime = 0
    this.basicDuration = 0
    this.pipDuration = 0
    this.isShape = false
    this.isComposeLoading = false
    this.maxWidth = -1
    this.isFullScreen = false
    this.pixelMapPipListLength = 0
    this.offsetPipX = 0
    this.offsetPipY = 0
    this.clipWidth = 0
    this.clipHeight = 0
    this.clipPipWidth = 0
    this.clipPipHeight = 0
    this.offWindowChangeListener();
  }
}
