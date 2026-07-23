import { application, common, ConfigurationConstant, contextConstant } from '@kit.AbilityKit';
import { AppStorageV2, display, UIContext, SymbolGlyphModifier, window } from '@kit.ArkUI';
import { fileIo, storageStatistics } from '@kit.CoreFileKit';
import { BusinessError, deviceInfo, emitter } from '@kit.BasicServicesKit';
import { RouterMap, RouterModule } from '@agctemplate/router_module';
import { Header } from '../component/Header';
import { AccountUtil, AppStorageKeys, BarVM, BreakPoint, BreakPointValue, ColorMode } from '@agctemplate/widgets';
import { UserInfoRow } from '../component/UserInfoRow';
import { titleBuilder } from 'live_interaction';
import { GlobalContext, Logger, PreferConstant, PreferenceUtil } from '@agctemplate/utils';
import { AppGalleryUtils } from '../utils/AppGalleryUtils';
import { UserInfo } from 'live_interaction'

@ComponentV2
export struct SetUpPage {
  @Local bottomHeight: number = 0;
  @Local logoUser: UserInfo = AccountUtil.getUserInfo();
  @Local isShowResolutionSheet: boolean = false
  @Local resolution: string = '1080P 原画（高帧率）'
  @Local isBackgroundPlay: boolean = false
  @Local isVersionCheckSheet: boolean = false
  @Local appCache: number = 10.33;
  @Local colorMode: ColorMode = AppStorageV2.connect(ColorMode, 'colorMode', () => new ColorMode('跟随系统'))!
  @Local breakPoint: BreakPoint = AppStorageV2.connect(BreakPoint, AppStorageKeys.CURRENT_BREAK_POINT,
    () => new BreakPoint())!;
  private context = this.getUIContext().getHostContext();
  private preferenceVideoQuality = PreferenceUtil.getInstance(this.context, PreferConstant.VIDEO_QUALITY)
  private preferenceBackgroundPlay = PreferenceUtil.getInstance(this.context, PreferConstant.BACKGROUND_PLAY)

  aboutToAppear(): void {
    try {
      this.getCache()
      window.getLastWindow(this.context, (_err, data) => {
        const avoidAreaBottom = data.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
        this.bottomHeight = avoidAreaBottom.bottomRect.height;
      })
    } catch (e) {
    }
    this.preferenceVideoQuality = PreferenceUtil.getInstance(this.context, PreferConstant.VIDEO_QUALITY)
    this.preferenceBackgroundPlay = PreferenceUtil.getInstance(this.context, PreferConstant.BACKGROUND_PLAY)
    this.resolution = this.preferenceVideoQuality.get('resolution', '1080P 原画（高帧率）') as string
    this.isBackgroundPlay = this.preferenceBackgroundPlay.get('backgroundPlay', true) as boolean
  }

  @Builder
  line() {
    Divider().strokeWidth('1px').width('100%').color($r('sys.color.comp_divider')).padding({ left: 12, right: 12 })
  }

  @Builder
  resolutionSheet(currentResolution: string) {
    Column() {
      Resolution({ currentResolution: currentResolution })
    }
    .width('100%')
    .padding({ left: 16, right: 16 })
    .height(243)
  }

