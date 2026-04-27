import { PlayInfo } from 'module_base';
import { TextReaderUtil } from '../utils/TextReaderUtil';
import { ReadStateCode, TextReader } from '@kit.SpeechKit';

@ComponentV2
export struct VoiceComponent {
  @Param @Require playInfo: PlayInfo;
  textReaderUtil: TextReaderUtil = TextReaderUtil.instance;

  aboutToDisappear(): void {
    TextReader.stop().then(() => {
      TextReader.release();
    });
  }

  build() {
    Image(this.textReaderUtil.readState === ReadStateCode.PLAYING ? $r('app.media.voice_pause') :
    $r('app.media.voice_play')).size({ width: 32, height: 32 }).objectFit(ImageFit.Fill).onClick(async () => {
      this.textReaderUtil.init(this.playInfo, this.getUIContext());
    });
  }
}