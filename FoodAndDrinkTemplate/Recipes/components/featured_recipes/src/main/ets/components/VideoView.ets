import display from '@ohos.display';
import { common, wantAgent } from '@kit.AbilityKit';
import media from '@ohos.multimedia.media';
import { fileIo as fs } from '@kit.CoreFileKit';
import { UtilLog } from '@hw-agconnect/util-log';
import { avSession } from '@kit.AVSessionKit';
import { audio } from '@kit.AudioKit';
import { backgroundTaskManager } from '@kit.BackgroundTasksKit';
import { RecipeBriefInfo } from '../types/Index';
import { Constants } from '../constants/Constants';
import { PipController } from '../utils/PipController';
import { VideoViewVM } from '../viewModels/VideoViewVM';
import { PiPWindowModel } from '../models/PiPWindowModel';
import { AppStorageV2, PiPWindow } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';

@ComponentV2
export struct VideoView {
  @Local vm: VideoViewVM = new VideoViewVM();
  @Param isSlider: boolean = false;
  @Param videoData: RecipeBriefInfo = new RecipeBriefInfo();
  @Param showPip: boolean = false;
  @Param isFullScreen: boolean = true;
  @Param breakPoint: string = 'sm';
  @Param videoUrl: string = '';
  @Param isCover: boolean = false;
  @Param detailScroller: Scroller = new Scroller();
  @Param isStop: boolean = false;
  tag: string = 'AVPlayManager';
  private xComponentController: XComponentController = new XComponentController();
  private avPlayer: media.AVPlayer | null = null;
  private surfaceId: string = '';
  private intervalID: number = -1;
  private seekTime: number = -1;
  private context: common.UIAbilityContext | undefined = undefined;
  private session: avSession.AVSession | null = null;
  private currentState: avSession.AVPlaybackState = {
    state: avSession.PlaybackState.PLAYBACK_STATE_PAUSE
  };
  @Local isSwiping: boolean = false; // 用户滑动过程中
  @Local isPaused: boolean = false; // 暂停播放
  @Local xComponentFlag: boolean = false;

  @Local windowWidth: number = 300;
  @Local windowHeight: number = 200;
  @Local subtitle: string = '';
  @Event onClickCb: (id: number) => void = () => {
  }
  @Local pipController: PipController = new PipController();
  @Local pipWindowModel: PiPWindowModel = AppStorageV2.connect(PiPWindowModel, () => new PiPWindowModel())!;
  @Event showFullScreen: () => void = () => {
  }

  @Monitor('showPip')
  onShowPip() {
    if(this.showPip) {
      if(this.avPlayer && !this.isPaused) {
        this.pipController.startPip(this.getUIContext().getHostContext() as Context, this.xComponentController,
          this.avPlayer, this.detailScroller)
      }
    } else {
      this.pipController.stopPip()
    }
  }

  @Monitor('pipWindowModel.videoPlayerStatus')
  onPlayState() {
    this.isPaused = this.pipWindowModel.videoPlayerStatus === 'paused';
    if(this.avPlayer && !this.isPaused) {
      this.vm.currentTime = this.vm.currentTime >= this.avPlayer.duration ? 0 : this.vm.currentTime;
    }
    this.setAVPlayerbackState(this.vm.currentTime);
  }

  @Monitor('isStop')
  onClosePip() {
    // 返回时出现的画中画，当关闭画中画时，需要销毁播放器对象
    if(this.isStop) {
      this.pipController.stopPip()
    }
  }

  async avSetupURL(){
    if (this.context === undefined) {
      return;
    }
    if (this.avPlayer) {
      UtilLog.info(`${this.tag}: init avPlayer release2createNew`);
      this.avPlayer.release();
      await this.vm.msleepAsync(1500);
    }
    // 创建avPlayer实例对象
    try {
      this.avPlayer = await media.createAVPlayer();
    } catch (e) {
      UtilLog.error('createAVPlayer fail, error: ' + JSON.stringify(e));
    }
    // 创建状态机变化回调函数
    await this.setAVPlayerCallback((avPlayer: media.AVPlayer) => {
      this.vm.percent = avPlayer.width / avPlayer.height;
      this.vm.setVideoWH();
      this.vm.durationTime = this.vm.getDurationTime();
      setInterval(() => { // 更新当前时间
        if (!this.isSwiping) {
          this.vm.currentTime = this.vm.getCurrentTime();
        }
      }, Constants.SET_INTERVAL);
    });
    // 设置对应的播放url
    if(this.videoData.video.includes('file:///')){
      let fdPath = 'fd://';
      let path = this.videoData.video;
      let file: fs.File | null = null;
      try {
        file = fs.openSync(path);
        fdPath = fdPath + '' + file.fd;
        if (this.avPlayer) {
          this.avPlayer.url = fdPath;
        }
      } catch (e) {
        UtilLog.error('fs.copyFileSync error: ' + JSON.stringify(e));
      } finally {
        if(this.avPlayer && this.avPlayer.url?.includes('file:///')) {
          fs.closeSync(file);
        }
      }
    } else {
      if(this.avPlayer) {
        if(this.videoUrl) {
          this.avPlayer.url = this.videoUrl;
        } else {
          this.avPlayer.url = this.videoData.video;
        }
      }
    }
  }

