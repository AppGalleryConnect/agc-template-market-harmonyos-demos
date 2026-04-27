import { cryptoFramework } from '@kit.CryptoArchitectureKit';
import { AudioRecorder } from '../utils/AudioRecorder';


// 音量变换
@ComponentV2
export struct VoiceView {
  @Require @Param audioPath: string = ''
  @Require @Param audioRecorder: AudioRecorder
  @Local channels: Array<number> = [1, 2, 3, 4, 5, 6, 5, 4, 3, 2, 1, 2, 3, 4, 5, 6, 5, 4, 3, 2, 1]
  private timerId: number = -1

  // 开启定时器
  private startTimer() {
    this.timerId = setInterval(() => {
      this.channels = Array.from(this.channels).map(() => {
        let rand = cryptoFramework.createRandom();
        let randOutput = rand.generateRandomSync(1);
        let result: number = randOutput.data[0] / 255;
        let tmp = Math.min(42, Math.max(10, this.audioRecorder.currentAmplitude * 42 * (1 + result + 0.3)))

        return tmp
      })
    }, 120);
  }

  // 关闭定时器
  private stopTimer() {
    if (this.timerId !== Number(-1)) {
      clearInterval(this.timerId);
    }
  }

  build() {
    Column() {
      Row() {
        ForEach(this.channels, (height: number) => {
          Column()
            .width(3)
            .height(height)
            .animation({
              duration: 120,
              curve: Curve.EaseInOut
            })
            .borderRadius(1.5)
            .backgroundColor('#564AF7')
        }, (height: number, index: number) => height + '_' + index)
      }
      .width(220)
      .height(42)
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
    .borderRadius(24)
    .onAppear(() => {
      // 进入
      this.audioRecorder.startRecorder(this.audioPath);
      this.startTimer();
    })
    .onDisAppear(() => {
      // 离开
      this.stopTimer();
      this.audioRecorder.stopRecorder();
    })
  }
}