import { SourceImageModel } from './PreviewModel'

@Observed
export class BaseOptions {
  /**
   * 数据源
   */
  dataList: SourceImageModel[] = []
  /**
   * 是否循环
   */
  loop?: boolean = false
  /**
   * 设置是否可以通过系统返回关闭preview 默认 true
   */
  dismissOnSystemBack: boolean = true
  /**
   * 弹窗显示层级模式
   */
  levelMode?: LevelMode
  /**
   * 对话框需要显示的层级下的节点uniqueId
   */
  levelUniqueId?: number | string
  /**
   * 设置页面内对话框蒙层效果
   */
  immersiveMode?: ImmersiveMode
  /**
   * 初始化index
   */
  startIndex: number = 0
  /**
   * 最小缩放比例
   */
  minScale: number = 1
  /**
   * 最大缩放比例
   */
  maxScale: number = 15
  /**
   * 指示器
   */
  indicator: DotIndicator | DigitIndicator | boolean = false
  /**
   * 背景色 默认 #000000
   */
  backgroundColor: ResourceColor = '#000000'
  /**
   * 动画时长,预览器打开关闭的动画时长
   */
  duration: number = 200
  /**
   * 是否在点击图片后关闭图片预览
   */
  closeOnClickImage?: boolean = true
  /**
   * 是否启用双击缩放手势，禁用后，点击时会立即关闭图片预览
   */
  doubleScale?: boolean = true

  /**
   * 设置数据list
   */
  setImageList(imageList: SourceImageModel[]) {
    this.dataList = [...imageList];
    return this
  }

  /**
   * 设置初始化index
   */
  setInitIndex(initIndex: number) {
    this.startIndex = (initIndex > this.dataList.length || initIndex < 0) ? 0 : initIndex
    return this
  }

  /**
   * 设置最小缩放比例
   */
  setMinScale(minScale: number) {
    this.minScale = Math.max(minScale, 1)
    return this
  }

  /**
   * 设置最大缩放比例
   */
  setMaxScale(maxScale: number) {
    this.maxScale = Math.max(maxScale, 1)
    return this
  }


  /**
   * 设置指示器
   */
  setIndicator(indicator: DotIndicator | DigitIndicator | boolean) {
    this.indicator = indicator
    return this
  }

  /**
   * 设置背景色
   */
  setBackgroundColor(backgroundColor: ResourceColor) {
    this.backgroundColor = backgroundColor
    return this
  }


  /**
   * 设置动画时长
   */
  setDuration(duration: number) {
    this.duration = duration
    return this
  }


  /**
   * 设置是否可以通过系统返回关闭preview 默认 true
   */
  setDismissOnSystemBack(dismissOnSystemBack: boolean) {
    this.dismissOnSystemBack = dismissOnSystemBack
    return this
  }

  /**
   * 设置 levelMode，可以设置弹窗随 Router push 消失
   */
  setLevelMode(levelMode?: LevelMode) {
    this.levelMode = levelMode
    return this
  }

  /**
   * 是否在点击图片后关闭图片预览
   */
  setCloseOnClickImage(closeOnClickImage: boolean) {
    this.closeOnClickImage = closeOnClickImage
    return this
  }

  /**
   * 设置页面 id，可以使弹出框在指定页面内弹出
   */
  setLevelUniqueId(levelUniqueId?: number | string) {
    this.levelUniqueId = levelUniqueId
    return this
  }

  /**
   * 设置 immersiveMode，可以设置页面级弹出框蒙层样式
   */
  setImmersiveMode(immersiveMode?: ImmersiveMode) {
    this.immersiveMode = immersiveMode
    return this
  }

  /**
   * 是否滑动循环
   */
  setLoop(loop: boolean) {
    this.loop = loop
    return this
  }

  /**
   * 是否启用双击缩放手势，禁用后，点击时会立即关闭图片预览
   */
  setDoubleScale(doubleScale: boolean) {
    this.doubleScale = doubleScale
    return this
  }
}