  async avTurnOffSubtitle() {
    this.avPlayer?.off('subtitleUpdate');
  }

  async avPlay(): Promise<void> {
    if (this.avPlayer) {
      if(this.vm.currentTime >= this.avPlayer.duration) {
        this.vm.currentTime = 0;
      }
      await this.CreateAVSession();
      await this.RegisterAVPlayerListener();
      try {
        this.avPlayer.play();
        this.setAVPlayerbackState(this.vm.currentTime)
      } catch (e) {
        UtilLog.error(`${this.tag}: avPlay = ${JSON.stringify(e)}`);
      }
    }
  }

  avPause(): void {
    if (this.avPlayer) {
      try {
        this.avPlayer.pause();
        this.setAVPlayerbackState(this.vm.currentTime)
        UtilLog.info(`${this.tag}: avPause==`);
      } catch (e) {
        UtilLog.info(`${this.tag}: avPause== ${JSON.stringify(e)}`);
      }
    }
  }

  async avSeek(seekTime: number, mode: SliderChangeMode): Promise<void> {
    if (this.avPlayer) {
      try {
        UtilLog.info(`${this.tag}: videoSeek  seekTime== ${seekTime}`);
        this.avPlayer.seek(seekTime, 2);
        this.vm.currentTime = seekTime;// 设置状态： 播放状态，进度位置，播放倍速，缓存的时间。
        this.setAVPlayerbackState(seekTime)
      } catch (e) {
        UtilLog.info(`${this.tag}: videoSeek== ${JSON.stringify(e)}`);
      }
    }
  }

  setAVPlayerbackState(currentTime: number): void {
    let playbackState: avSession.AVPlaybackState = {
      // 播放状态
      state: this.isPaused ? avSession.PlaybackState.PLAYBACK_STATE_PAUSE : avSession.PlaybackState.PLAYBACK_STATE_PLAY,
      position: {
        elapsedTime: currentTime, // 已经播放的位置，以ms为单位。
        updateTime: new Date().getTime(), // 应用更新当前位置时的时间戳，以ms为单位。
      },
    };
    let controlType: PiPWindow.PiPControlType = PiPWindow.PiPControlType.VIDEO_PLAY_PAUSE;
    let status: PiPWindow.PiPControlStatus = this.isPaused ?
      PiPWindow.PiPControlStatus.PAUSE : PiPWindow.PiPControlStatus.PLAY
    this.pipWindowModel.videoPlayerStatus = this.isPaused ? 'paused' : 'playing';
    if (this.pipWindowModel.pipController !== undefined) {
      this.pipWindowModel.pipController.updatePiPControlStatus(controlType, status);
    }
    this.session?.setAVPlaybackState(playbackState, (err) => {
      if (err) {
        UtilLog.error(`Failed to set AVPlaybackState. Code: ${err.code}, message: ${err.message}`);
      } else {
        UtilLog.info(`SetAVPlaybackState successfully`);
      }
    });
  }

  avSetSpeed(speed: number): void {
    if (this.avPlayer) {
      try {
        this.avPlayer.setSpeed(speed);
        UtilLog.info(`${this.tag}: avSetSpeed enum ${speed}`);
      } catch (e) {
        UtilLog.info(`${this.tag}: avSetSpeed == ${JSON.stringify(e)}`);
      }
    }
  }

