import { image } from '@kit.ImageKit';
import { fileIo, fileUri } from '@kit.CoreFileKit';
import { Logger } from './Logger';
import { UtilLog } from '@hw-agconnect/util-log';

export class ImageUtils {
  /**
   * Read the screenshot PixelMap object into the buffer area
   * @param {PixelMap} pixelMap - Screenshot PixelMap
   * @param {number[]} scrollYOffsets - Component scrolls an array of y-axis offsets
   * @param {number} listWidth - List component width
   * @param {number} listHeight - List component height
   * @returns {image.PositionArea} Picture buffer area
   */
  // [Start get_snapshot_area]
  static async getSnapshotArea(pixelMap: PixelMap, scrollYOffsets: number[], listWidth: number,
    listHeight: number, uiContext: UIContext): Promise<image.PositionArea> {
    // Gets the number of bytes per line of image pixels.
    let stride = pixelMap.getBytesNumberPerRow();
    // Get the total number of bytes of image pixels.
    let bytesNumber = pixelMap.getPixelBytesNumber();
    let buffer: ArrayBuffer = new ArrayBuffer(bytesNumber);
    // 	Region size, read based on region.   PositionArea represents the data within the specified area of the image.
    let len = scrollYOffsets.length;

    // // Except for the first screenshot, you don't need to crop it, and you need to crop the new parts
    if (scrollYOffsets.length >= 2) {
      // Realistic roll distance
      let realScrollHeight = scrollYOffsets[len-1] - scrollYOffsets[len-2];
      if (listHeight - realScrollHeight > 0) {
        let cropRegion: image.Region = {
          x: 0,
          y: uiContext.vp2px(listHeight - realScrollHeight),
          size: {
            height: uiContext.vp2px(realScrollHeight),
            width: uiContext.vp2px(listWidth),
          },
        };
        // Crop roll area
        await pixelMap.crop(cropRegion);
      }
    }

    let imgInfo = pixelMap.getImageInfoSync();
    // Region size, read based on region. PositionArea represents the data within the specified area of the image.
    let area: image.PositionArea = {
      pixels: buffer,
      offset: 0,
      stride: stride,
      region: {
        size: {
          width: imgInfo.size.width,
          height: imgInfo.size.height,
        },
        x: 0,
        y: 0,
      },
    };
    // Write data to a specified area
    pixelMap.readPixelsSync(area);
    return area;
  }

  // [End get_snapshot_area]

  /**
   * Merge image area array into long screenshots
   * @param {image.PositionArea[]} areaArray - screenshot area
   * @param {number} lastOffsetY - The offset Y of the last screenshot
   * @param {number} listWidth - List component width
   * @param {number} listHeight - List component height
   * @returns {PixelMap} Long image after merge
   */
  // [Start merge_image]
  static async mergeImage(areaArray: image.PositionArea[], lastOffsetY: number, listWidth: number,
    listHeight: number, uiContext: UIContext): Promise<PixelMap | undefined> {
    // Create a long screenshot PixelMap
    let opts: image.InitializationOptions = {
      editable: true,
      pixelFormat: 4,
      size: {
        width: uiContext.vp2px(listWidth),
        height: uiContext.vp2px(lastOffsetY + listHeight),
      },
    };
    let longPixelMap: image.PixelMap | undefined = undefined;
    try {
      longPixelMap = image.createPixelMapSync(opts);
      let imgPosition: number = 0;

      for (let i = 0; i < areaArray.length; i++) {
        let readArea = areaArray[i];
        let area: image.PositionArea = {
          pixels: readArea.pixels,
          offset: 0,
          stride: readArea.stride,
          region: {
            size: {
              width: readArea.region.size.width,
              height: readArea.region.size.height,
            },
            x: 0,
            y: imgPosition,
          },
        };
        imgPosition += readArea.region.size.height;
        longPixelMap.writePixelsSync(area);
      }
      return longPixelMap;
    } catch (e) {
      UtilLog.error(`createPixelMapSync failed with error ${e}`);
      return longPixelMap
    }
  }

  // [End merge_image]

