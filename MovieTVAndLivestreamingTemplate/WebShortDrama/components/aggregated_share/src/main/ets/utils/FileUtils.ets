import { http } from '@kit.NetworkKit';
import { image } from '@kit.ImageKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { fileUri, fileIo as fs } from '@kit.CoreFileKit';
import { Logger } from '../common/Logger';
import { BusinessError } from '@kit.BasicServicesKit';
import { GlobalContext } from '@agctemplate/utils';

const TAG = 'FileUtils';

/**
 * 写入数据到沙箱
 * @param buffer
 * @returns 沙箱文件对应的uri
 */
export async function saveToSandbox(buffer: ArrayBuffer): Promise<string> {
  let file: fs.File | null = null;
  try {
    const savePath =
      `${GlobalContext.getWindowStage()
        .getMainWindowSync()
        .getUIContext()
        .getHostContext()!.cacheDir}/${new Date().getTime()}.png`;
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
      fs.closeSync(file);
    }
  }
}

/**
 * 写入图片到沙箱
 * @param img
 * @returns 沙箱文件对应的uri
 */
export async function saveImgToSandbox(img: PixelMap): Promise<string> {
  try {
    // pixel转换成buffer
    const buf = await image.createImagePacker().packToData(img, {
      format: 'image/jpeg',
      quality: 100,
    });
    return saveToSandbox(buf);
  } catch (e) {
    return '';
  }
}


/**
 * 保存图片到相册
 * @param img
 */
export async function saveImgToAlbum(img: PixelMap): Promise<void> {
  return new Promise(async (resolve, reject) => {
    const uri = await saveImgToSandbox(img);
    const phAccessHelper =
      photoAccessHelper.getPhotoAccessHelper(GlobalContext.getContext());
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
      GlobalContext.getWindowStage()
        .getMainWindowSync()
        .getUIContext()
        .getPromptAction()
        .showToast({ message: '保存成功' });
      resolve();
    } catch (err) {
      Logger.error(TAG, 'saveImgToAlbum fail, error: ' + JSON.stringify(err));
      GlobalContext.getWindowStage()
        .getMainWindowSync()
        .getUIContext()
        .getPromptAction()
        .showToast({ message: '保存失败' });
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
  let pixel: image.PixelMap | null = null;

  try {
    // 1. 创建 ImageSource 并同步生成 PixelMap
    // 这里最容易因为 buf 数据问题抛出异常
    const imageSource = image.createImageSource(buf);
    pixel = imageSource.createPixelMapSync();

    // 注意：imageSource 是同步创建的，通常不需要显式 release，
    // 但 pixel 是重量级对象，必须手动 release。

    const packOpts: image.PackingOption = {
      format: 'image/jpeg',
      quality: 50
    };

    // 2. 执行压缩 (异步)
    const packedData = await image.createImagePacker().packToData(pixel, packOpts);

    return packedData;

  } catch (error) {
    // 捕获所有异常：包括 createPixelMapSync 的同步异常 和 packToData 的异步异常
    console.error('Image compression failed:', error);

    throw new Error(error instanceof Error ? error.message : String(error));
  } finally {
    // 3. 关键步骤：确保 pixel 资源被释放，防止内存泄漏
    if (pixel) {
      try {
        pixel.release();
      } catch (releaseError) {
        console.warn('Failed to release pixel resource:', releaseError);
      }
    }
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
