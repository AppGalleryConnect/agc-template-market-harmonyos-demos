import { FormatUtil, RouterModule, RouterMap, PreferencesUtil, Logger } from 'commonlib';
import { QuitLoginDialog } from '../viewModels/QuitLoginDialog';
import { MainPageVM, UserInfoStorage } from '../viewModels/MainPageVM';
import {NavHeaderBar} from '../components/NavHeaderBar'
import { FunctionalButton, functionalButtonComponentManager } from '@kit.ScenarioFusionKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import fs from '@ohos.file.fs';
import { util } from '@kit.ArkTS';
import { BusinessError } from '@kit.BasicServicesKit';
import { authentication } from '@kit.AccountKit';
import { PersistenceV2, promptAction } from '@kit.ArkUI';
import { GetUserInfoResp, HttpRequestApi } from 'network';
import { maskPhone } from '../utils/Util';
import { GlobalDialog } from '../components/GlobalDialog';

@Builder
export function minePageBuilder() {
  MinePage()
}

@ComponentV2
struct MinePage {
  vm: MainPageVM = MainPageVM.instance;
  dialog: CustomDialogController = new CustomDialogController({
    builder: QuitLoginDialog({
      cancel: () => {
        this.onCancel()
      },
      confirm: () => {
        this.onConfirm()
      },
    }),
    cancel: this.onCancel,
    autoCancel: true,
    gridCount: 4,
    customStyle: false,
    alignment: DialogAlignment.Bottom
  })
  onCancel() {
    this.dialog?.close()
  }

  onConfirm() {
    AppStorage.set<string>('userAccount', '');
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column() {
        NavHeaderBar({
        })
        Scroll() {
          Column() {
            UserMsgCard().margin({ top: 10 })
            HelpCenter()
          }
        }.layoutWeight(1).scrollBar(BarState.Off).align(Alignment.Top);

      }
      .alignItems(HorizontalAlign.Start)
      .width('100%')
      .padding({
        left: 12,
        right: 12,
      })
    }
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.background_secondary'))
  }


}

@ComponentV2
struct UserMsgCard {
  vm: MainPageVM = MainPageVM.instance;
  @Local loading: boolean = false;
  @Local authCode: string = ''
  @Local userName: string = ''
  @Local userIconPath: string = ''
  @Local userTel: string = ''
  @Local isRelative: boolean = false
  @Local userInfoStorage: UserInfoStorage = PersistenceV2.connect(UserInfoStorage, 'UserInfoStorage', () => new UserInfoStorage())!

  aboutToAppear(): void {
    this.change()
  }

  change() {
    if (this.userInfoStorage.phoneNumber) {
      let phone = this.userInfoStorage.phoneNumber
      this.userInfoStorage.phoneNumber = maskPhone(phone)
    }
    this.isRelative = !!this.userInfoStorage.phoneNumber
  }

  getUserAvatar(): ResourceStr {
    if (this.userInfoStorage.avatar) {
      // 判断是否是沙箱路径
      if (this.userInfoStorage.avatar.startsWith('file://')) {
        let sandboxPath = this.userInfoStorage.avatar.split('file://')[1]
        // 判断沙箱路径的图片是否存在，不存在，则使用默认头像
        if (!fs.accessSync(sandboxPath)) {
          return $r('app.media.ic_default_hd')
        }
      }
      return this.userInfoStorage.avatar || $r('app.media.ic_default_hd')
    }
    return $r('app.media.ic_default_hd')
  }

