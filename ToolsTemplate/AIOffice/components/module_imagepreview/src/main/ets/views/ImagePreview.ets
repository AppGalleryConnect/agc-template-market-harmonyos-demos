import { ComponentContent, PromptAction, window } from '@kit.ArkUI'
import { clamp, getComponentsInfo, getSizeByUnit } from '../utils/Utils'

type PreviewImgType = PixelMap | ResourceStr | DrawableDescriptor

interface CenterLocation {
  x: number;
  y: number;
}

interface ScaleImageInfo {
  width: number
  height: number
  localLeft: number
  localTop: number
}

/**
 * 对齐方式
 */
export enum PreviewVerticalAlign {
  Top = 'top',
  Bottom = 'bottom',
}


@ObservedV2
class ImagePreviewOption {
  /**
   * 是否简单模式，不展示评论、点赞、分享、关注等功能
   */
  isBasicMode?: boolean = false
  /**
   * 遮罩背景色
   */
  maskColor?: ResourceColor = '#000000'
  /**
   * 指定初始显示的图片索引
   */
  startIndex?: number = 0
  /**
   * 动画时长
   */
  swipeDuration?: number = 200
  /**
   * 是否显示页码
   */
  showIndex?: boolean = true
  /**
   * 页码位置
   */
  indexPosition?: PreviewVerticalAlign = PreviewVerticalAlign.Bottom
  /**
   * 页码距离顶部或底部距离
   */
  indexOffset?: number | string = 40
  /**
   * 页码字体颜色
   */
  indexFontColor?: ResourceColor
  /**
   * 页码字体大小
   */
  indexFontSize?: number | string = 14
  /**
   * 是否循环
   */
  loop?: boolean = true
  /**
   * 是否启用双击缩放手势，禁用后，点击时会立即关闭图片预览
   */
  doubleScale?: boolean = true
  /**
   * 是否在点击遮罩层后关闭图片预览
   */
  closeOnClickOverlay?: boolean = true
  /**
   * 是否在点击图片后关闭图片预览
   */
  closeOnClickImage?: boolean = true
  /**
   * 最大缩放比例
   */
  maxScale?: number = 3
  /**
   * 最小缩放比例
   */
  minScale?: number = 1
  /**
   * 图片点击事件
   */
  onImgClick?: (index: number) => void
  /**
   * 图片长按事件
   */
  onImgLongPress?: (index: number) => void
  /**
   * 顶部操作栏
   */
  authorBuilder?: () => void = () => {
  }
  /**
   * 底部操作栏
   */
  operationBuilder?: () => void = () => {
  }
  /*
   * 关闭操作栏
   * */
  onCloseExpand?: () => void = () => {
  }
}

class ImagePreviewParams extends ImagePreviewOption {
  list: PreviewImgType[] = []
  // 关闭
  hide: () => void = () => {
  }

  constructor(list: PreviewImgType[], params?: ImagePreviewOption) {
    super()
    this.list = list
    this.isBasicMode = params?.isBasicMode ?? false
    this.maskColor = params?.maskColor || '#000000'
    this.startIndex = params?.startIndex || 0
    this.swipeDuration = params?.swipeDuration || 200
    this.showIndex = params?.showIndex !== undefined ? params.showIndex : list.length >= 1
    this.indexPosition = params?.indexPosition || PreviewVerticalAlign.Bottom
    this.indexOffset = params?.indexOffset || 40
    this.indexFontColor = params?.indexFontColor || Color.White
    this.indexFontSize = params?.indexFontSize || 14
    this.loop = params?.loop !== undefined ? params.loop : true
    this.doubleScale = params?.doubleScale !== undefined ? params.doubleScale : true
    this.closeOnClickOverlay = params?.closeOnClickOverlay !== undefined ? params.closeOnClickOverlay : true
    this.closeOnClickImage = params?.closeOnClickImage !== undefined ? params.closeOnClickImage : true
    this.maxScale = params?.maxScale || 3
    this.minScale = params?.minScale || 1
    this.onImgClick = params?.onImgClick
    this.onImgLongPress = params?.onImgLongPress
    this.authorBuilder = params?.authorBuilder
    this.operationBuilder = params?.operationBuilder
    this.onCloseExpand = params?.onCloseExpand
  }
}

@ComponentV2
struct PreviewContent {
  @Param params: ImagePreviewParams = new ImagePreviewParams([])
  @Local active: number = 0
  @Local isDisabledSwiper: boolean = false
  @Local isExpand: boolean = false

  aboutToAppear(): void {
    this.active = this.params.startIndex as number
  }

