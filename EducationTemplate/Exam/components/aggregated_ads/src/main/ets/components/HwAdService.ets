import { AdComponent, advertising, identifier } from '@kit.AdsKit';
import { AdStatus, AdType } from '../common/Constant';
import { Prompt, window } from '@kit.ArkUI';
import { abilityAccessCtrl, common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { UtilLog } from '@hw-agconnect/util-log';

@ComponentV2
export struct HwAdService {
  @Param adId: string = '';
  @Param closeCallBack: () => void = () => {
  };
  @Param adType: number = 1;
  @Local oaid: string = '';
  @Local isShow: boolean = false;
  @Local visibilityState: Visibility = Visibility.Visible;
  private ads: Array<advertising.Advertisement> = [];
  private splashImageAdReqParams: advertising.AdRequestParams = {
    adId: '',
    adType: AdType.SPLASH_AD,
    adCount: 1,
  };
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext
  private adDisplayOptions: advertising.AdDisplayOptions = {
    mute: false,
  };
  @Local adOptions: advertising.AdOptions = {
    allowMobileTraffic: 0,
    tagForChildProtection: -1,
    tagForUnderAgeOfPromise: -1,
    adContentClassification: 'A',
  };

  aboutToAppear(): void {
    // 开启全屏模式沉浸页面
    void this.setWindowLayoutFullScreen(true).catch((error: BusinessError) => {
      UtilLog.info(0x0000, 'testTag',
        `Failed to setWindowLayoutFullScreen. Code is ${error.code}, message is ${error.message}`);
    });
    // 设置屏幕方向为竖屏
    void this.setWindowPreferredOrientation(window.Orientation.PORTRAIT).catch((error: BusinessError) => {
      UtilLog.info(0x0000, 'testTag',
        `Failed to setWindowPreferredOrientation. Code is ${error.code}, message is ${error.message}`);
    });
    this.splashImageAdReqParams.adId = this.adId;
    this.splashImageAdReqParams.adType = this.adType;
    try {
      this.requestOAIDTrackingConsentPermissions(this.context);
    } catch (error) {
      UtilLog.error(0x0000, 'testTag', `Catch err, code: ${error.code}, message: ${error.message}`);
    }
  }

  aboutToDisappear(): void {
    // 关闭全屏模式，开发者可根据实际情况修改
    void this.setWindowLayoutFullScreen(false).catch((error: BusinessError) => {
      UtilLog.info(0x0000, 'testTag',
        `Failed to setWindowLayoutFullScreen. Code is ${error.code}, message is ${error.message}`);
    });
    // 设置屏幕方向为默认值，开发者可根据实际情况修改
    void this.setWindowPreferredOrientation(window.Orientation.UNSPECIFIED).catch((error: BusinessError) => {
      UtilLog.info(0x0000, 'testTag',
        `Failed to setWindowPreferredOrientation. Code is ${error.code}, message is ${error.message}`);
    });
  }

  private async setWindowLayoutFullScreen(isLayoutFullScreen: boolean): Promise<void> {
    try {
      const win: window.Window = await window.getLastWindow(this.context);
      await win.setWindowLayoutFullScreen(isLayoutFullScreen);
    } catch (e) {
      UtilLog.error(0x0000, 'testTag', `Failed to set window layout. Code is ${e.code}, message is ${e.message}`);
    }
  }

  private async setWindowPreferredOrientation(orientation: Orientation): Promise<void> {
    try {
      const win: window.Window = await window.getLastWindow(this.context);
      await win.setPreferredOrientation(orientation);
    } catch (e) {
      UtilLog.error(0x0000, 'testTag', `Failed to set preferred orientation. Code is ${e.code}, message is ${e.message}`);
    }
  }

  private requestOAIDTrackingConsentPermissions(context: common.Context): void {
    const atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
    try {
      atManager.requestPermissionsFromUser(context, ['ohos.permission.APP_TRACKING_CONSENT']).then((data) => {
        identifier.getOAID().then((data: string) => {
          this.oaid = data;
          this.requestAd(this.splashImageAdReqParams, this.adOptions);
        }).catch((error: BusinessError) => {
          UtilLog.debug(0x0000, 'testTag', `ads[0].adType is : `);
        });
      }).catch((err: BusinessError) => {
        UtilLog.debug(0x0000, 'testTag', `ads[0].adType is :`);
      });
    } catch (err) {
      UtilLog.debug(0x0000, 'testTag', `ads[0].adType is : `);
    }
  }

  private requestAd(adReqParams: advertising.AdRequestParams, adOptions: advertising.AdOptions): void {
    adReqParams.oaid = this.oaid;
    const adLoaderListener: advertising.AdLoadListener = {
      onAdLoadFailure: (errorCode: number, errorMsg: string) => {
        Prompt.showToast({
          message: `Failed to request ad, errorCode is:  ${errorCode} , errorMsg is: ${errorMsg}`,
          duration: 1000,
        });
        this.closeCallBack()
      },
      onAdLoadSuccess: (ads: Array<advertising.Advertisement>) => {
        if (canIUse('SystemCapability.Advertising.Ads')) {
          this.ads = ads as Array<advertising.Advertisement>;
          this.isShow = true;
        }
      },
    };
    const load: advertising.AdLoader = new advertising.AdLoader(this.context);
    load.loadAd(adReqParams, adOptions, adLoaderListener);
  }

  @Builder
  splashScreenBuilder(he: string) {
    AdComponent({
      ads: this.ads, displayOptions: this.adDisplayOptions,
      interactionListener: {
        onStatusChanged: (status: string) => {
          switch (status) {
            case AdStatus.AD_OPEN:
              break;
            case AdStatus.AD_CLICKED:
              break;
            case AdStatus.AD_CLOSED:
              this.closeCallBack();
              break;
          }
        },
      },
    })
      .width('100%')
      .height(he)
  }

  @Builder
  splashHalfScreenBuilder() {
    Column() {
      this.splashScreenBuilder('90%');
      Column() {
        Row() {
          Image($r('app.media.video'))
            .width(36)
            .height(36)
            .margin({ right: 8 });
          Text('video')
            .fontColor('#1A1A1A');
        }.margin({ bottom: 8 });

        Text('Copyright © 2022-2024 Huawei Technologies Co., Ltd.')
          .fontColor('#1A1A1A')
          .fontSize(10);
      }
      .height('10%')
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Start)
      .padding({ left: 16 });
    }
    .height('100%')
    .backgroundColor('#FDF7F8');
  }

  @Builder
  nativeCardAd() {
    Row() {
      AdComponent({
        ads: this.ads, displayOptions: this.adDisplayOptions,
        interactionListener: {
          onStatusChanged: (status: string) => {
            switch (status) {
              case AdStatus.AD_OPEN:
                break;
              case AdStatus.AD_CLICKED:
                break;
              case AdStatus.AD_CLOSED:
                this.visibilityState = Visibility.None;
                break;
            }
          },
        },
      })
        .width('100%')
        .height('100%')
    }
    .width('100%')
    .visibility(this.visibilityState)
    .justifyContent(FlexAlign.Center)
  }

  build() {
    if (this.isShow) {
      if (this.adType === 3) {
        this.nativeCardAd()
      } else {
        if (this.ads[0].isFullScreen) {
          this.splashScreenBuilder('100%');
        } else {
          this.splashHalfScreenBuilder();
        }
      }
    }
  }
}