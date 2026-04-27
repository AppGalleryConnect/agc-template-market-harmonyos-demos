import { Constants as Const } from '../constant/Contants'
import { PlaySession } from '../controller/PlaySession';
import { secondToTime } from '../utils/CommonUtils';

/**
 * 功能描述：进度条默认实现，通过play session感知播放变化并控制播放进度
 */
@ComponentV2
export struct ProcessBar {
  @Param @Require playerSession:PlaySession
  @Local isTimeDisplay: boolean = false;
  @Local trackThicknessSize: number = Const.TRACK_SIZE_MIN;
  @Local currentTime: number = 0;
  @Local durationTime: number = 0;
  @Local durationStringTime: string = '00:00';
  @Local currentStringTime: string = '00:00';
  private duration: number = 0;
  private isSliderMoving: boolean = false;

  sliderOnChange(value: number, mode: SliderChangeMode) {
    this.currentTime = value;
    let seekTime: number = value * 1000;
    if (mode === SliderChangeMode.Begin || mode === SliderChangeMode.Moving) {
      this.isTimeDisplay = true;
      this.trackThicknessSize = Const.TRACK_SIZE_MAX;
    }
    if (mode === SliderChangeMode.Moving) {
      this.currentStringTime = secondToTime(Math.floor(seekTime / 1000));
      this.isSliderMoving = true;
    }
    if (mode === SliderChangeMode.End || mode === SliderChangeMode.Click) {
      this.currentStringTime = secondToTime(Math.floor(seekTime / 1000));
      this.playerSession?.avPlayer?.seek(seekTime);
      this.isTimeDisplay = false;
      this.trackThicknessSize = Const.TRACK_SIZE_MIN;
      this.isSliderMoving = false;
    }
  }

  aboutToAppear(): void {
    let avPlayer = this.playerSession.getAVPlayer();
    if (avPlayer) {
      this.duration = avPlayer.duration;
      this.durationTime = this.duration / 1000;
      this.durationStringTime = secondToTime(Math.floor(this.duration / 1000));
    }

    this.playerSession?.onStateChange('stateChange', (state: string) => {
      let avPlayer = this.playerSession.getAVPlayer();
      if (state === 'prepared' && avPlayer && avPlayer.duration > 0) {
        this.duration = avPlayer.duration;
        this.durationTime = this.duration / 1000;
        this.durationStringTime = secondToTime(Math.floor(this.duration / 1000));
      }
    });

    this.playerSession?.onTimeUpdate('timeUpdate', (time: number) => {
      if (!this.isSliderMoving) {
        this.currentTime = time / 1000;
        this.currentStringTime = secondToTime(Math.floor(time / 1000));
      }
    });
  }

  build() {
    this.playControlBar()
  }

  @Builder
  playControlBar() {
    // 控制条
    Stack({ alignContent: Alignment.Bottom }) {
      Column() {
        Row() {
          Text(this.currentStringTime)
            .fontSize(20)
            .fontColor(Color.White)
            .margin({ left: 2 })
            .width('45%')
            .textAlign(TextAlign.End)

          Divider()
            .vertical(true)
            .height(14)
            .width(2)
            .backgroundBlurStyle(BlurStyle.Regular, { colorMode: ThemeColorMode.LIGHT })
            .color(Color.White)
            .opacity(0.5)
            .margin({ left: 8, right: 8 })
            .rotate({
              x: 0,
              y: 0,
              z: 1,
              centerX: '50%',
              centerY: '50%',
              angle: 30
            })

          Text(this.durationStringTime)
            .fontSize(20)
            .fontColor(Color.White)
            .margin({ left: 2 })
            .width('45%')
            .textAlign(TextAlign.Start)
            .opacity(0.5)
        }
        .width('50%')
        .visibility(this.isTimeDisplay ? Visibility.Visible : Visibility.Hidden)

        Slider({
          value: this.currentTime,
          step: 0.1,
          min: 0,
          max: this.durationTime,
          style: SliderStyle.NONE
        })
          .width('100%')
          .height(15)
          .padding({ top:12 })
          .selectedColor(Color.White)
          .trackColor('#3fff')
          .showSteps(false)
          .showTips(false)
          .animation({ duration: 100, curve: Curve.Smooth })
          .trackThickness(this.trackThicknessSize)
          .trackBorderRadius(2)
          .onChange((value: number, mode: SliderChangeMode) => {
            this.sliderOnChange(value, mode);
          })
          .zIndex(3)
      }
    }
  }
}