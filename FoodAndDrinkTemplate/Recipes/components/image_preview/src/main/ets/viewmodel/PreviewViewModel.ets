import { display } from '@kit.ArkUI'
import { UtilLog } from '@hw-agconnect/util-log'
import { ImagePreviewOptions } from '../models/ImagePreviewOptions'
import { CenterLocation, ScaleImageInfo, ThumbnailSize } from '../models/PreviewModel'
import { PromptActionTool } from '../utils/PromptActionTool'
import { PreviewUtils } from '../utils/Utils'

const TAG = '[PreviewViewModel]'

@ObservedV2
export class PreviewViewModel {
  uiContext: UIContext
  /**
   * 预览配置参数
   * */
  @Trace params: ImagePreviewOptions = new ImagePreviewOptions()
  /**
   * 图片相关参数
   * url 图片地址
   * index 当前预览索引
   * uniId 安全数ID
   * rootWidth 尺寸容器宽度vp
   * rootHeight 尺寸容器高度vp
   * imgWidth 图片宽度vp
   * imgHeight 图片高度vp
   * */
  @Trace url: string = ''
  @Trace index: number = 0
  @Trace uniId: number = 0
  @Trace rootWidth: number = 0
  @Trace rootHeight: number = 0
  @Trace imgWidth: number = 0
  @Trace imgHeight: number = 0
  /**
   * 图片手势相关参数
   * curScale 缩放大小
   * pinchValue 缩放大小
   * offsetX x轴偏移量
   * offsetY y轴偏移量
   * startX x轴初始偏移量
   * startY y轴初始偏移量
   * offsetMaxX x轴最大偏移量
   * offsetMaxY y轴最大偏移量
   * imageRatio 图片宽高比
   * isLongImage 是否长图
   * imgDraggable 图片是否可拖动
   * isMoving 图片拖动状态
   * fixedThumbnailWidthPx 缩略图固定px
   * fixedThumbnailWidthVp 缩略图固定vp
   * */
  @Trace curScale: number = 1
  @Trace pinchValue: number = 1
  @Trace offsetX: number = 0
  @Trace offsetY: number = 0
  @Trace startX: number = 0
  @Trace startY: number = 0
  @Trace curX: number = 0
  @Trace curY: number = 0
  @Trace offsetMaxX: number = 0
  @Trace offsetMaxY: number = 0
  @Trace imageRatio: number = 0
  @Trace isLongImage: boolean = false
  @Trace imgDraggable: boolean = false
  @Trace isMoving: boolean = false
  @Trace fImageRatio: number = 0
  @Trace thumbnailWidth: number = 182
  private isImageMoved: boolean = false
  private isFingerMove: boolean = false
  private lastCenter: CenterLocation = { x: 0, y: 0 }
  private longImageRatio: number = 2.6
  private fixedThumbnailWidthVp = 56
  /**
   * 滑动惯性相关属性
   * lastTouchTime 上次触摸时间
   * lastTouchX 上次触摸X位置
   * lastTouchY 上次触摸Y位置
   * velocityX X方向速度
   * velocityY Y方向速度
   * minVelocity 最小滑动速度阈值
   * maxInertiaDistance 最大惯性滑动距离
   * */
  private lastTouchTime: number = 0
  private lastTouchX: number = 0
  private lastTouchY: number = 0
  private velocityX: number = 0
  private velocityY: number = 0
  minVelocity: number = 5
  maxInertiaDistance: number = 200
  /**
   * 图片缩放相关状态
   * lastOffsetX 记录最后一次x轴偏移量
   * lastOffsetY 记录最后一次y轴偏移量
   * originalImageWidth 原始图片宽度
   * originalImageHeight 原始图片高度
   * */
  @Trace lastOffsetX: number = 0
  @Trace lastOffsetY: number = 0
  @Trace isDragging: boolean = false
  @Trace originalImageWidth: number = 0
  @Trace originalImageHeight: number = 0
  /**
   * 惯性滑动相关
   * friction 摩擦系数
   * frameRate 帧率
   * */
  private friction: number = 0.98
  private frameRate: number = 60
  /**
   * 屏幕尺寸和图片信息
   * screenWidth 屏幕宽度
   * screenHeight 屏幕高度
   * */
  @Trace screenWidth: number = 0
  @Trace screenHeight: number = 0
  /**
   * 蒙层相关状态
   * thumbnailBoxX 蒙层x轴偏移量
   * thumbnailBoxY 蒙层y轴偏移量
   * thumbnailBoxWidth 蒙层高度
   * thumbnailBoxHeight 蒙层高度
   * */
  @Trace thumbnailBoxX: number = 0
  @Trace thumbnailBoxY: number = 0
  @Trace thumbnailBoxWidth: number = 0
  @Trace thumbnailBoxHeight: number = 0
  /**
   * 缩略图相关状态
   * showThumbnail 是否显示缩略图
   * thumbnailImageWidth 缩略图高度
   * thumbnailImageHeight 缩略图宽度
   * thumbnailOffsetX 缩略图x轴偏移量
   * thumbnailOffsetY 缩略图y轴偏移量
   * */
  @Trace showThumbnail: boolean = false
  @Trace thumbnailImageWidth: number = 0
  @Trace thumbnailImageHeight: number = 0
  @Trace thumbnailOffsetX: number = 0
  @Trace thumbnailOffsetY: number = 0
  /**
   * 边界状态记录
   * isLeftEdgeReached 左侧边界
   * isRightEdgeReached 右侧边界
   * isTopEdgeReached 上边界
   * isBottomEdgeReached 下边界
   * */
  @Trace isLeftEdgeReached: boolean = false
  @Trace isRightEdgeReached: boolean = false
  @Trace isTopEdgeReached: boolean = false
  @Trace isBottomEdgeReached: boolean = false
  /**
   * 缩略图拖拽相关
   * isDraggingThumbnailBox 缩略图拖拽状态
   * lastThumbnailBoxX 最后一次x轴偏移量
   * lastThumbnailBoxY 最后一次y轴偏移量
   * */
  @Trace isDraggingThumbnailBox: boolean = false
  @Trace lastThumbnailBoxX: number = 0
  @Trace lastThumbnailBoxY: number = 0
  /**
   * 缩略图惯性滑动相关
   * */
  @Trace isThumbnailInertialScrolling: boolean = false
  @Trace thumbnailVelocityX: number = 0
  @Trace thumbnailVelocityY: number = 0
  @Trace lastThumbnailTouchTime: number = 0
  @Trace lastThumbnailTouchX: number = 0
  @Trace lastThumbnailTouchY: number = 0
  /**
   * 缩略图参数
   * */
  @Trace thumbnailBorderWidth: number = 2
  @Trace timer: number = -1
  marginRight: number = 16
  marginBottom: number = 56
  /**
   * 蒙层属性相关
   * */
  overlayColor: Color = Color.Gray
  overlayOpacity: number = 0.6
  onDisabledSwiper: (val: boolean) => void = () => {
  }
  /**
   * 缩略图比例相关
   * */
  superVerticalRatio: number = 10
  horizontalRatio: number = 0.5
  superVerticalPadding: number = 64
  horizontalPadding: number = 32
  thumbnailMargin: number = 16
  /**
   * 动画相关
   * */
  duration: number = 500

