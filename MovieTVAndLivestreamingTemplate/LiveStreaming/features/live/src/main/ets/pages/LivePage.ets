import { abilityAccessCtrl, bundleManager, common, Permissions } from '@kit.AbilityKit';
import { camera } from '@kit.CameraKit';
import { AccountUtil, BarVM } from '@agctemplate/widgets'
import { RouterMap, RouterModule } from '@agctemplate/router_module';
import { LiveMsgModel } from '../models/LiveModel'
import { BigCard } from '../component/LiveCards'
import { display, LengthUnit } from '@kit.ArkUI';
import { geoLocationManager } from '@kit.LocationKit';
import { deviceInfo } from '@kit.BasicServicesKit';
import { wifiManager } from '@kit.ConnectivityKit';
import { UserInfo } from 'live_interaction'

const permissions: Array<Permissions> = ['ohos.permission.APPROXIMATELY_LOCATION'];

@ComponentV2
export struct LivePage {
  @Local userInfo: UserInfo = AccountUtil.getUserInfo()
  @Local isShow1: boolean = false
  @Local isShow2: boolean = false
  @Local liveStreamer: LiveMsgModel = LiveMsgModel.instance
  @Consumer('isLive') isLive: boolean = false;
  @Local liveFlag: boolean = false
  @Local isSpeak: boolean = true
  @Local isSpeak1: boolean = true
  @Local isSpeak2: boolean = false
  @Local isSpeak3: boolean = false
  @Provider('isLocated') isLocated: boolean = !!this.liveStreamer.location
  @Event startRecord: Function = () => {}
  @Local isExpanded: boolean = display.getFoldStatus() === display.FoldStatus.FOLD_STATUS_EXPANDED
  @Local isLandScapeTablet: boolean = display.getDefaultDisplaySync().orientation === display.Orientation.LANDSCAPE ||
    display.getDefaultDisplaySync().orientation === display.Orientation.LANDSCAPE_INVERTED &&
      deviceInfo.deviceType === 'tablet'
  @Consumer('mCameraPosition') mCameraPosition: camera.CameraPosition = camera.CameraPosition.CAMERA_POSITION_BACK;
  context: common.UIAbilityContext =
    this.getUIContext().getHostContext() as common.UIAbilityContext;
  atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
  callback: Callback<number> = (data: number) => {
    if (display.getDefaultDisplaySync().orientation === display.Orientation.LANDSCAPE ||
      display.getDefaultDisplaySync().orientation === display.Orientation.LANDSCAPE_INVERTED &&
        deviceInfo.deviceType === 'tablet') {
      this.isLandScapeTablet = true
    } else {
      this.isLandScapeTablet = false
    }
  }
  callback2: Callback<display.FoldStatus> = (data: display.FoldStatus) => {
    if (data === display.FoldStatus.FOLD_STATUS_EXPANDED) {
      this.isExpanded = true
    } else {
      this.isExpanded = false
    }
  }

  aboutToAppear(): void {
    try {
      display.on('change', this.callback)
      display.on('foldStatusChange', this.callback2)
    } catch (e) {
    }
  }

  aboutToDisappear(): void {
    try {
      display.off('change', this.callback)
      display.off('foldStatusChange', this.callback2)
    } catch (e) {
    }
  }

