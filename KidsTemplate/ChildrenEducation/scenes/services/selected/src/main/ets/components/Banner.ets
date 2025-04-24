import { CommonConstants } from '@ohos_agcit/children_education_utils';

@ComponentV2
export struct Banner {
  @Param  bannerArray: Array<string> = [];

  build() {
    Swiper() {
      ForEach(this.bannerArray, (item: string) => {
        Image(item)
          .borderRadius(16)
          .width(CommonConstants.FULL_PERCENT)
          .height(300)
      })
    }
    .margin({
      top : '2%',
      left: '4%',
      right: '4%'
    })
    .autoPlay(true)
  }
}