  /**
   * 画中画显示逻辑
   * 竖图宽高比大于3.0，则显示画中画
   * 横图宽高比大于0.5，则显示画中画
   * */
  @Computed
  get isShowImagePip() {
    return this.showThumbnail && (this.imageRatio > 1.5 || this.imageRatio < 0.5)
  }


  constructor(uiContext: UIContext) {
    this.uiContext = uiContext
  }

  /**
   * 保存全局参数
   * */
  setOptions(params: ImagePreviewOptions) {
    this.params = params
  }

  /**
   * 保存组件id随机数
   * */
  setUniId(uniId: number) {
    this.uniId = uniId
  }

  /**
   * 保存当前索引值
   * */
  setCurrentIndex(startIndex: number) {
    this.index = startIndex
  }

  /**
   * 保存滑动事件回调
   * */
  setEvent(onDisabledSwiper: (val: boolean) => void) {
    this.onDisabledSwiper = onDisabledSwiper
  }

  /**
   * 检查当前边界状态
   * */
  checkEdgeStatus() {
    // 直接使用图片的实际宽高，不基于屏幕宽高比
    const imageWidth = this.imgWidth
    const imageHeight = this.imgHeight

    const scaledWidth = imageWidth * this.curScale
    const scaledHeight = imageHeight * this.curScale

    const maxOffsetX = Math.max(0, (scaledWidth - this.rootWidth) / 2)
    const maxOffsetY = Math.max(0, (scaledHeight - this.rootHeight) / 2)

    if (maxOffsetX === 0 && maxOffsetY === 0) {
      this.isLeftEdgeReached = false
      this.isRightEdgeReached = false
      this.isTopEdgeReached = false
      this.isBottomEdgeReached = false
      return
    }

    const tolerance = 0.5
    this.isLeftEdgeReached = Math.abs(this.offsetX + maxOffsetX) <= tolerance
    this.isRightEdgeReached = Math.abs(this.offsetX - maxOffsetX) <= tolerance
    this.isTopEdgeReached = Math.abs(this.offsetY + maxOffsetY) <= tolerance
    this.isBottomEdgeReached = Math.abs(this.offsetY - maxOffsetY) <= tolerance
  }


