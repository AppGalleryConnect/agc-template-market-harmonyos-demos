import { IBannerItem } from 'network/src/main/ets/types/responseTypes/NoticeResp'
import { HomePageVM } from '../viewModels/HomePageVM'

@ComponentV2
export struct Banner {
  vm: HomePageVM = HomePageVM.instance
  private swiperController: SwiperController = new SwiperController()

  build() {
    Row() {
      Swiper(this.swiperController) {
        ForEach(this.vm.bannerList, (item: IBannerItem) => {
          Image(item.img)
            .width('100%')
            .height('100%')
        }, (item: IBannerItem[]) => JSON.stringify(item))
      }
      .cachedCount(2)
      .index(1)
      .autoPlay(true)
      .interval(4000)
      .loop(true)
      .indicatorInteractive(true)
      .duration(1000)
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height(184)
  }
}