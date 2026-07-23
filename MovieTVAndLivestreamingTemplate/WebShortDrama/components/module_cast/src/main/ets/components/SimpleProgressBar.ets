import { secondToTime } from '../common/utils/CommUtils';
import { CastService } from '../service/CastService';
import { hilog } from '@kit.PerformanceAnalysisKit';

/**
 * 功能描述：建议进度条默认实现，通过play session感知播放变化并控制播放进度
 */
const TAG = 'SimpleProgressBar'
const DOMAIN = 0x000

@ComponentV2
export struct SimpleProgressBar {
  @Param @Require castService: CastService
  @Event onSeek: Function
  @Local isTimeDisplay: boolean = false;
  @Local trackThicknessSize: number = 4;
  @Local currentTime: number = 5;
  @Local durationTime: number = 10;
  @Local durationStringTime: string = '00:00';
  @Local currentStringTime: string = '00:00';

  @Monitor('castService.castStatusModel.castCurrentTime', 'castService.castStatusModel.castDuration')
  onTimeChange(monitor: IMonitor) {
    monitor.dirty.forEach((path: string) => {

      let time: number = monitor.value(path)?.now as number
      if (path === 'castService.castStatusModel.castCurrentTime' && time) {
        this.currentStringTime = secondToTime(Math.floor(time / 1000))
        this.currentTime = time
      }
      if (path === 'castService.castDuration' && time) {
        hilog.info(DOMAIN, TAG, `${path} changed from ${monitor.value(path)?.before} to ${monitor.value(path)?.now}`);
        this.durationStringTime = secondToTime(Math.floor(time / 1000))
        this.durationTime = time
      }
    });
  }

  aboutToAppear(): void {
    this.currentTime = this.castService.castStatusModel.castCurrentTime
    this.durationTime = this.castService.castStatusModel.castDuration
    this.currentStringTime = secondToTime(Math.floor(this.currentTime / 1000))
    this.durationStringTime = secondToTime(Math.floor(this.durationTime / 1000))
    hilog.info(DOMAIN, TAG, `aboutToAppear ${this.castService.castStatusModel.castDuration}`);
  }

  sliderOnChange(value: number, mode: SliderChangeMode) {
    this.currentTime = value;
    let seekTime: number = value;
    if (mode === SliderChangeMode.Begin || mode === SliderChangeMode.Moving) {
      this.trackThicknessSize = 4;
    }
    if (mode === SliderChangeMode.Moving) {
      this.currentStringTime = secondToTime(Math.floor(seekTime / 1000));
    }
    if (mode === SliderChangeMode.End || mode === SliderChangeMode.Click) {
      this.currentStringTime = secondToTime(Math.floor(seekTime / 1000));
      this.castService.seek(seekTime);
      this.trackThicknessSize = 4
    }
  }

  build() {
    // 控制条
    Row() {
      Text(this.currentStringTime)
        .fontSize(10)
        .width(42)
        .margin({ right: 12 })
        .textAlign(TextAlign.End)
        .fontColor($r('sys.color.font_on_primary'))
      Slider({
        value: this.currentTime,
        step: 0.1,
        min: 0,
        max: this.durationTime,
        style: SliderStyle.OutSet
      })
        .layoutWeight(1)
        .height(15)
        .selectedColor(true?$r('sys.color.alert'):$r('sys.color.comp_background_emphasize'))
        .showSteps(false)
        .showTips(false)
        .animation({ duration: 100, curve: Curve.Smooth })
        .trackThickness(this.trackThicknessSize)
        .trackBorderRadius(2)
        .onChange((value: number, mode: SliderChangeMode) => {
          this.sliderOnChange(value, mode);
        })
        .zIndex(3)
      Text(secondToTime(Math.floor(this.castService.castStatusModel.castDuration / 1000)))
        .textAlign(TextAlign.Start)
        .fontSize(10)
        .fontColor($r('sys.color.font_on_primary'))
        .width(42)
        .margin({ left: 12 })
    }
    .justifyContent(FlexAlign.Center)
  }
}