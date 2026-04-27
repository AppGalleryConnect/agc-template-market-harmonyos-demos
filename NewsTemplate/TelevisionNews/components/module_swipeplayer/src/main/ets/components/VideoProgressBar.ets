import { emitter } from '@kit.BasicServicesKit';
import { Constants } from '../constants/Constants';
import { EventKey } from '../constants/EventKey';
import { AVPlayerController } from '../controller/AVPlayerController';
import { AVPlayerState } from '../type/Index';
import { Logger } from '../utils/Logger';
import { playVideo, setSeek } from '../utils/Util';
import { secondToTime } from '../utils/Util';

const TAG = '[VideoProgressBar]'

@ObservedV2
export class ProgressController {
  sliderOnChange: (value: number, mode: SliderChangeMode) => void = () => {
  };
  @Trace currentTime: number = 0
  @Trace durationTime: number = 0
  @Trace progressWidth: number = 0
}

@ComponentV2
export struct VideoProgressBar {
  // 视频播放avplayer控制器
  @Param @Require avPlayerController: AVPlayerController;
  // 进度条回调事件
  @Event onSlideChange: (sliderFlag: boolean) => void = () => {
  };
  // 进度条左边区域
  @Param showProgressBarLeft: boolean = false;
  // 进度条左边区域
  @Param showProgressBarRight: boolean = false;
  // 能否拖动进度条
  @Param canChangeSlide: boolean = true;
  // 进度条是否占满全屏宽度
  @Param isProgressFullWidth: boolean = false;
  // 进度条的高度
  @Param slideHeight: Length = 20;
  // 是否显示进度条滑块
  @Param showSlideBlock: boolean = true
  // 进度条已滑动部分颜色
  @Param selectedColor: ResourceColor = $r('app.color.slide_default_selected_color');
  // 进度条颜色
  @Param trackColor: ResourceColor = $r('app.color.slide_default_track_color')
  // 是否是全屏
  @Param isFullScreen: boolean = false;
  // 进度条组件控制器
  @Param progressController: ProgressController = new ProgressController();
  // 切换播放
  @Event onSwitchPlayCallback: () => void;
  // 全屏自定义图标
  @Param fullScreenIcon: Resource | undefined = undefined
  // 静音自定义图标
  @Param isNeedMuteIcon: boolean = false
  // 是否隐藏进度条
  @Param isHideSlide: boolean = false
  // 全屏切换
  @Event onSwitchFullScreenCallback: () => void;
  @Local currentTime: number = 0;
  @Local durationTime: number = 0;
  @Local durationStringTime: string = '00:00';
  @Local currentStringTime: string = '00:00';
  @Local isTimeDisplay: boolean = false;
  @Local trackThicknessSize: number = Constants.TRACK_SIZE_MIN;
  @Local isPlaying: boolean = true;
  @Param isMute: boolean = false
  @Event onMute: (value: boolean) => void = () => {
  };
  private duration: number = 0;
  private isSliderMoving: boolean = false;

  @Monitor('isMute')
  async muteChange(monitor: IMonitor) {
    this.avPlayerController.avPlayer!.setVolume(monitor.value('isMute')?.now ? Constants.VOLUME_LOW :
      Constants.VOLUME_HIGH)
  }

  private onSystemVolumeChange: (eventData: emitter.EventData) => void = (eventData) => {
    this.onMute((eventData.data!.volume || Constants.VOLUME_LOW) === Constants.VOLUME_LOW);
  };
  private onStateChange: (state: AVPlayerState) => void = (state) => {
    Logger.debug(TAG, 'stateChange: ' + state);
    let avPlayer = this.avPlayerController.getAVPlayer();
    if (avPlayer && avPlayer.duration > 0) {
      this.duration = avPlayer.duration;
      this.durationTime = this.duration / 1000
      this.durationStringTime = secondToTime(Math.floor(this.duration / 1000));
    }
    if (this.isNeedMuteIcon) {
      this.avPlayerController.avPlayer!.setVolume(Constants.VOLUME_LOW)
    }

    // 是否播放
    this.isPlaying = state === AVPlayerState.PLAYING;
    // 暂停状态
    if (state === AVPlayerState.PAUSED) {
      this.trackThicknessSize = Constants.TRACK_SIZE_MAX;
    } else {
      this.trackThicknessSize = Constants.TRACK_SIZE_MIN;
    }

    if (this.isPlaying) {
      this.avPlayerController.avPlayer!.setVolume(this.isMute ? Constants.VOLUME_LOW : Constants.VOLUME_HIGH)
    }
    emitter.on(EventKey.SYSTEM_VOLUME_CHANGE, this.onSystemVolumeChange);
  }
  private timeUpdate: (time: number) => void = (time) => {
    if (!this.isSliderMoving) {
      this.currentTime = time / 1000;
      this.currentStringTime = secondToTime(Math.floor(time / 1000));
      this.progressController.currentTime = this.currentTime
    }
  }
  private seekDone: (seekDoneTime: number) => void = () => {
    this.isSliderMoving = false;
    this.onSlideChange && this.onSlideChange(this.isSliderMoving);
  }

