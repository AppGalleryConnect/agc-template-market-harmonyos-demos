import { Constants } from '../constants/Constants';

const TAG = '[VideoViewVM]';

@ObservedV2
export class VideoViewVM {
  tag: string = 'AVPlayManager';
  @Trace currentTime: number = 0;
  @Trace durationTime: number = 0;
  @Trace surfaceW: number | null = null;
  @Trace surfaceH: number | null = null;
  @Trace percent: number = 0;
  @Trace windowWidth: number = 300;
  @Trace windowHeight: number = 200;

  getDurationTime(): number {
    return this.durationTime;
  }

  getCurrentTime(): number {
    return this.currentTime;
  }

  timeConvert(time: number): string {
    let min: number = Math.floor(time / Constants.TIME_ONE);
    let second: string = Math.floor((time % Constants.TIME_ONE) / Constants.TIME_TWO).toString();
    second = second.padStart(2, '0');
    return `${min}:${second}`;
  }

  async msleepAsync(ms: number): Promise<boolean> {
    return new Promise((resolve, reject) => {
      setTimeout(() => {
        resolve(true)
      }, ms)
    })
  }

  setVideoWH(): void {
    if (this.percent >= 1) { // 横向视频
      this.surfaceW = Math.round(this.windowWidth * Constants.PROPORTION);
      this.surfaceH = Math.round(this.surfaceW / this.percent);
    } else { // 纵向视频
      this.surfaceH = Math.round(this.windowHeight * Constants.PROPORTION);
      this.surfaceW = Math.round(this.surfaceH * this.percent);
    }
  }

}
