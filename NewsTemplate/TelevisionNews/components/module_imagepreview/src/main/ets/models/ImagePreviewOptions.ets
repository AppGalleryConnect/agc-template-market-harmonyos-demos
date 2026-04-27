import { ImageActionCallback, MovingCallback, PreviewCallback, PreviewCustomBuilder } from '../Interface/Interface'
import { BaseOptions } from './BaseOptions'
import { PreviewImgType, SourceImageModel } from './PreviewModel'


@Observed
export class ImagePreviewOptions extends BaseOptions {
  /**
   * 弹窗ID
   */
  dialogId: string = ''
  /**
   * 是否开启一镜到底效果
   */
  longTake?: boolean = true
  /**
   * 关闭预览标志位
   */
  needDismiss: boolean = false
  /**
   * 关闭预览动画是否开启
   */
  dismissAnimation: boolean = true
  /**
   * 是否显示分页文字
   */
  showPageText: boolean = true
  /**
   * 设置item的id 默认是 model + index
   */
  snapshotId: (item: PreviewImgType, index: number) => string = (item, index) => JSON.stringify(item) + index
  /**
   * 顶部自定义builder
   */
  topBuilder?: () => void
  /**
   * 底部自定义builder
   */
  bottomBuilder?: () => void
  /**
   * 返回回调
   */
  onBackListener: () => void = () => {
  }
  /**
   * 打开回调
   */
  onOpenListener: () => void = () => {
  }
  /**
   * 长按事件回调
   */
  onLongPressListener: (index: number) => void = () => {
  }
  /**
   * 图片点击事件
   */
  onImgClickListener: (index: number) => void = () => {
  }
  /**
   * 图片缩放事件
   */
  onImgScaleListener: (index: number, curScale: number) => void = () => {
  }
  /**
   * page 切换回调
   */
  onPageChangedListener: (item: SourceImageModel, index: number) => void = () => {
  }
  /**
   * 动图播放时触发该事件
   */
  onStartListener: (item: SourceImageModel, index: number) => void = () => {
  }
  /**
   * 动图播放暂停时触发该事件
   */
  onPauseListener: (item: SourceImageModel, index: number) => void = () => {
  }
  /**
   * 动图播放结束时触发该事件
   */
  onFinishListener: (item: SourceImageModel, index: number) => void = () => {
  }
  /**
   * 动图播放停止时触发该事件
   */
  onStopListener: (item: SourceImageModel, index: number) => void = () => {
  }
  /**
   * 动态照片准备播放时触发该事件
   */
  onPreparedListener: (item: SourceImageModel, index: number) => void = () => {
  }
  /**
   * 动图是否自动播放，false状态下手指按压触发播放
   */
  movingPhotoAutoPlay?: boolean = true

  /**
   * 设置组件快照id
   */
  setSnapshotId(snapshotId: (item: PreviewImgType, index: number) => string): ImagePreviewOptions {
    this.snapshotId = snapshotId
    return this
  }

  /**
   * 设置是否显示分页文字
   */
  setShowPageText(showPageText: boolean): ImagePreviewOptions {
    this.showPageText = showPageText
    return this
  }

  /**
   * 是否开启一镜到底效果
   */
  setLongTake(longTake: boolean): ImagePreviewOptions {
    this.longTake = longTake
    return this
  }

  /**
   * 动图是否自动播放，false状态下手指按压触发播放
   */
  setMovingPhotoAutoPlay(movingPhotoAutoPlay: boolean): ImagePreviewOptions {
    this.movingPhotoAutoPlay = movingPhotoAutoPlay
    return this
  }

  /**
   * 关闭预览动画是否开启
   */
  setDismissAnimation(dismissAnimation: boolean): ImagePreviewOptions {
    this.dismissAnimation = dismissAnimation
    return this
  }

  /**
   * 自定义插槽构建
   */
  setCustomBuilder(
    builder: PreviewCustomBuilder,
  ) {
    if (builder.bottomBuilder) {
      this.bottomBuilder = builder.bottomBuilder;
    }
    if (builder.topBuilder) {
      this.topBuilder = builder.topBuilder;
    }
    return this
  }

  /**
   * 动图状态监听回调
   */
  setMovingPhotoListener(
    callbacks: MovingCallback,
  ) {
    if (callbacks.onStart) {
      this.onStartListener = callbacks.onStart;
    }
    if (callbacks.onPause) {
      this.onPauseListener = callbacks.onPause;
    }
    if (callbacks.onFinish) {
      this.onFinishListener = callbacks.onFinish;
    }
    if (callbacks.onStop) {
      this.onStopListener = callbacks.onStop;
    }
    if (callbacks.onPrepared) {
      this.onPreparedListener = callbacks.onPrepared;
    }
    return this;
  }

  /**
   * 图片操作监听回调
   */
  setImageActionListener(
    callbacks: ImageActionCallback,
  ) {
    if (callbacks.onScale) {
      this.onImgScaleListener = callbacks.onScale
    }
    if (callbacks.onClick) {
      this.onImgClickListener = callbacks.onClick;
    }
    if (callbacks.onLongPress) {
      this.onLongPressListener = callbacks.onLongPress;
    }
    if (callbacks.onPageChanged) {
      this.onPageChangedListener = callbacks.onPageChanged;
    }
    return this;
  }

  /**
   * 预览器状态回调
   */
  setPreviewListener(
    callbacks: PreviewCallback,
  ) {
    if (callbacks.onOpen) {
      this.onOpenListener = callbacks.onOpen
    }
    if (callbacks.onBack) {
      this.onBackListener = callbacks.onBack;
    }
    return this;
  }
}