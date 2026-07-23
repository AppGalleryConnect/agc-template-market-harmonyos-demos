import { PreviewImgType } from '../models/PreviewModel'
import { PreviewViewModel } from '../viewmodel/PreviewViewModel'


@ComponentV2
export struct ImagePreviewPip {
  @Param @Require imageUrl: PreviewImgType
  @Param @Require viewModel: PreviewViewModel

  aboutToAppear(): void {
    this.viewModel.initImagePip()
  }

  build() {
    Stack() {
      // 缩略图
      Image(this.imageUrl)
        .width(this.viewModel.thumbnailImageWidth)
        .height(this.viewModel.thumbnailImageHeight)
        .objectFit(ImageFit.Contain)
        .interpolation(ImageInterpolation.Low)

      // 蒙层容器
      Stack() {
        // 顶部蒙层
        if (this.viewModel.thumbnailBoxY > 0) {
          Column()
            .width(this.viewModel.thumbnailImageWidth)
            .height(this.viewModel.thumbnailBoxY)
            .backgroundColor(this.viewModel.overlayColor)
            .opacity(this.viewModel.overlayOpacity)
            .position({
              x: 0,
              y: 0,
            })
        }

        // 底部蒙层
        if (this.viewModel.thumbnailBoxY + this.viewModel.thumbnailBoxHeight < this.viewModel.thumbnailImageHeight) {
          Column()
            .width(this.viewModel.thumbnailImageWidth)
            .height(this.viewModel.thumbnailImageHeight -
              (this.viewModel.thumbnailBoxY + this.viewModel.thumbnailBoxHeight))
            .backgroundColor(this.viewModel.overlayColor)
            .opacity(this.viewModel.overlayOpacity)
            .position({
              x: 0,
              y: this.viewModel.thumbnailBoxY + this.viewModel.thumbnailBoxHeight,
            })
        }

        // 蒙层
        if (this.viewModel.thumbnailBoxX > 0) {
          Column()
            .width(this.viewModel.thumbnailBoxX)
            .height(this.viewModel.thumbnailBoxHeight)
            .backgroundColor(this.viewModel.overlayColor)
            .opacity(this.viewModel.overlayOpacity)
            .position({
              x: 0,
              y: this.viewModel.thumbnailBoxY,
            })
        }

        // 蒙层
        if (this.viewModel.thumbnailBoxX + this.viewModel.thumbnailBoxWidth < this.viewModel.thumbnailImageWidth) {
          Column()
            .width(this.viewModel.thumbnailImageWidth -
              (this.viewModel.thumbnailBoxX + this.viewModel.thumbnailBoxWidth))
            .height(this.viewModel.thumbnailBoxHeight)
            .backgroundColor(this.viewModel.overlayColor)
            .opacity(this.viewModel.overlayOpacity)
            .position({
              x: this.viewModel.thumbnailBoxX + this.viewModel.thumbnailBoxWidth,
              y: this.viewModel.thumbnailBoxY,
            })
        }
      }
      .width(this.viewModel.thumbnailImageWidth)
      .height(this.viewModel.thumbnailImageHeight)
      // 移除蒙层容器的额外偏移，直接相对于外部容器定位
      .position({
        x: 0,
        y: 0,
      })

      // 白色边框
      Column()
        .width(this.viewModel.thumbnailBoxWidth)
        .height(this.viewModel.thumbnailBoxHeight)
        .border({
          width: this.viewModel.thumbnailBorderWidth,
          color: Color.White,
          style: BorderStyle.Solid,
        })
        .borderRadius(3)
        .backgroundColor(Color.Transparent)
        .position({
          x: this.viewModel.thumbnailBoxX,
          y: this.viewModel.thumbnailBoxY,
        })
        .gesture(
          PanGesture()
            .onActionStart(() => {
              this.viewModel.isDraggingThumbnailBox = true
              this.viewModel.lastThumbnailBoxX = this.viewModel.thumbnailBoxX
              this.viewModel.lastThumbnailBoxY = this.viewModel.thumbnailBoxY
              this.viewModel.stopThumbnailInertialScroll()
              this.viewModel.lastThumbnailTouchTime = Date.now()
              this.viewModel.lastThumbnailTouchX = this.viewModel.thumbnailBoxX
              this.viewModel.lastThumbnailTouchY = this.viewModel.thumbnailBoxY
            })
            .onActionUpdate((event: GestureEvent) => {
              if (this.viewModel.isDraggingThumbnailBox) {
                const currentTime = Date.now()
                const deltaTime = currentTime - this.viewModel.lastThumbnailTouchTime

                // 计算速度
                if (deltaTime > 0) {
                  this.viewModel.thumbnailVelocityX =
                    ((this.viewModel.lastThumbnailBoxX + event.offsetX) - this.viewModel.lastThumbnailTouchX) /
                      deltaTime
                  this.viewModel.thumbnailVelocityY =
                    ((this.viewModel.lastThumbnailBoxY + event.offsetY) - this.viewModel.lastThumbnailTouchY) /
                      deltaTime
                }

                this.viewModel.lastThumbnailTouchTime = currentTime
                this.viewModel.lastThumbnailTouchX = this.viewModel.lastThumbnailBoxX + event.offsetX
                this.viewModel.lastThumbnailTouchY = this.viewModel.lastThumbnailBoxY + event.offsetY

                // 计算新的红框位置
                let newBoxX = this.viewModel.lastThumbnailBoxX + event.offsetX
                let newBoxY = this.viewModel.lastThumbnailBoxY + event.offsetY

                // 限制红框在缩略图图片范围内移动
                const minX = 0
                const maxX = this.viewModel.thumbnailImageWidth - this.viewModel.thumbnailBoxWidth
                const minY = 0
                const maxY = this.viewModel.thumbnailImageHeight - this.viewModel.thumbnailBoxHeight

                newBoxX = Math.max(minX, Math.min(newBoxX, maxX))
                newBoxY = Math.max(minY, Math.min(newBoxY, maxY))

                // 更新红框位置
                this.viewModel.thumbnailBoxX = newBoxX
                this.viewModel.thumbnailBoxY = newBoxY

                // 根据红框位置更新原图位置
                this.viewModel.updateMainImageFromThumbnailBox()
              }
            })
            .onActionEnd(() => {
              this.viewModel.isDraggingThumbnailBox = false
              this.viewModel.lastThumbnailBoxX = this.viewModel.thumbnailBoxX
              this.viewModel.lastThumbnailBoxY = this.viewModel.thumbnailBoxY

              // 启动缩略图惯性滑动
              if (Math.abs(this.viewModel.thumbnailVelocityX) > this.viewModel.minVelocity ||
                Math.abs(this.viewModel.thumbnailVelocityY) > this.viewModel.minVelocity) {
                this.viewModel.startThumbnailInertialScroll()
              }
            }),
        )
    }
    .width(this.viewModel.thumbnailImageWidth)
    .visibility(this.viewModel.isShowImagePip ? Visibility.Visible : Visibility.Hidden)
    .margin({
      right: this.viewModel.imageRatio > 1 ? this.viewModel.marginRight : 0,
      bottom: this.viewModel.imageRatio > 1 ? 0 : this.viewModel.marginBottom,
    })
  }
}