  // 限制拖拽边界
  private limitOffset() {
    // 直接使用图片的实际宽高，不基于屏幕宽高比
    const imageWidth = this.imgWidth
    const imageHeight = this.imgHeight

    const scaledWidth = imageWidth * this.curScale
    const scaledHeight = imageHeight * this.curScale

    const maxOffsetX = Math.max(0, (scaledWidth - this.rootWidth) / 2)
    const maxOffsetY = Math.max(0, (scaledHeight - this.rootHeight) / 2)

    if (maxOffsetX === 0 && maxOffsetY === 0) {
      return
    }

    // X轴边界限制
    if (this.offsetX > maxOffsetX) {
      this.offsetX = maxOffsetX
      this.velocityX = 0
    } else if (this.offsetX < -maxOffsetX) {
      this.offsetX = -maxOffsetX
      this.velocityX = 0
    }

    // Y轴边界限制
    if (this.offsetY > maxOffsetY) {
      this.offsetY = maxOffsetY
      this.velocityY = 0
    } else if (this.offsetY < -maxOffsetY) {
      this.offsetY = -maxOffsetY
      this.velocityY = 0
    }
  }

  /**
   * 更新缩略图框的位置和大小
   * */
  public updateThumbnailBox() {
    if (this.isDraggingThumbnailBox) {
      return
    }

    // 直接使用图片的实际宽高，不基于屏幕宽高比
    const imageWidth = this.imgWidth
    const imageHeight = this.imgHeight

    const scaledWidth = imageWidth * this.curScale
    const scaledHeight = imageHeight * this.curScale

    // 使用 rootWidth 和 rootHeight 作为容器尺寸
    const containerWidth = this.rootWidth
    const containerHeight = this.rootHeight

    // 计算当前显示区域在缩放后图片中的位置
    const screenLeftInScaledImage = -this.offsetX - containerWidth / 2
    const screenTopInScaledImage = -this.offsetY - containerHeight / 2
    const screenRightInScaledImage = screenLeftInScaledImage + containerWidth
    const screenBottomInScaledImage = screenTopInScaledImage + containerHeight

    // 转换为原始图片坐标系
    const leftInOriginal = (screenLeftInScaledImage + scaledWidth / 2) / this.curScale
    const topInOriginal = (screenTopInScaledImage + scaledHeight / 2) / this.curScale
    const rightInOriginal = (screenRightInScaledImage + scaledWidth / 2) / this.curScale
    const bottomInOriginal = (screenBottomInScaledImage + scaledHeight / 2) / this.curScale

    // 计算相对于原始图片的比例
    const leftRatio = Math.max(0, Math.min(leftInOriginal / imageWidth, 1))
    const topRatio = Math.max(0, Math.min(topInOriginal / imageHeight, 1))
    const rightRatio = Math.max(0, Math.min(rightInOriginal / imageWidth, 1))
    const bottomRatio = Math.max(0, Math.min(bottomInOriginal / imageHeight, 1))

    // 计算指示框在缩略图上的大小和位置
    let boxWidth: number
    let boxHeight: number
    let boxLeft: number
    let boxTop: number

    /**
     * 初始化状态处理
     * 当缩放比例为1时，指示框应覆盖整个显示区域
     * */
    if (this.curScale <= 1.0) {
      /**
       * 原图状态
       * 指示框应覆盖整个缩略图
       * */
      boxWidth = this.thumbnailImageWidth
      boxHeight = this.thumbnailImageHeight
      boxLeft = 0
      boxTop = 0
    } else {
      /**
       * 缩放状态
       * 根据显示区域计算指示框位置
       * */
      boxWidth = (rightRatio - leftRatio) * this.thumbnailImageWidth
      boxHeight = (bottomRatio - topRatio) * this.thumbnailImageHeight
      boxLeft = leftRatio * this.thumbnailImageWidth
      boxTop = topRatio * this.thumbnailImageHeight
    }

    // 确保指示框大小合理
    const minBoxSize = 8
    const finalBoxWidth = Math.max(minBoxSize, boxWidth)
    const finalBoxHeight = Math.max(minBoxSize, boxHeight)

    // 确保指示框位置在缩略图范围内
    const minLeft = 0
    const maxLeft = this.thumbnailImageWidth - finalBoxWidth
    const minTop = 0
    const maxTop = this.thumbnailImageHeight - finalBoxHeight

    const finalBoxLeft = Math.max(minLeft, Math.min(boxLeft, maxLeft))
    const finalBoxTop = Math.max(minTop, Math.min(boxTop, maxTop))

    // 更新指示框属性
    this.thumbnailBoxWidth = finalBoxWidth
    this.thumbnailBoxHeight = finalBoxHeight
    this.thumbnailBoxX = finalBoxLeft
    this.thumbnailBoxY = finalBoxTop
    UtilLog.info(TAG,
      `indicator box thumbnailBoxWidth:${this.thumbnailBoxWidth},thumbnailBoxHeight:${this.thumbnailBoxHeight}`)
  }

