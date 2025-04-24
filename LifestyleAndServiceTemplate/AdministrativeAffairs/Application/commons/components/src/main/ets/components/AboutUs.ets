import { Constants, DividerTmp } from 'common'
import { bundleManager } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';

@ComponentV2
export struct AboutUsPage {
  @Local versionNo: number | null = null
  @Consumer('pageInfos') pageInfos: NavPathStack = new NavPathStack();
  @Local egDivider: DividerTmp = new DividerTmp(1, 10, 10, '#ffe9f0f0')

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
      Scroll(){
        Column(){
          Column() {
            Column() {
              Image($r('app.media.logo_about_us')).width($r('app.float.about_us_size')).height($r('app.float.about_us_size'))
              Text($r('app.string.medical_security_title'))
                .fontSize($r('sys.float.Body_L'))
                .fontWeight(FontWeight.Regular)
                .fontColor($r('sys.color.font_primary'))
                .margin({ top: $r('app.float.medical_security_title_margin') })
            }

            Column() {
              List() {
                ListItem() {
                  Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
                    Row() {
                      Text($r('app.string.opinions_suggestions'))
                        .fontWeight(FontWeight.Regular)
                        .fontColor($r('sys.color.font_primary'))
                        .fontSize($r('sys.float.Body_M'))
                    }

                    Image($r('app.media.about_more'))
                      .width($r('app.float.about_more_width'))
                      .height($r('app.float.about_more_height'))
                      .syncLoad(false)
                      .objectFit(ImageFit.Fill)
                  }
                  .width(Constants.FULL_PERCENT_WIDTH)
                  .padding({ top: $r('app.float.common_margin_sixty'), bottom: $r('app.float.common_margin_sixty') })
                  .onClick(() => {
                    this.pageInfos.pushPathByName('suggestion', null)
                  })
                }
                ListItem() {
                  Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
                    Row() {
                      Text('反馈记录')
                        .fontWeight(FontWeight.Regular)
                        .fontColor($r('sys.color.font_primary'))
                        .fontSize($r('sys.float.Body_M'))
                    }

                    Image($r('app.media.about_more'))
                      .width($r('app.float.about_more_width'))
                      .height($r('app.float.about_more_height'))
                      .syncLoad(false)
                      .objectFit(ImageFit.Fill)
                  }
                  .width(Constants.FULL_PERCENT_WIDTH)
                  .padding({ top: $r('app.float.common_margin_sixty'), bottom: $r('app.float.common_margin_sixty') })
                  .onClick(() => {
                    this.pageInfos.pushPathByName('feedback', null)
                  })
                }
              }
              .backgroundColor($r('sys.color.background_primary'))
              .divider(this.egDivider)
              .borderRadius(Constants.RADIUS_SIXTY)
              .padding($r('app.float.about_padding'))
              .margin({ top: $r('app.float.about_margin') })
            }
            .padding({ left: $r('app.float.about_padding'), right: $r('app.float.about_padding') })
          }
        }
      }.scrollBar(BarState.Off)
    }
    .title('关于我们')
    .padding({ top: Number(AppStorage.get('topRectHeight')) })
    .backgroundColor($r('sys.color.background_secondary'))
  }
}