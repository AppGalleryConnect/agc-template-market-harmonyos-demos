import { image } from '@kit.ImageKit';
import { componentSnapshot, UIContext } from '@kit.ArkUI';
import {
  BaseViewModel,
  BeautyParam,
  ContextUtil,
  Logger,
  OperateType,
  RouterMap,
  RouterModule,
  UIDialogUtil,
} from 'commonlib';
import { CanvasTextItem, StickerModel } from '../model/BeautificationParam';
import { ImageProcessingUtil } from '../util/ImageProcessingUtil';
import { Constants, WATERMARK_WIDTH } from '../constant/Constants';
import { LayerType } from '../constant/Enum';
import { Matrix4TransitVM } from './Matrix4TransitVM';
import { CropVM } from './CropVM';
import { PixelMapLayer } from '../model/ImageModel';
import { TextFontUtil } from '../util/TextFontUtil';
import { DrawBoardVM } from './DrawBoardVM';
import { ToastDialog } from '@hw-agconnect/ui-toast';
import { MosaicVM } from './MosaicVM';

const TAG = '[PhotoBeautificationVM]'

@ObservedV2
export class PhotoBeautificationVM extends BaseViewModel {
  uiContext: UIContext = ContextUtil.globalUIContext;
  private static _instance: PhotoBeautificationVM;
  // 图片原始宽高比
  @Trace imageRatio: number = 0;
  // 对图片的操作类型。 默认是预览展示，不做操作
  @Trace operateType: OperateType = OperateType.NONE;
  // 操作栏的偏移距离
  @Trace barOffsetY: number = 200;
  // 默认原图
  @Trace originalPixelMap: image.PixelMap | undefined = undefined;
  // 当前显示的图片，操作过的图片
  @Trace currentPixelMap: image.PixelMap | undefined = undefined;
  // 临时预览图
  @Trace previewPixelMap?: image.PixelMap;
  // 图片缩放和移动
  @Trace matrix4TransitVM: Matrix4TransitVM = new Matrix4TransitVM();
  // 图片滤镜
  @Trace filterName: string = '';
  // 选择的滤镜下标
  @Trace selectedFilterIndex: number = 0;
  // 操作过的图片
  @Trace layers: PixelMapLayer[] = [];
  @Trace currentLayerIndex: number = 0;
  @Trace totalLayerCount: number = 0;
  // 图片调整
  @Trace cropVM: CropVM = new CropVM();
  @Trace cutSelectIndex: number = 0;
  @Trace carouselCutTabIndex: number = 0;
  // 贴纸
  @Trace stickerList: StickerModel[] = [];
  // 当前贴纸
  @Trace currentStickerIndex: number = 0;
  // 文字样式
  @Trace canvasText: CanvasTextItem = new CanvasTextItem();
  // 是否展示文字
  @Trace showCanvasText: boolean = false;
  // 是否保存文字
  @Trace saveText: boolean = false;
  @Trace isShowMosaicOperateBar: boolean = true;
  // 会员提示是否展示
  @Trace showRemind: boolean = false;
  // 马赛克
  @Trace mosaicVM = new MosaicVM();
  // 涂鸦
  @Trace drawBoardVM = new DrawBoardVM();
  // 会员到期时间
  @Trace lastPurchaseProductExpireTime: string = '';

  public static get instance() {
    if (!PhotoBeautificationVM._instance) {
      PhotoBeautificationVM._instance = new PhotoBeautificationVM();
    }
    return PhotoBeautificationVM._instance;
  }

  public static set instance(_instance: PhotoBeautificationVM) {
    PhotoBeautificationVM._instance = _instance;
  }

  // 注册字体
  registerFont() {
    TextFontUtil.registerFont(this.uiContext);
  }

  // 初始化图片信息
  initImageData() {
    // 获取页面参数
    let param = RouterModule.getNavParam({ url: RouterMap.PICTURE_BEAUTIFICATION }) as BeautyParam;
    // 图片的操作类型
    this.operateType = param?.operateType ?? OperateType.NONE;
    // 图片资源
    if (param.pixelMap) {
      // 滤镜
      this.filterName = param?.filterName ?? '';
      this.originalPixelMap = param.pixelMap;
      // 默认图层
      this.layers = [{ type: LayerType.BASE, pixelMap: this.originalPixelMap }];
      this.totalLayerCount = this.layers.length;
      // 初始化图片信息
      this.initCurrentImageInfo(param.pixelMap);
      // 当前图片
      this.initCurrentPixelMap(param.pixelMap);
    }
  }

