import { CommonConstants, OperateType, WindowUtil, CustomFilter } from 'commonlib';
import { Constants } from '../constant/Constants';
import { PhotoBeautificationVM } from '../viewmodel/PhotoBeautificationVM';
import { LayerType } from '../constant/Enum';
import { ImageProcessingUtil } from '../util/ImageProcessingUtil';
import { ToolBarHeader } from './ToolBarHeader';

@ComponentV2
export struct FilterToolBar {
  vm: PhotoBeautificationVM = PhotoBeautificationVM.instance;
  listScroller: ListScroller = new ListScroller();

  aboutToAppear(): void {
    WindowUtil.setGestureBackEnabled(false);
    const layers = this.vm.layers.slice(0, this.vm.currentLayerIndex + 1)
    const currentLayer = layers.find((item) => item.type === LayerType.FILTER);
    this.vm.selectedFilterIndex = currentLayer?.filterIndex ?? 0;
  }

  aboutToDisappear(): void {
    WindowUtil.setGestureBackEnabled(true);
  }

  // 处理图片滤镜
  async handleImageFilter(item: CustomFilter, index: number) {
    this.vm.selectedFilterIndex = index;
    this.listScroller.scrollToIndex(index, true, ScrollAlign.CENTER);
    // 原图滤镜
    const initFilter = Constants.filterList[0];
    // 过滤非滤镜图片
    const layers = this.vm.layers.slice(0, this.vm.currentLayerIndex + 1);
    const noFilterLayers = layers.filter((item) => item.type !== LayerType.FILTER);
    const lastPixelMap = noFilterLayers[noFilterLayers.length - 1].pixelMap;
    // 处理预览图片
    const previewPixelMap = lastPixelMap;
    const originPixelMap = await ImageProcessingUtil.filterImage(initFilter, previewPixelMap);
    this.vm.previewPixelMap = await ImageProcessingUtil.filterImage(item, originPixelMap)
  }

  // 重置图片
  resetImageTransform() {
    // 切换操作时，图片需要复原位置和大小
    this.vm.matrix4TransitVM.resetImageTransform(() => {
      this.vm.operateType = OperateType.NONE;
    })
  }

  // 清除滤镜
  cleanFilter() {
    this.vm.selectedFilterIndex = 0;
    this.vm.previewPixelMap = undefined;
  }

  // 退出滤镜操作
  exitFilter() {
    // 切换操作时，图片需要复原位置和大小
    this.resetImageTransform();
    // 清除滤镜
    this.cleanFilter();
  }

  // 保存滤镜
  async saveFilter() {
    // 保存滤镜操作记录
    const selectedFilterIndex = this.vm.selectedFilterIndex;
    if (!this.vm.previewPixelMap) {
      return
    }
    this.vm.currentPixelMap = this.vm.previewPixelMap;
    this.vm.layers = this.vm.layers.slice(0, this.vm.currentLayerIndex + 1)
    this.vm.layers.push({
      type: LayerType.FILTER,
      pixelMap: this.vm.previewPixelMap,
      filterIndex: selectedFilterIndex,
    })

    this.vm.previewPixelMap = undefined;
    this.vm.totalLayerCount = this.vm.layers.length;
    this.vm.currentLayerIndex = this.vm.totalLayerCount - 1;
    // 保存操作，图片复原位置和大小
    this.resetImageTransform();
  }

  build() {
    Column({ space: 12 }) {
      // 滤镜操作栏的头部
      ToolBarHeader({
        close: () => {
          this.exitFilter();
        },
        confirm: () => {
          this.saveFilter();
        },
        centerBuilder: () => {
          this.filterTitle()
        }
      })

      // 滤镜类型
      this.filterTypeView()
    }
    .padding({ bottom: CommonConstants.PADDING_M })
    .borderRadius({ topLeft: 16, topRight: 16 })
    .backgroundColor($r('sys.color.background_primary'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }

  @Builder
  filterTitle() {
    Text('滤镜').fontColor($r('sys.color.multi_color_aux_01'));
  }

  @Builder
  filterTypeView() {
    List({ space: 20, scroller: this.listScroller }) {
      ForEach(Constants.filterList, (item: CustomFilter, index: number) => {
        ListItem() {
          Column({ space: 4 }) {
            Stack() {
              Image(item.image)
                .width(50)
                .height(68)
                .borderRadius(8)

              if (this.vm.selectedFilterIndex === index) {
                Column() {
                  SymbolGlyph($r('sys.symbol.checkmark_circle'))
                    .fontSize(24)
                    .fontColor([$r('sys.color.icon_primary')])
                }
                .width(50)
                .height(68)
                .borderRadius(8)
                .border({
                  width: 2,
                  color: $r('sys.color.icon_primary'),
                  style: BorderStyle.Solid,
                })
                .backgroundColor('rgba(255, 255, 255, 0.5)')
                .justifyContent(FlexAlign.Center)
              }
            }

            Text(item.name)
              .fontSize(12)
              .fontColor($r('sys.color.font_primary'))
              .lineHeight(16)
          }
          .onClick(() => {
            this.handleImageFilter(item, index);
          });
        }
      })
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(88)
    .contentStartOffset(16)
    .contentEndOffset(16)
    .listDirection(Axis.Horizontal)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
  }
}