  build() {
    NavDestination() {
      Stack({alignContent:Alignment.Bottom}){
        Column() {
          Header({ title: '设置' })
          Scroll(){
            Column() {
              Column() {
                GenericCard() {
                  UserInfoRow({
                    leftTitle: '个人信息', rightOnClick: () => {
                      RouterModule.push({ url: RouterMap.PERSONAL_CENTER_PAGE })
                    }
                  })
                  this.line()
                  UserInfoRow({
                    leftTitle: '隐私设置', rightOnClick: () => {
                      RouterModule.push({ url: RouterMap.PRIVACY_SETTINGS_PAGE })
                    }
                  })
                }

                GenericCard() {
                  UserInfoRow({
                    leftTitle: '显示模式',
                    rightContent: this.colorMode.modeName,
                    isTriangle: true,
                    rightMenu: () => {
                      this.menuBuilder()
                    }
                  })
                }

                GenericCard() {
                  UserInfoRow({
                    leftTitle: '视频后台播放',
                    isSwitch: true,
                    switchButton: (isOn) => {
                      this.isBackgroundPlay = isOn
                      this.preferenceBackgroundPlay.put('backgroundPlay', this.isBackgroundPlay)
                      let event: emitter.InnerEvent = {
                        eventId: 4,
                      };
                      let eventData: emitter.EventData = {
                        data: {
                          content: 'changeBack',
                          id: 4
                        }
                      };
                      try {
                        emitter.emit(event, eventData);
                      } catch (e) {
                      }
                    }
                  })
                  this.line()
                  UserInfoRow({
                    leftTitle: '视频默认清晰度', rightContent: this.resolution, rightOnClick: () => {
                      this.isShowResolutionSheet = !this.isShowResolutionSheet
                    }
                  })
                    .bindSheet($$this.isShowResolutionSheet, this.resolutionSheet(this.resolution), {
                      height: 363,
                      preferType: SheetType.CENTER,
                      title: titleBuilder('清晰度设置'),
                      backgroundColor: $r('sys.color.comp_background_tertiary'),
                      blurStyle: BlurStyle.COMPONENT_THICK,
                      onWillAppear: () => {
                        try {
                          emitter.on('ResolutionSelected', (event: emitter.EventData) => {
                            this.resolution = event.data!.resolution
                          })
                        } catch (e) {
                        }
                      },
                      onWillDisappear: () => {
                        this.preferenceVideoQuality.put('resolution', this.resolution)
                      }
                    })
                  this.line()
                  UserInfoRow({
                    leftTitle: '清除缓存', rightContent: this.appCache + 'M', rightOnClick: () => {
                      this.showAlert()
                    }
                  })
                }

                GenericCard() {
                  UserInfoRow({
                    leftTitle: '版本检测', rightOnClick: () => {
                      this.checkAppUpdate()
                    }
                  })

                  this.line()
                  UserInfoRow({
                    leftTitle: '关于我们', rightOnClick: () => {
                      RouterModule.push({ url: RouterMap.ABOUT_PAGE })
                    }
                  })
                }
              }
              .height(388)
              .width('100%')

              Row()
                .height(40)

            }
            .justifyContent(FlexAlign.SpaceBetween)
            // .layoutWeight(1)
            .width(this.breakPoint.value === BreakPointValue.LG ? '70%' : '100%')
            .padding({
              left: 16,
              right: 16,
            })
          }
          .align(Alignment.TopStart)
          .edgeEffect(EdgeEffect.Spring)
          .scrollBar(BarState.Off)
          .height(`calc(100% - 80vp - ${BarVM.instance.aiBarH})`)
          .backgroundColor($r('sys.color.comp_background_gray'))
        }
        .width('100%')
        .height('100%')

        Row() {
          Button('退出登录')
            .fontColor($r('sys.color.font_primary'))
            .backgroundColor($r('sys.color.comp_background_tertiary'))
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(500)
            .width('100%')
            .height(40)
            .onClick(() => {
              if (this.logoUser.isLogin) {
                this.logoUser.isLogin = false
                this.getUIContext().getPromptAction().showToast({ message: '退出成功', duration: 2000 });
                RouterModule.pop()
              } else {
                this.getUIContext().getPromptAction().showToast({ message: '您还未登录', duration: 2000 });
              }
              try {
                emitter.emit('MinePageShown')
              } catch (e) {
              }
            })
        }
        .width(this.breakPoint.value === BreakPointValue.LG ? '70%' : '100%')
        .padding({
          left: 16,
          right: 16,
        })
      }
    }
    .backgroundColor($r('sys.color.comp_background_gray'))
    .padding({ top: BarVM.instance.staBarH, bottom: BarVM.instance.aiBarH })
    .hideTitleBar(true)
  }

  // 检查更新
  checkAppUpdate() {
    AppGalleryUtils.checkAppUpdate(this.context as common.UIAbilityContext)
      .then((hasUpdate) => {
        if (hasUpdate) {
          AppGalleryUtils.showUpdateDialog(this.context as common.UIAbilityContext)
        } else {
          // AppGalleryUtils.showUpdateDialog(getContext() as common.UIAbilityContext)
          this.getUIContext().getPromptAction().showToast({
            message: '已是最新版本'
          })
        }
      })
      .catch((error: Error) => {
        console.log('===>', JSON.stringify(error))
      });
  }

  getClearSize() {
    try {
      storageStatistics.getCurrentBundleStats((error: BusinessError, bundleStats: storageStatistics.BundleStats) => {
        if (error) {
          // Logger.error('getCurrentBundleStats failed with error:' + JSON.stringify(error));
        } else {
          // Logger.info('getCurrentBundleStats successfully:' + JSON.stringify(bundleStats));

          // this.setupList.forEach(async (eme) => {
          //   // 模拟缓存cache
          //   if (eme.msg === '清除缓存') {
          //     // let isClean = PreferenceUtil.getInstance().isClean() &&
          //     // PreferenceUtil.getInstance(PreferConstant.TOPIC_NOTES).isClean()
          //     // if (isClean) {
          //     //   eme.cache = 0 + 'KB'
          //     // } else {
          //     //   eme.cache = (bundleStats.dataSize / 1024).toFixed(2) + 'KB'
          //     // }
          //   }
          // })
        }
      });
    } catch (e) {
    }
  }

