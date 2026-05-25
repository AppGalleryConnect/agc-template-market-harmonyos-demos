import { BusinessError, emitter } from '@kit.BasicServicesKit';
import { fileIo, storageStatistics } from '@kit.CoreFileKit';
import { Logger } from '@hw-agconnect/ui-base';
import {
  BreakpointStorage,
  BreakpointSystem,
  BreakpointTypeEnum,
  Constants,
  FontModel,
  MinorsMode,
  MinorsProtectionUtils,
  NavHeaderBar,
  TCRouter
} from 'common';
import { UserInfo, fp2pxUtil } from 'base_common';
import { AppStorageV2 } from '@kit.ArkUI';

@ComponentV2
export struct SettingPage {
  @Local windowTopHeight: number = AppStorage.get('windowTopHeight') as number || 38.77;
  @Local userInfo: UserInfo | undefined = undefined;
  @Local appCache: number = 10.33;
  @Local curBreakpoint: BreakpointStorage = BreakpointSystem.currentBreakpoint
  @Local minorsMode: MinorsMode =
    AppStorageV2.connect(MinorsMode, 'isMinorsMode', () => new MinorsMode(MinorsProtectionUtils.getMinorsMode()))!
  @Local fontModel: FontModel = AppStorageV2.connect(FontModel, () => new FontModel())!;
  bottomRectHeight: number = AppStorage.get('bottomRectHeight') as number || 38.77

  async aboutToAppear(): Promise<void> {
    this.userInfo = AppStorage.get('userInfo') as UserInfo;
    this.getCache();
    try {
      emitter.on(Constants.LOGIN_CHANGE, () => {
        this.userInfo = AppStorage.get('userInfo') as UserInfo;
      })
    } catch (e) {
      console.error('Failed to emitter on login change. Cause: ' + JSON.stringify(e));
    }
  }