  build() {
    Row() {
      Row() {
        if (this.isRelative) {
          FunctionalButton({
            params: {
              // OpenType.CHOOSE_AVATAR表示Button为选择头像类型
              openType: functionalButtonComponentManager.OpenType.CHOOSE_AVATAR,
              label: '',
              // 调整Button样式
              styleOption: {
                styleConfig: new functionalButtonComponentManager.ButtonConfig()
                  .type(ButtonType.Normal)
                  .backgroundImage(this.getUserAvatar())
                  .backgroundImageSize(ImageSize.Cover)
                  .width(64)
                  .height(64)
                  .borderRadius(50)
                  .backgroundColor('#E5E5E5'),
              },
            },
            // OpenType为“CHOOSE_AVATAR”时，回调必须选择“onChooseAvatar”
            controller: new functionalButtonComponentManager.FunctionalButtonController().onChooseAvatar((err,
              data) => {
              if (err) {
                // 错误日志处理
                hilog.error(0x0000, 'testTag', 'error： %{public}d %{public}s', err.code, err.message);
                return;
              }
              // 成功日志处理
              hilog.info(0x0000, 'testTag', 'succeeded in choosing avatar');
              let file: fs.File = null!;
              try {
                file = fs.openSync(data.avatarUri, fs.OpenMode.READ_ONLY)
                this.userIconPath = `${util.generateRandomUUID(false)}.jpg`
                let imagePath = `${getContext().filesDir}/${this.userIconPath}`
                fs.copyFileSync(file.fd, imagePath)
                this.userInfoStorage.avatar = 'file://' + imagePath
              } catch (error) {
                let err: BusinessError = error as BusinessError;
                console.error(`PhotoViewPicker failed with err: ${err.code}, ${err.message}`);
              } finally {
                fs.closeSync(file);
              }
            }),
          })
        } else {
          Image($r('app.media.ic_default_hd'))
            .width(64)
            .height(64)
            .borderRadius(50)
        }

        Column() {
          if (this.isRelative) {
            Text(this.userInfoStorage.userName)
              .fontSize(`${ this.vm.changeFontSize + 18 }`)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_primary'))

            Row() {
              Image($r('app.media.icon_phone')).width(16)
              Text(this.userInfoStorage.phoneNumber)
                .fontSize(`${ this.vm.changeFontSize + 12 }`)
                .fontColor($r('sys.color.font_secondary'))
                .margin({ left: 2 })
            }.margin({ top: 12, left: 1 })
          } else {
            Text('华为用户').fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_secondary'))
          }
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 12 })
        .onClick(() => {
          if (this.isRelative) {
            RouterModule.push({
              url: RouterMap.USER_INFO_SETTING
            })
          }
        })
      }

      Row() {
        Row() {
          Image(this.isRelative ? $r('app.media.ic_relatived') : $r('app.media.connect'))
            .width(12)
            .height(12)
            .margin({ right: 4 })
          Text(this.isRelative ? '解除关联' : '关联账号')
            .fontSize(`${ this.vm.changeFontSize + 12 }`)
            .fontColor(this.isRelative ? $r('sys.color.font_on_primary') : $r('sys.color.comp_background_emphasize'))
        }
        .padding({
          left: 10,
          right: 10,
          top: 6,
          bottom: 6,
        })
        .borderRadius(14)
        .backgroundColor(this.isRelative ? $r('sys.color.comp_background_emphasize') : $r('sys.color.background_secondary'))
        .onClick(() => {
          if (this.isRelative) {
            GlobalDialog.showTextDialog({
              title: '账号解除关联',
              content: '请确认是否解除账号关联？',
              primaryButName: '确定',
              secondaryButName: '取消',
              primaryButAction: () => {
                this.loading = true
                this.cancelRelative()
                GlobalDialog.close()
              },
              secondaryButAction: () => {
                GlobalDialog.close()
              },
            })
          } else {
            this.getQuickLoginAnonymousPhone()
          }
        })
      }
      .height('100%')
      .alignItems(VerticalAlign.Center)

    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .height(112)
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .borderRadius(16)
    .padding({
      left: 16,
      right: 16,
      top: 24,
      bottom: 24,
    })
  }

  getQuickLoginAnonymousPhone() {
    // 创建授权请求，并设置参数
    const authRequest = new authentication.HuaweiIDProvider().createAuthorizationWithHuaweiIDRequest();
    // 获取手机号需要传如下scope，传参数之前需要先申请对应scope权限,才能返回对应数据
    authRequest.scopes = ['phone'];
    // 获取code需传如下permission
    authRequest.permissions = ['serviceauthcode'];
    // 用户是否需要登录授权，该值为true且用户未登录或未授权时，会拉起用户登录或授权页面
    authRequest.forceAuthorization = true;
    // 用于防跨站点请求伪造
    authRequest.state = util.generateRandomUUID();
    try {
      const controller = new authentication.AuthenticationController(getContext(this));
      controller.executeRequest(authRequest).then((data) => {
        const authorizationWithHuaweiIDResponse = data as authentication.AuthorizationWithHuaweiIDResponse;
        const state = authorizationWithHuaweiIDResponse.state;
        if (state !== undefined && authRequest.state !== state) {
          hilog.error(0x0000, 'testTag', `Failed to authorize. The state is different, response state: ${state}`);
          return;
        }
        hilog.info(0x0000, 'testTag', 'Succeeded in authentication.');
        const authorizationWithHuaweiIDCredential = authorizationWithHuaweiIDResponse.data!;
        const code = authorizationWithHuaweiIDCredential.authorizationCode;
        this.authCode = code ?? '';
        // 开发者处理code
        if (code) {
          HttpRequestApi.getOpenLoginHm(encodeURIComponent(code)).then((res) => {
            if (res.status === 1) {
              let tel = res.userTel  as string ?? ''
              this.userInfoStorage.phoneNumber = maskPhone(tel)
              this.userInfoStorage.userName = this.userInfoStorage.userName || res.name
              this.isRelative = true
            } else {
              promptAction.showToast({ message: '账号关联失败，请重试~' })
            }
          }).catch(() => {
            promptAction.showToast({ message: '账号关联失败' })
          })
        } else {
          promptAction.showToast({ message: '账号关联失败' })
        }
      }).catch((err: BusinessError<Object>) => {
        this.dealAllError(err);
      });
    } catch (error) {
      this.dealAllError(error);
    }

  }

