import { CommonBanner } from 'componentlib';
import { HomePageVM } from '../viewModels/HomePageVM';

@ComponentV2
export struct Banner {
  vm: HomePageVM = HomePageVM.instance;

  build() {
    CommonBanner({
      x: 4,
      y: 3,
      covers: this.vm.bannerList,
      imageFit: ImageFit.Fill,
    })
  }
}