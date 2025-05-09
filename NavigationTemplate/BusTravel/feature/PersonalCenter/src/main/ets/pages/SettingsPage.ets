import { abilityAccessCtrl, common, PermissionRequestResult, Permissions, Want } from '@kit.AbilityKit'
import { BusinessError } from '@kit.BasicServicesKit';
import { fileIo, storageStatistics } from '@kit.CoreFileKit';
import { RouteEntryVM } from 'common';
import { bundleManager } from '@kit.AbilityKit';

@Builder
export function SettingsPageBuilder() {
  SettingsPage()
}
const TAG: string = '[PublishOperation]';
const DOMAIN_NUMBER: number = 0xFF00;
@Component
export struct SettingsPage {
  @State notifyToggle: boolean = false;
  @State appCache: number = 100.3
  @State isShow: Boolean = false;
  @StorageLink('isLogin') isLogin: boolean = AppStorage.get('isLogin') ?? false;
  @State localToggle: boolean = false;
  private context = getContext(this) as common.UIAbilityContext;
  localPermissions: Array<Permissions> = ['ohos.permission.LOCATION', 'ohos.permission.APPROXIMATELY_LOCATION'];
  vm: RouteEntryVM = RouteEntryVM.instance;
  async aboutToAppear(): Promise<void>{
    this.localToggle = await this.checkPermissions(this.localPermissions)
    this.getCache()
  }

  // 请求权限
  async reqPermissionsFromUser(permissions: Array<Permissions>): Promise<boolean> {
    let context: Context = getContext(this) as common.UIAbilityContext;
    let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
    // requestPermissionsFromUser会判断权限的授权状态来决定是否唤起弹窗
    let data: PermissionRequestResult = await atManager.requestPermissionsFromUser(context, permissions)

    let grantStatus: Array<number> = data.authResults;
    let length: number = grantStatus.length;
    for (let i = 0; i < length; i++) {
      if (grantStatus[i] === 0) {
        // 用户授权，可以继续访问目标操作
        console.log('授权成功')
      } else {
        // 用户拒绝授权，提示用户必须授权才能访问当前页面的功能，并引导用户到系统设置中打开相应的权限
        let secondData: Array<abilityAccessCtrl.GrantStatus> =
          await atManager.requestPermissionOnSetting(context, permissions)
        for (let i = 0; i < secondData.length; i++) {
          if (secondData[i] === abilityAccessCtrl.GrantStatus.PERMISSION_DENIED) {
            return false;
          }
        }
        return true;
      }
    }
    return true
  }

  // 校验应用是否被授予定位权限，可以通过调用checkAccessToken()方法来校验当前是否已经授权。
  async checkPermissions(permissions: Array<Permissions>): Promise<boolean> {
    for (let permission of permissions) {
      let grantStatus: abilityAccessCtrl.GrantStatus = await this.checkAccessToken(permission);
      if (grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_DENIED) {
        return false;
      }
    }
    return true;
  }

  async checkAccessToken(permission: Permissions): Promise<abilityAccessCtrl.GrantStatus> {
    let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
    let grantStatus: abilityAccessCtrl.GrantStatus = abilityAccessCtrl.GrantStatus.PERMISSION_DENIED;

    // 获取应用程序的accessTokenID
    let tokenId: number = 0;
    let bundleInfo: bundleManager.BundleInfo =
      await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
    console.info('Succeeded in getting Bundle.');
    let appInfo: bundleManager.ApplicationInfo = bundleInfo.appInfo;
    tokenId = appInfo.accessTokenId;

    // 校验应用是否被授予权限
    grantStatus = await atManager.checkAccessToken(tokenId, permission);
    console.info('Succeeded in checking access token.');
    return grantStatus;
  }

  byteToM(num: number) {
    const mb = num / 1048576
    return Math.round(mb * 100) / 100
  }

  // 获取应用数据空间大小
  getCache() {
    storageStatistics.getCurrentBundleStats((error: BusinessError, bundleStats: storageStatistics.BundleStats) => {
      if (error) {
        console.error('getCurrentBundleStats failed with error:' + JSON.stringify(error));
      } else {
        console.info('getCurrentBundleStats successfully:' + JSON.stringify(bundleStats));
        console.info('appsize :' + bundleStats.appSize);
        console.info('cacheSize :' + bundleStats.cacheSize);
        console.info('dataSize :' + bundleStats.dataSize);
        this.appCache = this.byteToM(bundleStats.cacheSize)
      }
    });
  }

  // 清理缓存
  clearCache() {
    let cacheDir = getContext(this).cacheDir;
    console.info(cacheDir);

    fileIo.listFile(cacheDir).then((filenames) => {
      for (let i = 0; i < filenames.length; i++) {
        let dirPath = cacheDir + '/' + filenames[i];
        console.log(dirPath);
        // 判断是否为文件夹
        let isDirectory: boolean = false;
        try {
          isDirectory = fileIo.statSync(dirPath).isDirectory();
        } catch (e) {
          console.error('==========aaaa' + JSON.stringify(e));
        }

        if (isDirectory) {
          fileIo.rmdirSync(dirPath);
        } else {
          fileIo.unlink(dirPath).then(() => {
            console.info('remove file succeed');
          }).catch((err: Error) => {
            console.error('remove file failed with error message: ' + err.message);
          });
        }
      }
    })
  }

