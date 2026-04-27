import { ImagePreviewOptions } from '../models/ImagePreviewOptions'
import { PreviewComponentInfo, PreviewImgType } from '../models/PreviewModel'
import { PreviewViewModel } from '../viewmodel/PreviewViewModel'

@ComponentV2
export struct SwiperImageItem {
  @Param @Require vm: PreviewViewModel
  @Param @Require startIndex: number
  @Param @Require params: ImagePreviewOptions
  @Param @Require imageUrl: PreviewImgType
  @Param @Require index: number
  @Param @Require uniId: number = 0
  @Param longTakeEffectMap: Map<number, PreviewComponentInfo> = new Map()
  @Event onLoadingStatus: (val: number, index: number) => void = () => {
  }
  @Event onDisabledSwiper: (val: boolean) => void = () => {
  }


  build() {
    Stack({ alignContent: Alignment.Center }) {
      Row() {
        Image(this.imageUrl)
          .objectFit(ImageFit.Contain)
          .scale({ x: this.vm.curScale, y: this.vm.curScale, z: 1 })
          .translate({ x: this.vm.offsetX, y: this.vm.offsetY, z: 0 })
          .draggable(this.vm.imgDraggable)
          .animation({ duration: 100, curve: Curve.Linear })
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
            }
          })
          .gesture(
            GestureGroup(GestureMode.Exclusive,
              // 双击
              TapGesture({ count: 2 }).onAction((event) => this.vm.doubleClick(event.fingerList)),
            ),
          )
      }
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
            this.params.onLongPressListener && this.params.onLongPressListener(this.startIndex)
          }),
          // 缩放
          PinchGesture({ fingers: 2 })
            .onActionStart(() => this.vm.onActionStart())
            .onActionUpdate((event: GestureEvent) => this.vm.onActionUpdate(event))
            .onActionEnd(() => this.vm.onActionEnd()),
        ),
      )
    }
  }
}