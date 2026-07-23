import { AppStorageV2, LengthMetrics, SymbolGlyphModifier, TipsDialog } from '@kit.ArkUI';
import { ConfigurationConstant } from '@kit.AbilityKit';
import { emitter } from '@kit.BasicServicesKit';
import { Header } from '../component/Header';
import { UserInfoRow } from '../component/UserInfoRow';
import { getString, NAV_PAGE_NAME } from '@agctemplate/resources';
import {
  AppStorageKeys,
  AssociateUtil,
  ColorMode,
  FontModel,
  fp2pxUtil,
  ListItemModel,
  MinePageVM,
  MinorsMode,
  MinorsProtectionUtils,
  StatusBarHeight,
  UserInfoModel
} from '@agctemplate/widgets';
import { appRouter, GlobalContext, PreferConstant, PreferenceUtil, SafeJson } from '@agctemplate/utils';

const minorsMode: MinorsMode =
  AppStorageV2.connect(MinorsMode, 'isMinorsMode', () => new MinorsMode(MinorsProtectionUtils.getMinorsMode()))!

@ComponentV2
export struct SetUpPage {
  @Local userInfo: UserInfoModel = AppStorageV2.connect(UserInfoModel, 'userInfo', () => new UserInfoModel())!
  @Local statusBarHeight: StatusBarHeight = AppStorageV2.connect(StatusBarHeight, AppStorageKeys.STATUS_BAR_HEIGHT,
    () => new StatusBarHeight())!;
  @Local vm: MinePageVM = MinePageVM.instance
  @Local isBackgroundPlay: boolean = false
  @Local isShowSpeedSheet: boolean = false
  @Local currentSpeed: string = '1.0x'
  @Local userAvatar: ListItemModel = new ListItemModel(getString('app.string.avatar'))
  @Local userName: ListItemModel = new ListItemModel(getString('app.string.nick_name'))
  @Local userPhone: ListItemModel = new ListItemModel(getString('app.string.phone_number'))
  @Local textValue: string = '';
  @Local colorMode: ColorMode = AppStorageV2.connect(ColorMode, 'colorMode', () => new ColorMode('跟随系统'))!
  @Local fontModel: FontModel = AppStorageV2.connect(FontModel, () => new FontModel())!;
  dialogController: CustomDialogController | null = new CustomDialogController({
    builder: TipsDialog({
      content: '是否退出登录',
      primaryButton: {
        value: '取消',
        action: () => {
          console.info('Callback when the first button is clicked')
        },
      },
      secondaryButton: {
        value: '确定',
        role: ButtonRole.ERROR,
        action: () => {
          console.info('Callback when the second button is clicked')
          this.onAccept()
        }
      }
    })
  });

  async onAccept() {
    console.info('Callback when the second button is clicked');
    this.userInfo.isVip = false;
    await AssociateUtil.disassociateAccount(this.getUIContext().getHostContext()!)
    appRouter.back()

  }

  aboutToDisappear() {
    this.dialogController = null; // 将dialogController置空
  }

  aboutToAppear(): void {
    this.currentSpeed =
      PreferenceUtil.getInstance(this.getUIContext().getHostContext())
        .get(PreferConstant.PLAY_SPEED_SETTINGS, '1.0x') as string
  }

  @Builder
  line() {
    Divider().strokeWidth('1px').width('100%').color($r('sys.color.comp_divider')).padding({ left: 12, right: 12 })
  }

  @Builder
  speedSheet(currentSpeed: string) {
    Column() {
      Speed({ currentSpeed: currentSpeed })
    }
    .width('100%')
    .padding({ left: 16, right: 16 })
  }

