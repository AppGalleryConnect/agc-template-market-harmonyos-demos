import { getInstance, setPathStack } from '../common/CommonRoute';
import { LanguageCheck } from '../components/LanguageCheck';
import { TitleBar } from '../components/TitleBar';
import { TranslatorRes } from '../components/TranslatorRes';
import { contextUtil } from '../util/ContextUtil';
import { TranslatorPageVM } from '../viewmodel/TranslatorPageVM';

@ComponentV2
struct TranslatorPage {
  vm: TranslatorPageVM = TranslatorPageVM.instance
  controller: TextAreaController = new TextAreaController();

  aboutToAppear(): void {
    contextUtil.setUiContext(this.getUIContext())
    this.vm.clear()
  }

  build() {
    NavDestination() {
      TitleBar({
        name: `翻译`,
        img: $r('sys.symbol.doc_plaintext'),
        onClear: () => {
          getInstance().pushPathByName('HistoryPage', '')
        }
      })
      Column() {
        titleBuilder('快速翻译')
        LanguageCheck({
          onChange: (inputLanguage: string, outputLanguage: string) => {
            this.vm.inputLanguage = inputLanguage
            this.vm.outputLanguage = outputLanguage
          },
          onClear: () => {
            this.vm.inputText = ''
            this.vm.translatorRes = ''
          }
        })
        TranslatorRes({
          input: this.vm.inputText,
          translatorRes: this.vm.translatorRes,
          onChange: (inputText: string) => {
            this.vm.inputText = inputText
          }
        })

        Row({ space: 12 }) {
          Button('一键清空')
            .width('50%')
            .backgroundColor($r('sys.color.comp_background_tertiary'))
            .fontColor($r('sys.color.font_emphasize'))
            .onClick(() => {
              this.vm.clear()
            })
          Button('翻译')
            .flexGrow(1)
            .backgroundColor($r('sys.color.comp_background_emphasize'))
            .fontColor($r('sys.color.font_on_primary'))
            .enabled(this.vm.inputText ? true : false)
            .onClick(async () => {
              this.vm.translate()
            })
        }
        .width('100%')

        titleBuilder('快速翻译')

        Row() {
          Row() {
            Image($r('app.media.tran_mic'))
              .width(40)
              .height(40)
              .margin({ right: 16 })
            Text('语音翻译')
              .fontSize($r('sys.float.Subtitle_M'))
              .fontColor($r('sys.color.font_primary'))
              .fontWeight(FontWeight.Medium)
          }
          .width('50%')
          .padding(12)
          .backgroundColor($r('sys.color.comp_background_primary'))
          .borderRadius(16)
          .onClick(() => {
            getInstance().pushPathByName('VideoTranPage', '')
          })
        }
        .width('100%')
      }
      .padding({ left: 16, right: 16 })
      .layoutWeight(1)
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .title('翻译')
    .hideTitleBar(true)
    .onReady((ctx) => {
      setPathStack(ctx.pathStack);
    });
  }
}

@Builder
function titleBuilder(title: string) {
  Row() {
    Text(title)
      .fontSize($r('sys.float.Subtitle_L'))
      .fontColor($r('sys.color.font_primary'))
      .fontWeight(FontWeight.Bold)
  }
  .width('100%')
  .padding({ top: 24, bottom: 8 })
}

@Builder
export function TranslatorPageBuilder() {
  TranslatorPage();
}