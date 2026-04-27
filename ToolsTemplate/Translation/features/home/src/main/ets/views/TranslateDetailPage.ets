//翻译详情页
import { TranslateDetailViewModel } from '../viewmodel/TranslateDetailViewModel'
import { Language, LanguagePickerHeader, LanguageType } from 'choose_language'
import { TextRead, TextReaderController, ReaderParams, DisplayTab } from 'text_reader'
import { TranslateHomeViewModel } from '../viewmodel/TranslateHomeViewModel'
import { TranslateDialogViewModel } from '../viewmodel/TranslateDialogViewModel'
import { TranslateLanguageList } from '../comp/TranslateLanguageList'
import { TranslateTextReader } from '../comp/TranslateTextReader'
import { BreakpointModel, RouterMap, UserInfo } from 'common'
import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI'
import { OHPage, phoneRouterControl } from 'oh_router'
import { VipCenterPageBuilder, LoginPageBuilder, LoginRedirectFlag } from 'person'

@Builder
export function TranslateDetailPageBuilder() {
  TranslateDetailPage()
}

@ComponentV2
export struct TranslateDetailPage {
  vm: TranslateDetailViewModel = TranslateDetailViewModel.instance
  homeVm: TranslateHomeViewModel = TranslateHomeViewModel.instance
  @Local translateVm: TranslateDialogViewModel = new TranslateDialogViewModel()
  @Local userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!
  @Local showLanguagePicker: boolean = false

  @Monitor('userInfo.isVip')
  onVipStatusChange(): void {
    this.homeVm.languageViewModel.setVipStatus(this.userInfo.isVip);
  }

  @Local isSelectingSource: boolean = false
  @Local isImageTranslate: boolean = false
  private textReaderController: TextReaderController = new TextReaderController()
  @Local readerParam: ReaderParams = {
    isVoiceBrandVisible: false,
    isFastForward: false,
    isMinibarNeeded: false,
    displayTab: DisplayTab.CONTENT,
  }
  @Local breakpointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Local isSourcePlaying: boolean = false
  @Local isTargetPlaying: boolean = false
  @Local currentPlayingId: string = ''

  aboutToAppear(): void {
    this.isImageTranslate = this.vm.imageBuffer !== null
    this.homeVm.languageViewModel.setVipStatus(this.userInfo.isVip);
  }

  aboutToDisappear(): void {
    this.stopAndRelease()
  }

  @Builder
  header() {
    LanguagePickerHeader({
      onReturnClick: () => {
        this.stopAndRelease()
        phoneRouterControl.popPage()
      },
      sourceLanguageName: this.vm.sourceLanguageDisplayName,
      targetLanguageName: this.vm.targetLanguageDisplayName,
      showSourceLanguageSelect: !this.isImageTranslate,
      showTargetLanguageSelect: !this.isImageTranslate,
      showSwapButton: true,
      centerLanguageSelector: true,
      headerBackgroundColor: Color.Transparent,
      onSourceLanguageClick: () => {
        if (!this.isImageTranslate) {
          this.homeVm.languageViewModel.setEditingType(LanguageType.SOURCE)
          this.isSelectingSource = true
          this.showLanguagePicker = true
        }
      },
      onTargetLanguageClick: () => {
        if (!this.isImageTranslate) {
          this.homeVm.languageViewModel.setEditingType(LanguageType.TARGET)
          this.isSelectingSource = false
          this.showLanguagePicker = true
        }
      },
      onSwapClick: () => {
        this.handleSwapLanguages()
      }
    })
  }

  @Builder
  translationCard() {
    Column({ space: 16 }) {
      Column({ space: 12 }) {
        this.sourceTextBlock()
      }

      Divider().width('100%').color($r('sys.color.comp_background_emphasize'))
      Column({ space: 12 }) {
        this.targetTextBlock()
      }
    }
    .padding({
      left: 24,
      right: 24,
      top: 24,
      bottom: 24
    })
    .backgroundColor('#DCF0FF')
    .borderRadius(12)
    .margin({ left: 12, right: 12, top: 16 })
  }