  // 注册avplayer回调函数
  async setAVPlayerCallback(callback: (avPlayer: media.AVPlayer) => void, vType?: number): Promise<void> {
    // seek操作结果回调函数
    if (this.avPlayer == null) {
      UtilLog.info(`${this.tag}: avPlayer has not init!`);
      return;
    }
    this.avPlayer.on('seekDone', (seekDoneTime) => {
      UtilLog.info(`${this.tag}: setAVPlayerCallback AVPlayer seek succeeded, seek time is ${seekDoneTime}`);
    });
    this.avPlayer.on('speedDone', (speed) => {
      UtilLog.info(`${this.tag}: setAVPlayerCallback AVPlayer speedDone, speed is ${speed}`);
    });
    // error回调监听函数,当avPlayer在操作过程中出现错误时调用reset接口触发重置流程
    this.avPlayer.on('error', (err) => {
      UtilLog.error(`${this.tag}: setAVPlayerCallback Invoke avPlayer failed ${JSON.stringify(err)}`);
      if (this.avPlayer == null) {
        UtilLog.info(`${this.tag}: avPlayer has not init on error`);
        return;
      }
      this.avPlayer.reset();
    });
    // 状态机变化回调函数
    this.avPlayer.on('stateChange', async (state, reason) => {
      if (this.avPlayer == null) {
        UtilLog.info(`${this.tag}: avPlayer has not init on state change`);
        return;
      }
      switch (state) {
        case 'idle': // 成功调用reset接口后触发该状态机上报
          UtilLog.info(`${this.tag}: setAVPlayerCallback AVPlayer state idle called.`);
          break;
        case 'initialized': // avplayer 设置播放源后触发该状态上报
          UtilLog.info(`${this.tag}: setAVPlayerCallback AVPlayer state initialized called.`);
          if (this.surfaceId) {
            this.avPlayer.surfaceId = this.surfaceId; // 设置显示画面，当播放的资源为纯音频时无需设置
            UtilLog.info(`${this.tag}: setAVPlayerCallback this.avPlayer.surfaceId = ${this.avPlayer.surfaceId}`);
            this.avPlayer.prepare();
          }
          break;
        case 'prepared': // prepare调用成功后上报该状态机
          UtilLog.info(`${this.tag}: setAVPlayerCallback AVPlayer state prepared called.`);
          this.avPlayer.on('bufferingUpdate', (infoType: media.BufferingInfoType, value: number) => {
            UtilLog.info(`${this.tag}: bufferingUpdate called, infoType value: ${infoType}, value:${value}}`);
          })
          this.vm.durationTime = this.avPlayer.duration;
          this.vm.currentTime = this.avPlayer.currentTime;
          // 调用播放接口开始播放
          if(this.isCover) {
            this.isPaused = true;
            this.avPlayer.pause();
          } else {
            this.avPlay();
          }
          this.avPlayer?.seek(2, media.SeekMode.SEEK_PREV_SYNC);
          callback(this.avPlayer);
          break;
        case 'playing': // play成功调用后触发该状态机上报
          UtilLog.info(`${this.tag}: setAVPlayerCallback AVPlayer state playing called.`);
          if (this.intervalID !== -1) {
            clearInterval(this.intervalID)
          }
          this.intervalID = setInterval(() => { // 更新当前时间
          }, 100);
          break;
        case 'completed': // 播放结束后触发该状态机上报
          UtilLog.info(`${this.tag}: setAVPlayerCallback AVPlayer state completed called.`);
          this.isPaused = true;
          let controlType: PiPWindow.PiPControlType = PiPWindow.PiPControlType.VIDEO_PLAY_PAUSE;
          let status: PiPWindow.PiPControlStatus = PiPWindow.PiPControlStatus.PAUSE;
          this.pipWindowModel.videoPlayerStatus = 'paused';
          if (this.pipWindowModel.pipController !== undefined) {
            this.pipWindowModel.pipController.updatePiPControlStatus(controlType, status);
          }

          if (this.intervalID !== -1) {
            clearInterval(this.intervalID)
          }
          this.avPlayer.off('bufferingUpdate')
          break;
        case 'released':
          UtilLog.info(`${this.tag}: setAVPlayerCallback released called.`);
          break
        case 'stopped':
          UtilLog.info(`${this.tag}: setAVPlayerCallback AVPlayer state stopped called.`);
          break
        case 'error':
          UtilLog.info(`${this.tag}: setAVPlayerCallback AVPlayer state error called.`);
          break
        case 'paused':
          UtilLog.info(`${this.tag}: setAVPlayerCallback AVPlayer state paused called.`);
          break
        default:
          UtilLog.info(`${this.tag}: setAVPlayerCallback AVPlayer state unknown called.`);
          break;
      }
    });
    // 时间上报监听函数
    this.avPlayer.on('timeUpdate', (time: number) => {
      this.vm.currentTime = time;
    });

    this.avPlayer.on('subtitleUpdate', (info: media.SubtitleInfo) => {
      if (!!info) {
        let text = (!info.text) ? '' : info.text;
        let startTime = (!info.startTime) ? 0 : info.startTime;
        let duration = (!info.duration) ? 0 : info.duration;
        UtilLog.info('subtitleUpdate info: text=' + text + ' startTime=' + startTime +' duration=' + duration);
        this.subtitle = text;
      } else {
        UtilLog.info('subtitleUpdate info is null');
      }
    });
  }

