import { AppStorageV2 } from '@kit.ArkUI';
import { Constant } from 'common';
import { PlayControlComponent } from './PlayControlComponent';
import { PlayInfo } from '../model/PlayInfo';

@Component
export struct VoiceComponent {
  @Prop index: string;
  @Prop name: string;
  @State isShowPlayList: boolean = false;
  private playInfo: PlayInfo = AppStorageV2.connect(PlayInfo, 'playInfo', () => new PlayInfo())!;

  build() {
    Column({ space: 8 }) {
      Text('语音讲解').fontWeight(500).width(Constant.FULL_PERCENT).textAlign(TextAlign.Start);

      Row() {
        PlayControlComponent({ isPlay: this.playInfo.isPlay, url: this.index, isGuide: false }).width('10%');

        Column() {
          Row() {
            Text(this.name).fontSize(14).opacity(0.9);

            Row() {
              Text(`${this.playInfo.currentTime}/`)
                .fontColor(Color.Black)
                .fontSize(14).opacity(0.6);
              Text(this.playInfo.totalTime)
                .fontColor(Color.Black)
                .fontSize(14).opacity(0.6);
            };
          }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.SpaceBetween);

          Slider({
            min: 0,
            max: this.playInfo.progressMax,
            step: 1,
            style: SliderStyle.OutSet,
            value: this.playInfo.progress,
          }).width(Constant.FULL_PERCENT)
            .height(24)
            .hitTestBehavior(HitTestMode.Block);
        }.width('90%');
      }
      .backgroundColor('#F1F3F5F2')
      .borderRadius(8)
      .padding(12)
      .width(Constant.FULL_PERCENT)
      .justifyContent(FlexAlign.SpaceBetween);
    };
  }
}