  build() {
    Stack({ alignContent: this.params.indexPosition === PreviewVerticalAlign.Top ? Alignment.Top : Alignment.Bottom }) {
      Swiper() {
        ForEach(this.params.list, (item: PreviewImgType, index: number) => {
          SwiperItem({
            url: item,
            index: index,
            active: this.active,
            params: this.params,
            isDisabledSwiper: this.isDisabledSwiper,
            onDisabledSwiper: (isDisabled: boolean) => {
              this.isDisabledSwiper = isDisabled
            },
          })
        }, (item: PreviewImgType, index: number) => JSON.stringify(item) + index)
      }
      .width('100%')
      .height('100%')
      .index($$this.active)
      .indicator(false)
      .loop(this.params.loop)
      .duration(this.params.swipeDuration)
      .disableSwipe(this.isDisabledSwiper)

      if (this.params.showIndex && !this.isExpand) {
        Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
          if (this.params.authorBuilder) {
            AuthorBuilder({ option: this.params })
          }

          Blank()

          Column() {
            Text(`${this.active + 1} / ${this.params.list.length}`)
              .fontColor(this.params.indexFontColor)
              .fontSize(this.params.indexFontSize ? getSizeByUnit(this.params.indexFontSize, true) : '')
              .constraintSize({ minWidth: 50 })
              .textAlign(TextAlign.Center)
          }
          .backgroundColor($r('sys.color.mask_fourth'))
          .borderRadius(16)
          .padding(4)
        }
        .offset({
          y: `${this.params.indexPosition === PreviewVerticalAlign.Top ? '' :
            '-'}${getSizeByUnit(this.params.indexOffset)}`,
        })
        .padding({ left: 16, right: 16 })
      }
      Column() {
        if (this.params.operationBuilder) {
          OperationBuilder({ option: this.params })
        }
      }
      .position({ bottom: 28 })
      .padding({ left: 16, right: 16 })
    }
  }
}


@ComponentV2
struct OperationBuilder {
  @Require @Param option: ImagePreviewOption

  build() {
    OperationBuilderComponent({ operationBuilder: this.option.operationBuilder })
  }
}

@ComponentV2
struct OperationBuilderComponent {
  @BuilderParam operationBuilder?: () => void

  build() {
    if (this.operationBuilder) {
      this.operationBuilder()
    }
  }
}


@ComponentV2
struct AuthorBuilder {
  @Require @Param option: ImagePreviewOption

  build() {
    AuthorBuilderComponent({ authorBuilder: this.option.authorBuilder })
  }
}

@ComponentV2
struct AuthorBuilderComponent {
  @BuilderParam authorBuilder?: () => void

  build() {
    if (this.authorBuilder) {
      Column() {
        this.authorBuilder()
      }
      .margin({ top: 16 })
    }
  }
}

@ComponentV2
struct SwiperItem {
  @Param @Require params: ImagePreviewParams = new ImagePreviewParams([])
  @Require @Param url: PreviewImgType
  @Require @Param index: number
  @Require @Param active: number
  @Require @Param isDisabledSwiper: boolean
  @Local rootWidth: number = 0
  @Local rootHeight: number = 0
  @Local imgWidth: number = 0
  @Local imgHeight: number = 0
  @Local curScale: number = 1
  @Local pinchValue: number = 1
  @Local offsetX: number = 0
  @Local offsetY: number = 0
  @Local startX: number = 0
  @Local startY: number = 0
  @Local curX: number = 0
  @Local curY: number = 0
  @Local offsetMaxX: number = 0
  @Local offsetMaxY: number = 0
  @Local imageRatio: number = 0
  @Local isLongImage: boolean = false
  @Local imgDraggable: boolean = true
  @Local isMoving: boolean = false
  private isImageMoved: boolean = false
  private isFingerMove: boolean = false
  private longImageRatio: number = 2.6
  private lastCenter: CenterLocation = { x: 0, y: 0 }
  @Event onDisabledSwiper: (isDisabled: boolean) => void = () => {
  }

  @Monitor('isMoving')
  moveChange() {
    console.log('isMoving')
  }

  // 初始化
  init(width: number, height: number) {
    let comInfo = getComponentsInfo(this.getUIContext(), 'PreviewImgContent')
    let rootRatio = comInfo.height / comInfo.width
    this.imgWidth = this.getUIContext().px2vp(width)
    this.imgHeight = this.getUIContext().px2vp(height)
    this.imageRatio = height / width
    this.rootWidth = this.imgWidth
    this.rootHeight = this.imgHeight

    this.isLongImage = this.imageRatio > rootRatio && this.imageRatio >= this.longImageRatio
    this.imgDraggable = !this.params.onImgLongPress

    this.setParams(1)
  }