  /**
   * 根据缩略图指示框位置更新主图位置
   * */
  updateMainImageFromThumbnailBox() {
    /**
     * 移除缩放比例限制，允许在原图状态下也能拖动指示框更新位置
     * 直接使用图片的实际宽高比，不基于屏幕宽高比
     * */
    const imageWidth = this.imgWidth
    const imageHeight = this.imgHeight

    const scaledWidth = imageWidth * this.curScale
    const scaledHeight = imageHeight * this.curScale

    const effectiveBoxX = Math.max(0, Math.min(this.thumbnailBoxX,
      this.thumbnailImageWidth - this.thumbnailBoxWidth))
    const effectiveBoxY = Math.max(0, Math.min(this.thumbnailBoxY,
      this.thumbnailImageHeight - this.thumbnailBoxHeight))

    const boxCenterX = effectiveBoxX + this.thumbnailBoxWidth / 2
    const boxCenterY = effectiveBoxY + this.thumbnailBoxHeight / 2

    const boxCenterXRatio = boxCenterX / this.thumbnailImageWidth
    const boxCenterYRatio = boxCenterY / this.thumbnailImageHeight

    // 计算实际图片中心在缩放后的位置
    const scaledImageCenterX = boxCenterXRatio * scaledWidth - scaledWidth / 2
    const scaledImageCenterY = boxCenterYRatio * scaledHeight - scaledHeight / 2

    const newOffsetX = -scaledImageCenterX
    const newOffsetY = -scaledImageCenterY

    this.offsetX = newOffsetX
    this.offsetY = newOffsetY
    UtilLog.info(TAG, `current offset is x:${this.offsetX},y:${this.offsetY}`)
    this.lastOffsetX = newOffsetX
    this.lastOffsetY = newOffsetY
    this.showThumbnailChange(true)
    this.limitOffset()
  }

  /**
   * 重置位置到中心
   * */
  public resetPosition() {
    this.offsetX = 0
    this.offsetY = 0
    this.lastOffsetX = 0
    this.lastOffsetY = 0
    this.isLeftEdgeReached = false
    this.isRightEdgeReached = false
    this.isTopEdgeReached = false
    this.isBottomEdgeReached = false
  }

