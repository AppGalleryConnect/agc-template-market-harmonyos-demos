import { HomePageVM } from '../viewModels/HomePageVM';

@ComponentV2
export struct Banner {
  vm: HomePageVM = HomePageVM.instance;

  build() {
    Swiper() {
      ForEach(this.vm.bannerUrl, (item: string) => {
        Image(item).width('100%').height(200);
      }, (item: string) => item);
    }
    .width('100%')
    .height(200)
    .autoPlay(true)
    .loop(true)
    .indicator(false);
  }
}