import { CommonConstants, OperateType, WindowUtil } from 'commonlib';
import { Constants } from '../constant/Constants';
import { PhotoBeautificationVM } from '../viewmodel/PhotoBeautificationVM';
import { ImageTextItem } from '../model/ImageModel';
import { LayerType } from '../constant/Enum';
import { display } from '@kit.ArkUI';
import { ToolBarHeader } from './ToolBarHeader';

@ComponentV2
export struct CarouseCutToolBar {
  vm: PhotoBeautificationVM = PhotoBeautificationVM.instance;
  @Local memoryRatio: number = 1;
  tabTitle: string[] = ['裁切', '旋转'];

  aboutToAppear(): void {
    WindowUtil.setGestureBackEnabled(false);
  }

  aboutToDisappear(): void {
    WindowUtil.setGestureBackEnabled(true);
  }

  exitCrop() {
    // 切换操作时，图片需要复原位置和大小
    this.vm.matrix4TransitVM.resetImageTransform(() => {
      this.vm.operateType = OperateType.NONE;
    })

    this.vm.carouselCutTabIndex = 0;
    this.vm.cutSelectIndex = 0;
    this.vm.cropVM.cleanReact();
    this.vm.cropVM.cropRatio = this.getCropRatio();
    this.vm.cropVM.determineCropType();
  }

  async saveCrop() {
    // 裁切操作
    if (this.vm.carouselCutTabIndex === 0) {
      // 非原图时，保存
      if (this.vm.cutSelectIndex > 0) {
        this.vm.saveImage(LayerType.CLIP);
      }
    } else if (this.vm.carouselCutTabIndex === 1) { // 旋转操作
      if (!this.vm.previewPixelMap) {
        return;
      }
      this.vm.currentPixelMap = this.vm.previewPixelMap;
      this.vm.layers = this.vm.layers.slice(0, this.vm.currentLayerIndex + 1)
      this.vm.layers.push({
        type: LayerType.ROTATE,
        pixelMap: this.vm.previewPixelMap,
      })
      this.vm.previewPixelMap = undefined;
      this.vm.totalLayerCount = this.vm.layers.length;
      this.vm.currentLayerIndex = this.vm.totalLayerCount - 1;
    }

    this.exitCrop();
  }

  // 图片旋转
  rotateImage(rotate: string) {
    if (!this.vm.currentPixelMap) {
      return
    }

    if (!this.vm.previewPixelMap) {
      this.vm.previewPixelMap = this.vm.currentPixelMap;
    }

    try {
      let pixelMap = this.vm.previewPixelMap.cloneSync();

      switch (rotate) {
        case 'left_90':
          pixelMap.rotateSync(-90);
          break;
        case 'right_90':
          pixelMap.rotateSync(90);
          break;
        case 'horizontal':
          pixelMap.flipSync(true, false);
          break;
        case 'vertical':
          pixelMap.flipSync(false, true);
          break;
      }

      const imgInfo = pixelMap.getImageInfoSync();
      const rotateRatio = imgInfo.size.width / imgInfo?.size.height;
      this.vm.imageRatio = rotateRatio;
      this.vm.previewPixelMap = pixelMap;
    } catch (error) {
    }
  }

  getCropRatio() {
    let cropRatio = 0;
    switch (this.vm.cutSelectIndex) {
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


  build() {
    Column() {
      // 头部
      ToolBarHeader({
        close: () => {
          this.exitCrop();
        },
        confirm: () => {
          this.saveCrop();
        },
        centerBuilder: () => {
          this.carouseCutTitle()
        }
      })
      // 裁切操作
      this.cutListBuilder()
      // 旋转操作
      this.rotateListBuilder()
    }
    .padding({ bottom: CommonConstants.PADDING_M })
    .borderRadius({ topLeft: 16, topRight: 16 })
    .backgroundColor($r('sys.color.background_primary'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }

  @Builder
  carouseCutTitle() {
    Row({ space: 32 }) {
      ForEach(this.tabTitle, (item: string, index: number) => {
        Text(item)
          .fontColor(this.vm.carouselCutTabIndex === index ? $r('sys.color.multi_color_aux_01') : Color.Black)
          .fontSize(16)
          .fontWeight(this.vm.carouselCutTabIndex === index ? FontWeight.Medium : FontWeight.Regular)
          .onClick(() => {
            this.vm.carouselCutTabIndex = index;
          });
      }, (item: string) => item);
    }
  }

  @Builder
  cutListBuilder() {
    Row() {
      ForEach(Constants.cutList, (item: ImageTextItem, index: number) => {
        CarouseItemView({
          item: item,
          fillColor: this.vm.cutSelectIndex === index ? $r('sys.color.multi_color_aux_01') : Color.Black,
          clickAction: () => {
            this.vm.cutSelectIndex = index;
            this.vm.cropVM.cropRatio = this.getCropRatio();
            this.vm.cropVM.determineCropType();
          }
        })
      }, (item: ImageTextItem) => JSON.stringify(item));
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(60)
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Bottom)
    .padding({
      left: this.vm.breakPointModel.pagePadding,
      right: this.vm.breakPointModel.pagePadding
    })
    .visibility(this.vm.carouselCutTabIndex === 0 ? Visibility.Visible : Visibility.None);
  }

  @Builder
  rotateListBuilder() {
    Row() {
      ForEach(Constants.carouseList, (item: ImageTextItem, index: number) => {
        CarouseItemView({
          item: item,
          fillColor: Color.Black,
          clickAction: () => {
            this.rotateImage(item.value)
          }
        })
      }, (item: ImageTextItem) => JSON.stringify(item));
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(60)
    .justifyContent(FlexAlign.SpaceEvenly)
    .alignItems(VerticalAlign.Bottom)
    .padding({
      left: this.vm.breakPointModel.pagePadding,
      right: this.vm.breakPointModel.pagePadding
    })
    .visibility(this.vm.carouselCutTabIndex === 1 ? Visibility.Visible : Visibility.None);
  }
}

@ComponentV2
struct CarouseItemView {
  @Param @Require item: ImageTextItem;
  @Param fillColor: ResourceColor = Color.Black;
  @Event clickAction: () => void = () => {}

  build() {
    Column({ space: 4 }) {
      Image(this.item.icon)
        .width(24)
        .height(24)
        .fillColor(this.fillColor);

      Text(this.item.text)
        .fontSize(12)
        .fontColor(this.fillColor)
        .lineHeight(16)
    }
    .onClick(() => {
      this.clickAction?.();
    });
  }
}