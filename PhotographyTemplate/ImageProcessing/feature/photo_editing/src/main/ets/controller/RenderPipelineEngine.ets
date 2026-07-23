import { image } from '@kit.ImageKit';
import { Logger, CustomFilter } from 'commonlib';
import { LayerType } from '../constant/Enum';
import { PixelMapLayer } from '../model/ImageModel';
import { ImageProcessingUtil } from '../util/ImageProcessingUtil';

const TAG = '[RenderPipelineEngine]'

@ObservedV2
export class RenderPipelineEngine {
  // 原图
  originalPixelMap?: image.PixelMap;
  @Trace currentLayerIndex: number = 0;
  @Trace totalLayerCount: number = 0;
  // 操作过的图片
  @Trace layers: PixelMapLayer[] = [];
  // 临时预览图
  @Trace previewPixelMap?: image.PixelMap;
  @Trace currentPixelMap?: image.PixelMap;

  // 初始化参数
  async initRenderData(pixelMap: image.PixelMap) {
    // 设置原图
    this.originalPixelMap = pixelMap;
    this.currentPixelMap = pixelMap;
    this.layers = [
      { type: LayerType.BASE, pixelMap: pixelMap },
    ]
    this.totalLayerCount = this.layers.length;
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

  /**
   * 应用滤镜
   */
  async previewFilter(item: CustomFilter, initFilter: CustomFilter) {
    // 过滤非滤镜图片
    const noFilterLayers = this.layers.filter((item) => item.type !== LayerType.FILTER);
    const lastPixelMap = noFilterLayers[noFilterLayers.length - 1].pixelMap;
    // 处理预览图片
    const previewPixelMap = lastPixelMap;
    const originPixelMap = await ImageProcessingUtil.filterImage(initFilter, previewPixelMap);
    this.previewPixelMap = await ImageProcessingUtil.filterImage(item, originPixelMap)
  }

  /**
   * 保存滤镜
   */
  saveFilter(selectedFilterIndex: number) {
    if (!this.previewPixelMap) {
      return
    }
    this.currentPixelMap = this.previewPixelMap;
    this.layers = this.layers.slice(0, this.currentLayerIndex + 1)
    this.layers.push({
      type: LayerType.FILTER,
      pixelMap: this.previewPixelMap,
      filterIndex: selectedFilterIndex,
    })

    this.previewPixelMap = undefined;
    this.totalLayerCount = this.layers.length;
    this.currentLayerIndex = this.totalLayerCount - 1;
  }

  /**
   * 取消滤镜预览
   */
  cancelPreviewFilter() {
    this.previewPixelMap = undefined;
  }

  /**
   * 保存裁剪
   */
  saveCrop(pixelMap?: image.PixelMap) {
    if (!pixelMap) {
      return;
    }
    this.currentPixelMap = pixelMap;
    this.layers = this.layers.slice(0, this.currentLayerIndex + 1)
    this.layers.push({
      type: LayerType.CLIP,
      pixelMap,
    })

    this.totalLayerCount = this.layers.length;
    this.currentLayerIndex = this.totalLayerCount - 1;
  }

  // 图片旋转
  rotateImage(rotate: string, callback: (rotateRatio: number) => void) {
    if (!this.currentPixelMap) {
      Logger.error(TAG, 'currentPixelMap is undefined');
      return
    }

    if (!this.previewPixelMap) {
      this.previewPixelMap = this.currentPixelMap;
    }

    try {
      let pixelMap = this.previewPixelMap.cloneSync();

      switch (rotate) {
        case 'left_90':
          pixelMap.rotateSync(-90);
          break;
        case 'right_90':
          pixelMap.rotateSync(90);
          break;
        case 'horizontal':
          pixelMap.flipSync(true, false);
          break;
        case 'vertical':
          pixelMap.flipSync(false, true);
          break;
      }

      const imgInfo = pixelMap.getImageInfoSync();
      const rotateRatio = imgInfo.size.width / imgInfo?.size.height;
      this.previewPixelMap = pixelMap;
      callback(rotateRatio)
    } catch (error) {
      Logger.error(TAG,  `rotateImage failed. error: ${JSON.stringify(error)}`);
    }
  }

  // 图片旋转保存
  saveRotate() {
    if (!this.previewPixelMap) {
      return;
    }
    this.currentPixelMap = this.previewPixelMap;
    this.layers = this.layers.slice(0, this.currentLayerIndex + 1)
    this.layers.push({
      type: LayerType.ROTATE,
      pixelMap: this.previewPixelMap,
    })
    this.previewPixelMap = undefined;
    this.totalLayerCount = this.layers.length;
    this.currentLayerIndex = this.totalLayerCount - 1;
  }
}