  // 将图片保存到沙箱
  static saveImgToCache(context: Context, imageUri: string, name: string): string {
    let imgDirPath = context.filesDir + '/diaryDir';
    if (!fileIo.accessSync(imgDirPath)) {
      fileIo.mkdirSync(imgDirPath);
    }
    let cachePath = context.filesDir + '/diaryDir/' + name;
    let file = fileIo.openSync(imageUri, fileIo.OpenMode.READ_ONLY);
    let file2 = fileIo.openSync(cachePath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
    fileIo.copyFileSync(file.fd, file2.fd);
    fileIo.closeSync(file);
    fileIo.closeSync(file2);

    let uri = fileUri.getUriFromPath(cachePath);
    // 这里替换是为了在查看详情的时候，web组件能展示图片
    const resUri = uri.replace(/^file:\/\/[^/]+/, 'file:///');
    return resUri;
  }

  // 将图片拷贝到cache
  static saveToCache(context: Context, srcPath: string, newFileName: string): string {
    try {
      let realPath = srcPath.replace('file://', '');
      // 拼接目标路径（cache 目录）
      let cachePath = context.cacheDir + '/' + newFileName;
      // 拷贝文件
      fileIo.copyFileSync(realPath, cachePath);
      return 'file://' + cachePath;
    } catch (err) {
      Logger.error('保存失败: ' + JSON.stringify(err));
      return '';
    }
  }

  // 图片压缩
  static async compressImage(context: Context, imageUri: string, name: string): Promise<string> {
    try {
      let file = fileIo.openSync(imageUri, fileIo.OpenMode.READ_ONLY);
      let imgFileSize = fileIo.statSync(file.fd).size;
      let buffer = new ArrayBuffer(imgFileSize);
      fileIo.readSync(file.fd, buffer);
      fileIo.closeSync(file);
      // 图片超过1.5M进行压缩
      if (imgFileSize > 1.5 * 1024 * 1024) {
        const decodingOptions: image.DecodingOptions = { editable: true };
        const imageSource: image.ImageSource = image.createImageSource(buffer);
        let imgPixel: image.PixelMap = await imageSource.createPixelMap(decodingOptions);
        // 使用scale对图片进行缩放。入参分别为图片宽高的缩放倍数
        imgPixel.scaleSync(0.6, 0.6);
        let imagePackerApi = image.createImagePacker();
        const packOpts: image.PackingOption = { format: 'image/jpeg', quality: 50 }
        await imagePackerApi.packToData(imgPixel, packOpts);
        imagePackerApi.release();
        let imgDirPath = context.filesDir + '/diaryDir';
        if (!fileIo.accessSync(imgDirPath)) {
          fileIo.mkdirSync(imgDirPath);
        }
        const cachePath = imgDirPath + '/' + name;
        let file2 = fileIo.openSync(cachePath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
        imagePackerApi = image.createImagePacker();
        await imagePackerApi.packToFile(imgPixel, file2.fd, packOpts)
        fileIo.closeSync(file2);
        imagePackerApi.release();
        let uri = fileUri.getUriFromPath(cachePath);
        // 这里替换是为了在查看详情的时候，web组件能展示图片
        const resUri = uri.replace(/^file:\/\/[^/]+/, 'file:///');
        return resUri;
      }
      return ImageUtils.saveImgToCache(context, imageUri, name)
    } catch (error) {
      Logger.error('保存失败: ' + JSON.stringify(error));
      return '';
    }
  }

  // 找出html中img的src
  static findImgSrcList(htmlStr: string): string[] {
    const regx = /<img[^>]+src=["']\s*([^"']+)\s*["']/g;
    const matches = htmlStr.matchAll(regx);
    let imgSrcList: string[] = [];
    for (const match of matches) {
      const imgSrc = match[1];
      imgSrcList.push(imgSrc.trim());
    }
    return imgSrcList;
  }

  // 将不使用的图片移除
  static removeSandboxImg(srcPath: string) {
    try {
      let realPath = srcPath.replace('file://', '');
      if (fileIo.accessSync(realPath)) {
        fileIo.unlinkSync(realPath);
      }
    } catch (err) {
      Logger.error('移除失败: ' + JSON.stringify(err));
    }
  }
}