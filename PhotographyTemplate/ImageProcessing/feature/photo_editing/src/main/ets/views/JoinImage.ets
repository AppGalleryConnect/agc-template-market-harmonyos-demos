import { CollageVM } from '../viewmodel/CollageVM';

@ComponentV2
export struct JoinImage {
  vm: CollageVM = CollageVM.instance;

  async aboutToAppear() {
    await this.vm.joinImages(this.vm.imagesToJoin);
  }

  build() {
    Column() {
      Scroll() {
        if (this.vm.joinImagePixelMap) {
          Image(this.vm.joinImagePixelMap);
        }
      }.padding(16).scrollBar(BarState.Off)
      .backgroundColor($r('sys.color.background_secondary'))
      .height('calc(100% - 80vp)');
    };
  }
}