  @Builder
  sourceTextBlock() {
    Column({ space: 12 }) {
      Text(this.vm.sourceText)
        .fontSize(15)
        .fontColor(this.isSourcePlaying ? '#1855FF' : $r('sys.color.font_primary'))
        .lineHeight(24)
        .textAlign(TextAlign.Start)
        .width('100%')

      Row() {
        Image($r('app.media.ic_voice'))
          .width(24)
          .height(24)
          .objectFit(ImageFit.Contain)
          .fillColor('#1855FF')
          .onClick(() => {
            this.handlePlaySourceText()
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  targetTextBlock() {
    Column({ space: 12 }) {
      Text(this.vm.translatedText)
        .fontSize(15)
        .fontColor(this.isTargetPlaying ? '#1855FF' : $r('sys.color.font_primary'))
        .lineHeight(24)
        .textAlign(TextAlign.Start)
        .direction(Direction.Ltr)
        .width('100%')

      Row() {
        Image($r('app.media.ic_voice'))
          .width(24)
          .height(24)
          .objectFit(ImageFit.Contain)
          .fillColor('#1855FF')
          .onClick(() => {
            this.handlePlayTargetText()
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  languagePickerSheet() {
    TranslateLanguageList({
      languages: this.getFilteredLanguages(),
      selectedLanguageCode: this.isSelectingSource ?
        (this.vm.sourceLanguageCode || 'auto') :
      this.homeVm.languageViewModel.targetLanguage.code,
      isVipUser: this.homeVm.languageViewModel.isVipUser,
      onLanguageSelect: (language: Language) => {
        if (this.isSelectingSource) {
          this.selectSourceLanguage(language)
        } else {
          this.selectTargetLanguage(language)
        }
      },
      onVipUpgrade: () => {
        this.showLanguagePicker = false;
        setTimeout(() => {
          if (!this.userInfo.isLogin) {
            const flag = AppStorageV2.connect(LoginRedirectFlag, () => new LoginRedirectFlag())!;
            flag.redirectToVip = true;
            phoneRouterControl.jumpPage({
              pageName: RouterMap.LOGIN_PAGE,
              builder: wrapBuilder(LoginPageBuilder)
            });
          } else {
            phoneRouterControl.jumpPage({
              pageName: RouterMap.VIP_CENTER_PAGE,
              builder: wrapBuilder(VipCenterPageBuilder)
            });
          }
        }, 100);
      }
    })
  }

  getFilteredLanguages(): Language[] {
    const languages = this.homeVm.languageViewModel.availableLanguages;
    // 目标语言选择时，过滤掉"自动检测"
    if (!this.isSelectingSource) {
      return languages.filter((lang: Language) => lang.code !== 'auto');
    }
    return languages;
  }

  selectSourceLanguage(language: Language): void {
    this.homeVm.languageViewModel.setSourceLanguage(language)
    this.vm.sourceLanguageName = language.name
    this.vm.sourceLanguageDisplayName = language.name
    this.vm.sourceLanguageCode = language.code
    this.showLanguagePicker = false
  }

  selectTargetLanguage(language: Language): void {
    if (language.code !== 'auto') {
      this.homeVm.languageViewModel.setTargetLanguage(language)
      this.vm.targetLanguageName = language.name
      this.vm.targetLanguageDisplayName = language.name
      this.vm.targetLanguageCode = language.code
      this.showLanguagePicker = false
      this.retranslateWithNewLanguages(this.vm.sourceLanguageCode || 'auto', language.code, true)
    }
  }

  private async retranslateWithNewLanguages(sourceLanguageCode: string, targetLanguageCode: string,
    showToast: boolean = false): Promise<void> {
    if (!this.vm.sourceText) {
      return
    }
    this.translateVm.inputText = this.vm.sourceText
    this.translateVm.sourceLanguage = sourceLanguageCode
    this.translateVm.targetLanguage = targetLanguageCode
    const response = await this.translateVm.translate(showToast)
    if (response && response.success) {
      this.vm.translatedText = response.result
      this.vm.targetLanguageCode = targetLanguageCode
    }
  }

  private async handleSwapLanguages(): Promise<void> {
    await this.vm.switchLanguages()
  }

  build() {
    OHPage({
      childBuilder: () => {
        this.render();
      },
      isFullScreen: true,
      useSafePadding: false,
      pageBackgroundColor: '#F4F6FB'
    })
  }

  @Builder
  render() {
    Stack() {
      Column() {
        this.header()
        Scroll() {
          Column({ space: 16 }) {
            this.translationCard()
          }
          .padding({ bottom: 24 })
        }
        .layoutWeight(1)
        .width('100%')
        .align(Alignment.Top)
        .scrollBar(BarState.Auto)
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F4F6FB')
      .bindSheet($$this.showLanguagePicker, this.languagePickerSheet(), {
        height: '95%',
        showClose: false,
        dragBar: true,
        backgroundColor: Color.White,
        onDisappear: () => {
          this.showLanguagePicker = false
        }
      })

      TextRead({
        currentId: '',
        readInfoList: [],
        readerParam: this.readerParam,
        controller: this.textReaderController,
      })
        .width(0)
        .height(0)
        .opacity(0)
    }
    .width('100%')
    .height('100%')
  }

  private stopAndRelease(): void {
    this.isSourcePlaying = false
    this.isTargetPlaying = false
    this.currentPlayingId = ''
    TranslateTextReader.stop(this.textReaderController)
  }

  private async handlePlaySourceText(): Promise<void> {
    if (this.isSourcePlaying && this.currentPlayingId === 'source_text') {
      TranslateTextReader.stop(this.textReaderController)
      this.isSourcePlaying = false
      this.currentPlayingId = ''
      return
    }
    if (this.isTargetPlaying || this.currentPlayingId !== '') {
      TranslateTextReader.stop(this.textReaderController)
      this.isTargetPlaying = false
    }
    const success = await TranslateTextReader.playText(
      this.textReaderController,
      this.vm.sourceText,
      this.vm.sourceLanguageDisplayName,
      'source_text',
      this.vm.sourceLanguageCode
    )
    if (success) {
      this.isSourcePlaying = true
      this.currentPlayingId = 'source_text'
    }
  }

  private async handlePlayTargetText(): Promise<void> {
    if (this.isTargetPlaying && this.currentPlayingId === 'target_text') {
      TranslateTextReader.stop(this.textReaderController)
      this.isTargetPlaying = false
      this.currentPlayingId = ''
      return
    }
    if (this.isSourcePlaying || this.currentPlayingId !== '') {
      TranslateTextReader.stop(this.textReaderController)
      this.isSourcePlaying = false
    }
    const success = await TranslateTextReader.playText(
      this.textReaderController,
      this.vm.translatedText,
      this.vm.targetLanguageDisplayName,
      'target_text',
      this.vm.targetLanguageCode
    )
    if (success) {
      this.isTargetPlaying = true
      this.currentPlayingId = 'target_text'
    }
  }
}
