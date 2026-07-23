import { ImageActionCallback, MovingCallback, PreviewCallback, PreviewCustomBuilder } from '../Interface/Interface'
import { BaseOptions } from './BaseOptions'
import { PreviewImgType, SourceImageModel } from './PreviewModel'


@ObservedV2
export class ImagePreviewOptions extends BaseOptions {
  @Trace dialogId: string = ''
  @Trace longTake?: boolean = true
  @Trace needDismiss: boolean = false
  @Trace dismissAnimation: boolean = true
  @Trace showPageText: boolean = true
  snapshotId: (item: PreviewImgType, index: number) => string = (item, index) => JSON.stringify(item) + index
  topBuilder?: () => void
  bottomBuilder?: () => void
  onBackListener: () => void = () => {
  }
  onOpenListener: () => void = () => {
  }
  onLongPressListener: (index: number) => void = () => {
  }
  onImgClickListener: (index: number) => void = () => {
  }
  onImgScaleListener: (index: number, curScale: number) => void = () => {
  }
  onPageChangedListener: (item: SourceImageModel, index: number) => void = () => {
  }
  onStartListener: (item: SourceImageModel, index: number) => void = () => {
  }
  onPauseListener: (item: SourceImageModel, index: number) => void = () => {
  }
  onFinishListener: (item: SourceImageModel, index: number) => void = () => {
  }
  onStopListener: (item: SourceImageModel, index: number) => void = () => {
  }
  onPreparedListener: (item: SourceImageModel, index: number) => void = () => {
  }
  @Trace movingPhotoAutoPlay?: boolean = true
  @Trace showIndicator?: boolean = true

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
   * 是否开启图片指示器
   */
  setShowIndicator(showIndicator: boolean): ImagePreviewOptions {
    this.showIndicator = showIndicator
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