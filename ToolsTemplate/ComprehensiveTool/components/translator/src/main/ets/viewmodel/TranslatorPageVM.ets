import { allLanguages } from '../common/Constant'
import { TranslatorService } from '../service/TranslatorService'
import { PersistenceV2 } from '@kit.ArkUI';
import { HistoryInfo, MyHistory } from '../model/History';
import { util } from '@kit.ArkTS';

@ObservedV2
export class TranslatorPageVM {
  private static _instance: TranslatorPageVM
  @Trace history = PersistenceV2.connect(MyHistory, () => new MyHistory())!;
  @Trace isShow: boolean = false
  @Trace currentIndex: number = 0
  @Trace inputLanguage: string = '中文'
  @Trace outputLanguage: string = '英文'
  @Trace inputText: string = ''
  @Trace translatorRes: string = ''

  public static get instance() {
    if (!TranslatorPageVM._instance) {
      TranslatorPageVM._instance = new TranslatorPageVM();
    }
    return TranslatorPageVM._instance;
  }

  async translate() {
    const inputCode = allLanguages.find((language) => {
      return language.text === this.inputLanguage
    })
    const outputCode = allLanguages.find((language) => {
      return language.text === this.outputLanguage
    })
    this.translatorRes =
      await TranslatorService.translate(inputCode ? inputCode.code : 'cn', outputCode ? outputCode.code : 'en',
        this.inputText)
    if (this.translatorRes) {
      this.history.addHistory(new HistoryInfo(util.generateRandomUUID(false), this.inputText, this.translatorRes))
    }
  }

  clear() {
    this.inputText = ''
    this.translatorRes = ''
    this.inputLanguage = '中文'
    this.outputLanguage = '英文'
  }
}
