import { MovingPhotoView, MovingPhotoViewAttribute, MovingPhotoViewController } from '@kit.MediaLibraryKit'
import { PreviewConstants } from '../constants/Constants'
import { ImagePreviewOptions } from '../models/ImagePreviewOptions'
import { PreviewComponentInfo, SourceImageModel } from '../models/PreviewModel'
import { AvPlayerController } from '../movingPhotoXComp/AvPlayerController'
import { MovingPhotoXComp } from '../movingPhotoXComp/MovingPhotoXComp'
import { PreviewUtils } from '../utils/Utils'
import { MovingPhotoVM } from '../viewmodel/MovingPhotoVM'
import { PreviewViewModel } from '../viewmodel/PreviewViewModel'

@ComponentV2
export struct SwiperMovingPhotoItem {
  @Param @Require vm: PreviewViewModel
  @Param @Require startIndex: number
  @Param @Require params: ImagePreviewOptions
  @Param @Require imageSrc: SourceImageModel
  @Param @Require index: number
  @Param @Require uniId: number = 0
  @Param longTakeEffectMap: Map<number, PreviewComponentInfo> = new Map()
  @Event onDisabledSwiper: (val: boolean) => void = () => {
  }
  movingPhotoVM: MovingPhotoVM = new MovingPhotoVM(this.getUIContext())
  @Event onLoadingStatus: (val: number, index: number) => void = () => {
  }
  @Local loadingStatus: number = 0
  @Local isPrepared: boolean = false
  @Local avPlayerController: AvPlayerController = new AvPlayerController(this.getUIContext())
  controller: MovingPhotoViewController = new MovingPhotoViewController();

  aboutToAppear(): void {
    this.movingPhotoVM.setResource(this.imageSrc)
    this.movingPhotoVM.getMovingPhoto()
  }

  @Monitor('startIndex','isPrepared')
  startIndexChange() {
    // 切换到对应的页签，自动播放动图
    if(!this.params.movingPhotoAutoPlay) {
      return
    }
    if (this.startIndex === this.index && this.isPrepared) {
      if (PreviewUtils.isMovingPhotoFromSandbox(this.imageSrc)) {
        this.controller.startPlayback()
        return
      }
      this.avPlayerController.videoPlay()
    }
  }

  build() {
    Stack() {
      Image(this.imageSrc.imageUrl)
        .objectFit(ImageFit.Contain)
        .id(`preview+${this.params.snapshotId(this.imageSrc.imageUrl, this.index)}`)
        .onComplete((event) => {
          if (event) {
            this.vm.init(event.contentWidth, event.contentHeight)
            let aspectRatio = this.getUIContext().px2vp(event.contentWidth) / event.width
            /**
             * 图片解码成功，保存组件相关信息
             * 触发一镜到底渲染效果
             * */
            this.longTakeEffectMap.set(this.index, {
              width: event.width * aspectRatio,
              height: event.height * aspectRatio,
              contentOffsetY: event.contentOffsetY,
              contentOffsetX: event.contentOffsetX,
            })
            this.onLoadingStatus(event.loadingStatus, this.index)
            this.loadingStatus = event.loadingStatus
          }
        })
      Row() {
        if (PreviewUtils.isMovingPhotoFromSandbox(this.imageSrc)) {
          /**
           * 处理沙箱动图
           * */
          MovingPhotoView({
            movingPhoto: this.movingPhotoVM.movingPhoto,
            controller: this.controller,
          })
            .objectFit(ImageFit.Contain)
            .scale({ x: this.vm.curScale, y: this.vm.curScale, z: 1 })
            .translate({ x: this.vm.offsetX, y: this.vm.offsetY, z: 0 })
            .draggable(this.vm.imgDraggable)
            .animation({ duration: 100 })
            .onStart(() => {
              this.params.onStartListener(this.imageSrc, this.startIndex)
            })
            .onPause(() => {
              this.params.onPauseListener(this.imageSrc, this.startIndex)
            })
            .onFinish(() => {
              this.params.onFinishListener(this.imageSrc, this.startIndex)
            })
            .onStop(() => {
              this.params.onStopListener(this.imageSrc, this.startIndex)
            })
            .onPrepared(() => {
              this.isPrepared = true
              this.params.onPreparedListener(this.imageSrc, this.startIndex)
            })
            .gesture(
              GestureGroup(GestureMode.Exclusive,
                TapGesture({ count: 2 }).onAction((event) => this.vm.doubleClick(event.fingerList)),
              ),
            )
        } else {
          /**
           * 处理云侧动图
           * */
          MovingPhotoXComp({
            avPlayerController: this.avPlayerController,
            params: this.params,
            loadingStatus: this.loadingStatus,
            index: this.index,
            imageSrc: this.imageSrc,
            startIndex: this.startIndex,
            longTakeEffectMap: this.longTakeEffectMap,
            onPrepared: () => {
              this.isPrepared = true
            },
          })
            .scale({ x: this.vm.curScale, y: this.vm.curScale, z: 1 })
            .translate({ x: this.vm.offsetX, y: this.vm.offsetY, z: 0 })
            .draggable(this.vm.imgDraggable)
            .animation({ duration: 100 })
        }
      }
      .width(PreviewConstants.FULL_SIZE)
      .height(PreviewConstants.FULL_SIZE)
      .justifyContent(FlexAlign.Center)
      .id(`image_preview_comp_${this.uniId}`)
      .onTouch((event) => {
        this.vm.handleTouchEvent(event)
      })
      .gesture(
        GestureGroup(GestureMode.Exclusive,
          // 双击
          TapGesture({ count: 2 }).onAction((event) => {
            this.vm.doubleClick(event.fingerList)
          }),
          // 单击
          TapGesture().onAction(() => {
            this.vm.singleClick('img')
          }),
          // 长按
          LongPressGesture().onAction(() => {
            this.params.onLongPressListener && this.params.onLongPressListener(this.index)
          }),
          // 缩放
          PinchGesture({ fingers: 2 })
            .onActionStart(() => this.vm.onActionStart())
            .onActionUpdate((event: GestureEvent) => this.vm.onActionUpdate(event))
            .onActionEnd(() => this.vm.onActionEnd()),
        ),
      )

      SymbolGlyph($r('sys.symbol.livephoto'))
        .fontColor([$r('sys.color.font_on_primary')])
        .fontWeight(FontWeight.Normal)
        .fontSize(20)
        .position({ left: 16, bottom: 90 })
    }
  }
}