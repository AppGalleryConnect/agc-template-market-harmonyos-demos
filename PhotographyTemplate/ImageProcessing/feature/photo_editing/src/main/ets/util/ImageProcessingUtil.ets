import { image } from '@kit.ImageKit';
import { effectKit } from '@kit.ArkGraphics2D';
import { fileIo as fs } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { CustomFilter, Logger } from 'commonlib';

export class ImageProcessingUtil {
  static saveToAlbum(id: string, uiContext: UIContext, callback?: (uri: string) => void) {
    uiContext.getComponentSnapshot().get(id, async (error: Error, pixmap: image.PixelMap) => {
      if (error) {
        return;
      }
      let imageQualityLevel: number | undefined = AppStorage.get('imageQualityLevel');
      let quality = 100;
      if (imageQualityLevel === 1) {
        quality = 60;
      } else if (imageQualityLevel === 2) {
        quality = 30;
      }

      let imagePackerApi = image.createImagePacker();
      let packOpts: image.PackingOption = { format: `image/jpeg`, quality: quality };
      let file: fs.File = null!;
      imagePackerApi.packToData(pixmap, packOpts).then(async (buffer: ArrayBuffer) => {
        try {
          let helper = photoAccessHelper.getPhotoAccessHelper(uiContext.getHostContext());
          let uri = await helper.createAsset(photoAccessHelper.PhotoType.IMAGE, 'jpeg');
          file = await fs.open(uri, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
          // 写入文件
          await fs.write(file.fd, buffer);
          callback?.(uri);
        } catch (error) {
          Logger.error('error is ' + JSON.stringify(error));
        } finally {
          await fs.close(file);
        }
      }).catch((error: BusinessError) => {
        Logger.error('Failed to pack the image. And the error is: ' + error);
      });
      pixmap.release().catch((error: BusinessError) => {
        Logger.error('Failed to release. error is: ' + JSON.stringify(error));
      });
    });
  }

  //图片加滤镜
  static filterImage(item: CustomFilter, pixelMap?: PixelMap): Promise<PixelMap> {
    let filter = effectKit.createEffect(pixelMap);
    filter.blur(item.blur);
    if (item.grayscale) {
      filter.grayscale();
    }
    if (item.invert) {
      filter.invert();
    }
    filter.setColorMatrix(item.colorMatrix);
    filter.brightness(item.brightness);
    if (item.grayscale) {
      filter.grayscale();
    }
    return filter.getEffectPixelMap();
  }

  //矩形裁剪
  static getRectanglePixelMap(pixelMap: PixelMap, x: number, y: number, width: number, height: number) {
    let imageInfo = pixelMap.getImageInfoSync();
    let widthOrg = imageInfo.size.width;
    let heightOrg = imageInfo.size.height;
    let readBuffer: ArrayBuffer = new ArrayBuffer(widthOrg * heightOrg * 4);
    let desBuffer: ArrayBuffer = new ArrayBuffer(width * height * 4);
    pixelMap.readPixelsToBufferSync(readBuffer);
    let uint32Buffer: Uint32Array = new Uint32Array(readBuffer);
    let uint8BufferTemp: Uint8Array = new Uint8Array(desBuffer);
    if (x >= widthOrg) {
      x = widthOrg - 1;
    }

    if (y >= heightOrg) {
      y = heightOrg - 1;
    }
    if (width > (widthOrg - x)) {
      width = widthOrg - x;
    }

    if (height > (heightOrg - y)) {
      height = heightOrg - y;
    }

    for (let h = 0; h < height; h++) {
      for (let w = 0; w < width; w++) {
        let index = (y + h) * widthOrg + (x + w);
        let pixelColor = uint32Buffer[index];
        let indexTemp = h * width + w;
        uint8BufferTemp[indexTemp*4] = (pixelColor >> 16) & 0x000000ff;
        uint8BufferTemp[indexTemp * 4+1] = (pixelColor >> 8) & 0x000000ff;
        uint8BufferTemp[indexTemp * 4+2] = (pixelColor >> 0) & 0x000000ff;
        uint8BufferTemp[indexTemp * 4+3] = (pixelColor >> 24) & 0x000000ff;
      }
    }

    let color: ArrayBuffer = uint8BufferTemp.buffer as ArrayBuffer;
    let opts: image.InitializationOptions =
      { editable: true, pixelFormat: imageInfo.pixelFormat, size: { height: height, width: width } };
    try {
      let pixelMapTemp: image.PixelMap = image.createPixelMapSync(color, opts);
      return pixelMapTemp;
    } catch (e) {
      return undefined;
    }

  }
}
