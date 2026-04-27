import { display } from '@kit.ArkUI';
import { ImageShowModel } from '../model/PageParams';
import { Constants } from '../constant/Constants';
import { PhotoBeautificationVM } from '../viewmodel/PhotoBeautificationVM';

@ComponentV2
export struct CarouseCutToolBar {
  vm: PhotoBeautificationVM = PhotoBeautificationVM.instance;
  @Local cutSelectIndex: number = 0;
  @Local carouseSelectIndex: number = 0;
  private carouselCutController: TabsController = new TabsController();
  tabTitle: string[] = ['裁切', '旋转'];

  build() {
    Column() {
      Row() {
        Tabs({ barPosition: BarPosition.Start, controller: this.carouselCutController }) {
          TabContent() {
            Row() {
              ForEach(Constants.cutList, (item: ImageShowModel, index: number) => {
                Column() {
                  Image(item.imageSource)
                    .width(32)
                    .height(32)
                    .objectFit(ImageFit.Contain)
                    .margin({ bottom: 4 })
                    .fillColor(this.cutSelectIndex === index ? '#ED6F21' : Color.Black);

                  Text(item.text)
                    .fontSize(12)
                    .fontColor(this.cutSelectIndex === index ? '#ED6F21' : Color.Black);
                }.onClick(() => {
                  this.cutSelectIndex = index;
                  this.vm.cropRatio = this.getCropRatio();
                  this.vm.determineCropType();
                });
              }, (item: ImageShowModel) => JSON.stringify(item));
            }
            .justifyContent(FlexAlign.SpaceBetween)
            .width('100%');
          };

          TabContent() {
            Row() {
              ForEach(Constants.carouseList, (item: ImageShowModel, index: number) => {
                Column() {
                  Image(item.imageSource)
                    .width(32)
                    .height(32)
                    .objectFit(ImageFit.Contain)
                    .margin({ bottom: 4 })
                    .fillColor(Color.Black);

                  Text(item.text)
                    .fontSize(12)
                    .fontColor(Color.Black);
                }.onClick(() => {
                  this.carouseSelectIndex = index;
                  let number = this.vm.getRotate(index);
                  this.vm.rotateImage(number);
                });
              }, (item: ImageShowModel) => JSON.stringify(item));
            }
            .justifyContent(FlexAlign.SpaceBetween)
            .width('100%');
          };
        }
        .barHeight(0)
        .onChange((index: number) => {
          this.vm.carouselCutTabIndex = index;
        });
      }
      .height(80)
      .margin({
        top: 24,
        bottom: 20,
        left: 16,
        right: 16,
      });

      Row() {
        Image($r('app.media.xmark'))
          .width(24)
          .height(24)
          .margin({ left: 16 })
          .onClick(() => {
            this.vm.barIndex = -1;
            this.vm.carouselCutTabIndex = 0;
            this.carouselCutController.changeIndex(this.vm.carouselCutTabIndex)
            this.carouseSelectIndex = 0;
            this.cutSelectIndex = 0;
            this.vm.cleanReact();
            if (this.vm.originImagePixelMap) {
              this.vm.currentPixelMap = this.vm.originImagePixelMap;
            }
          });
        Row({ space: 32 }) {
          ForEach(this.tabTitle, (item: string, index: number) => {
            Text(item)
              .fontColor(this.vm.carouselCutTabIndex === index ? '#ED6F21' : Color.Black)
              .fontSize(16)
              .fontWeight(this.vm.carouselCutTabIndex === index ? FontWeight.Medium : FontWeight.Regular)
              .onClick(() => {
                this.vm.carouselCutTabIndex = index;
                this.carouselCutController.changeIndex(index);
              });
          }, (item: string) => item);
        };

        Image($r('app.media.checkMark'))
          .width(24)
          .height(24)
          .margin({ right: 16 })
          .onClick(() => {
            if (this.vm.carouselCutTabIndex === 1) {
              this.vm.cleanReact();
            }
            if (this.vm.saveImage) {
              this.vm.saveImage();
            }
            this.vm.carouselCutTabIndex = 0;
            this.carouselCutController.changeIndex(this.vm.carouselCutTabIndex)
            this.carouseSelectIndex = 0;
            this.cutSelectIndex = 0;
          });
      }
      .width('100%')
      .margin({ top: 14 })
      .justifyContent(FlexAlign.SpaceBetween);
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    .borderRadius({ topLeft: 16, topRight: 16 });
  }

  getCropRatio() {
    let cropRatio = 0;
    switch (this.cutSelectIndex) {
      case 0:
        cropRatio = 0;
        break;
      case 1:
        const displayInfo = display.getDefaultDisplaySync();
        const width = displayInfo.width;
        const height = displayInfo.height;
        cropRatio = height / width;
        break;
      case 2:
        cropRatio = 16 / 9;
        break;
      case 3:
        cropRatio = 9 / 16;
        break;
      case 4:
        cropRatio = 1;
        break;
      case 5:
        cropRatio = 2 / 3;
        break;
      case 6:
        cropRatio = 3 / 4;
        break;
      default:
        break;
    }
    return cropRatio;
  }
}