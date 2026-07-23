import { BreakpointNameEnum, CommonConstants, OperateType } from 'commonlib';
import { Constants } from '../constant/Constants';
import { CarouseCutToolBar } from './CarouseCutToolBar';
import { FilterToolBar } from './FilterToolBar';
import { AddTextToolBar } from './AddTextToolBar';
import { ImageShowModel } from '../model/PageParams';
import { StickerToolBar } from './StickerToolBar';
import { IconAndTextView } from './IconAndTextView';
import { MosaicToolBar } from './MosaicToolBar';
import { WaterMarkToolBar } from './WaterMarkToolBar';
import { PhotoBeautificationVM } from '../viewmodel/PhotoBeautificationVM';
import { ScrawlToolBar } from './ScrawlToolBar';

@ComponentV2
export struct BeautyActionBar {
  vm: PhotoBeautificationVM = PhotoBeautificationVM.instance;

  @Computed
  get listSpace() {
    return this.vm.breakPointModel.currentBreakpoint === BreakpointNameEnum.SM ? 16 : 0
  }

  @Monitor('vm.operateType')
  onOperateTypeChange() {
    if (this.vm.operateType === OperateType.NONE) {
      this.vm.barOffsetY = 200;
    }
  }

  getOperateTypeByIndex(index: number): OperateType {
    switch (index) {
      case 0:
        return OperateType.FILTER;
      case 1:
        return OperateType.CROP;
      case 2:
        return OperateType.STICKER;
      case 3:
        this.vm.showCanvasText = true;
        return OperateType.TEXT;
      case 4:
        return OperateType.MOSAIC;
      case 5:
        return OperateType.SCRAWL;
      case 6:
        return OperateType.WATERMARK;
      default:
        return OperateType.NONE;
    }
  }

  build() {
    Column() {
      this.allToolsBuilder();
      this.toolBarsStack()
    }
    .width('100%')
    .padding({ top: 4 })
    .justifyContent(FlexAlign.End)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor($r('sys.color.background_primary'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    .borderRadius({ topLeft: 16, topRight: 16 });
  }

  @Builder
  toolBarsStack() {
    // 滤镜
    if (this.vm.operateType === OperateType.FILTER) {
      FilterToolBar()
        .translate({ y: this.vm.barOffsetY })
    }
    // 调整
    if (this.vm.operateType === OperateType.CROP) {
      CarouseCutToolBar()
        .translate({ y: this.vm.barOffsetY })
    }
    // 贴纸
    if (this.vm.operateType === OperateType.STICKER) {
      StickerToolBar()
        .translate({ y: this.vm.barOffsetY })
    }
    // 文字
    if (this.vm.operateType === OperateType.TEXT) {
      AddTextToolBar()
        .translate({ y: this.vm.barOffsetY })
    }
    // 马赛克
    if (this.vm.operateType === OperateType.MOSAIC) {
      MosaicToolBar()
        .translate({ y: this.vm.barOffsetY })
    }
    // 涂鸦
    if (this.vm.operateType === OperateType.SCRAWL) {
      ScrawlToolBar()
        .translate({ y: this.vm.barOffsetY })
    }
    // 水印
    if (this.vm.operateType === OperateType.WATERMARK) {
      WaterMarkToolBar()
        .translate({ y: this.vm.barOffsetY })
    }
  }

  @Builder
  allToolsBuilder() {
    List({ space: this.listSpace }) {
      ForEach(Constants.BAR_LIST, (item: ImageShowModel, index: number) => {
        ListItem() {
          IconAndTextView({
            barItem: item,
            clickAction: () => {
              this.vm.operateType = this.getOperateTypeByIndex(index);
              // 切换操作时，图片需要复原位置和大小
              this.vm.matrix4TransitVM.resetImageTransform(() => {
                this.vm.barOffsetY = 0;
              })
            }
          })
        }
        .width(`calc((100% - ${2 * this.vm.breakPointModel.pagePadding}vp) / ${Constants.BAR_LIST.length})`)
        .constraintSize({ minWidth: 48 })
      }, (item: ImageShowModel) => JSON.stringify(item));
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(72)
    .contentStartOffset(this.vm.breakPointModel.pagePadding)
    .contentEndOffset(this.vm.breakPointModel.pagePadding)
    .listDirection(Axis.Horizontal)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
    .alignListItem(ListItemAlign.End)
    .visibility(this.vm.operateType === OperateType.NONE ? Visibility.Visible : Visibility.None);
  }
}