  aboutToAppear(): void {
    // 绑定滑动事件
    this.progressController.sliderOnChange =
      (value: number, mode: SliderChangeMode): void => this.sliderOnChange(value, mode)
    let avPlayer = this.avPlayerController.getAVPlayer();
    if (avPlayer) {
      this.duration = avPlayer.duration;
      this.durationTime = this.duration / 1000
      this.durationStringTime = secondToTime(Math.floor(this.duration / 1000));
      this.progressController.durationTime = this.durationTime
      Logger.info(TAG, 'player duration is ' + this.duration)
      if (this.isMute) {
        avPlayer!.setVolume(Constants.VOLUME_LOW)
      }
    }
    this.avPlayerController?.onEvent('stateChange', this.onStateChange);
    this.avPlayerController?.onEvent('timeUpdate', this.timeUpdate);
    this.avPlayerController?.onEvent('seekDone', this.seekDone);
  }

  aboutToDisappear(): void {
    emitter.off(EventKey.SYSTEM_VOLUME_CHANGE, this.onSystemVolumeChange);
    this.avPlayerController?.offEvent('stateChange', this.onStateChange);
    this.avPlayerController?.offEvent('timeUpdate', this.timeUpdate);
    this.avPlayerController?.offEvent('seekDone', this.seekDone);
  }

