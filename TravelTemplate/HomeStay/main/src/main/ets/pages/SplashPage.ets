import { AdServicePage, AdType, ChannelType } from 'aggregated_ads';

@Builder
export function SplashPageBuilder() {
  SplashPage()
}

@ComponentV2
export struct SplashPage {
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();

  build() {
    NavDestination() {
      Column() {
        AdServicePage({
          channelType: ChannelType.HUAWEI_AD,
          // todo 替换广告id
          adId: 'testd7c5cewoj6',
          adType: AdType.SPLASH_AD,
          closeCallBack: () => {
            this.mainPathStack.replacePathByName('Main', null);
          },
        })
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#FDF7F8');
    }
    .hideTitleBar(true)
  }
}