  /**
   * 预览初始化
   * */
  init(width: number, height: number) {
    let comInfo = PreviewUtils.getComponentsInfo(this.uiContext, `image_preview_comp_${this.uniId}`)
    if (!comInfo) {
      return
    }
    let rootRatio = comInfo.height / comInfo.width
    this.imgWidth = this.uiContext.px2vp(width)
    this.imgHeight = this.uiContext.px2vp(height)
    this.imageRatio = height / width
    this.rootWidth = comInfo.width
    this.rootHeight = comInfo.height
    this.originalImageWidth = width
    this.originalImageHeight = height
    this.isLongImage = this.imageRatio > rootRatio && this.imageRatio >= this.longImageRatio
    // 确保screenHeight已初始化
    if (this.screenHeight === 0) {
      this.initImagePip()
    }
    this.setParams(1)
    this.calculateThumbnailImageSize()
  }


  public calculateThumbnailImageSize() {
    const thumbnailSize = this.calculateScalingRatio()
    this.thumbnailImageWidth = thumbnailSize.width
    this.thumbnailImageHeight = thumbnailSize.height
    UtilLog.info(TAG,
      `indicator box thumbnailImageWidth:${this.thumbnailImageWidth},thumbnailImageHeight:${this.thumbnailImageHeight}`)
    /**
     * 计算内部缩略图的偏移量
     * 对于内部蒙层和指示框，它们是相对于外部 Stack 容器定位的
     * 因此需要确保它们的偏移量是相对于容器的正确位置
     * 重置偏移量，避免累计错误
     * */
    this.thumbnailOffsetX = 0
    this.thumbnailOffsetY = 0
    // 初始化指示框大小和位置
    this.updateThumbnailBox()
  }

  /**
   * 计算缩放比例
   * */
  calculateScalingRatio(): ThumbnailSize {
    // 缩放之后不超过屏幕宽度，按照56宽度进行缩放
    let originalRatio = this.uiContext.vp2px(this.fixedThumbnailWidthVp) / this.originalImageWidth
    if (this.imageRatio > this.superVerticalRatio) {
      // 竖图处理
      return this.verticalImageHandle(originalRatio)
    } else if (this.imageRatio < this.horizontalRatio) {
      // 横图处理
      return this.horizonImageHandle(originalRatio)
    } else {
      // 普通图处理
      return this.commonImageHandle(originalRatio)
    }
  }

  /**
   * 长竖图处理：固定为不超过屏幕宽度 64的padding值
   * */
  verticalImageHandle(originalRatio: number): ThumbnailSize {
    originalRatio = this.screenHeight / this.originalImageHeight
    let newWidth = Math.floor(this.originalImageWidth * originalRatio)
    this.fImageRatio = newWidth / (this.screenHeight - this.superVerticalPadding)
    return {
      height: this.screenHeight - this.superVerticalPadding,
      width: newWidth,
    }
  }

  /**
   * 超宽横图处理：固定高度，计算宽度
   * 计算合适的缩放比例，保持原始图片比例
   * 固定横图缩略图高度为56
   * 重置偏移量，避免累计错误
   * */
  horizonImageHandle(originalRatio: number): ThumbnailSize {
    const thumbnailHeight = this.fixedThumbnailWidthVp
    originalRatio = thumbnailHeight / this.originalImageHeight
    // 计算缩略图宽度
    const newWidth = Math.floor(this.originalImageWidth * originalRatio)
    const thumbnailWidth = newWidth
    this.fImageRatio = thumbnailWidth / thumbnailHeight
    if (thumbnailWidth >= this.screenWidth) {
      return this.horizontalCalculateScalingRatio()
    }
    return {
      height: thumbnailHeight,
      width: thumbnailWidth,
    }
  }

  /**
   * 普通图处理
   * 固定宽度为56，计算高度
   * */
  commonImageHandle(originalRatio: number): ThumbnailSize {
    this.fImageRatio =
      this.fixedThumbnailWidthVp / Math.floor(this.uiContext.px2vp(this.originalImageHeight) * originalRatio)
    return {
      height: Math.floor(this.uiContext.px2vp(this.originalImageHeight) * originalRatio),
      width: this.fixedThumbnailWidthVp,
    }
  }

  /**
   * 超长横图如果缩小后宽度超过屏幕宽度，则等比例缩小
   * */
  horizontalCalculateScalingRatio(): ThumbnailSize {
    let originalRatio = this.screenWidth / this.originalImageWidth
    let newHeight = Math.floor(this.originalImageHeight * originalRatio)
    this.fImageRatio = newHeight / (this.screenWidth - this.horizontalPadding)
    return {
      height: newHeight,
      width: this.screenWidth - this.horizontalPadding,
    }
  }