  cancelRelative() {
    // 创建取消授权请求，并设置参数
    const cancelRequest = new authentication.HuaweiIDProvider().createCancelAuthorizationRequest();
    cancelRequest.state = util.generateRandomUUID(); // 建议使用generateRandomUUID生成state

    // 执行取消授权请求，并处理结果
    try {
      const controller = new authentication.AuthenticationController(getContext(this));
      controller.executeRequest(cancelRequest, (error: BusinessError<Object>, data) => {
        if (error) {
          this.dealAllError(error);
          return;
        }
        const cancelAuthorizationResponse = data as authentication.CancelAuthorizationResponse;
        const state = cancelAuthorizationResponse.state;
        if (state && cancelRequest.state !== state) {
          hilog.error(0x0000, 'testTag', `Failed to cancel. The state is different, response state: ${state}`);
          return;
        }
        hilog.info(0x0000, 'testTag', 'Succeeded in canceling.');
        HttpRequestApi.getCloseLoginHm()
          .then((resp: GetUserInfoResp) => {
            this.isRelative = false
            this.userInfoStorage.phoneNumber = ''
            if (resp) {
              console.info(`getCancelLoginUtil resp:${JSON.stringify(resp)}.`);

            } else {
              console.error(`getCancelLoginUtil error: ${JSON.stringify(resp)}.`);

            }
          })
          .catch((e: BusinessError) => {
            console.error(`getCancelLoginUtil error: ${JSON.stringify(e)}.`);

          })
      });
    } catch (error) {
      this.dealAllError(error);
    }
  }

  // 错误处理
  dealAllError(error: BusinessError<Object>): void {
    hilog.error(0x0000, 'testTag',
      `Failed to login, errorCode is ${error.code}, errorMessage is ${error.message}`);
    promptAction.showToast({ message: '账号关联失败' })
  }
}

@ComponentV2
struct HelpCenter {
  vm: MainPageVM = MainPageVM.instance;
  @Local callTelSheet: boolean = false

  aboutToAppear(): void {
    PreferencesUtil.getChangeFontSize().then((value:number) => {
      this.vm.changeFontSize = value;
      Logger.info('setfontsize', 'Get the value of changeFontSize: ' + this.vm.changeFontSize);
    });
  }

  build() {
    Column() {
      Column() {
        Row() {
          Row() {
            Text('常用服务')
              .fontSize(`${ this.vm.changeFontSize + 18 }`)
              .fontColor($r('sys.color.font_primary'))
              .fontWeight(FontWeight.Bold)
          }
        }
        .width('100%')
        .padding({top:18,bottom:18})

        Row() {
          Row() {
            Image($r('app.media.my_collect')).width(24).height(24)
            Text('我的收藏')
              .fontSize(`${ this.vm.changeFontSize + 16 }`)
              .fontColor($r('sys.color.font_primary'))
              .margin({ left: 12 })
          }

          Image($r('app.media.right_arrow')).width(16).height(16)
        }
        .width('100%')
        .padding({top:18,bottom:18})
        .justifyContent(FlexAlign.SpaceBetween)
        .onClick(() => {
          RouterModule.push({ url: RouterMap.HISTORY_RECORD, param: '我的收藏' });
        })
        Divider().margin({ left: 28, top: 6, bottom: 6 })
        Row() {
          Row() {
            Image($r('app.media.my_comment')).width(24).height(24)
            Text('我的评论')
              .fontSize(`${ this.vm.changeFontSize + 16 }`)
              .fontColor($r('sys.color.font_primary'))
              .margin({ left: 12 })
          }

          Image($r('app.media.right_arrow')).width(16).height(16)
        }
        .width('100%')
        .height(56)
        .justifyContent(FlexAlign.SpaceBetween)
        .onClick(() => {
          //跳转到评论
          RouterModule.push({ url: RouterMap.MY_COMMENT, param: null });
        })

        Divider().margin({ left: 28, top: 6, bottom: 6 })
        Row() {
          Row() {
            Image($r('app.media.my_record')).width(22).height(26)
            Text('浏览记录')
              .fontSize(`${ this.vm.changeFontSize + 16 }`)
              .fontColor($r('sys.color.font_primary'))
              .margin({ left: 12 })
          }
          Image($r('app.media.right_arrow')).width(16).height(16)
        }
        .width('100%')
        .height(56)
        .justifyContent(FlexAlign.SpaceBetween)
        .onClick(() => {
          RouterModule.push({ url: RouterMap.HISTORY_RECORD, param: '浏览记录' });
        })

        Divider().margin({ left: 28, top: 6, bottom: 6 })
        Row() {
          Row() {
            Image($r('app.media.my_setting')).width(24).height(24)
            Text('设置')
              .fontSize(`${ this.vm.changeFontSize + 16 }`)
              .fontColor($r('sys.color.font_primary'))
              .margin({ left: 12 })
          }

          Image($r('app.media.right_arrow')).width(16).height(16)
        }
        .width('100%')
        .height(56)
        .justifyContent(FlexAlign.SpaceBetween)
        .onClick(() => {
          RouterModule.push({ url: RouterMap.MY_SETTINGS, param: null });
        })
      }
      .padding(12)
      .margin({ top: 12 })
      .width('100%')
      .backgroundColor($r('sys.color.comp_background_list_card'))
      .borderRadius(16)
    }.margin({ top: 16 }).alignItems(HorizontalAlign.Start)
  }
}