  async onPageShow(): Promise<void> {
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Bottom }) {
        Column() {
          NavHeaderBar({
            title: '设置',
            hasBackButton: true,
            hasBgColor: true,
            isMainPage: false,
          })
          Scroll() {
            Column({ space: 12 }) {
              Column() {
                this.settingOptionView('个人信息', Constants.ACCOUNT_ROUTE);
                this.settingOptionView('隐私设置', Constants.PRIVACY_ROUTE)
              }
              .width(Constants.FULL_WIDTH)
              .borderRadius(20)
              .backgroundColor($r('sys.color.comp_background_list_card'))

              Column() {
                this.settingOptionView('阅读设置', Constants.READ_SETTING_ROUTE)
                // 自动下载
                Row() {
                  Text('清理缓存')
                    .fontSize(this.fontModel.getFg(16))
                    .height(21)
                    .width(100)
                  Row({ space: 6.6 }) {
                    Text(this.appCache + 'M')
                      .fontSize(this.fontModel.getFg(16))
                      .fontWeight(400)
                      .fontColor($r('sys.color.font_secondary'))
                    Image($r('app.media.ic_arrow_right'))
                      .width(8)
                      .height(14)
                      .objectFit(ImageFit.Contain)
                  }

                }
                .width(Constants.FULL_SIZE)
                .height(61)
                .borderRadius(16)
                .justifyContent(FlexAlign.SpaceBetween)
                .padding({
                  left: 18,
                  top: 20,
                  bottom: 20,
                  right: 18
                })
                .onClick(() => {
                  this.getUIContext().showAlertDialog(
                    {
                      title: '温馨提示',
                      message: '您确定清除所有缓存？离线内容及图片均会被清除。',
                      autoCancel: true,
                      buttons: [
                        {
                          value: '取消',
                          action: () => {
                            console.info('Button-clicking callback');
                          }
                        },
                        {
                          value: '确定',
                          action: () => {
                            this.clearCache()
                            this.getCache()
                          }
                        }]
                    }
                  );
                })
              }
              .width(Constants.FULL_WIDTH)
              .borderRadius(20)
              .backgroundColor($r('sys.color.comp_background_list_card'))

              // 显示模式 字体大小

              Column() {
                this.settingOptionView('字体大小', Constants.FONT_ROUTE)
              }
              .borderRadius(16)
              .backgroundColor($r('sys.color.comp_background_list_card'))

              Row() {
                Column() {
                  Text('青少年模式')
                    .fontWeight(500)
                    .fontSize(this.fontModel.getFg(16))
                  Text('帮助青少年合理使用应用，引导孩子浏览合适内容')
                    .fontSize(fp2pxUtil(14))
                    .fontColor($r('sys.color.font_secondary'))
                }
                .width(224)
                .height('100%')
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Start)

                Row({ space: 6.6 }) {
                  Text(this.minorsMode.isMinorsMode ? '已开启' : '未开启')
                    .fontSize(this.fontModel.getFg(16))
                    .fontColor($r('sys.color.font_secondary'))

                  Image($r('app.media.ic_arrow_right'))
                    .width(8)
                    .height(14)
                    .objectFit(ImageFit.Contain)
                }

              }
              .width(Constants.FULL_SIZE)
              .height(80)
              .backgroundColor($r('sys.color.comp_background_list_card'))
              .borderRadius(16)
              .justifyContent(FlexAlign.SpaceBetween)
              .padding({
                left: 18,
                right: 18
              })
              .onClick(() => {
                TCRouter.pushByLogin(Constants.MINORS_MODE_ROUTE)
              })

              Column() {
                Text('更多')
                  .fontSize(this.fontModel.getFg(14))
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('sys.color.font_secondary'))
                  .width('100%')
                  .padding({ left: 12, top: 16, bottom: 8 })

                Column(){
                  this.settingOptionView('关于', Constants.ABOUT_ROUTE, $r('app.string.agcit_huawei_book_read'))
                }
                .borderRadius(16)
                .backgroundColor($r('sys.color.comp_background_list_card'))
              }
            }
            .width(this.curBreakpoint.value === BreakpointTypeEnum.LG ? '70%' : Constants.FULL_SIZE)
            .padding({
              left: 12,
              right: 12,
              top: 20,
              bottom: this.bottomRectHeight + (this.userInfo?.isLogin? 60 :0)
            })
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
          .align(Alignment.Top)
        }
        .width(Constants.FULL_SIZE)

        if (this.userInfo?.isLogin) {
          this.loginOut()
        }
      }
      .width(Constants.FULL_SIZE)
      .height(Constants.FULL_SIZE)
      .backgroundColor($r('sys.color.background_secondary'))
    }
    .hideTitleBar(true)
  }

  @Builder
  settingOptionView(text: string, url: string, extraText?: ResourceStr) {
    Row() {
      Text(text)
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium)
        .fontSize(this.fontModel.getFg(16))
        .height(21)
        .width(100)

      Row({ space: 6.6 }) {
        if (extraText) {
          Text(extraText)
            .fontSize(this.fontModel.getFg(16))
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.font_secondary'))
        }
        Image($r('app.media.ic_arrow_right'))
          .width(8)
          .height(14)
          .objectFit(ImageFit.Contain)
      }

    }
    .width(Constants.FULL_SIZE)
    .height(61)
    .borderRadius(16)
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({
      left: 18,
      top: 20,
      bottom: 20,
      right: 18
    })
    .onClick(() => {
      if (url === Constants.ACCOUNT_ROUTE || url === Constants.READ_SETTING_ROUTE) {
        TCRouter.pushByLogin(url)
      } else {
        TCRouter.push(url);
      }
    })
  }

  @Builder
  loginOut() {
    if (this.userInfo?.isLogin) {
      Button('退出登录')
        .width(312)
        .height(40)
        .borderRadius(20)
        .padding({
          top: 9,
          right: 16,
          bottom: 9,
          left: 16
        })
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .fontColor($r('sys.color.font_primary'))
        .fontSize(this.fontModel.getFg(16))
        .align(Alignment.Bottom)
        .margin({ bottom: 10 + this.bottomRectHeight })
        .onClick(() => {
          const promptAction = this.getUIContext().getPromptAction();
          if (!this.userInfo?.isLogin) {
            promptAction.showToast({ message: $r('app.string.no_login_out') })
          } else {
            promptAction.showDialog({
              title: $r('app.string.ask_for_login_out'),
              message: $r('app.string.ask_for_login_out_again'),
              buttons: [
                {
                  text: $r('app.string.cancel'),
                  color: $r('app.color.button_color')
                },
                {
                  text: $r('app.string.agreement_and_login_out'),
                  color: $r('app.color.button_color')
                }
              ]
            }, (err, data) => {
              if (data.index === 1) {
                try {
                  // 保留会员状态和书币信息，只清除登录状态
                  const savedMembershipStatus = this.userInfo?.isMembership || false;
                  const savedBookCoins = typeof this.userInfo?.bookCoins === 'number' ? this.userInfo.bookCoins : 100;

                  // 保存会员状态和书币信息到本地存储
                  AppStorage.setOrCreate('membershipStatus', savedMembershipStatus);
                  AppStorage.setOrCreate('bookCoins', savedBookCoins);

                  // 清除用户信息
                  AppStorage.setOrCreate('userInfo', undefined);
                  emitter.emit(Constants.LOGIN_CHANGE);
                  TCRouter.pop();
                } catch (e) {
                  console.error('Failed to emitter emit login change. Cause: ' + JSON.stringify(e));
                }
              }
            })
          }
        })
    }
  }

  // 获取应用数据空间大小
  getCache() {
    try {
      storageStatistics.getCurrentBundleStats((error: BusinessError, bundleStats: storageStatistics.BundleStats) => {
        if (error) {
          Logger.error('getCurrentBundleStats failed with error:' + JSON.stringify(error));
        } else {
          Logger.info('getCurrentBundleStats successfully:' + JSON.stringify(bundleStats));
          Logger.info('appsize :' + bundleStats.appSize);
          Logger.info('cacheSize :' + bundleStats.cacheSize);
          Logger.info('dataSize :' + bundleStats.dataSize);
          this.appCache = this.byteToM(bundleStats.cacheSize)
        }
      });
    } catch (e) {
      console.error('Failed to getCache. Cause: ' + JSON.stringify(e));
    }

  }

  // 清理缓存
  clearCache() {
    let cacheDir = (this.getUIContext().getHostContext() as Context).cacheDir;
    Logger.info(cacheDir);
    fileIo.listFile(cacheDir).then((filenames) => {
      for (let i = 0; i < filenames.length; i++) {
        let dirPath = cacheDir + '/' + filenames[i];
        Logger.info(dirPath);
        // 判断是否为文件夹
        let isDirectory: boolean = false;
        try {
          isDirectory = fileIo.statSync(dirPath).isDirectory();
        } catch (e) {
          Logger.error(JSON.stringify(e));
        }

        if (isDirectory) {
          fileIo.rmdirSync(dirPath);
        } else {
          fileIo.unlink(dirPath).then(() => {
            Logger.info('remove file succeed');
          }).catch((err: Error) => {
            Logger.error('remove file failed with error message: ' + err.message);
          });
        }
      }
    })
    this.getUIContext().getPromptAction().showToast({ message: '缓存清理完成！' })
  }

  byteToM(num: number) {
    const mb = num / 1048576
    return Math.round(mb * 100) / 100
  }
}
