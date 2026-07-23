import { WaterMark } from 'commonlib';
import { PhotoBeautificationVM } from '../viewmodel/PhotoBeautificationVM';

@ComponentV2
export struct WatermarkComponent {
  vm: PhotoBeautificationVM = PhotoBeautificationVM.instance;
  // 水印组件id
  waterMarkId: string = 'photoWaterMark';

  build() {
    Column() {
      WaterMark()
    }
    .id(this.waterMarkId)
    .width('100%')
    .height('100%')
    .onAppear(() => {
      this.vm.watermarkTip();
    })
  }
}