  build() {
    NavDestination() {
      Column() {
        Header({ title: '设置' })
        Scroll() {
          Column() {
            GenericCard() {
              UserInfoRow({
                leftTitle: getString('app.string.personal_info'), rightOnClick: () => {
                  appRouter.push({
                    builderName: NAV_PAGE_NAME.PersonalInfoPage.name, params: {
                      userAvatar: [
                        this.userAvatar.setContentImage(this.vm.localInfo.avatar ? this.vm.localInfo.avatar :
                          this.vm.userInfo.avatar)
                          .setHandle(() => {
                            appRouter.push({
                              builderName: NAV_PAGE_NAME.ChangePage.name
                            })
                          })],
                      userDetail: [this.userName.setContentText(this.vm.localInfo.nickname ?
                        this.vm.localInfo.nickname :
                        this.vm.userInfo.nickname)
                        .setHandle(() => {
                          appRouter.push({
                            builderName: NAV_PAGE_NAME.ChangePage.name
                          })
                        }),
                        this.userPhone.setContentText(this.vm.userInfo.cellphone).setHandle(() => {
                          this.getUIContext().getPromptAction().showToast({
                            message: getString('app.string.phone_tip'),
                            alignment: Alignment.Center
                          });
                        })]
                    }
                  })
                }
              })
              this.line()
              UserInfoRow({
                leftTitle: getString('app.string.privacy_policy'), rightOnClick: () => {
                  appRouter.push({ builderName: NAV_PAGE_NAME.PrivacyStatementPage.name })
                }
              })
            }

            GenericCard() {
              UserInfoRow({
                leftTitle: getString('app.string.color_mode'),
                isTriangle: true,
                rightContent: this.colorMode.modeName,
                rightMenu: () => {
                  this.menuBuilder()
                }
              })
              this.line()
              UserInfoRow({
                leftTitle: getString('app.string.font_size'), rightOnClick: () => {
                  appRouter.push({ builderName: NAV_PAGE_NAME.SettingFontPage.name })
                }
              })
            }

            GenericCard() {
              UserInfoRow({
                leftTitle: getString('app.string.preferences'), rightContent: '', rightOnClick: () => {
                  appRouter.push({ builderName: NAV_PAGE_NAME.MyPreferencesPage.name })
                }
              })
              this.line()
              UserInfoRow({
                leftTitle: getString('app.string.play_speed_settings'),
                rightContent: this.currentSpeed,
                rightOnClick: () => {
                  this.isShowSpeedSheet = !this.isShowSpeedSheet
                }
              })
                .bindSheet($$this.isShowSpeedSheet, this.speedSheet(this.currentSpeed), {
                  height: 400,
                  preferType: SheetType.BOTTOM,
                  title: titleBuilder(getString('app.string.play_speed_settings')),
                  onWillAppear: () => {
                    try {
                      emitter.on('SpeedSelected', (event: emitter.EventData) => {
                        this.currentSpeed = event.data!.speed
                      })
                    } catch (error) {
                      console.error('Failed. Cause:' + SafeJson.ohAegJsonStringify(error));
                    }
                  },
                  onWillDisappear: () => {
                    PreferenceUtil.getInstance(this.getUIContext().getHostContext())
                      .put(PreferConstant.PLAY_SPEED_SETTINGS, this.currentSpeed)
                  }
                })
              this.line()
              UserInfoRow({
                leftTitle: $r('app.string.background_mini_window_playback'),
                isSwitch: true,
                switchButton: (isOn) => {
                  this.isBackgroundPlay = isOn
                  PreferenceUtil.getInstance(this.getUIContext().getHostContext())
                    .put(PreferConstant.BACKGROUND_MINI_WINDOW_PLAYBACK, this.isBackgroundPlay)
                  let event: emitter.InnerEvent = {
                    eventId: 4,
                  }
                  let eventData: emitter.EventData = {
                    data: {
                      content: 'changeBack',
                      id: 4
                    }
                  };
                  try {
                    emitter.emit(event, eventData);
                  } catch (error) {
                    console.error('Failed. Cause:' + SafeJson.ohAegJsonStringify(error));
                  }
                }
              })

            }

            GenericCard() {
              UserInfoRow({
                leftTitle: '青少年模式',
                subTitle: '帮助青少年合理使用应用，引导孩子浏览合适内容',
                rightContent: minorsMode.isMinorsMode ? '已开启' : '未开启',
                rightOnClick: () => {
                  appRouter.push({ builderName: NAV_PAGE_NAME.MinorsModePage.name })
                }
              })
            }

            GenericCard() {
              UserInfoRow({
                leftTitle: '关于我们', rightOnClick: () => {
                  appRouter.push({ builderName: NAV_PAGE_NAME.AboutPage.name })
                }
              })
            }
          }
          .width('100%')
        }
        .scrollBar(BarState.Off)
        .layoutWeight(1)
        .align(Alignment.Top)

        Button('退出登录')
          .margin({ top: 16 })
          .borderRadius($r('sys.float.corner_radius_level10'))
          .fontColor($r('sys.color.font_primary'))
          .backgroundColor($r('sys.color.background_tertiary'))
          .fontSize(fp2pxUtil(16))
          .fontWeight(500)
          .width('100%')
          .constraintSize({
            maxWidth: 448
          })
          .onClick(() => {
            if (this.dialogController != null) {
              this.dialogController.open();
            }
          })
      }
      .constraintSize({
        maxWidth: 837
      })
      .padding({
        left: 16,
        right: 16,
      })
      .backgroundColor($r('sys.color.comp_background_gray'))
      .width('100%')
      .layoutWeight(1)
    }
    .backgroundColor($r('sys.color.comp_background_gray'))
    .padding({ top: `${this.getUIContext().px2vp(this.statusBarHeight.value)}vp`, bottom: 36 })
    .hideTitleBar(true)
  }

