import { HomePageVM } from '../viewModels/HomePageVM';

@ComponentV2
export struct Banner {
  vm: HomePageVM = HomePageVM.instance;

  build() {
    Swiper() {
      ForEach(this.vm.bannerUrl, (item: ResourceStr, index) => {
        Image(item).width('100%').height(270).borderRadius(16);
      }, (item: ResourceStr, index) => index.toString());
    }
    .width('100%')
    .height(270)
    .autoPlay(true)
    .loop(true)
    .indicator( // 设置圆点导航点样式
      new DotIndicator()
        .itemWidth(8)
        .itemHeight(8)
        .selectedItemWidth(12)
        .selectedItemHeight(8)
        .color('#33FFFFFF')
        .selectedColor('#E84026'))
    .borderRadius(16);
  }
}