  aboutToAppear() {
    this.windowWidth = display.getDefaultDisplaySync().width;
    this.windowHeight = display.getDefaultDisplaySync().height;
    this.vm.surfaceW = this.windowWidth * Constants.SURFACE_W;
    this.vm.surfaceH = this.vm.surfaceW / Constants.SURFACE_H;
    this.context = this.getUIContext().getHostContext() as common.UIAbilityContext;
  }

  aboutToDisappear() {
    if (this.avPlayer == null) {
      UtilLog.info(`${this.tag}: avPlayer has not init aboutToDisappear`);
      return;
    }
    this.avPlayer.release((err) => {
      if (err == null) {
        UtilLog.info(`${this.tag}: videoRelease release success`);
      } else {
        UtilLog.error(`${this.tag}: videoRelease release filed,error message is = ${JSON.stringify(err.message)}`);
      }
    });
    this.UnRegisterListener();
  }

  onPageHide() {
    this.startContinuousTask();
  }

  async startContinuousTask(): Promise<void> {
    let wantAgentInfo: wantAgent.WantAgentInfo = {
      wants: [
        {
          bundleName: 'com.Hlldemo.recipes',
          abilityName: 'EntryAbility'
        }
      ],
      actionType: wantAgent.OperationType.START_ABILITY,
      requestCode: 0,
      wantAgentFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
    };
    try {
      let tmpWantAgent = await wantAgent.getWantAgent(wantAgentInfo);
      this.session?.setLaunchAbility(tmpWantAgent);
      await backgroundTaskManager.startBackgroundRunning(this.context,
        backgroundTaskManager.BackgroundMode.AUDIO_PLAYBACK, tmpWantAgent);
    } catch (error) {
      let err = error as BusinessError;
      UtilLog.error(`startContinuousTask failed. error code=${err.code}, message=${err.message}`);
    }
  }

  async stopContinuousTask(): Promise<void> {
    try {
      await backgroundTaskManager.stopBackgroundRunning(this.context);
      UtilLog.info(`stop background startBackgroundRunning success`);
    } catch (e) {
      UtilLog.error(`stop background startBackgroundRunning err ${e.stack}`);
    }
  }

  async CreateAVSession(): Promise<boolean> {
    UtilLog.info(`Start create AVSession`);
    let ret: boolean = true;
    if (this.session) {
      UtilLog.info(`has a session: ` + this.session.sessionId);
      return ret;
    }
    try {
      this.session = await avSession.createAVSession(this.context!, 'AVSessionDemo', 'video');
      if(this.session) {
        this.setAVMetadataToController();
      }
      this.startContinuousTask();
    } catch (error) {
      let err = error as BusinessError;
      UtilLog.error(0x0000, 'ProviderManager', `createAVSession failed. error code=${err.code}, message=${err.message}`);
    }
    this.RegisterSessionListener();
    await this.session?.activate().catch((err: BusinessError) => {
      if (err) {
        UtilLog.error(`Failed to activate AVSession, error info: ${JSON.stringify(err)}`);
        ret = false;
      }
    });
    return ret;
  }