  showAlert() {
    this.getUIContext().showAlertDialog({
      message: '请确认是否清除缓存',
      autoCancel: false,
      alignment: DialogAlignment.Center,
      showInSubWindow: true,
      isModal: true,
      buttonDirection: DialogButtonDirection.HORIZONTAL,
      buttons: [
        {
          value: '取消',
          action: () => {
          }
        },
        {
          value: '确定',
          action: () => {
            this.clean()
            this.getCache()
          }
        }
      ]
    })
  }

  byteToM(num: number) {
    const mb = num / 1048576
    return Math.round(mb * 100) / 100
  }

  getCache() {
    try {
      storageStatistics.getCurrentBundleStats((error: BusinessError, bundleStats: storageStatistics.BundleStats) => {
        if (error) {

        } else {

          this.appCache = this.byteToM(bundleStats.cacheSize)
        }
      });
    } catch (e) {
      console.error('Failed to getCache. Cause: ' + JSON.stringify(e));
    }
  }

  async clean() {
    try {
      let paths: Array<string> = []
      let moduleContext: common.Context;
      let context = this.getUIContext().getHostContext() as common.UIAbilityContext;
      moduleContext = await application.createModuleContext(this.context, 'entry');
      paths.push(moduleContext.cacheDir)
      paths.push(context.cacheDir)
      moduleContext.area = contextConstant.AreaMode.EL1;
      context.area = contextConstant.AreaMode.EL1;
      paths.push(moduleContext.cacheDir)
      paths.push(context.cacheDir)
      paths.push(moduleContext.preferencesDir)
      PreferenceUtil.getInstance(this.getUIContext().getHostContext()).clear()

      for (let i = 0; i < paths.length; i++) {
        let path = paths[i]
        fileIo.listFile(path).then((filenames) => {
          for (let i = 0; i < filenames.length; i++) {
            let dirPath = path + '/' + filenames[i];
            // 判断是否为文件夹
            let isDirectory: boolean = false;
            try {
              isDirectory = fileIo.statSync(dirPath).isDirectory();
            } catch (e) {
              // Logger.error(JSON.stringify(e));
            }
            if (isDirectory) {
              fileIo.rmdirSync(dirPath);
            } else {
              fileIo.unlink(dirPath).then(() => {
                // Logger.info('remove file succeed');
              }).catch((err: Error) => {
                // Logger.error('remove file failed with error message: ' + err.message);
              });
            }
          }
        })
      }
      this.getClearSize()
      this.getUIContext().getPromptAction().showToast({ message: '缓存清理完成！' })
    } catch (e) {
    }
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
        .onChange((selected: boolean) => {
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
        .onChange((selected: boolean) => {
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
        .onChange((selected: boolean) => {
          GlobalContext.getContext()
            .getApplicationContext()
            .setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT)
          this.colorMode.modeName = '浅色模式'
        })
    }
    .width(224)
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
    .margin({ top: 8 })
    .borderRadius(16)
    .backgroundColor($r('sys.color.comp_background_list_card'))
  }
}

@ComponentV2
struct Resolution {
  @Param currentResolution: string = '1080P 原画（高帧率）'
  resolutionList: string[] = ['1080P 原画（高帧率）', '1080P 蓝光', '720P超清', '480P高清']
  @Local index: number = this.resolutionList.indexOf(this.currentResolution)
  private uiContext: UIContext = this.getUIContext();

  build() {
    Column() {
      ForEach(this.resolutionList, (item: string, index: number) => {
        Column() {
          Row() {
            Text(item)
              .fontSize(16)
              .fontWeight(500)
              .fontColor(this.index === index ? '#EE5D1A' : $r('sys.color.font_primary'))
          }
          .width('100%')
          .height(48)
          .onClick(() => {
            this.index = index
            this.onResolutionSelected(item)
          })

          Divider()
            .strokeWidth('1px')
            .color($r('sys.color.comp_divider'))
            .margin({ bottom: 16 })
        }
      },(item: string, index: number) => { return index + '__' + JSON.stringify(item); })
    }
  }

  onResolutionSelected(resolution: string) {
    try {
      let eventData: emitter.EventData = {
        data: { resolution: resolution }
      }
      emitter.emit('ResolutionSelected', eventData)
    } catch (e) {
    }
  }
}

@Extend(Text)
function textStyle() {
  .fontSize(16)
  .fontWeight(400)
  .lineHeight(21)
  .fontColor($r('sys.color.font_primary'))
}