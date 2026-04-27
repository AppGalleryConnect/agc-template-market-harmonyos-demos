import { formatTime } from '../util/FormatUtil';
import { CastService } from '../service/CastService';
import { UtilLog as Logger } from '@hw-agconnect/util-log';

/**
 * 功能描述：建议进度条默认实现，通过play session感知播放变化并控制播放进度
 */
const TAG = 'SimpleProgressBar';


@ComponentV2
export struct SimpleProgressBar {
  @Param @Require castService: CastService;
  @Event onSeek: Function;
  @Local isTimeDisplay: boolean = false;
  @Local trackThicknessSize: number = 4;
  @Local currentTime: number = 5;
  @Local durationTime: number = 10;
  @Local durationStringTime: string = '00:00:00';
  @Local currentStringTime: string = '00:00:00';

  @Monitor('castService.castStatusModel.castCurrentTime','castService.castStatusModel.castDuration')
  onTimeChange(monitor: IMonitor) {
    monitor.dirty.forEach((path: string) => {
      let time: number = monitor.value(path)?.now as number;
      if (path === 'castService.castStatusModel.castCurrentTime' && time) {
        this.currentStringTime = formatTime(time);
        this.currentTime = time;
      }
      if (path === 'castService.castStatusModel.castDuration' && time) {
        Logger.info(TAG, `${path} changed from ${monitor.value(path)?.before} to ${monitor.value(path)?.now}`);
        this.durationStringTime = formatTime(time);
        this.durationTime = time;
      }
    });
  }

  aboutToAppear(): void {
    this.currentTime = this.castService.castStatusModel.castCurrentTime;
    this.durationTime = this.castService.castStatusModel.castDuration;
    this.currentStringTime = formatTime(this.currentTime);
    this.durationStringTime = formatTime(this.durationTime);
    Logger.info(TAG, `aboutToAppear ${this.castService.castStatusModel.castDuration}`);
  }

  sliderOnChange(value: number, mode: SliderChangeMode) {
    this.currentTime = value;
    let seekTime: number = value;
    if (mode === SliderChangeMode.Begin || mode === SliderChangeMode.Moving) {
      this.trackThicknessSize = 4;
    }
    if (mode === SliderChangeMode.Moving) {
      this.currentStringTime = formatTime(seekTime);
    }
    if (mode === SliderChangeMode.End || mode === SliderChangeMode.Click) {
      this.currentStringTime = formatTime(seekTime);
      this.castService.seek(seekTime);
      this.trackThicknessSize = 4;
    }
  }

  build() {
    // 控制条
    Row({ space: 12 }) {
      Text(this.currentStringTime)
        .fontSize(10)
        .width(42)
        .textAlign(TextAlign.End)
        .fontColor($r('sys.color.font_primary'));
      Slider({
        value: this.currentTime,
        step: 0.1,
        min: 0,
        max: this.durationTime,
        style: SliderStyle.OutSet,
      })
        .layoutWeight(1)
        .height(15)
        .blockColor('#E5E5E5')
        .selectedColor($r('sys.color.comp_background_emphasize'))
        .trackColor($r('sys.color.comp_background_secondary'))
        .showSteps(false)
        .showTips(false)
        .animation({ duration: 100, curve: Curve.Smooth })
        .trackThickness(this.trackThicknessSize)
        .trackBorderRadius(2)
        .onChange((value: number, mode: SliderChangeMode) => {
          this.sliderOnChange(value, mode);
        })
        .zIndex(3);
      Text(this.durationStringTime)
        .textAlign(TextAlign.Start)
        .fontSize(10)
        .fontColor($r('sys.color.font_primary'))
        .width(42);
    }
    .justifyContent(FlexAlign.Center);
  }
}