import { VoiceInputViewModel, VoiceInputStatus } from 'voice_input';
import { Language, VipUpgradeDialog } from 'choose_language';
import { TranslateLanguageList } from './TranslateLanguageList';
import { phoneRouterControl } from 'oh_router';
import { RouterMap, UserInfo } from 'common';
import { VipCenterPageBuilder, LoginPageBuilder, LoginRedirectFlag } from 'person';
import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { TranslateHomeViewModel } from '../viewmodel/TranslateHomeViewModel';

export interface VoiceTranslateSheetCallbacks {
  onComplete: (text: string, targetLanguageCode: string) => void;
  onDismiss: () => void;
}

/**
 * @usage: 语音翻译弹窗组件，提供语音输入识别功能。支持实时语音识别、目标语言选择、识别结果显示和清空。
 * 主要数据结构包括VoiceInputViewModel（语音输入视图模型）、VoiceTranslateSheetCallbacks（回调接口）、TranslateHomeViewModel
 （首页视图模型）。
 * 包含if逻辑判断语音状态显示不同的录音按钮和波形动画。
 * @layout: 组件采用Column垂直布局。顶部Header区域Row（返回按钮、目标语言选择器），中间识别结果区域Column（Scroll滚动文本和清空按钮），
 * 波形动画区域Column（WaveView），底部录音按钮区域Column（RecordButton/CompleteButton）。
 * 通过bindSheet绑定语言选择弹窗。
 * @constraints: 需要用户授权麦克风权限，目前仅支持中文语音识别
 * @domain: 翻译工具
 * @zhName: 语音翻译弹窗组件
 * @fileType: component
 * @isGen: true
 * @subPage: VipCenterPage,LoginPage
 * @component: TranslateLanguageList,VipUpgradeDialog
 * @image: screenshot/home/VoiceTranslateSheet.jpg
 */
@ComponentV2
export struct VoiceTranslateSheet {
  @Param callbacks: VoiceTranslateSheetCallbacks = {
    onComplete: () => {
    },
    onDismiss: () => {
    }
  };
  @Local vm: VoiceInputViewModel = new VoiceInputViewModel();
  private homeVm: TranslateHomeViewModel = TranslateHomeViewModel.instance;
  @Local showLanguageSheet: boolean = false;
  @Local showVipDialog: boolean = false;
  @Local userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;
  private textScroller: Scroller = new Scroller();

  @Monitor('vm.resultText')
  onResultTextChange(): void {
    setTimeout(() => {
      this.textScroller.scrollEdge(Edge.Bottom);
    }, 50);
  }

  aboutToAppear(): void {
    this.homeVm.languageViewModel.setVipStatus(this.userInfo.isVip);
  }

  aboutToDisappear(): void {
    this.vm.shutdown();
  }

