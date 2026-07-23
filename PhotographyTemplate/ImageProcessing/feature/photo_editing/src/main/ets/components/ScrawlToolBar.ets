import { CommonColorPicker, CommonConstants, OperateType, ToastLoading, WindowUtil } from 'commonlib';
import { PhotoBeautificationVM } from '../viewmodel/PhotoBeautificationVM';
import { Constants } from '../constant/Constants';
import { LayerType } from '../constant/Enum';
import { ToolBarHeader } from './ToolBarHeader';
import { ToolBarBtn } from './ToolBarBtn';
import { ScrawlInfo } from '../model/ImageModel';
import { DrawBoardVM } from '../viewmodel/DrawBoardVM';

@ComponentV2
export struct ScrawlToolBar {
  vm: PhotoBeautificationVM = PhotoBeautificationVM.instance;
  drawVM: DrawBoardVM = this.vm.drawBoardVM;
  @Local isShowBlock: boolean = false;

  aboutToAppear(): void {
    WindowUtil.setGestureBackEnabled(false);
    this.drawVM.brushLineWidth = 8;
    this.drawVM.brushWidthRatio = Constants.scrawlList[0].brushWidth / 8;
    this.drawVM.brushShadowBlur = 0;
  }

  aboutToDisappear(): void {
    WindowUtil.setGestureBackEnabled(true);
  }

  exitScrawl() {
    // 切换操作时，图片需要复原位置和大小
    this.vm.matrix4TransitVM.resetImageTransform(() => {
      this.vm.operateType = OperateType.NONE;
    });
  }

  saveScrawl() {
    ToastLoading.open();
    this.vm.saveImage(LayerType.SCRAWL);
    ToastLoading.close();
    this.exitScrawl();
  }

  handleChangeBrush(item: ScrawlInfo, index: number) {
    this.drawVM.scrawlIndex = index;
    this.drawVM.brushWidthRatio = item.brushWidth / 8;
    this.drawVM.brushShadowBlur = item.shadowBlur;
    this.drawVM.lineCap = item.lineCap || 'round';
    if (item.lineDash) {
      this.drawVM.lineDash = item.lineDash;
    }
    this.drawVM.applyBrushSettings();
  }

  build() {
    Column() {
      this.operateBarView()

      Column() {
        // 头部
        ToolBarHeader({
          close: () => {
            this.exitScrawl();
          },
          confirm: () => {
            this.saveScrawl();
          },
          centerBuilder: () => {
            this.scrawlTitle()
          }
        })

        // 颜色
        Column({ space: 12 }) {
          // 颜色选择
          CommonColorPicker({
            onSelectColor: (color: string) => {
              this.drawVM.brushColor = color;
              this.drawVM.applyBrushSettings();
            }
          })

          Row({ space: 16 }) {
            Text('不透明度').fontSize(16)
            Slider({
              value: this.drawVM.brushAlpha,
              min: 0,
              max: 1,
              step: 0.1,
              style: SliderStyle.OutSet,
            })
              .layoutWeight(1)
              .showTips(true)
              .onChange((value: number) => {
                this.drawVM.brushAlpha = value;
                this.drawVM.applyBrushSettings();
              });
          }
        }
        .width('100%')
        .padding({
          left: this.vm.breakPointModel.pagePadding,
          right: this.vm.breakPointModel.pagePadding
        })

        Grid() {
          ForEach(Constants.scrawlList, (item: ScrawlInfo, index: number) => {
            GridItem() {
              Stack() {
                Image(item.icon);
                if (this.drawVM.scrawlIndex === index) {
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
            }
            .constraintSize({ maxWidth: 68, maxHeight: 68 })
            .onClick(() => {
              this.handleChangeBrush(item, index)
            });
          }, (item: ScrawlInfo) => JSON.stringify(item));
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
        Circle({ width: this.drawVM.brushLineWidth, height: this.drawVM.brushLineWidth })
          .fill($r('sys.color.multi_color_aux_01'))
          .visibility(this.isShowBlock ? Visibility.Visible : Visibility.None)
      }
      .height(30)

      Row({ space: 12 }) {
        ToolBarBtn({
          symbol: 'sys.symbol.undo',
          enable: this.drawVM.unDoDraw,
          btnSize: 24,
          iconSize: 14,
          fontColor: $r('sys.color.icon_on_primary'),
          btnBg: $r('sys.color.multi_color_aux_01'),
          onClickAction: () => {
            this.drawVM.drawOperateUndo();
            this.drawVM.renderWithCache();
          }
        })

        ToolBarBtn({
          symbol: 'sys.symbol.redo',
          enable: this.drawVM.redoDraw,
          btnSize: 24,
          iconSize: 14,
          fontColor: $r('sys.color.icon_on_primary'),
          btnBg: $r('sys.color.multi_color_aux_01'),
          onClickAction: () => {
            this.drawVM.drawOperateRedo();
            this.drawVM.renderWithCache();
          }
        })

        Slider({
          value: this.drawVM.brushLineWidth,
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
            this.drawVM.brushLineWidth = value;
            if (mode === SliderChangeMode.End) {
              this.isShowBlock = false
            } else {
              this.isShowBlock = true
            }
            this.drawVM.applyBrushSettings();
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

  @Builder
  scrawlTitle() {
    Text('画笔').fontColor($r('sys.color.multi_color_aux_01'));
  }
}