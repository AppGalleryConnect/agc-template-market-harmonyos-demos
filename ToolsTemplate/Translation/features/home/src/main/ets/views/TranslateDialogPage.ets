import { TranslateDialogViewModel } from '../viewmodel/TranslateDialogViewModel'
import { TranslateHistoryItem } from '../model/TranslateDialogModel'
import { TranslateHomeViewModel } from '../viewmodel/TranslateHomeViewModel'
import { LanguageType, Language, LanguagePickerHeader } from 'choose_language'
import { TranslateDetailViewModel } from '../viewmodel/TranslateDetailViewModel';
import { OHPage, phoneRouterControl } from 'oh_router';
import { TranslateDetailPageBuilder } from './TranslateDetailPage';
import { BreakpointModel, RouterMap, UserInfo } from 'common';
import { LanguageCodeConverter } from '../utils/LanguageCodeConverter';
import { TranslateLanguageList } from '../comp/TranslateLanguageList';
import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI';
import { LoginPageBuilder, LoginRedirectFlag, VipCenterPageBuilder } from 'person';


/**
 * @usage: 翻译对话页面，提供文本输入翻译功能和历史记录管理。支持源语言和目标语言选择、语言交换、翻译历史记录查看和清空。
 * 主要数据结构包括TranslateDialogViewModel（对话视图模型）、TranslateHistoryItem（历史记录项）、TranslateHomeViewModel
 （首页视图模型）。
 * 包含if逻辑判断输入状态显示发送按钮和清空按钮。
 * @layout: 页面采用Stack堆叠布局，主体为Column垂直布局。顶部为LanguagePickerHeader导航栏（含语言选择和交换按钮），
 * 中间为输入区域Row（TextInput输入框和操作按钮），下方为历史记录区域Column（标题行和List列表）。
 * 底部通过bindSheet绑定语言选择弹窗，通过条件渲染显示清空历史确认弹窗。
 * @constraints: 翻译功能需要网络连接，VIP语言需要会员权限
 * @domain: 翻译工具
 * @zhName: 翻译对话页面
 * @fileType: page
 * @isGen: true
 * @subPage: TranslateDetailPage,VipCenterPage,LoginPage
 * @component: LanguagePickerHeader,TranslateLanguageList
 * @image: screenshot/home/TranslateDialogPage.jpg
 */
@ComponentV2
export struct TranslateDialogPage {
  @Local vm: TranslateDialogViewModel = new TranslateDialogViewModel();
  homeVm: TranslateHomeViewModel = TranslateHomeViewModel.instance;
  @Local userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;
  @Local showLanguagePicker: boolean = false;
  @Local showClearDialog: boolean = false;
  @Local breakpointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;

  aboutToAppear(): void {
    // 同步VIP状态
    this.homeVm.languageViewModel.setVipStatus(this.userInfo.isVip);
  }

  //顶部导航栏
  @Builder
  navigationBar() {
    LanguagePickerHeader({
      onReturnClick: () => {
        phoneRouterControl.popPage()
      },
      sourceLanguageName: this.homeVm.languageViewModel.sourceLanguageDisplay.name,
      targetLanguageName: this.homeVm.languageViewModel.targetLanguage.name,
      showSourceLanguageSelect: true,
      showTargetLanguageSelect: true,
      showSwapButton: true,
      sourceLanguageHighlight: false,
      targetLanguageHighlight: false,
      centerLanguageSelector: true,
      headerBackgroundColor: Color.Transparent,
      onSourceLanguageClick: () => {
        this.homeVm.languageViewModel.setEditingType(LanguageType.SOURCE)
        this.showLanguagePicker = true
      },
      onTargetLanguageClick: () => {
        this.homeVm.languageViewModel.setEditingType(LanguageType.TARGET)
        this.showLanguagePicker = true
      },
      onSwapClick: () => {
        if (this.homeVm.languageViewModel.canSwap()) {
          this.homeVm.languageViewModel.swapLanguages()
        }
      }
    })
  }

