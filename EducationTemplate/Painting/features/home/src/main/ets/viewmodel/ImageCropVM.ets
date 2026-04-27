import { GlobalContext } from 'common';
import { image } from '@kit.ImageKit';
import { PhotoUtils } from '../utils/PhotoUtils';
import { CommonConstants } from '../constants/Constant';

/**
 * 图片裁剪视图模型
 */
@ObservedV2
export class ImageCropVM {
  /** 图片URI */
  @Trace imageUri: string = ''
  /** 目标图片URI */
  @Trace targetImage: string = ''
  /** 图片缩放比例 */
  @Trace scaleValue: number = 1
  @Trace scaleZ: number = 1
  //图片的坐标
  @Trace positionX: number = 0;
  @Trace positionY: number = 0;
  /** 图片X轴偏移 */
  @Trace offsetX: number = 0
  /** 图片Y轴偏移 */
  @Trace offsetY: number = 0
  /** 捏合手势的缩放值 */
  @Trace pinchValue: number = 1
  /** 裁剪框宽度 */
  @Trace cropBoxWidth: number = 0
  /** 裁剪框高度 */
  @Trace cropBoxHeight: number = 0
  /** 裁剪框坐标 */
  @Trace cropBoxPositionX: number = 0
  @Trace cropBoxPositionY: number = 0
  /** 最小缩放比例 */
  private readonly MIN_SCALE: number = 0.5
  /** 最大缩放比例 */
  private readonly MAX_SCALE: number = 5

  /**
   * 初始化
   * @param uri 图片URI
   * @param canvasWidth 画布宽度
   * @param canvasHeight 画布高度
   */
  init(uri: string, canvasWidth: number, canvasHeight: number): void {
    this.imageUri = uri
    this.cropBoxWidth = canvasWidth * 0.8
    this.cropBoxHeight = canvasHeight * 0.8
  }

  /**
   * 处理拖拽手势
   * @param offsetX X轴偏移量
   * @param offsetY Y轴偏移量
   */
  handleMove(event: GestureEvent): void {
    if (event) {
      this.offsetX = this.positionX + event.offsetX;
      this.offsetY = this.positionY + event.offsetY;
    }
  }

  handleEnd() {
    this.positionX = this.offsetX
    this.positionY = this.offsetY
  }


  /**
   * 开始捏合手势
   */
  handlePinchStart(): void {
    this.pinchValue = this.scaleValue
  }

  /**
   * 处理捏合手势
   * @param scale 缩放比例
   */
  handlePinchUpdate(scale: number): void {
    let newScale = this.pinchValue * scale
    // 限制缩放范围
    if (newScale < this.MIN_SCALE) {
      newScale = this.MIN_SCALE
    } else if (newScale > this.MAX_SCALE) {
      newScale = this.MAX_SCALE
    }
    this.scaleValue = newScale
  }

  /**
   * 结束捏合手势
   */
  handlePinchEnd(): void {
    this.pinchValue = this.scaleValue
  }


  private mathCeil(size: number) {
    return Math.ceil(GlobalContext.getUIContext().vp2px(size))
  }

  /**
   * 获取目标图片URI
   */
  async getTargetImage() {
    const pixelMap = await GlobalContext.getUIContext().getComponentSnapshot()
      .get(CommonConstants.CROP_AREA, { scale: 1, waitUntilRenderFinished: true })
    if (pixelMap !== undefined) {
      let region: image.Region = {
        x: this.mathCeil(this.cropBoxPositionX + 2),
        y: this.mathCeil(this.cropBoxPositionY + 2),
        size: {
          width: this.mathCeil(this.cropBoxWidth - 4),
          height: this.mathCeil(this.cropBoxHeight - 4)
        }
      };
      this.targetImage = await PhotoUtils.savePixelMapToBox(pixelMap, region)
    }
  }
}