  getCenter(fingers: FingerInfo[]): CenterLocation {
    return {
      x: (fingers[0].localX + fingers[1].localX) / 2,
      y: (fingers[0].localY + fingers[1].localY) / 2,
    }
  }

  getMaxMoveX() {
    if (this.imageRatio) {
      const displayWidth = this.isLongImage ? this.imgWidth : this.rootWidth
      return Math.max(0, (this.curScale * displayWidth - this.rootWidth) / 2)
    }
    return 0
  }

  getMaxMoveY() {
    if (this.imageRatio) {
      const displayHeight = this.isLongImage ? this.rootHeight : this.imgHeight
      return Math.max(0, (this.curScale * displayHeight - this.rootHeight) / 2)
    }
    return 0
  }

  // 获取缩放后图片信息
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

  // 单击
  singleClick(type: 'img' | 'mask') {
    if (!this.isFingerMove) {
      !this.params.closeOnClickImage && this.params.onImgClick && this.params.onImgClick(this.index)
      if (type === 'img') {
        this.params.closeOnClickImage && this.params.hide()
      } else {
        this.params.closeOnClickOverlay && this.params.hide()
      }
    }
  }

  // 双击
  doubleClick(fingers: FingerInfo[]) {
    this.params?.onCloseExpand?.()
    if (!this.isFingerMove) {
      if (this.params.doubleScale) {
        let scale = this.curScale === 1 ? 2 : 1
        this.setParams(scale,
          scale === 2 || this.isLongImage ? { x: fingers[0].localX, y: fingers[0].localY } : undefined)
      } else {
        this.params.closeOnClickImage && this.params.hide()
      }
    }
  }

  // 手指移动
  onFingerMove(event: TouchEvent) {
    switch (event.type) {
      case TouchType.Down:
        this.isMoving = this.curScale !== 1 || this.isLongImage
        this.startX = event.touches[0].x
        this.startY = event.touches[0].y
        this.curX = this.offsetX
        this.curY = this.offsetY
        this.isImageMoved = false
        this.isFingerMove = false
        break
      case TouchType.Move:
        let x = event.touches[0].x - this.startX
        let y = event.touches[0].y - this.startY
        this.isFingerMove = x !== 0 || y !== 0
        let offsetX = this.curX + x
        let offsetY = this.curY + y
        let isDisabled = Math.abs(offsetX) <= this.offsetMaxX
        this.onDisabledSwiper(isDisabled)
        if (this.isMoving) {
          if (Math.abs(offsetX) > this.offsetMaxX && !this.isImageMoved) {
            this.isMoving = false
            return
          }
          this.isImageMoved = true
          this.offsetX = clamp(offsetX, -this.offsetMaxX, this.offsetMaxX)
          this.offsetY = clamp(offsetY, -this.offsetMaxY, this.offsetMaxY)
        }
        break
      case TouchType.Up:
        this.isMoving = false
        break
    }
  }

  // 设置参数
  setParams(scale: number, lastCenter?: CenterLocation) {
    scale = clamp(scale, +(this.params.minScale as number), +(this.params.maxScale as number) + 1)
    if (scale !== this.curScale) {
      const ratio = scale / this.curScale
      this.curScale = scale
      this.offsetMaxX = this.getMaxMoveX()
      this.offsetMaxY = this.getMaxMoveY()
      if (lastCenter) {
        const imgInfo = this.getScaleImageInfo()
        const moveX = this.offsetX - (lastCenter.x - imgInfo.localLeft - imgInfo.width / 2) * (ratio - 1)
        const moveY = this.offsetY - (lastCenter.y - imgInfo.localTop - imgInfo.height / 2) * (ratio - 1)

        this.offsetX = clamp(moveX, -this.offsetMaxX, this.offsetMaxX)
        this.offsetY = clamp(moveY, -this.offsetMaxY, this.offsetMaxY)
      } else {
        this.offsetX = 0
        this.offsetY = 0
      }
    }
  }

  // 重置
  @Monitor('active')
  reset() {
    this.setParams(1)
  }

