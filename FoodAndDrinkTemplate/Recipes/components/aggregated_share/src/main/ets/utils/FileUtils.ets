import { http } from '@kit.NetworkKit';
import { image } from '@kit.ImageKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { fileUri, fileIo as fs } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { ToastDialog as promptAction } from '@hw-agconnect/ui-toast';
import { UtilLog as Logger } from '@hw-agconnect/util-log';

const TAG = 'FileUtils';

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
      };
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
 * @param img
 */
export async function saveImgToAlbum(uiContext: UIContext, img: PixelMap): Promise<void> {
  return new Promise(async (resolve, reject) => {
    const uri = await saveImgToSandbox(uiContext, img);
    let srcFile: fs.File | null = null;
    let desFile: fs.File | null = null;
    try {
      const phAccessHelper = photoAccessHelper.getPhotoAccessHelper(uiContext.getHostContext());
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
      image.createImagePacker().packToData(pixel, packOpts).then((data: ArrayBuffer) => {
        resolve(data);
      }).catch((err: BusinessError) => {
        Logger.error(TAG, `packToData fail, err: ${JSON.stringify(err)}`);
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
    Logger.info(TAG, 'to delete cache files: ' + files);
    files.forEach((file: string) => {
      fs.unlinkSync(file);
    })
    Logger.info(TAG, 'delete cache files success');
  } catch (err) {
    Logger.error(TAG, `delete cache files failed, error:` + err);
  }
}
