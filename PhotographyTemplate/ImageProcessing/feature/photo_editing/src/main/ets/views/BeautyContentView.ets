import { CommonConstants, Logger, OperateType, WaterMark } from 'commonlib';
import { AddTextComponent } from '../components/AddTextComponent';
import { DrawBoard } from '../components/DrawBoard';
import { MosaicComponent } from '../components/MosaicComponent';
import { StickerComponent } from '../components/StickerComponent';
import { WatermarkComponent } from '../components/WatermarkComponent';
import { StickerModel } from '../model/BeautificationParam';
import { PhotoBeautificationVM } from '../viewmodel/PhotoBeautificationVM';
import { VipTipView } from './VipTipView';


@ComponentV2
export struct BeautyContentView {
  vm: PhotoBeautificationVM = PhotoBeautificationVM.instance;

  @Computed
  get maskVisibility() {
    return this.vm.operateType === OperateType.CROP && this.vm.carouselCutTabIndex === 0 ? Visibility.Visible :
      Visibility.None
  }

  @Computed
  get clipVisibility() {
    return this.vm.operateType === OperateType.CROP && this.vm.carouselCutTabIndex === 0 ? Visibility.Visible :
      Visibility.None
  }

  @Computed
  get currentPixelMap() {
    const previewPixelMap = this.vm.previewPixelMap;
    return previewPixelMap ?? this.vm.currentPixelMap;
  }

  @Computed
  get isImageEnable() {
    const enableTypes = [OperateType.NONE, OperateType.FILTER]
    return enableTypes.includes(this.vm.operateType);
  }

  @Monitor('currentPixelMap')
  onPixelMapChange() {
    if (this.currentPixelMap) {
      try {
        const imgInfo = this.currentPixelMap.getImageInfoSync();
        const imageRatio = imgInfo.size.width / imgInfo?.size.height;
        this.vm.imageRatio = imageRatio;
      } catch (error) {
        Logger.error(`getImageInfoSync failed. error: ${JSON.stringify(error)}`)
      }
    }
  }

  build() {
    Stack() {
      // 会员开通提醒
      VipTipView()

      Stack() {
        Image(this.currentPixelMap)
          .aspectRatio(this.vm.imageRatio)
          .objectFit(ImageFit.Cover)
          .autoResize(false)
          .draggable(false)
          .enabled(this.isImageEnable)
          .transform(this.vm.matrix4TransitVM.matrix)
          .offset({
            // 通过offset控制图片的偏移
            x: this.vm.matrix4TransitVM.offsetX,
            y: this.vm.matrix4TransitVM.offsetY
          })
          .gesture(
            GestureGroup(GestureMode.Exclusive, // 互斥模式
              // 双指缩放 最小5vp触发
              PinchGesture({ fingers: 2, distance: 1 })
                .onActionStart(() => {
                  this.vm.matrix4TransitVM.handlePinchStart();
                })
                .onActionUpdate((event: PinchGestureEvent) => {
                  this.vm.matrix4TransitVM.handlePinchUpdate(event);
                })
                .onActionEnd(() => {
                  this.vm.matrix4TransitVM.handlePinchEnd()
                }),
              // 单指拖动
              PanGesture({ fingers: 1 })
                .onActionStart(() => {
                  this.vm.matrix4TransitVM.single4ActionStart();
                })
                .onActionUpdate((event: PanGestureEvent) => {
                  this.vm.matrix4TransitVM.single4ActionUpdate(event);
                })
                .onActionEnd((event: PanGestureEvent) => {
                  this.vm.matrix4TransitVM.single4ActionEnd();
                }),
              // 双击
              TapGesture({ count: 2 }).onAction((event) => {
                this.vm.matrix4TransitVM.handleDoubleTap(event.fingerList)
              }),
            ),
          )

        // 贴纸
        if (this.vm.stickerList.length) {
          ForEach(this.vm.stickerList, (item: StickerModel, index: number) => {
            StickerComponent({
              item: item,
              currentStickerIndex: this.vm.currentStickerIndex!!,
              index: index,
              onDelete: (id: string) => {
                this.vm.deleteSticker(id)
              }
            });
          }, (item: StickerModel) => item.id);
        }

        // 文字
        if (this.vm.showCanvasText) {
          AddTextComponent()
        }

        // 马赛克
        if (this.vm.operateType === OperateType.MOSAIC) {
          MosaicComponent()
        }

        // 涂鸦
        if (this.vm.operateType === OperateType.SCRAWL) {
          DrawBoard()
        }

        // 水印
        if (this.vm.operateType === OperateType.WATERMARK) {
          WatermarkComponent()
        }
      }
      .id('ImageContent')
      .aspectRatio(this.vm.imageRatio)
      .onSizeChange((_oldValue: SizeOptions, newValue: SizeOptions) => {
        this.vm.matrix4TransitVM.onImgSizeChange(newValue);
      })
      .onAreaChange((_value: Area, newVal: Area) => {
        this.vm.cropVM.getAreaSize(newVal);
      })

      // 裁剪框蒙层
      Canvas(this.vm.cropVM.maskContext)
        .position({
          x: this.vm.cropVM.imageArea.x,
          y: this.vm.cropVM.imageArea.y,
        })
        .width(this.vm.cropVM.imageArea.width)
        .height(this.vm.cropVM.imageArea.height)
        .visibility(this.maskVisibility);

      // 裁剪框
      Canvas(this.vm.cropVM.cropContext)
        .position({
          x: this.vm.cropVM.clipRect.x - 2,
          y: this.vm.cropVM.clipRect.y - 2,
        })
        .width(this.vm.cropVM.clipRect.width! + 4)
        .height(this.vm.cropVM.clipRect.height! + 4)
        .visibility(this.clipVisibility)
        .onReady(() => {
          this.vm.cropVM.drawClipImage();
        })
        .onTouch((event: TouchEvent) => {
          if (this.vm.cutSelectIndex === 0) {
            return;
          }
          this.vm.cropVM.handleTouch(event, this.vm.cutSelectIndex);
        });

      Image($r('app.media.switch'))
        .width(40)
        .height(40)
        .position({ bottom: 12, right: 12 })
        .draggable(false)
        .visibility(this.vm.operateType === OperateType.NONE ? Visibility.Visible : Visibility.None)
        .onTouch((event: TouchEvent) => {
          this.vm.previewSwitch(event);
        });
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
    .onSizeChange((_oldValue: SizeOptions, newValue: SizeOptions) => {
      this.vm.matrix4TransitVM.onStackSizeChange(newValue);
    })
    .onClick(() => {
      // 清除贴纸的选中态
      this.vm.currentStickerIndex = -1;
    })
  }
}