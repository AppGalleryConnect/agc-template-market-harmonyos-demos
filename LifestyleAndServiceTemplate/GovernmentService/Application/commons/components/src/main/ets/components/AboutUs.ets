import { bundleManager } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';

@ComponentV2
export struct AboutUs {
  @Local versionNo: number | null = null
  @Consumer('pageInfos') pageInfos: NavPathStack = new NavPathStack();

  getAppBundleInfo() {
    bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION).then((bundleInfo) => {
      this.versionNo = bundleInfo.versionCode; //应用版本号
    }).catch((error: BusinessError) => {
      console.error('get bundleInfo failed,error is ' + error)
    })
  }

  aboutToAppear(): void {
    this.getAppBundleInfo()
  }

  build() {
    NavDestination() {
      Column() {
        Column({ space: 20 }) {
          Column() {
            Image($r('app.media.ic_start_icon')).width(96).height(96)
            Text($r('app.string.medical_security_title'))
              .fontSize($r('sys.float.Body_L'))
              .fontWeight(FontWeight.Regular)
              .fontColor($r('sys.color.font_primary'))
              .margin({ top: 24 })
          }

          Column() {
            Text(`版本号：${String(this.versionNo)}`)
          }
        }.margin({ bottom: Number(AppStorage.get('topRectHeight')) })
      }
      .height('100%')
      .justifyContent(FlexAlign.Center)
    }
    .title('关于我们')
    .padding({ top: Number(AppStorage.get('topRectHeight')) })
    .backgroundColor($r('sys.color.background_secondary'))
  }
}