// 翻译首页
import { LanguageType } from 'choose_language';
import { TranslateHomeViewModel } from '../viewmodel/TranslateHomeViewModel';
import { phoneRouterControl } from 'oh_router';
import { BarVM, BreakpointModel, RouterMap, UserInfo } from 'common';
import { TranslateDialogPageBuilder } from './TranslateDialogPage';
import { CameraTranslatePageBuilder } from './CameraTranslatePage';
import { DocumentTranslatePageBuilder } from './DocumentTranslatePage';
import { TranslateHomeFunctionCards } from '../comp/TranslateHomeFunctionCards';
import { CameraTranslateSourceDialog, CameraTranslateSourceSheet } from '../comp/CameraTranslateSourceSheet';
import { TranslateLanguagePickerSheet } from '../comp/TranslateLanguagePickerSheet';
import { VoiceTranslateSheet } from '../comp/VoiceTranslateSheet';
import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI';
import { TranslateDetailPageBuilder } from './TranslateDetailPage';
import { VoiceTranslateHelper } from '../model/VoiceTranslateHelper';


@Builder
export function TranslateHomePageBuilder() {
  TranslateHomePage()
}

/**
 * @usage: 翻译应用首页，提供多种翻译功能入口。支持文本翻译、语音翻译、拍照翻译、文档翻译四种翻译方式。
 * 主要数据结构包括TranslateHomeViewModel（首页视图模型）、UserInfo（用户信息）、BreakpointModel（断点模型）。
 * 包含if逻辑判断折叠屏状态以适配不同设备显示。
 * @layout: 页面采用Stack堆叠布局，底层为渐变背景Column，上层为可滚动内容区域Scroll。
 * 内容区域包含Banner图、翻译输入容器（语言选择和输入提示）、功能卡片区域（文档/语音/拍照翻译入口）。
 * 底部通过bindSheet绑定语音翻译弹窗和相机选择弹窗。
 * @constraints: 需要用户授权麦克风和相机权限才能使用语音翻译和拍照翻译功能
 * @domain: 翻译工具
 * @zhName: 翻译首页
 * @fileType: page
 * @isGen: true
 * @subPage: TranslateDialogPage,CameraTranslatePage,DocumentTranslatePage,TranslateDetailPage
 * @component: TranslateHomeFunctionCards,CameraTranslateSourceSheet,TranslateLanguagePickerSheet,VoiceTranslateSheet
 * @image: screenshot/home.jpg
 */
@ComponentV2
export struct TranslateHomePage {
  vm: TranslateHomeViewModel = TranslateHomeViewModel.instance;
  @Local showCameraSheet: boolean = false;
  @Local showVoiceSheet: boolean = false;
  @Local breakpointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Local userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;