  // 获取图片的宽高比
  initCurrentImageInfo(pixelMap: PixelMap) {
    try {
      const imgInfo = pixelMap.getImageInfoSync();
      // 获取宽高比
      let imageWidth = imgInfo.size.width;
      let imageHeight = imgInfo.size.height;
      // 图片宽高比
      this.imageRatio = imageWidth / imageHeight;
    } catch (error) {
      Logger.error(TAG, 'initCurrentImageInfo', error);
    }
  }

  // 初始化当前图片效果
  async initCurrentPixelMap(pixelMap: PixelMap) {
    if (this.filterName) {
      this.barOffsetY = 0;
      // 热门滤镜入口
      let index = Constants.filterList.findIndex(item => item.name === this.filterName);
      if (index !== -1) {
        const filter = Constants.filterList[index];
        this.previewPixelMap = await ImageProcessingUtil.filterImage(filter, pixelMap);
        this.selectedFilterIndex = index;
      }
    }
    this.currentPixelMap = pixelMap;
  }

  // 删除贴纸
  deleteSticker(id: string) {
    const idx = this.stickerList.findIndex(item => item.id === id);
    if (idx > -1) {
      this.stickerList.splice(idx, 1);
    }
  };


  saveImage(layerType: LayerType) {
    try {
      let pixelMapOrigin = componentSnapshot.getSync('ImageContent');
      let imageInfo = pixelMapOrigin.getImageInfoSync();
      const imageWidth = imageInfo.size.width;
      const imageHeight = imageInfo.size.height;

      const imageAreaWidth = this.cropVM.imageArea.width!;
      const imageAreaHeight = this.cropVM.imageArea.height!;
      const imageAreaX = this.cropVM.imageArea.x;
      const imageAreaY = this.cropVM.imageArea.y;

      const clipRect = this.cropVM.clipRect;

      let ratioX = imageWidth / imageAreaWidth;
      let ratioY = imageHeight / imageAreaHeight;
      let x = clipRect.x - imageAreaX;
      let y = clipRect.y - imageAreaY;
      let pixelMap = ImageProcessingUtil.getRectanglePixelMap(
        pixelMapOrigin as PixelMap,
        Math.round(x * ratioX),
        Math.round(y * ratioY),
        Math.round(clipRect.width! * ratioX),
        Math.round(clipRect.height! * ratioY),
      );
      if (pixelMap) {
        this.currentPixelMap = pixelMap;
        this.layers = this.layers.slice(0, this.currentLayerIndex + 1);
        this.layers.push({
          type: layerType,
          pixelMap,
        });
        this.totalLayerCount = this.layers.length;
        this.currentLayerIndex = this.totalLayerCount - 1;
      }
    } catch (error) {
      Logger.error(TAG, `saveImage error: ${JSON.stringify(error)}`);
    }
  };

  watermarkTip() {
    if (!this.cropVM.imageArea.width) {
      return;
    }
    if (this.cropVM.imageArea.width < WATERMARK_WIDTH) {
      ToastDialog.showToast({ message: '当前可能导致水印截断，您可以通旋转、裁剪等方式调整图片后再次添加水印' });
    }
  }


  showDiscardDialog() {
    UIDialogUtil.open({ content: '是否放弃当前操作？' }, () => {
      RouterModule.pop();
    })
  }

  // 撤销undo
  undo() {
    if (this.currentLayerIndex !== 0) {
      this.currentLayerIndex--;
      this.currentPixelMap = this.layers[this.currentLayerIndex].pixelMap;
    }
  }

  // 重做redo
  redo() {
    if (this.currentLayerIndex !== this.totalLayerCount - 1) {
      this.currentLayerIndex++;
      this.currentPixelMap = this.layers[this.currentLayerIndex].pixelMap;
    }
  }

  /**
   * 预览图和原图切换对比
   */
  previewSwitch(event: TouchEvent) {
    if (event.type === TouchType.Down) {
      this.currentPixelMap = this.layers[0].pixelMap;
    } else if (event.type === TouchType.Up) {
      this.currentPixelMap = this.layers[this.currentLayerIndex].pixelMap;
    }
  }
}