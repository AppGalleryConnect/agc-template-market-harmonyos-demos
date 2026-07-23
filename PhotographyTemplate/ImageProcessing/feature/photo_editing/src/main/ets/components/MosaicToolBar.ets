import { CommonConstants, OperateType, ToastLoading, WindowUtil } from 'commonlib';
import { PhotoBeautificationVM } from '../viewmodel/PhotoBeautificationVM';
import { Constants } from '../constant/Constants';
import { LayerType } from '../constant/Enum';
import { MosaicInfo } from '../model/ImageModel';
import { ToolBarHeader } from './ToolBarHeader';
import { ToolBarBtn } from './ToolBarBtn';
import { MosaicVM } from '../viewmodel/MosaicVM';

@ComponentV2
export struct MosaicToolBar {
  vm: PhotoBeautificationVM = PhotoBeautificationVM.instance;
  mosaicVM: MosaicVM = this.vm.mosaicVM;

  @Local isShowBlock: boolean = false;

  aboutToAppear(): void {
    WindowUtil.setGestureBackEnabled(false);
    this.mosaicVM.lineWidth = 8;
  }

  aboutToDisappear(): void {
    WindowUtil.setGestureBackEnabled(true);
  }

  exitMosaic() {
    // 切换操作时，图片需要复原位置和大小
    this.vm.matrix4TransitVM.resetImageTransform(() => {
      this.vm.operateType = OperateType.NONE;
    });
    this.vm.showRemind = false;
    this.mosaicVM.clearPath();
  }

  saveMosaic() {
    if (this.mosaicVM.hasDrawVip && !this.vm.userInfo.isVip) {
      this.vm.showRemind = true;
      this.getUIContext().getPromptAction().showToast({ message: '成为vip享受很多精彩资源！' });
    } else {
      ToastLoading.open();
      this.vm.saveImage(LayerType.MOSAIC);
      this.mosaicVM.isVipMosaic = false;
      this.mosaicVM.hasDrawVip = false;
      ToastLoading.close();
      this.exitMosaic();
    }
  }

  // 是否可以撤销绘制
  canUndoDraw(): boolean {
    return this.mosaicVM.historyIndex >= 0;
  }

  // 是否可以重做绘制
  canRedoDraw(): boolean {
    return this.mosaicVM.historyIndex < this.mosaicVM.drawHistory.length - 1;
  }

  build() {
    Column() {
      this.operateBarView()

      Column() {
        // 头部
        ToolBarHeader({
          close: () => {
            this.exitMosaic();
          },
          confirm: () => {
            this.saveMosaic();
          },
        })

        Grid() {
          GridItem() {
            Image($r('app.media.origin_icon'));
          }
          .constraintSize({ maxWidth: 67 })
          .onClick(() => {
            this.vm.showRemind = false;
            this.mosaicVM.clearPath();
          });

          ForEach(Constants.mosaicList, (item: MosaicInfo, index) => {
            GridItem() {
              Stack() {
                Image(item.icon);
                if (this.mosaicVM.mosaicIndex === index) {
                  Column() {
                    Image($r('app.media.checkmark_circle')).width(24);
                  }
                  .width('100%')
                  .height(68)
                  .justifyContent(FlexAlign.Center)
                  .backgroundColor('rgba(0, 0, 0, 0.3)')
                  .borderRadius(8);
                }
              };
            }.constraintSize({ maxWidth: 68, maxHeight: 68 }).onClick(() => {
              this.mosaicVM.isVipMosaic = item.isVip;
              this.mosaicVM.mosaicSource = item.mosaicSource;
              this.mosaicVM.mosaicIndex = index;
              this.mosaicVM.createPattern();
              if (this.vm.userInfo.isVip || !item.isVip && !this.mosaicVM.hasDrawVip) {
                this.vm.showRemind = false;
              } else {
                this.vm.showRemind = true;
              }
            });
          }, (item: MosaicInfo) => item.mosaicSource);
        }.constraintSize({ maxHeight: 68 })
        .columnsTemplate('1fr 1fr 1fr 1fr')
        .rowsGap(16)
        .columnsGap(20);
      }
      .backgroundColor($r('sys.color.background_primary'))
      .borderRadius({ topLeft: 16, topRight: 16 })
    }
    .padding({ bottom: CommonConstants.PADDING_M })
    .borderRadius({ topLeft: 16, topRight: 16 })
    .backgroundColor($r('sys.color.background_primary'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }


  @Builder
  operateBarView() {
    Column({ space: 8 }) {
      Column() {
        Circle({ width: this.mosaicVM.lineWidth, height: this.mosaicVM.lineWidth })
          .fill($r('sys.color.multi_color_aux_01'))
          .visibility(this.isShowBlock ? Visibility.Visible : Visibility.None)
      }
      .height(30)

      Row({ space: 12 }) {
        ToolBarBtn({
          symbol: 'sys.symbol.undo',
          enable: this.canUndoDraw(),
          btnSize: 24,
          iconSize: 14,
          fontColor: $r('sys.color.icon_on_primary'),
          btnBg: $r('sys.color.multi_color_aux_01'),
          onClickAction: () => {
            this.mosaicVM.undoDraw();
          }
        })

        ToolBarBtn({
          symbol: 'sys.symbol.redo',
          enable: this.canRedoDraw(),
          btnSize: 24,
          iconSize: 14,
          fontColor: $r('sys.color.icon_on_primary'),
          btnBg: $r('sys.color.multi_color_aux_01'),
          onClickAction: () => {
            this.mosaicVM.redoDraw();
          }
        })

        Slider({
          value: this.mosaicVM.lineWidth,
          min: 3,
          max: 30,
          step: 1,
          style: SliderStyle.OutSet,
        })
          .height(16)
          .layoutWeight(1)
          .blockSize({
            width: 16,
            height: 16,
          })
          .blockColor($r('sys.color.comp_background_primary_contrary'))
          .trackColor($r('sys.color.comp_background_tertiary'))
          .selectedColor($r('sys.color.comp_background_emphasize'))
          .showSteps(false)
          .showTips(false)
          .trackThickness(4)
          .trackBorderRadius(2)
          .onChange((value: number, mode: SliderChangeMode) => {
            this.mosaicVM.lineWidth = value;
            if (mode === SliderChangeMode.End) {
              this.isShowBlock = false
            } else {
              this.isShowBlock = true
            }
          });
      }
      .width(CommonConstants.FULL_PERCENT)
    }
    .width(CommonConstants.FULL_PERCENT)
    .padding({
      left: this.vm.breakPointModel.pagePadding,
      right: this.vm.breakPointModel.pagePadding,
    })
    .position({ top: -72 })
    .justifyContent(FlexAlign.SpaceBetween)
    .visibility(this.vm.isShowMosaicOperateBar ? Visibility.Visible : Visibility.None)
  }
}