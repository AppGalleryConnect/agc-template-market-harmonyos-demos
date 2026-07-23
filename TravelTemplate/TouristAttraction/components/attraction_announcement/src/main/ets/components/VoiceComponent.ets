import { ReadStateCode, TextReader } from '@kit.SpeechKit';
import { PlayInfo } from 'module_base';
import { TextReaderUtil } from '../utils/TextReaderUtil';

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
    SymbolGlyph(this.textReaderUtil.readState === ReadStateCode.PLAYING ? $r('sys.symbol.pause') :
      $r('sys.symbol.earphone_bluetooth_left'))
      .width(40)
      .height(40)
      .fontSize(24)
      .fontColor([$r('sys.color.icon_primary')])
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .borderRadius(1000)
      .padding(8)
      .onClick(async () => {
        this.textReaderUtil.init(this.playInfo, this.getUIContext());
      });
  }
}