import { FormatUtil } from '../util/FormatUtil';
import { VideoTranPageVM } from '../viewmodel/VideoTranPageVM'
import { LanguageCheck } from './LanguageCheck';
import { TranslatorRes } from './TranslatorRes';

@ComponentV2
export struct EndRecord {
  vm: VideoTranPageVM = VideoTranPageVM.instance

  build() {
    Column() {
      Row({ space: 16 }) {
        if (this.vm.isPlaying) {
          SymbolGlyph($r('sys.symbol.pause_circle'))
            .fontSize(24)
            .fontColor(['#2070F3'])
            .margin({ right: 8 })
            .onClick(() => {
              this.vm.pause();
            });
        } else {
          SymbolGlyph($r('sys.symbol.play_circle'))
            .fontSize(24)
            .fontColor(['#2070F3'])
            .margin({ right: 8 })
            .onClick(() => {
              this.vm.play();
            });
        }

        Stack({ alignContent: Alignment.Top }) {
          Row() {
            Slider({
              style: SliderStyle.NONE,
              value: (this.vm.curTime / this.vm.duration) * 100,
              min: 0,
              max: 100,
            })
              .trackColor($r('sys.color.comp_background_secondary'))
              .selectedColor($r('sys.color.comp_background_emphasize'))
          }.height(40);

          Row() {
            Text(FormatUtil.formatSecondsToMMSS(Math.floor(this.vm.curTime))).labelExtend();
            Text(FormatUtil.formatSecondsToMMSS(Math.floor(this.vm.duration))).labelExtend();
          }
          .margin({ top: 22 })
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .padding({ left: 4, right: 4 });
        }.layoutWeight(1).height(40);
      }
      .backgroundColor($r('sys.color.comp_background_primary'))
      .borderRadius(16)
      .padding({
        left: 12,
        right: 12,
        top: 17,
        bottom: 17
      })
      .margin({ bottom: 12 })

      LanguageCheck({
        audio: true,
        input: this.vm.input,
        output: this.vm.outputLanguage,
        onChange: (inputLanguage: string, outputLanguage: string) => {
          this.vm.inputLanguage = inputLanguage
          this.vm.outputLanguage = outputLanguage
        }
      })

      TranslatorRes({
        isAudio: true,
        input: this.vm.text,
        translatorRes: this.vm.translatorRes,
        onChange: (inputText: string) => {
          this.vm.text = inputText
        }
      })

      Row({ space: 12 }) {
        Button('开始录音')
          .width('50%')
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .fontColor($r('sys.color.font_emphasize'))
          .onClick(() => {
            this.vm.reStart()
          })
        Button('翻译')
          .flexGrow(1)
          .backgroundColor($r('sys.color.comp_background_emphasize'))
          .fontColor($r('sys.color.font_on_primary'))
          .onClick(async () => {
            this.vm.translate()
          })
      }
      .width('100%')
    }
  }
}


@Extend(Text)
function labelExtend() {
  .fontSize($r('sys.float.Caption_M'))
  .fontWeight(FontWeight.Regular)
  .fontColor($r('sys.color.font_secondary'))
  .lineHeight(14);
}