  build() {
    Row() {
      Image(this.url)
        .width(this.isLongImage ? '' : '100%')
        .height(this.isLongImage ? '100%' : '')
        .objectFit(ImageFit.Contain)
        .scale({ x: this.curScale, y: this.curScale, z: 1 })
        .translate({ x: this.offsetX, y: this.offsetY, z: 0 })
        .draggable(this.imgDraggable)
        .animation({
          duration: 100,
        })
        .onComplete((event) => {
          if (event) {
            this.init(event.contentWidth, event.contentHeight)
          }
        })
        .gesture(
          // 长按
          LongPressGesture({ fingers: 1 }).onAction(() => {
            this.params.onImgLongPress && this.params.onImgLongPress(this.index)
          }),
        )
    }
    .justifyContent(FlexAlign.Center)
    .id('PreviewImgContent')
    .onTouch((event) => {
      this.onFingerMove(event)
    })
    .parallelGesture(
      GestureGroup(GestureMode.Exclusive,
        // 双击
        TapGesture({ fingers: 1, count: 2 }).onAction((event) => {
          this.doubleClick(event.fingerList)
        }),
        // 单击
        TapGesture({ fingers: 1, count: 1 }).onAction(() => {
          this.singleClick('mask')
        }),
        // 缩放
        PinchGesture({ fingers: 2 })
          .onActionStart(() => {
            this.params?.onCloseExpand?.()
            this.pinchValue = this.curScale
          })
          .onActionUpdate((event: GestureEvent) => {
            let scale = Number((this.pinchValue * event.scale).toFixed(1))
            let lastCenter = this.getCenter(event.fingerList)
            this.lastCenter = lastCenter
            this.isMoving = false
            this.onDisabledSwiper(true)
            this.setParams(scale, lastCenter)
          })
          .onActionEnd(() => {
            const maxZoom = +(this.params.maxScale as number)
            if (this.curScale > maxZoom) {
              this.setParams(maxZoom, this.lastCenter)
            }
            this.pinchValue = Math.min(this.curScale, maxZoom)
          }),
      ),
    )
  }
}

@Builder
function previewBuilder(params: ImagePreviewParams) {
  PreviewContent({ params })
}

class ImagePreview {
  private static _instance: ImagePreview = new ImagePreview()
  private contentNode: ComponentContent<ImagePreviewParams> | null = null
  private promptAction: PromptAction | null = null

  private getInstance(contentNode: ComponentContent<ImagePreviewParams>,
    promptAction: PromptAction): ImagePreview {
    if (!ImagePreview._instance) {
      ImagePreview._instance = new ImagePreview()
    }
    ImagePreview._instance.contentNode = contentNode
    ImagePreview._instance.promptAction = promptAction
    return ImagePreview._instance
  }

  /**
   * 显示预览
   */
  public async show(list: PreviewImgType[], option?: ImagePreviewOption) {
    let opt: ImagePreviewParams = new ImagePreviewParams(list, option)
    opt.hide = (): void => this.hide()
    if (ImagePreview._instance.contentNode) {
      this.hide()
    }
    let windowClass = (AppStorage.get('windowStage') as window.WindowStage).getMainWindowSync();
    let systemBarProperty = windowClass.getWindowSystemBarProperties()
    AppStorage.setOrCreate('statusBarContentColor', systemBarProperty.statusBarContentColor)
    let uiContext = windowClass.getUIContext()
    let contentNode = new ComponentContent(uiContext, wrapBuilder(previewBuilder), opt)
    let promptAction = uiContext.getPromptAction()
    ImagePreview._instance = this.getInstance(contentNode, promptAction)
    try {
      promptAction.openCustomDialog(contentNode, {
      alignment: DialogAlignment.Center,
      isModal: true,
      maskColor: opt.maskColor,
      autoCancel: false,
      onDidAppear: () => {
        try {
          windowClass.setWindowSystemBarProperties({
            statusBarContentColor: '#ffffff',
          })
        } catch (error) {
          console.error('[ImagePreview] setWindowSystemBarProperties error: ' + JSON.stringify(error));
        }
      },
      onWillDisappear: () => {
        let mainStatusBarContentColor: string = AppStorage.get('statusBarContentColor') ?? '#ffffff'
        try {
          windowClass.setWindowSystemBarProperties({
            statusBarContentColor: mainStatusBarContentColor,
          })
        } catch (error) {
          console.error('[ImagePreview] setWindowSystemBarProperties error: ' + JSON.stringify(error));
        }
      },
    })
    } catch (error) {
      console.error('[ImagePreview] openCustomDialog error: ' + JSON.stringify(error));
    }
  }

  /**
   * 关闭预览
   */
  public hide() {
    if (ImagePreview._instance.contentNode) {
      try {
        ImagePreview._instance.promptAction?.closeCustomDialog(ImagePreview._instance.contentNode)
        ImagePreview._instance.contentNode?.dispose()
      } catch (error) {
        console.error('[ImagePreview] hide error: ' + JSON.stringify(error));
      }
      ImagePreview._instance.contentNode = null
    }
  }
}

const imagePreview = new ImagePreview()

export { imagePreview }