  //输入
  @Builder
  inputHintArea() {
    Row({ space: 8 }) {
      TextInput({ placeholder: '输入要翻译的单词/句子', text: $$this.vm.inputText })
        .layoutWeight(1)
        .height(60)
        .fontSize(14)
        .backgroundColor('#E8F4FF')
        .borderRadius(12)
        .padding({ left: 16, right: 16 })
        .border({ width: 0 })
        .type(InputType.Normal)
        .enterKeyType(EnterKeyType.Send)
        .onChange((value: string) => {
          if (this.homeVm.languageViewModel.sourceLanguage.code === 'auto') {
            this.vm.detectLanguage(value)
          }
        })
        .onSubmit(() => {
          this.handleTranslateSubmit()
        })

      if (this.vm.inputText && this.vm.inputText.length > 0) {
        Image($r('app.media.ic_public_close'))
          .width(24)
          .height(24)
          .objectFit(ImageFit.Contain)
          .onClick(() => {
            this.vm.inputText = ''
            this.vm.detectedLanguage = ''
          })
      }
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 16 })
  }

  //历史记录区域
  @Builder
  historyArea() {
    Column() {
      Row() {
        Text('历史记录')
          .fontSize(14)
          .fontColor($r('sys.color.font_secondary'))
          .layoutWeight(1)

        SymbolGlyph($r('sys.symbol.trash'))
          .fontSize(20)
          .fontColor([$r('sys.color.font_tertiary')])
          .onClick(() => {
            if (this.vm.historyList.length > 0) {
              this.showClearDialog = true
            }
          })
      }
      .width('100%')
      .padding({
        left: 16,
        right: 16,
        top: 16,
        bottom: 12
      })

      List({ space: 0 }) {
        ForEach(this.vm.historyList, (item: TranslateHistoryItem) => {
          ListItem() {
            Row() {
              Text(item.languagePair)
                .fontSize(12)
                .fontColor($r('sys.color.font_tertiary'))
                .backgroundColor('#F0F0F0')
                .padding({
                  left: 8,
                  right: 8,
                  top: 4,
                  bottom: 4
                })
                .borderRadius(4)
                .margin({ right: 12 })

              Text(item.text)
                .fontSize(14)
                .fontColor($r('sys.color.font_primary'))
                .layoutWeight(1)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .width('100%')
            .padding({
              left: 16,
              right: 16,
              top: 12,
              bottom: 12
            })
            .onClick(() => {
              TranslateDetailViewModel.instance.updateDetail({
                sourceLanguageName: this.getLanguageName(item.sourceLanguage),
                targetLanguageName: this.getLanguageName(item.targetLanguage),
                sourceText: item.text,
                translatedText: item.translatedText,
                sourceLanguageCode: item.sourceLanguage,
                targetLanguageCode: item.targetLanguage,
                imageBuffer: undefined
              });
              phoneRouterControl.jumpPage({
                pageName: RouterMap.TRANSLATE_DETAIL_PAGE,
                builder: wrapBuilder(TranslateDetailPageBuilder)
              })
            })
          }
          .backgroundColor(Color.White)
        })
        ListItem() {
          Column().height(20)
        }
      }
      .width('100%')
      .height('100%')
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
      .layoutWeight(1)
      .divider({
        strokeWidth: 1,
        color: '#F0F0F0',
        startMargin: 16,
        endMargin: 16
      })
    }
    .width('100%')
    .layoutWeight(1)
    .clip(true)
  }

  //语言选择列表
  @Builder
  languagePickerSheet() {
    TranslateLanguageList({
      languages: this.getFilteredLanguages(),
      selectedLanguageCode: this.getSelectedLanguageCode(),
      isVipUser: this.homeVm.languageViewModel.isVipUser,
      onLanguageSelect: (language: Language) => {
        this.selectLanguage(language)
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

  getSelectedLanguageCode(): string {
    if (this.homeVm.languageViewModel.editingType === LanguageType.SOURCE) {
      return this.homeVm.languageViewModel.sourceLanguage.code
    } else {
      return this.homeVm.languageViewModel.targetLanguage.code
    }
  }

  getFilteredLanguages(): Language[] {
    const languages = this.homeVm.languageViewModel.availableLanguages;
    // 目标语言选择时，过滤掉"自动检测"
    if (this.homeVm.languageViewModel.editingType === LanguageType.TARGET) {
      return languages.filter((lang: Language) => lang.code !== 'auto');
    }
    return languages;
  }

  selectLanguage(language: Language): void {
    if (this.homeVm.languageViewModel.editingType === LanguageType.SOURCE) {
      this.homeVm.languageViewModel.setSourceLanguage(language)
    } else {
      if (language.code !== 'auto') {
        this.homeVm.languageViewModel.setTargetLanguage(language)
      }
    }
    this.showLanguagePicker = false
  }

  private getLanguageName(code: string): string {
    return LanguageCodeConverter.toDisplayName(code);
  }

  @Builder
  clearHistoryDialog() {
    Column() {
      Text('确定清空所有历史记录吗？')
        .fontSize(16)
        .fontColor($r('sys.color.font_primary'))
        .textAlign(TextAlign.Center)
        .margin({ top: 24, bottom: 24 })

      Row() {
        Button('取消')
          .layoutWeight(1)
          .height(48)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_primary'))
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            this.showClearDialog = false
          })

        Divider()
          .vertical(true)
          .height(48)
          .strokeWidth(1)
          .color('#F0F0F0')

        Button('清空')
          .layoutWeight(1)
          .height(48)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.warning'))
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            this.vm.clearHistory()
            this.showClearDialog = false
          })
      }
      .width('100%')
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(12)
    .padding({ left: this.breakpointModel.pagePadding, right: this.breakpointModel.pagePadding })
  }

  build() {
    OHPage({
      childBuilder: () => {
        this.render();
      },
      isFullScreen: true,
      useSafePadding: false,
      pageBackgroundColor: '#FAFAFA'
    })
  }

  @Builder
  render() {
    Stack() {
      Column() {
        this.navigationBar()
        this.inputHintArea()
        this.historyArea()
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#FAFAFA')
      .bindSheet($$this.showLanguagePicker, this.languagePickerSheet(), {
        height: '95%',
        showClose: false,
        dragBar: true,
        backgroundColor: Color.White,
        onAppear: () => {
          this.homeVm.syncVipStatus();
        },
        onDisappear: () => {
          this.showLanguagePicker = false
        }
      })

      if (this.showClearDialog) {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0, 0, 0, 0.5)')
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            this.showClearDialog = false
          })

        Column() {
          this.clearHistoryDialog()
        }
        .width('80%')
        .position({ x: '10%', y: '40%' })
      }
    }
    .width('100%')
    .height('100%')
  }

  private async handleTranslateSubmit(): Promise<void> {
    const textSnapshot = this.vm.inputText
    const response = await this.vm.translate()
    if (!response) {
      return
    }

    const languageVm = this.homeVm.languageViewModel
    const actualSourceLanguageName = LanguageCodeConverter.toDisplayName(response.sourceLanguage)
    const targetLanguageName = languageVm.targetLanguage.name

    TranslateDetailViewModel.instance.updateDetail({
      sourceLanguageName: actualSourceLanguageName,
      targetLanguageName: targetLanguageName,
      sourceLanguageDisplayName: actualSourceLanguageName,
      targetLanguageDisplayName: languageVm.targetLanguage.name,
      detectedLanguageHint: '',
      sourceText: textSnapshot,
      translatedText: response.result,
      sourceLanguageCode: response.sourceLanguage,
      targetLanguageCode: languageVm.targetLanguage.code
    })

    phoneRouterControl.jumpPage({
      pageName: RouterMap.TRANSLATE_DETAIL_PAGE,
      builder: wrapBuilder(TranslateDetailPageBuilder)
    })
  }
}

@Builder
export function TranslateDialogPageBuilder() {
  TranslateDialogPage()
}