  @Builder
  menuBuilder() {
    Menu() {
      MenuItem({
        content: '跟随系统',
        symbolEndIcon: this.colorMode.modeName === '跟随系统' ?
          new SymbolGlyphModifier($r('sys.symbol.checkmark')).fontSize(24) :
          null
      })
        .contentFont({ size: this.fontModel.getFg(16), weight: 500 })
        .onChange((_selected: boolean) => {
          GlobalContext.getContext()
            .getApplicationContext()
            .setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET)
          this.colorMode.modeName = '跟随系统'
        })

      MenuItem({
        content: '深色模式',
        symbolEndIcon: this.colorMode.modeName === '深色模式' ?
          new SymbolGlyphModifier($r('sys.symbol.checkmark')).fontSize(24) :
          null
      })
        .contentFont({ size: this.fontModel.getFg(16), weight: 500 })
        .onChange((_selected: boolean) => {
          GlobalContext.getContext()
            .getApplicationContext()
            .setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_DARK)
          this.colorMode.modeName = '深色模式'
        })

      MenuItem({
        content: '浅色模式',
        symbolEndIcon: this.colorMode.modeName === '浅色模式' ?
          new SymbolGlyphModifier($r('sys.symbol.checkmark')).fontSize(24) :
          null
      })
        .contentFont({ size: this.fontModel.getFg(16), weight: 500 })
        .onChange((_selected: boolean) => {
          GlobalContext.getContext()
            .getApplicationContext()
            .setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT)
          this.colorMode.modeName = '浅色模式'
        })
    }
    .width(224)
    .menuItemDivider({
      startMargin: new LengthMetrics(12),
      endMargin: new LengthMetrics(12),
      strokeWidth: new LengthMetrics(1),
      color: $r('sys.color.comp_divider'),
      mode: DividerMode.FLOATING_ABOVE_MENU
    })
  }
}

@Builder
export function SetUpPageBuilder() {
  SetUpPage()
}

@ComponentV2
export struct GenericCard {
  @BuilderParam content: () => void

  build() {
    Column() {
      this.content()
    }
    .width('100%')
    .borderRadius(16)
    .margin({ top: 8, bottom: 4 })
    .padding({ top: 4, bottom: 4 })
    .borderRadius(16)
    .backgroundColor($r('sys.color.comp_background_list_card'))
  }
}

@ComponentV2
struct Speed {
  @Param currentSpeed: string = '1.0x'
  speedList: string[] = ['2.0x', '1.5x', '1.25x', '1.0x', '0.5x']
  @Local index: number = this.speedList.indexOf(this.currentSpeed)
  @Local fontModel: FontModel = AppStorageV2.connect(FontModel, () => new FontModel())!;

  build() {
    Column() {
      ForEach(this.speedList, (item: string, index: number) => {
        Column() {
          Row() {
            Text(item)
              .fontSize(this.fontModel.getFg(16))
              .fontWeight(500)
              .fontColor(this.index === index ? '#EE5D1A' : $r('sys.color.font_primary'))
          }
          .width('100%')
          .height(48)
          .onClick(() => {
            this.index = index
            this.onSpeedSelected(item)
          })

          Divider()
            .strokeWidth('1px')
            .color($r('sys.color.comp_divider'))
            .margin({ bottom: 16 })
        }
      }, (item: string) => item)
    }
  }

  onSpeedSelected(speed: string) {
    let eventData: emitter.EventData = {
      data: { speed: speed }
    }
    try {
      emitter.emit('SpeedSelected', eventData)
    } catch (e) {
    }
  }
}

@Builder
export function titleBuilder(title: ResourceStr) {
  Row() {
    Text(title)
      .width(256)
      .height(27)
      .fontSize(fp2pxUtil(20))
      .fontWeight(FontWeight.Bold)
      .fontColor($r('sys.color.font_primary'))
      .textAlign(TextAlign.Start)
  }
  .height(56)
  .width(328)
}