  async RegisterSessionListener(): Promise<void> {
    try {
      this.session?.on('play', async () => {
        UtilLog.info(`on play, do play task`);
        this.avPlayer?.play();
        this.isPaused = false;
        if(this.avPlayer) {
          if(this.vm.currentTime >= this.avPlayer.duration) {
            this.vm.currentTime = 0;
          }
        }
        this.setAVPlayerbackState(this.vm.currentTime)
      });

      this.session?.on('pause', async () => {
        UtilLog.info(`on pause, do pause task`);
        this.avPlayer?.pause();
        this.isPaused = true;
        this.setAVPlayerbackState(this.vm.currentTime)
      });

      this.session?.on('stop', async () => {
        UtilLog.info(`on stop , do stop task`);
        this.avPlayer?.stop();
        this.currentState.state = avSession.PlaybackState.PLAYBACK_STATE_PAUSE;
        await this.session?.setAVPlaybackState(this.currentState);
      });

      this.session?.on('seek', (position) => {
        UtilLog.info('on seek: seek to' + position);
        if(position >= this.vm.durationTime) {
          this.avPlayer?.pause();
          this.isPaused = true;
          this.vm.currentTime = 0;
        } else {
          this.vm.currentTime = position;
          this.avPlayer?.seek(position);
        }
        this.setAVPlayerbackState(position)
      });

      this.session?.on('setLoopMode', (mode) => {
        UtilLog.info('on setLoopMode: ' + mode);
        this.session?.setAVPlaybackState(this.currentState);
      });

      this.session?.on('fastForward', (skipInterval?: number) => {
        if(this.vm.currentTime + skipInterval! * 1000 > this.vm.durationTime) {
          this.vm.currentTime = 0;
          this.isPaused = true;
          this.avPlayer?.pause();
        } else {
          this.vm.currentTime = this.vm.currentTime + skipInterval! * 1000;
        }
        this.avPlayer?.seek(this.vm.currentTime);
        this.setAVPlayerbackState(this.vm.currentTime)
      });

      this.session?.on('rewind', (skipInterval?: number) => {
        if(this.vm.currentTime - skipInterval! * 1000 <= 0) {
          this.vm.currentTime = 0;
        } else {
          this.vm.currentTime = this.vm.currentTime - skipInterval! * 1000;
        }
        this.avPlayer?.seek(this.vm.currentTime);
        this.setAVPlayerbackState(this.vm.currentTime)
      });
    } catch (error) {
      let err = error as BusinessError;
      UtilLog.error(`RegisterSessionListener failed. error code=${err.code}, message=${err.message}`);
    }
  }

  async UnRegisterListener(): Promise<void> {
    if (this.session) {
      try {
        this.session.off('pause');
        this.session.off('stop');
        this.session.off('fastForward');
        this.session.off('rewind');
        this.session.off('seek');
        this.session.off('setLoopMode');
      } catch (error) {
        let err = error as BusinessError;
        UtilLog.error(`UnRegisterListener failed. error code=${err.code}, message=${err.message}`);
      }
      this.session.destroy((err) => {
        if (err) {
          UtilLog.error(`Destroy BusinessError: code: ${err.code}, message: ${err.message}`);
        } else {
          UtilLog.info('Destroy : SUCCESS');
        }
      });
    }
  }

  async setAVMetadataToController(): Promise<void> {
    let avMetadata: avSession.AVMetadata = {
      assetId: this.videoData.id.toString(), // 由应用指定，用于标识应用媒体库里的媒体。
      title: this.videoData.title,
      mediaImage: this.videoData.coverUrl,
      artist: this.videoData.author,
      duration: this.vm.durationTime,
    };
    UtilLog.info(`setAVMetadataToController avMetadata: ` + JSON.stringify(avMetadata));
    try {
      await this.session?.setAVMetadata(avMetadata);
    } catch (error) {
      let err = error as BusinessError;
      UtilLog.error(0x0000, 'ProviderManager', `setAVMetadata failed. error code=${err.code}, message=${err.message}`);
    }
  }

  async localPlayOrPause(): Promise<void> {
    try {
      UtilLog.info('localPlayOrPause start play' + this.avPlayer?.state);
      if (!this.avPlayer) {
        UtilLog.error('localPlayOrPause start play no avplayer');
        return;
      }
      if (this.avPlayer.state === 'playing') {
        UtilLog.info('localPlayOrPause start play start pause');
        await this.avPlayer.pause();
      } else if (this.avPlayer.state === 'stopped') {
        UtilLog.info('localPlayOrPause start play from stopped');
        await this.avPlayer.prepare();
        await this.avPlayer.play();
      } else {
        UtilLog.info('localPlayOrPause start play');
        await this.avPlayer.play();
        UtilLog.info('localPlayOrPause start play done');
      }
    } catch (error) {
      let err = error as BusinessError;
      UtilLog.error(0x0000, 'ProviderManager', `localPlayOrPause failed. error code=${err.code}, message=${err.message}`);
    }
  }

