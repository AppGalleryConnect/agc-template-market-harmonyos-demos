import { AdType, ChannelType } from '../common/Constant';
import { HwAdService } from './HwAdService';

@ComponentV2
export struct AdServicePage {
  /**
   * 广告类型数组
   */
  @Param channelType: ChannelType = ChannelType.HUAWEI_AD;
  /**
   * 通用广告位Id
   */
  @Param adId: string = '';
  /**
   * 广告类型，目前只支持开屏广告
   */
  @Param adType: AdType = AdType.SPLASH_AD;
  /**
   * 应用Id（三方广告平台必传）
   */
  @Param appId?: string = '';
  /**
   * 应用名称（三方广告平台必传）
   */
  @Param appName?: string = '';
  /**
   * 广告关闭的回调
   */
  @Param closeCallBack: () => void = () => {
  };

  build() {
    NavDestination() {
      Column() {
        if (this.channelType === ChannelType.HUAWEI_AD) {
          HwAdService({
            adId: this.adId,
            adType: this.adType,
            closeCallBack: this.closeCallBack,
          });
        }
      }.height('100%').width('100%');
    }.hideTitleBar(true).hideToolBar(true);
  }
}