  build() {
    NavDestination(){
      Column(){
        Column(){
          this.buildPersonalInfo()
          this.buildLocation()
          this.buildClearCache()
        }

        if (this.isLogin) {
          Button('退出登录')
            .width('90%')
            .height('40vp')
            .backgroundColor('#E5E5EA')
            .fontColor($r('sys.color.font_primary'))
            .fontSize($r('sys.float.Body_L'))
            .margin({ bottom: '40vp' })
            .onClick(() => {
              AppStorage.setOrCreate('isLogin', false)
              AppStorage.setOrCreate('userInfo', '')
              this.vm.pop()
            });
        }

      }
      .height('100%')
      .width('100%')
      .backgroundColor('#F1F3F5')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .title('设置')
  }

  @Builder
  buildPersonalInfo(){
    Row() {
      Text('个人信息')
      Image($r('app.media.icon_right'))
        .height(24)
        .width(24)
    }
    .width('90%')
    .padding({ left: 16, right: 16, top: 20, bottom: 20 })
    .backgroundColor($r('sys.color.white'))
    .borderRadius($r('sys.float.corner_radius_level8'))
    .justifyContent(FlexAlign.SpaceBetween)
    .margin({top:12,bottom:12})
    .onClick(()=>{
      if (this.isLogin === false) {
        this.vm.toRouteDetail('Login')
      }else{
        this.vm.toRouteDetail('PersonalSetting')
      }

    })
  }

  @Builder
  buildLocation() {
      Row() {
        Text('地理位置')
          .fontColor($r('sys.color.black'))
          .fontSize(16)
          .fontWeight(400)

        Toggle({ type: ToggleType.Switch, isOn: $$this.localToggle })
          .selectedColor(($r('app.color.system_color_green')))
          .margin({ right: '12lpx' })
          .onClick(async () => {
            if (!this.localToggle) {
              let res = await this.reqPermissionsFromUser(this.localPermissions)
              this.localToggle = res
            } else {
              let want: Want = {
                bundleName: 'com.huawei.hmos.settings',
                abilityName: 'com.huawei.hmos.settings.MainAbility',
                uri: 'application_info_entry',
                parameters: {
                  pushParams: this.context.abilityInfo.bundleName // 应用包名
                }
              };
              await this.context.startAbility(want)
              this.localToggle = await this.checkPermissions(this.localPermissions)
            }
          })
      }
      .width('90%')
      .padding({ left: 16, right: 12, top: 20, bottom: 20 })
      .justifyContent(FlexAlign.SpaceBetween)
      .backgroundColor($r('app.color.background_color_white'))
      .borderRadius($r('sys.float.corner_radius_level8'))
      .margin({ bottom: 12 })
  }

  @Builder
  buildClearCache() {
    Row() {
      Text('清除缓存')
        .fontColor(Color.Black)
        .fontSize(16)
        .height('24lpx')

      Row() {
        Text() {
          Span(this.appCache.toString())
          Span('M')
        }
        .fontSize(16)
        .fontWeight(400)
        .fontColor($r('sys.color.mask_secondary'))
        .margin({ right: 10 })

        Image($r('app.media.icon_right'))
          .height(24)
          .width(24)
          .margin({left:4})
      }
    }
    .width('90%')
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor($r('app.color.background_color_white'))
    .borderRadius($r('sys.float.corner_radius_level8'))
    .padding({ left: 16, right: 16, top: 20, bottom: 20 })
    .onClick(() => {
      this.isShow = true
    })
    .bindSheet($$this.isShow, this.myBuilder(), {
      height: '236lpx',
      blurStyle: BlurStyle.Thick,
      showClose: false,
      preferType: SheetType.CENTER,
    })
  }

  @Builder
  myBuilder() {
    Column() {
      Text('您确认要清除缓存吗？')
        .fontSize(16)
        .fontWeight(500)
        .margin({ top: '56lpx' })
      Text('点击确定将清除软件使用过程中产生的临时数据，不包含软件运行的必要数据，您可以放心清理释放更大空间。')
        .fontSize(12)
        .fontColor('#757575')
        .height('40lpx')
        .width('312lpx')
      Row() {
        Button('取消')
          .height('32lpx')
          .width('156lpx')
          .fontColor($r('sys.color.font_tertiary'))
          .backgroundColor('#F3F3F3')
          .margin({ left: '12lpx', right: '24lpx' })
          .onClick(() => {
            this.isShow = false;
          })
        Button('确认')
          .height('32lpx')
          .width('156lpx')
          .backgroundColor($r('app.color.system_color_green'))
          .onClick(() => {
            this.isShow = false;
            this.appCache = 0;
            this.clearCache()
            this.getCache()
          })
      }
      .margin({ top: '32lpx' })
    }
  }

}