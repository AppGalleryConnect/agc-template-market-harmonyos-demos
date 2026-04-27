import { http } from '@kit.NetworkKit';
import { image } from '@kit.ImageKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { fileUri, fileIo as fs } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { util } from '@kit.ArkTS';
import { ToastDialog as promptAction } from '@hw-agconnect/ui-toast';
import { UtilLog as Logger } from '@hw-agconnect/util-log';

const TAG = '[FileUtils]';

/**
 * 写入数据到沙箱
 * @param uiContext
 * @param buffer
 * @returns 沙箱文件对应的uri
 */
export async function saveToSandbox(uiContext: UIContext, buffer: ArrayBuffer): Promise<string> {
  let file: fs.File | null = null;
  try {
    const savePath = `${uiContext.getHostContext()?.cacheDir}/${new Date().getTime()}.png`;
    file = fs.openSync(savePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
    fs.writeSync(file.fd, buffer);

    // 记录缓存文件路径
    const files: string[] = AppStorage.get('cacheFiles') ?? [];
    files.push(savePath);
    AppStorage.set('cacheFiles', files);

    return fileUri.getUriFromPath(savePath);
  } catch (e) {
    return '';
  } finally {
    if (file) {
      try {
        fs.closeSync(file)
      } catch (err) {
        Logger.error(TAG, `PoPViewUtils close sync failed. Code is ${err.code}, message is ${err.message}`);
      }
    }
  }
}

/**
 * 写入图片到沙箱
 * @param uiContext
 * @param img
 * @returns 沙箱文件对应的uri
 */
export async function saveImgToSandbox(uiContext: UIContext, img: PixelMap): Promise<string> {
  try {
    // pixel转换成buffer
    const buf = await image.createImagePacker().packToData(img, {
      format: 'image/jpeg',
      quality: 100,
    });
    return saveToSandbox(uiContext, buf);
  } catch (e) {
    return '';
  }
}


/**
 * 保存图片到相册
 * @param uiContext
 * @param img 支持沙箱路径和pixelmap格式
 */
export async function saveImgToAlbum(uiContext: UIContext, img: PixelMap | string): Promise<void> {
  return new Promise(async (resolve, reject) => {
    let uri: string = '';
    if (typeof img === 'string') {
      // 如果是沙箱，直接赋值
      uri = img;
    } else {
      // 如果是pixelmap，需要转换成沙箱路径
      uri = await saveImgToSandbox(uiContext, img);
    }
    const phAccessHelper = photoAccessHelper.getPhotoAccessHelper(uiContext.getHostContext());
    let srcFile: fs.File | null = null;
    let desFile: fs.File | null = null;
    try {
      const srcFileUris: string[] = [uri];
      const photoCreationConfigs: Array<photoAccessHelper.PhotoCreationConfig> = [
        {
          fileNameExtension: 'jpg',
          photoType: photoAccessHelper.PhotoType.IMAGE,
        },
      ];
      /**
       * 调用此接口时请确保module.json5文件中的abilities标签中配置了label和icon项。
       */
      const desFileUris: Array<string> =
        await phAccessHelper.showAssetsCreationDialog(srcFileUris, photoCreationConfigs);
      if (desFileUris.length <= 0) {
        Logger.warn(TAG, 'saveImgToAlbum cancel, cause: user dont not agree');
        reject();
        return;
      }
      srcFile = fs.openSync(srcFileUris[0], fs.OpenMode.READ_ONLY);
      desFile = fs.openSync(desFileUris[0], fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      fs.copyFileSync(srcFile.fd, desFile.fd);
      promptAction.showToast({ message: '保存成功' });
      resolve();
    } catch (err) {
      Logger.error(TAG, 'saveImgToAlbum fail, error: ' + JSON.stringify(err));
      promptAction.showToast({ message: '保存失败' });
      reject();
    } finally {
      if (srcFile) {
        fs.closeSync(srcFile);
      }
      if (desFile) {
        fs.closeSync(desFile);
      }
    }
  });
}

/**
 * 将base64格式的图片写入沙箱
 * @param uiContext
 * @param base64Data base64格式图片数据（包含或不包含data:image/xxx;base64,前缀均可）
 * @returns 沙箱地址，失败返回空字符串
 */
export async function base64ToSandbox(uiContext: UIContext, base64Data: string): Promise<string> {
  if (!base64Data) {
    Logger.error(TAG, 'base64ToSandbox fail: base64Data is empty');
    return '';
  }
  try {
    // 移除base64前缀（如 data:image/png;base64,）
    const base64String = base64Data.replace(/^data:image\/[A-Za-z]+;base64,/, '');
    // 验证 base64 字符串有效性
    if (!base64String) {
      return '';
    }
    // 解码base64
    const uint8Array = new util.Base64Helper().decodeSync(base64String);
    return await saveToSandbox(uiContext, uint8Array.buffer as ArrayBuffer);
  } catch (e) {
    Logger.error(TAG, `base64ToSandbox fail, error: ${JSON.stringify(e)}`);
    return '';
  }
}

/**
 * 下载图片
 * @param url
 * @returns
 */
export function downloadImage(url: string): Promise<ArrayBuffer> {
  return new Promise((resolve, reject) => {
    http.createHttp()
      .request(url, { method: http.RequestMethod.GET })
      .then((data: http.HttpResponse) => {
        if (http.ResponseCode.OK === data.responseCode) {
          const imageBuffer: ArrayBuffer = data.result as ArrayBuffer;
          resolve(imageBuffer);
        } else {
          Logger.error(TAG, `downloadImage fail, url: ${url}, responseCode: ${data.responseCode}`);
          reject();
        }
      })
      .catch((err: BusinessError) => {
        Logger.error(TAG, `downloadImage fail, url: ${url}, err: ${JSON.stringify(err)}`);
        reject();
      })
  })
}

/**
 * 压缩图片
 * @param buf
 * @returns
 */
export async function compressImage(buf: ArrayBuffer): Promise<ArrayBuffer> {
  try {
    const pixel = image.createImageSource(buf).createPixelMapSync();
    const packOpts: image.PackingOption = { format: 'image/jpeg', quality: 50 };
    return new Promise((resolve) => {
      image.createImagePacker()
        .packToData(pixel, packOpts)
        .then((data: ArrayBuffer) => {
          resolve(data);
        })
        .catch((err: BusinessError) => {
          Logger.error(TAG, `packToData fail, err: ${JSON.stringify(err)}`);
        })
        .finally(() => {
          pixel.release();
        })
    })
  } catch (err) {
    Logger.error(TAG, `createImageSource fail, err: ${JSON.stringify(err)}`);
    return new ArrayBuffer(0); // 返回空的 ArrayBuffer 表示失败
  }
}

/**
 * 清理缓存文件
 * @param files
 */
export function clearCache(files: string[]) {
  try {
    Logger.info(TAG, 'to delete cache files: ' + JSON.stringify(files));
    files.forEach((file: string) => {
      fs.unlinkSync(file);
    })
    Logger.info(TAG, 'delete cache files success');
  } catch (err) {
    Logger.error(TAG, `delete cache files failed, error:` + err);
  }
}

/**
 * 判断路径是否为沙箱路径
 * @param path
 * @returns
 */
export function isSandboxPath(path: string): boolean {
  return path.startsWith('file://');
}

/**
 * 判断路径是否为网络地址
 * @param path
 * @returns
 */
export function isNetPath(path: string): boolean {
  return path.startsWith('http');
}

/**
 * 判断路径是否base64
 * @param path
 * @returns
 */
export function isBase64Path(path: string): boolean {
  return /^data:image\/[^;]+;base64,/.test(path);
}