  /**
   * 触摸中心点
   * */
  getCenter(fingers: FingerInfo[]): CenterLocation {
    return {
      x: (fingers[0].localX + fingers[1].localX) / 2,
      y: (fingers[0].localY + fingers[1].localY) / 2,
    }
  }

  /**
   * x轴最大偏移量
   * */
  getMaxMoveX() {
    if (this.imageRatio) {
      const scaledWidth = this.imgWidth * this.curScale
      return Math.max(0, (scaledWidth - this.rootWidth) / 2)
    }
    return 0
  }

  /**
   * y轴最大偏移量
   * */
  getMaxMoveY() {
    if (this.imageRatio) {
      const scaledHeight = this.imgHeight * this.curScale
      return Math.max(0, (scaledHeight - this.rootHeight) / 2)
    }
    return 0
  }

  /**
   * 获取缩放后图片信息
   * */
  getScaleImageInfo(): ScaleImageInfo {
    let scaleWidth = this.imgWidth * this.curScale
    let scaleHeight = this.imgHeight * this.curScale
    return {
      width: scaleWidth,
      height: scaleHeight,
      localLeft: (this.rootWidth - scaleWidth) / 2,
      localTop: (this.rootHeight - scaleHeight) / 2,
    }
  }

  /**
   * 惯性滑动方法
   * */
  private inertiaSlide() {
    // 检查速度是否超过阈值
    if (Math.abs(this.velocityX) < this.minVelocity && Math.abs(this.velocityY) < this.minVelocity) {
      return
    }

    // 计算惯性滑动距离
    let inertiaDistanceX = this.velocityX * 10
    let inertiaDistanceY = this.velocityY * 10

    // 限制最大惯性滑动距离
    inertiaDistanceX = PreviewUtils.clamp(inertiaDistanceX, -this.maxInertiaDistance, this.maxInertiaDistance)
    inertiaDistanceY = PreviewUtils.clamp(inertiaDistanceY, -this.maxInertiaDistance, this.maxInertiaDistance)

    // 计算目标位置
    const targetOffsetX = this.offsetX + inertiaDistanceX
    const targetOffsetY = this.offsetY + inertiaDistanceY

    // 限制在边界内
    const finalTargetX = PreviewUtils.clamp(targetOffsetX, -this.offsetMaxX, this.offsetMaxX)
    const finalTargetY = PreviewUtils.clamp(targetOffsetY, -this.offsetMaxY, this.offsetMaxY)

    // 如果目标位置和当前位置相同，不需要动画
    if (finalTargetX === this.offsetX && finalTargetY === this.offsetY) {
      return
    }

    this.uiContext.animateTo({
      duration: this.duration,
      curve: Curve.Ease,
      onFinish: () => {
        this.velocityX = 0
        this.velocityY = 0
      },
    }, () => {
      this.offsetX = finalTargetX
      this.offsetY = finalTargetY
      this.updateThumbnailBox()
    })
  }

  /**
   * 单击
   * @param type 'img'
   * */
  singleClick(type: 'img') {
    if (this.isFingerMove) {
      return
    }
    if (type === 'img') {
      !this.params.closeOnClickImage && this.params.onImgClickListener && this.params.onImgClickListener(this.index)
      this.params.closeOnClickImage && PromptActionTool.closePreview()
    }
  }

  /**
   * 双击
   * @param fingers
   * */
  doubleClick(fingers: FingerInfo[]) {
    if (this.isFingerMove) {
      return
    }
    if (this.params.doubleScale) {
      let scale = this.curScale === 1 ? 2 : 1
      this.setParams(scale,
        scale === 2 || this.isLongImage ? { x: fingers[0].localX, y: fingers[0].localY } : undefined)
    } else {
      this.params.closeOnClickImage && this.params?.onBackListener?.()
    }
    this.uiContext.animateTo({
      duration: this.duration,
      curve: Curve.Ease,
    }, () => {
      this.updateThumbnailBox()
    })
  }