  sliderOnChange(value: number, mode: SliderChangeMode) {
    let avPlayer = this.avPlayerController.getAVPlayer();
    if (!avPlayer) {
      return;
    }

    // 锁定进度更新，防止 timeUpdate 干扰
    this.isSliderMoving = true;
    this.currentTime = value;
    let seekTime: number = value * 1000;
    // 进度条滑动
    if (mode === SliderChangeMode.Moving) {
      this.isTimeDisplay = true;
      this.trackThicknessSize = Constants.TRACK_SIZE_MAX;
      this.currentStringTime = secondToTime(Math.floor(value));
    }
    // 滑动结束或者点击某个位置时
    if (mode === SliderChangeMode.End || mode === SliderChangeMode.Click) {
      // 更新时间显示
      this.currentStringTime = secondToTime(Math.floor(value));
      setSeek(avPlayer, seekTime);
      // 处理 UI 状态
      this.isTimeDisplay = false;
      this.trackThicknessSize = Constants.TRACK_SIZE_MIN;
      // 如果是暂停状态则播放；如果是播放状态，seek 会自动在完成后继续播放
      if (!this.isPlaying) {
        playVideo(avPlayer);
      }
    }

    this.onSlideChange && this.onSlideChange(this.isSliderMoving);
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Row({ space: 16 }) {
        Text(this.currentStringTime)
          .fontSize(20)
          .fontColor(Color.White)
          .textAlign(TextAlign.End)
          .zIndex(3)

        Divider()
          .vertical(true)
          .height(18)
          .strokeWidth(2)
          .color(Color.White)
          .rotate({
            x: 0,
            y: 0,
            z: 1,
            centerX: '50%',
            centerY: '50%',
            angle: 26,
          })

        Text(this.durationStringTime)
          .fontSize(20)
          .fontColor(Color.White)
          .textAlign(TextAlign.Start)
          .opacity(0.5)
          .zIndex(3)
      }
      .accessibilityLevel('no-hide-descendants')
      .width(Constants.FULL_PERCENT)
      .visibility(this.isTimeDisplay ? Visibility.Visible : Visibility.Hidden)
      .justifyContent(FlexAlign.Center)
      .offset({ bottom: 120 })

      Row({ space: 8 }) {
        if (this.showProgressBarLeft) {
          Row({ space: Constants.SPACE_L }) {
            Image(this.isPlaying ? $r('app.media.ic_pause') : $r('app.media.ic_play'))
              .width(24)
              .height(24)
              .objectFit(ImageFit.Contain)
              .accessibilityText(this.isPlaying ? '点击暂停' : '点击播放')
              .onClick(() => {
                this.onSwitchPlayCallback && this.onSwitchPlayCallback()
              })
            Text(this.currentStringTime)
              .fontSize(10)
              .fontColor(Color.White)
              .textAlign(TextAlign.Start)
              .lineHeight(13)
              .visibility(this.isHideSlide ? Visibility.None : Visibility.Visible)
          }
        }
        if (this.isHideSlide) {
          Blank()
        } else {
          Slider({
            value: this.currentTime,
            step: 0.1,
            min: 0,
            max: this.durationTime,
            style: this.showSlideBlock ? SliderStyle.OutSet : SliderStyle.NONE,
          })
            .layoutWeight(1)
            .height(this.slideHeight)
            .enabled(this.canChangeSlide)
            .blockSize({
              width: this.showSlideBlock ? 4 + (this.trackThicknessSize) : 0,
              height: this.showSlideBlock ? 4 + (this.trackThicknessSize) : 0,
            })
            .blockColor(this.isTimeDisplay || !this.isPlaying ? '#ffffff' : this.selectedColor)
            .trackColor(this.trackColor)
            .selectedColor(this.isTimeDisplay || !this.isPlaying ? '#ffffff' : this.selectedColor)
            .showSteps(false)
            .showTips(false)
            .trackThickness(this.trackThicknessSize)
            .trackBorderRadius(2)
            .offset(!this.showSlideBlock ? { top: 6 } : null)
            .zIndex(3)
            .onChange((value: number, mode: SliderChangeMode) => {
              this.sliderOnChange(value, mode);
            })
            .onAreaChange((_ov: Area, nv: Area) => {
              this.progressController.progressWidth = nv.width as number
            })
        }
        if (this.showProgressBarRight) {
          Row({ space: Constants.SPACE_L }) {
            Text(this.durationStringTime)
              .fontSize(10)
              .fontColor(Color.White)
              .textAlign(TextAlign.End)
              .lineHeight(13)
              .visibility(this.isHideSlide ? Visibility.None : Visibility.Visible)
            if (!!this.isNeedMuteIcon) {
              SymbolGlyph(this.isMute ? $r('sys.symbol.speaker_wave_3_slash') : $r('sys.symbol.speaker_wave_3'))
                .fontColor([$r('sys.color.font_on_primary')])
                .fontWeight(FontWeight.Normal)
                .fontSize(24)
                .accessibilityText(this.isMute ? '静音' : '取消静音')
                .onClick(() => {
                  this.onMute(!this.isMute)
                })
            }
            if (this.fullScreenIcon) {
              Image(this.fullScreenIcon)
                .width(24)
                .aspectRatio(1)
                .fillColor($r('sys.color.font_on_primary'))
                .accessibilityText(this.isFullScreen ? '退出全屏' : '进入全屏')
                .onClick(() => {
                  this.onSwitchFullScreenCallback && this.onSwitchFullScreenCallback()
                })
            } else {
              Image(this.isFullScreen ? $r('app.media.ic_exit_full_screen') : $r('app.media.ic_expand_full_screen'))
                .width(16)
                .height(16)
                .objectFit(ImageFit.Contain)
                .accessibilityText(this.isFullScreen ? '退出全屏' : '进入全屏')
                .onClick(() => {
                  this.onSwitchFullScreenCallback && this.onSwitchFullScreenCallback()
                })
            }

          }
        }
      }
      .padding(this.isProgressFullWidth ? null :
        { left: Constants.PADDING_PAGE, right: Constants.PADDING_PAGE, bottom: Constants.PADDING_S },
      )
      .justifyContent(FlexAlign.SpaceBetween)
      .width('100%')
    }
  }
}