  build() {
    Column({ space: 12 }) {
      Row() {
        Text('我的直播')
          .size({ width: 280, height: 35 })
          .fontSize(26)
          .fontWeight(700)
          .fontColor($r('sys.color.font_primary'))
          .lineHeight(35)
          .margin({ top: 10.5, left: 8, bottom: 10.5 })
        // Image($r('app.media.icon_Setting')).size({ width: 30, height: 30 })
        //   .margin({ right: 16 })
        // .onClick(this.rightOnClick)
        // 预留中心接口
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)

      BigCard({
        getLocation: () => {
          this.getLocation()
        }
      })
        .margin({ top: 8 })
        .width(this.isLandScapeTablet ? '60%' : '90%')

      Blank()

      Row() {
        Column() {
          Button({ type: ButtonType.Circle }) {
            SymbolGlyph($r('sys.symbol.switch_camera'))
              .fontSize(24)
              .fontColor(['#E6FFFFFF'])
          }
          .width(40)
          .height(40)
          .backgroundColor('#19000000')

          Text('翻转')
            .fontColor('rgba(255, 255, 255, 1)')
            .fontWeight(500)
            .fontSize(12)
            .lineHeight(16)
            .margin({ top: 4, bottom: 8 })
        }
        .onClick(() => {
          this.mCameraPosition = this.mCameraPosition === camera.CameraPosition.CAMERA_POSITION_BACK ?
            camera.CameraPosition.CAMERA_POSITION_FRONT : camera.CameraPosition.CAMERA_POSITION_BACK;
        })

        Blank()

        Column() {
          Button({ type: ButtonType.Circle }) {
            SymbolGlyph($r('sys.symbol.gearshape'))
              .fontSize(24)
              .fontColor(['#E6FFFFFF'])
          }
          .width(40)
          .height(40)
          .backgroundColor('#19000000')

          Text('设置')
            .fontColor('rgba(255, 255, 255, 1)')
            .fontWeight(500)
            .fontSize(12)
            .lineHeight(16)
            .margin({ top: 4, bottom: 8 })
        }
        .onClick(() => {
          this.isShow1 = true
        })
        .bindSheet($$this.isShow1, this.setBuilder(), {
          backgroundColor: $r('sys.color.comp_background_tertiary'),
          blurStyle: BlurStyle.COMPONENT_THICK,
          preferType: SheetType.CENTER,
          height: 304,
          detents: [332],
          title: { title: '更多' }
        })
      }
      .width(204)

      Button($r('app.string.start_live'))
        .width(deviceInfo.deviceType === 'tablet' ? 448 : this.isExpanded ? 400 : 328)
        .border({ radius: 20 })
        .fontWeight(500)
        .height(40)
        .backgroundColor('rgba(238, 93, 26, 1)')
        .margin({ bottom: 44, top: 33 })
        .onClick(() => {
          this.reqPermissionsFromUser(permissions, this.context)
          if (!wifiManager.isConnected()) {
            this.getUIContext().getPromptAction().showToast({ message: '请先连接WLAN网络', duration: 2000 })
          } else if (!this.userInfo.isLogin) {
            RouterModule.push({ url: RouterMap.LOGIN_PAGE, param: true })
          } else if (!this.userInfo.realNameAuthFlag) {
            RouterModule.push({ url: RouterMap.Real_Name_Auth_Page })
          } else {
            this.isLive = true
            this.startRecord()
          }
        })
    }
    .alignItems(HorizontalAlign.Center)
    .width('100%')
    .height('100%')
    .padding({ left: 16, right: 16, top: BarVM.instance.staBarH })
  }

  @Builder
  setBuilder() {
    Column() {
      Row() {
        Text('开启定位')
          .fontWeight(500)
          .fontSize(16)
          .lineHeight(21)
        Blank()
        Toggle({ type: ToggleType.Switch, isOn: $$this.isLocated })
          .height(20)
          .width(36)
          .onChange((isOn: boolean) => {
            if (isOn) {
              this.getLocation()
            }
          })
      }
      .width('100%')
      .height(54)


      Row() {
        Text('发言权限')
          .fontWeight(500)
          .fontSize(16)
          .lineHeight(21)
        Blank()
        Column() {
          SymbolGlyph($r('sys.symbol.chevron_right'))
            .fontSize(24)
            .fontColor([$r('sys.color.icon_fourth')])
        }
        .height(48)
        .width(36)
        .justifyContent(FlexAlign.Center)
      }
      .width('100%')
      .height(54)
      .onClick(() => {
        this.isShow2 = true
      })
      .bindSheet($$this.isShow2, this.speakPermission(), {
        backgroundColor: $r('sys.color.comp_background_tertiary'),
        blurStyle: BlurStyle.COMPONENT_THICK,
        preferType: SheetType.CENTER,
        height: 304,
        detents: [332],
        title: { title: '发言权限' }
      })
    }
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .borderRadius(20)
    .width('90%')
    .padding({ left: 12, right: 12, top: 8 })

  }

  @Builder
  speakPermission() {
    Column() {
      Row() {
        Text('允许发言')
          .fontWeight(500)
          .fontSize(16)
          .lineHeight(21)
        Blank()
        Toggle({ type: ToggleType.Switch, isOn: $$this.isSpeak })
          .height(20)
          .width(36)
      }
      .width('100%')
      .height(54)

      if (this.isSpeak) {
        Row() {
          Text('允许所有观众发言')
            .fontWeight(500)
            .fontSize(16)
            .lineHeight(21)
          Blank()
          Toggle({ type: ToggleType.Checkbox, isOn: $$this.isSpeak1 })
            .onChange((isOn: boolean) => {
              if (isOn) {
                this.isSpeak2 = false
                this.isSpeak3 = false
              } else {
                if (!this.isSpeak2 && !this.isSpeak3) {
                  this.isSpeak1 = true
                }
              }
            })
        }
        .width('100%')
        .height(54)

        Row() {
          Text('仅允许我关注的人')
            .fontWeight(500)
            .fontSize(16)
            .lineHeight(21)
          Blank()
          Toggle({ type: ToggleType.Checkbox, isOn: $$this.isSpeak2 })
            .onChange((isOn: boolean) => {
              if (isOn) {
                this.isSpeak1 = false
                this.isSpeak3 = false
              } else {
                if (!this.isSpeak1 && !this.isSpeak3) {
                  this.isSpeak2 = true
                }
              }
            })
        }
        .width('100%')
        .height(54)

        Row() {
          Text('仅允许我的粉丝')
            .fontWeight(500)
            .fontSize(16)
            .lineHeight(21)
          Blank()
          Toggle({ type: ToggleType.Checkbox, isOn: $$this.isSpeak3 })
            .onChange((isOn: boolean) => {
              if (isOn) {
                this.isSpeak2 = false
                this.isSpeak1 = false
              } else {
                if (!this.isSpeak2 && !this.isSpeak1) {
                  this.isSpeak3 = true
                }
              }
            })
        }
        .width('100%')
        .height(54)
      }
    }
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .borderRadius(20)
    .width('90%')
    .padding({ left: 12, right: 12, top: 8 })
  }