  /**
   * 手指移动
   * @param event
   * */
  handleTouchEvent(event: TouchEvent) {
    const currentTime = Date.now()
    const currentX = event.touches[0].x
    const currentY = event.touches[0].y

    switch (event.type) {
      case TouchType.Down:
        this.isMoving = this.curScale !== 1 || this.isLongImage
        this.startX = currentX
        this.startY = currentY
        this.curX = this.offsetX
        this.curY = this.offsetY
        this.isImageMoved = false
        this.isFingerMove = false
        // 初始化触摸信息
        this.lastTouchTime = currentTime
        this.lastTouchX = currentX
        this.lastTouchY = currentY
        this.velocityX = 0
        this.velocityY = 0
        break
      case TouchType.Move:
        /**
         * 计算时间差
         * 转换为每帧速度
         * */
        const deltaTime = currentTime - this.lastTouchTime
        if (deltaTime > 0) {
          // 计算位置差和速度
          this.velocityX = (currentX - this.lastTouchX) / deltaTime * 16
          this.velocityY = (currentY - this.lastTouchY) / deltaTime * 16
          // 更新触摸信息
          this.lastTouchTime = currentTime
          this.lastTouchX = currentX
          this.lastTouchY = currentY
        }

        let x = currentX - this.startX
        let y = currentY - this.startY
        this.isFingerMove = x !== 0 || y !== 0
        let offsetX = this.curX + x
        let offsetY = this.curY + y
        let isDisabled = Math.abs(offsetX) <= this.offsetMaxX
        this.onDisabledSwiper(isDisabled)
        if (this.isMoving) {
          this.isImageMoved = true
          this.offsetX = PreviewUtils.clamp(offsetX, -this.offsetMaxX, this.offsetMaxX)
          this.offsetY = PreviewUtils.clamp(offsetY, -this.offsetMaxY, this.offsetMaxY)
          if (this.offsetX || this.offsetY) {
            this.updateThumbnailBox()
            this.showThumbnailChange(true)
          }
        }
        break
      case TouchType.Up:
        this.isMoving = false
        // 触发惯性滑动
        if (this.isImageMoved) {
          this.inertiaSlide()
        }
        break
    }
  }

  /**
   * 设置缩放参数
   * @param scale
   * @param lastCenter
   * */
  setParams(scale: number, lastCenter?: CenterLocation) {
    scale = PreviewUtils.clamp(scale, +(this.params.minScale as number), +(this.params.maxScale as number) + 1)
    if (scale !== this.curScale) {
      const oldScale = this.curScale
      const ratio = scale / oldScale
      // 更新缩放比例
      this.curScale = scale
      // 更新最大偏移量
      this.offsetMaxX = this.getMaxMoveX()
      this.offsetMaxY = this.getMaxMoveY()
      // 获取原始缩放比例下的图片信息
      const oldImgInfo: ScaleImageInfo = {
        width: this.imgWidth * oldScale,
        height: this.imgHeight * oldScale,
        localLeft: (this.rootWidth - this.imgWidth * oldScale) / 2,
        localTop: (this.rootHeight - this.imgHeight * oldScale) / 2,
      }

      if (lastCenter) {
        // 计算缩放中心相对于图片左上角的位置（考虑当前偏移量）
        const centerInImageX = lastCenter.x - (oldImgInfo.localLeft + this.offsetX)
        const centerInImageY = lastCenter.y - (oldImgInfo.localTop + this.offsetY)

        // 计算缩放后图片的位置
        const newImgLeft = (this.rootWidth - this.imgWidth * this.curScale) / 2
        const newImgTop = (this.rootHeight - this.imgHeight * this.curScale) / 2

        // 计算缩放后，中心点应该在的位置
        const newOffsetX = lastCenter.x - (newImgLeft + centerInImageX * ratio)
        const newOffsetY = lastCenter.y - (newImgTop + centerInImageY * ratio)

        // 限制在边界内
        this.offsetX = PreviewUtils.clamp(newOffsetX, -this.offsetMaxX, this.offsetMaxX)
        this.offsetY = PreviewUtils.clamp(newOffsetY, -this.offsetMaxY, this.offsetMaxY)
      } else {
        this.offsetX = 0
        this.offsetY = 0
      }
      UtilLog.info(TAG,
        `setParams offset offsetX:${this.offsetX},offsetY:${this.offsetY}`)
      this.params?.onImgScaleListener?.(this.index, this.curScale)
    }
  }

  /**
   * 启动缩略图惯性滑动
   * */
  startThumbnailInertialScroll() {
    if (this.isThumbnailInertialScrolling) {
      return
    }

    this.isThumbnailInertialScrolling = true
    this.performThumbnailInertialScroll()
  }