  async RegisterAVPlayerListener(): Promise<void> {
    UtilLog.info(` RegisterAVPlayerListener`);
    this.avPlayer?.on('audioInterrupt', (info: audio.InterruptEvent) => {
      UtilLog.info('audioInterrupt success,and InterruptEvent info is:' + info);
      if (this.avPlayer?.state === 'playing') {
        UtilLog.info('audio interrupt, start pause');
        this.avPlayer?.pause();
        this.currentState.state = avSession.PlaybackState.PLAYBACK_STATE_PAUSE;
        this.session?.setAVPlaybackState(this.currentState);
      }
    });
    this.avPlayer?.on('timeUpdate', (time: number) => {
      this.vm.currentTime = time;
      UtilLog.info('time update progress:' + time);
    });
  }

  async unRegisterAVPlayerListener(): Promise<void> {
    UtilLog.info(`unRegisterAVPlayerListener`);
    this.avPlayer?.off('audioInterrupt');
    this.avPlayer?.off('timeUpdate');
    this.avPlayer?.off('stateChange');
    this.avPlayer?.off('seekDone');
    this.avPlayer?.off('error');
  }

  controlPlay(): void {
    if(this.isSlider) {
      if (this.isPaused) {
        this.isPaused = false;
        this.avPlay();
      } else {
        this.isPaused = true;
        this.avPause();
      }
    } else {
      this.onClickCb(this.videoData.id)
    }
  }

  build() {
    Column() {
      Stack({ alignContent: this.isCover ? Alignment.Top : Alignment.Center }) {
        // 视频内容
        Column(){
          XComponent({
            // 装载视频容器
            id: 'xComponent',
            type: XComponentType.SURFACE,
            controller: this.xComponentController
          })
            .id('VideoView')
            .onLoad(() => {
              this.surfaceId = this.xComponentController.getXComponentSurfaceId();
              this.avSetupURL();
            })
            .width('100%')
            .aspectRatio(this.isCover ? 1 : this.vm.percent)
        }
        .width('100%')
        .height('100%')
        .aspectRatio(this.isCover ? 1 : this.vm.percent)
        .onClick(() => {
          this.controlPlay();
        })

        if(this.isFullScreen && !this.isCover) {
          // 播放按钮（居中）
          Column() {
            Image($r('app.media.ic_video_pause'))
              .width(40)
              .height(40)
              .onClick(() => {
                this.controlPlay();
              })
          }
          .padding(0)
          .visibility(this.isPaused ? Visibility.Visible : Visibility.None)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
        }
        // 底部控制栏（独立区域）
        Column() {
          Row() {
            Image(this.isPaused ? $r('app.media.ic_video_pause') : $r('app.media.ic_video_play'))
              .width(24)
              .height(24)
              .visibility(this.isFullScreen ? Visibility.None : Visibility.Visible)
              .onClick(() => {
                this.controlPlay();
              })
            Text(this.vm.timeConvert(this.vm.currentTime))
              .fontColor(Color.White)
              .margin({left: 8})
              .visibility(this.isFullScreen ? Visibility.None : Visibility.Visible)
            Slider({
              value: this.vm.currentTime,
              min: 0,
              max: this.vm.durationTime,
              style: this.isFullScreen ? SliderStyle.NONE : SliderStyle.OutSet
            })
              .blockColor($r('sys.color.comp_background_primary_contrary'))
              .selectedColor(this.isFullScreen ? 'rgba(255, 255, 255, 0.4)' : $r('sys.color.comp_background_primary'))
              .trackColor(this.isFullScreen ? 'rgba(255, 255, 255, 0.2)' : $r('sys.color.comp_background_secondary'))
              .showTips(false)
              .onChange((value: number, mode: SliderChangeMode) => {
                if (this.seekTime !== value) {
                  this.seekTime = value;
                  this.avSeek(value, mode);
                }
              })
              .layoutWeight(1)
            Text(this.vm.timeConvert(this.vm.durationTime))
              .fontColor(Color.White)
              .visibility(this.isFullScreen ? Visibility.None : Visibility.Visible)
            Image($r('app.media.ic_full_screen'))
              .width(24)
              .height(24)
              .margin({left: 8})
              .visibility(this.isFullScreen ? Visibility.None : Visibility.Visible)
              .onClick(() => {
                this.showFullScreen()
              })
          }
          .width('100%').justifyContent(FlexAlign.SpaceBetween)
        }
        .width('100%')
        .position({ y: '100%' })
        .translate({ y: this.isFullScreen ? -117 : this.breakPoint === 'md' ? -145 : -60 })
        .padding(10)
        .visibility(this.isSlider ? Visibility.Visible : Visibility.None)
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.isCover ? '' : Color.Black)
  }
}