  // 查看是否已获取权限
  async checkPermissionGrant(permission: Permissions): Promise<abilityAccessCtrl.GrantStatus> {
    let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
    let grantStatus: abilityAccessCtrl.GrantStatus = abilityAccessCtrl.GrantStatus.PERMISSION_DENIED;

    // 获取应用程序的accessTokenID。
    let tokenId: number = 0;
    try {
      let bundleInfo: bundleManager.BundleInfo =
        await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
      let appInfo: bundleManager.ApplicationInfo = bundleInfo.appInfo;
      tokenId = appInfo.accessTokenId;
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      console.error(`Failed to get bundle info for self, code: ${err.code}, message: ${err.message}`);
    }

    // 校验应用是否被授予权限。
    try {
      grantStatus = await atManager.checkAccessToken(tokenId, permission);
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      console.error(`Failed to check access token, code: ${err.code}, message: ${err.message}`);
    }
    // -1未授权，0已授权
    return grantStatus;
  }

  //申请获取权限
  reqPermissionsFromUser(permissions: Array<Permissions>,
    context: common.UIAbilityContext) {
    // requestPermissionsFromUser会判断权限的授权状态来决定是否唤起弹窗。
    this.atManager.requestPermissionsFromUser(context, permissions).then((data) => {
      if (!data.dialogShownResults![0] && data.authResults[0]) {
        this.atManager.requestPermissionOnSetting(context, permissions)
          .then((data: Array<abilityAccessCtrl.GrantStatus>) => {
            if (!data[0]) {
              this.getLocation()
            } else {
              this.isLocated = false
            }
            console.info(`requestPermissionOnSetting success, result: ${data}`);
          })
          .catch((err: BusinessError) => {
            console.error(`requestPermissionOnSetting fail, code: ${err.code}, message: ${err.message}`);
          });
      } else if (data.dialogShownResults![0] && !data.authResults[0]) {
        this.getLocation()
      } else if (data.dialogShownResults![0] && data.authResults[0]) {
        this.isLocated = false
      }
    }).catch((e: Error) => {
      console.error(`requestPermissionsFromUser failed: ${e.message}`);
    })
  }

  getLocation() {
    this.checkPermissionGrant(permissions[0]).then((result: abilityAccessCtrl.GrantStatus) => {
      if (result) {
        //未获取权限去获取权限
        this.reqPermissionsFromUser(permissions, this.context)
      } else {
        //已获取权限，去获得具体位置
        try {
          //是否打开位置开关
          let locationEnabled = geoLocationManager.isLocationEnabled();
          if (!locationEnabled) { //拉起设置打开位置开关
            this.atManager.requestGlobalSwitch(this.context, abilityAccessCtrl.SwitchType.LOCATION)
              .then((data: boolean) => {
                if (data) {
                  this.getLocation()
                } else {
                  this.isLocated = false
                }
                console.info(`requestGlobalSwitch success, result: ${data}`);
              }).catch((err: BusinessError) => {
              console.error(`requestGlobalSwitch fail, code: ${err.code}, message: ${err.message}`);
            });
          } else {
            //已有权限并打开位置开关后，获取具体位置
            let location = geoLocationManager.getLastLocation();
            let reverseGeocodeRequest: geoLocationManager.ReverseGeoCodeRequest =
              { 'latitude': location.latitude, 'longitude': location.longitude, 'maxItems': 1 };
            geoLocationManager.getAddressesFromLocation(reverseGeocodeRequest, (err, data) => {
              if (err) {
                console.log('getAddressesFromLocation err: ' + JSON.stringify(err));
              } else {
                //获取定位到某市的信息
                this.liveStreamer.location = data[0].subAdministrativeArea!
                this.isLocated = true
              }
            });
          }

        } catch (err) {
          console.error('errCode:' + err.code + ', message:' + err.message);
          this.isLocated = false
        }

      }
    })

  }
}