  /**
   * 执行缩略图惯性滑动动画
   * */
  performThumbnailInertialScroll() {
    if (!this.isThumbnailInertialScrolling ||
      (Math.abs(this.thumbnailVelocityX) < this.minVelocity &&
        Math.abs(this.thumbnailVelocityY) < this.minVelocity)) {
      this.isThumbnailInertialScrolling = false
      this.thumbnailVelocityX = 0
      this.thumbnailVelocityY = 0
      return
    }

    // 应用摩擦系数
    this.thumbnailVelocityX *= this.friction
    this.thumbnailVelocityY *= this.friction

    // 计算新位置
    const deltaX = this.thumbnailVelocityX * (1000 / this.frameRate)
    const deltaY = this.thumbnailVelocityY * (1000 / this.frameRate)

    let newBoxX = this.thumbnailBoxX + deltaX
    let newBoxY = this.thumbnailBoxY + deltaY

    // 限制边界
    const minX = 0
    const maxX = this.thumbnailImageWidth - this.thumbnailBoxWidth
    const minY = 0
    const maxY = this.thumbnailImageHeight - this.thumbnailBoxHeight

    newBoxX = Math.max(minX, Math.min(newBoxX, maxX))
    newBoxY = Math.max(minY, Math.min(newBoxY, maxY))

    // 如果到达边界，停止该方向的惯性
    if (newBoxX <= minX || newBoxX >= maxX) {
      this.thumbnailVelocityX = 0
    }
    if (newBoxY <= minY || newBoxY >= maxY) {
      this.thumbnailVelocityY = 0
    }

    // 更新位置
    this.thumbnailBoxX = newBoxX
    this.thumbnailBoxY = newBoxY

    // 更新主图
    this.updateMainImageFromThumbnailBox()

    // 继续下一帧
    setTimeout(() => {
      this.performThumbnailInertialScroll()
    }, 1000 / this.frameRate)
  }

  /**
   * 停止缩略图惯性滑动
   * */
  stopThumbnailInertialScroll() {
    this.isThumbnailInertialScrolling = false
    this.thumbnailVelocityX = 0
    this.thumbnailVelocityY = 0
  }

  /**
   * 滑动开始
   * */
  onActionStart() {
    this.pinchValue = this.curScale
  }

  /**
   * 滑动过程
   * @param event
   * */
  onActionUpdate(event: GestureEvent) {
    let scale = Number((this.pinchValue * event.scale).toFixed(1))
    let lastCenter = this.getCenter(event.fingerList)
    this.lastCenter = lastCenter
    this.isMoving = false
    this.onDisabledSwiper(true)
    this.setParams(scale, lastCenter)
    if (this.curScale <= 1.0) {
      this.resetPosition()
      this.showThumbnailChange(false)
    } else {
      this.updateThumbnailBox()
      this.showThumbnailChange(true)
    }
  }

  /**
   * 滑动结束
   * */
  onActionEnd() {
    const maxZoom = +(this.params.maxScale as number)
    if (this.curScale > maxZoom) {
      this.setParams(maxZoom, this.lastCenter)
    }
    this.pinchValue = Math.min(this.curScale, maxZoom)
    if (this.curScale < 1.0) {
      this.curScale = 1.0
      this.resetPosition()
      this.showThumbnailChange(false)
    }
  }

  /**
   * 更新缩略图显示状态
   * */
  showThumbnailChange(val: boolean) {
    this.uiContext.animateTo({
      duration: this.duration,
      curve: Curve.Ease,
    }, () => {
      this.showThumbnail = val
      this.resetThumbnailTimer()
    })
  }

  private resetThumbnailTimer() {
    if (this.timer !== -1) {
      clearTimeout(this.timer);
    }
    this.timer = setTimeout(() => {
      this.uiContext.animateTo({
        duration: this.duration,
        curve: Curve.Ease,
      }, () => {
        this.showThumbnail = false
      })
    }, 3000);
  }


  /**
   * 缩略图初始化
   * */
  initImagePip() {
    const displayClass = display.getDefaultDisplaySync()
    this.screenWidth = this.uiContext.px2vp(displayClass.width)
    this.screenHeight = this.uiContext.px2vp(displayClass.height)
  }
}