  build() {
    Column() {
      this.Header()
      Column() {
        if (this.vm.resultText) {
          Row() {
            Scroll(this.textScroller) {
              Text(this.vm.resultText)
                .fontSize(18)
                .fontColor($r('sys.color.font_primary'))
                .textAlign(TextAlign.Start)
                .width('100%')
            }
            .layoutWeight(1)
            .scrollBar(BarState.Auto)
            .align(Alignment.Bottom)

            Image($r('app.media.ic_close'))
              .width(24)
              .height(24)
              .fillColor($r('sys.color.font_tertiary'))
              .margin({ left: 12 })
              .onClick(() => {
                this.vm.clearResult()
              })
          }
          .width('100%')
          .layoutWeight(1)
          .alignItems(VerticalAlign.Bottom)
        } else {
          Text(this.vm.status === VoiceInputStatus.IDLE ? '点击话筒后即可开始识别中文' : '正在聆听中...')
            .fontSize(16)
            .fontColor($r('sys.color.font_secondary'))
        }
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
      .width('100%')
      .padding({ left: 20, right: 20 })

      Column() {
        if (this.vm.status === VoiceInputStatus.LISTENING) {
          this.WaveView()
        }
      }
      .height(50)
      .justifyContent(FlexAlign.Center)
      .width('100%')

      Column() {
        if (this.vm.resultText) {
          this.CompleteButton()
        } else {
          this.RecordButton()
        }
      }
      .padding({ bottom: 24 })
      .width('100%')
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
    .bindSheet($$this.showLanguageSheet, this.buildLanguageSheet(), {
      height: '95%',
      showClose: false,
      dragBar: true,
      backgroundColor: Color.White,
      onAppear: () => {
        this.homeVm.languageViewModel.setVipStatus(this.userInfo.isVip);
      },
      onDisappear: () => {
        this.showLanguageSheet = false;
        this.showVipDialog = false;
      }
    })
  }

  @Builder
  Header() {
    Row() {
      Button() {
        SymbolGlyph($r('sys.symbol.chevron_backward'))
          .fontSize(24)
          .fontColor([$r('sys.color.icon_primary')])
          .fontWeight(FontWeight.Normal)
      }
      .width(40)
      .height(40)
      .type(ButtonType.Circle)
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .onClick(() => {
        this.callbacks.onDismiss();
      })

      Row() {
        Row() {
          Text(this.homeVm.languageViewModel.targetLanguage.name)
            .fontSize(14)
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Medium)

          Image($r('app.media.select'))
            .width(25)
            .height(25)
            .margin({ left: 6 })
        }
        .backgroundColor('#EBEBEB')
        .padding({
          left: 12,
          right: 10,
          top: 6,
          bottom: 6
        })
        .borderRadius(16)
        .onClick(() => {
          this.showLanguageSheet = true;
        })
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)

      Row().width(40).height(40)
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  buildLanguageSheet() {
    Stack() {
      Column() {
        Row() {
          Button() {
            SymbolGlyph($r('sys.symbol.chevron_backward'))
              .fontSize(24)
              .fontColor([$r('sys.color.icon_primary')])
              .fontWeight(FontWeight.Normal)
          }
          .width(40)
          .height(40)
          .type(ButtonType.Circle)
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .onClick(() => {
            this.showLanguageSheet = false;
          })
        }
        .width('100%')
        .height(56)
        .padding({ left: 16 })
        .alignItems(VerticalAlign.Center)
        .backgroundColor(Color.White)

        TranslateLanguageList({
          languages: this.homeVm.languageViewModel.availableLanguages.filter((lang: Language) => lang.code !== 'auto'),
          selectedLanguageCode: this.homeVm.languageViewModel.targetLanguage.code,
          isVipUser: this.userInfo.isVip,
          onLanguageSelect: (language: Language) => {
            this.homeVm.languageViewModel.setTargetLanguage(language);
            this.showLanguageSheet = false;
          },
          onShowVipDialog: () => {
            this.showVipDialog = true;
          },
          onVipUpgrade: () => {
            this.handleVipUpgrade();
          }
        })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Color.White)

      if (this.showVipDialog) {
        VipUpgradeDialog({
          visible: this.showVipDialog,
          onClose: () => {
            this.showVipDialog = false;
          },
          onUpgrade: () => {
            this.handleVipUpgrade();
          }
        })
      }
    }
    .width('100%')
    .height('100%')
  }

  private handleVipUpgrade(): void {
    this.showVipDialog = false;
    this.showLanguageSheet = false;
    this.callbacks.onDismiss();
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

  @Builder
  WaveView() {
    Row({ space: 4 }) {
      ForEach(this.vm.volumeList, (height: number) => {
        Column()
          .width(4)
          .height(height)
          .backgroundColor('#4080FF')
          .borderRadius(2)
          .animation({ duration: 200, curve: Curve.EaseInOut })
      })
    }
    .height(40)
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  CompleteButton() {
    Stack() {
      Image($r('app.media.ic_complete'))
        .width(100)
        .height(100)
        .objectFit(ImageFit.Contain)
    }
    .width(100)
    .height(100)
    .onClick(() => {
      this.callbacks.onComplete(this.vm.resultText, this.homeVm.languageViewModel.targetLanguage.code);
    })
  }

  @Builder
  RecordButton() {
    Stack() {
      if (this.vm.status === VoiceInputStatus.IDLE) {
        Image($r('app.media.ic_voice_input'))
          .width(100)
          .height(100)
          .objectFit(ImageFit.Contain)
      } else {
        Image($r('app.media.ic_complete'))
          .width(100)
          .height(100)
          .objectFit(ImageFit.Contain)
      }
    }
    .width(100)
    .height(100)
    .onClick(async () => {
      if (this.vm.status === VoiceInputStatus.IDLE) {
        this.vm.startListening(getContext(this) as common.UIAbilityContext);
      } else {
        await this.vm.stopListening();
      }
    })
  }
}