  // 监听VIP状态变化
  @Monitor('userInfo.isVip')
  onVipStatusChange(): void {
    this.vm.languageViewModel.setVipStatus(this.userInfo.isVip);
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      // 渐变背景 - 从淡蓝紫色渐变融入白色背景
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          angle: 180,
          colors: [
            ['#E6EEFF', 0.0],
            ['#EDE8FA', 0.15],
            ['#FFFFFF', 0.4]
          ]
        })
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])

      // 可滚动内容区域
      Scroll() {
        Column() {
          // Banner图
          Image($r('app.media.banner'))
            .width('100%')
            .height(280)
            .objectFit(ImageFit.Contain)
            .margin({ top: BarVM.instance.staBarH })

          // 翻译输入容器
          Column() {
            // 语言选择区域
            Row({ space: 2 }) {
              // 源语言
              Text(this.vm.languageViewModel.sourceLanguageDisplay.name)
                .fontSize(14)
                .fontColor($r('sys.color.font_primary'))
                .fontWeight(FontWeight.Medium)

              // 分隔符
              Text('/')
                .fontSize(14)
                .fontColor($r('sys.color.font_primary'))

              // 目标语言
              Text(this.vm.languageViewModel.targetLanguage.name)
                .fontSize(14)
                .fontColor($r('sys.color.font_primary'))
                .fontWeight(FontWeight.Medium)

              // 下拉按钮
              Image($r('app.media.select'))
                .width(25)
                .height(25)
                .objectFit(ImageFit.Contain)
                .fillColor($r('sys.color.font_tertiary'))
            }
            .width('100%')
            .justifyContent(FlexAlign.Start)
            .alignItems(VerticalAlign.Center)
            .clickEffect({ level: ClickEffectLevel.LIGHT })
            .onClick(() => {
              this.vm.openLanguagePicker(LanguageType.TARGET);
            })

            // 跳转按钮区域
            Row() {
              Text('输入要翻译的单词/句子')
                .fontSize(14)
                .fontColor($r('sys.color.font_tertiary'))
                .textAlign(TextAlign.Start)
            }
            .width('100%')
            .justifyContent(FlexAlign.Start)
            .alignItems(VerticalAlign.Center)
            .layoutWeight(1)
            .clickEffect({ level: ClickEffectLevel.LIGHT })
            .onClick(() => {
              // 点击跳转到翻译对话页面
              phoneRouterControl.jumpPage({
                pageName: RouterMap.TRANSLATE_DIALOG_PAGE,
                builder: wrapBuilder(TranslateDialogPageBuilder)
              });
            })
          }
          .height(95)
          .padding({
            left: 16,
            right: 16,
            top: 16,
            bottom: 16
          })
          .margin({ left: this.breakpointModel.pagePadding, right: this.breakpointModel.pagePadding, top: -30 })
          .borderRadius(20)
          .border({ width: 2, color: '#000000' })
          .backgroundColor(Color.White)

          // 功能卡片
          TranslateHomeFunctionCards({
            isFoldScreen: this.vm.isFoldScreen,
            breakpointModel: this.breakpointModel,
            onVoiceInputClick: () => {
              this.showVoiceSheet = true;
            },
            onDocumentClick: () => {
              phoneRouterControl.jumpPage({
                pageName: RouterMap.DOCUMENT_TRANSLATE_PAGE,
                builder: wrapBuilder(DocumentTranslatePageBuilder)
              });
            },
            onCameraClick: () => {
              if (this.vm.isFoldScreen) {
                CameraTranslateSourceDialog.showDialog({
                  onImageSelected: (imageUri: string, source: 'camera' | 'album') => {
                    const params: Record<string, Object> = {
                      'imageUri': imageUri,
                      'imageSource': source
                    };
                    phoneRouterControl.jumpPage({
                      pageName: RouterMap.CAMERA_TRANSLATE_PAGE,
                      builder: wrapBuilder(CameraTranslatePageBuilder),
                      param: params
                    });
                  },
                  onDismiss: () => {
                  }
                });
              } else {
                this.showCameraSheet = true;
              }
            }
          })
        }
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .align(Alignment.Top)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
      .bindSheet($$this.showVoiceSheet, this.buildVoiceSheet(), {
        height: 350,
        showClose: false,
        dragBar: true,
        blurStyle: BlurStyle.COMPONENT_ULTRA_THICK,
        onDisappear: () => {
          this.showVoiceSheet = false;
        }
      })

      TranslateLanguagePickerSheet({ vm: this.vm })
    }
    .width('100%')
    .height('100%')
    .bindSheet($$this.showCameraSheet, this.buildCameraSheet(), {
      height: SheetSize.FIT_CONTENT,
      width: this.vm.isFoldScreen ? 400 : undefined,
      showClose: false,
      dragBar: false,
      blurStyle: BlurStyle.COMPONENT_ULTRA_THICK,
      preferType: this.vm.isFoldScreen ? SheetType.CENTER : SheetType.BOTTOM,
      onDisappear: () => {
        this.showCameraSheet = false;
      }
    })
    .onAppear(() => {
      if (!this.userInfo.isLogin && this.userInfo.isVip) {
        this.userInfo.isVip = false;
      }
      this.vm.syncVipStatus();
    })
  }

  @Builder
  buildCameraSheet() {
    CameraTranslateSourceSheet({
      callbacks: {
        onImageSelected: (imageUri: string, source: 'camera' | 'album') => {
          this.showCameraSheet = false;
          const params: Record<string, Object> = {
            'imageUri': imageUri,
            'imageSource': source
          };
          phoneRouterControl.jumpPage({
            pageName: RouterMap.CAMERA_TRANSLATE_PAGE,
            builder: wrapBuilder(CameraTranslatePageBuilder),
            param: params
          });
        },
        onDismiss: () => {
          this.showCameraSheet = false;
        }
      }
    })
  }

  @Builder
  buildVoiceSheet() {
    VoiceTranslateSheet({
      callbacks: {
        onComplete: (text: string, targetLanguageCode: string) => {
          this.showVoiceSheet = false;
          this.handleVoiceInputFinish(text, targetLanguageCode);
        },
        onDismiss: () => {
          this.showVoiceSheet = false;
        }
      }
    })
  }

  private async handleVoiceInputFinish(text: string, targetLangCode: string): Promise<void> {
    const success = await VoiceTranslateHelper.handleVoiceTranslate(text, targetLangCode);
    if (success) {
      phoneRouterControl.jumpPage({
        pageName: RouterMap.TRANSLATE_DETAIL_PAGE,
        builder: wrapBuilder(TranslateDetailPageBuilder)
      });
    }
  }
}
