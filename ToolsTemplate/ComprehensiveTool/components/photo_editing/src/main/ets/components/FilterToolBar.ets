import { Constants } from '../constant/Constants';
import { CustomFilter } from '../model/CustomFilter';
import { ImageProcessingUtil } from '../util/ImageProcessingUtil';
import { PhotoBeautificationVM } from '../viewmodel/PhotoBeautificationVM';

@ComponentV2
export struct FilterToolBar {
  vm: PhotoBeautificationVM = PhotoBeautificationVM.instance;

  build() {
    Column({ space: 20 }) {
      Row() {
        Swiper(this.vm.filterController) {
          ForEach(Constants.filterList, (item: CustomFilter, index: number) => {
            Column() {
              Stack() {
                Image(item.image)
                  .width(60)
                  .height(80)
                  .borderRadius(8);

                Column() {
                  Text('');
                  if (this.vm.selectedFilterIndex === index) {
                    Image($r('app.media.ic_filter_checked')).size({ width: 24, height: 24 });
                  }
                  Text(item.name)
                    .fontSize(12)
                    .fontColor($r('sys.color.font_on_primary'))
                    .padding({ bottom: 8 });
                }.height(80).justifyContent(FlexAlign.SpaceBetween);
              }
              .margin({ bottom: 4 })
              .alignContent(Alignment.Bottom);
            }.onClick(() => {
              this.vm.selectedFilterIndex = index;
              this.filterImage(item);
            });
          }, (item: CustomFilter) => JSON.stringify(item));
        }
        .width('100%')
        .autoPlay(false)
        .loop(false)
        .displayCount(4)
        .effectMode(EdgeEffect.Spring)
        .indicator(false)
        .curve(Curve.Linear);
      };

      Row() {
        Image($r('app.media.xmark'))
          .width(24)
          .height(24)
          .onClick(() => {
            this.vm.barIndex = -1;
            this.cleanFilter();
          });
        Text('滤镜').fontColor($r('sys.color.multi_color_09'));
        Image($r('app.media.checkMark'))
          .width(24)
          .height(24)
          .onClick(() => {
            this.vm.saveImage();
            this.cleanFilter();
          });
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween);
    }.padding(16)
    .backgroundColor($r('sys.color.background_secondary'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    .borderRadius({ topLeft: 16, topRight: 16 });
  }

  filterImage(item: CustomFilter) {
    if (!this.vm.originImagePixelMap) {
      this.vm.originImagePixelMap = this.vm.currentPixelMap;
    }
    ImageProcessingUtil.filterImage(item, this.vm.originImagePixelMap)
      .then(data => {
        this.vm.currentPixelMap = data;
      });
  }

  cleanFilter() {
    this.vm.selectedFilterIndex = 0;
    if (this.vm.originImagePixelMap) {
      this.vm.currentPixelMap = this.vm.originImagePixelMap;
    }
  }
}