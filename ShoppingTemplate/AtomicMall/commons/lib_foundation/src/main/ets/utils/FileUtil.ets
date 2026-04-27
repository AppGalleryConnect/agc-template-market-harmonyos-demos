import { BusinessError } from '@kit.BasicServicesKit';
import { fileUri, fileIo as fs } from '@kit.CoreFileKit';
import { image } from '@kit.ImageKit';
import { http } from '@kit.NetworkKit';
import { UtilLog } from '@hw-agconnect/util-log';
import { WindowUtil } from './WindowUtil';

const TAG: string = '[FileUtil]';

export class FileUtil {
  public static downloadImage(url: string): Promise<ArrayBuffer> {
    return new Promise((resolve, reject) => {
      http.createHttp()
        .request(url, { method: http.RequestMethod.GET })
        .then((data: http.HttpResponse) => {
          if (http.ResponseCode.OK === data.responseCode) {
            const imageBuffer: ArrayBuffer = data.result as ArrayBuffer;
            resolve(imageBuffer);
          } else {
            UtilLog.error(TAG, `downloadImage fail, url: ${url}, responseCode: ${data.responseCode}`);
            reject();
          }
        })
        .catch((err: BusinessError) => {
          UtilLog.error(TAG, `downloadImage fail, url: ${url}, err: ${JSON.stringify(err)}`);
          reject();
        });
    });
  }

  /**
   * 写入数据到沙箱
   * @param buffer
   * @returns 沙箱文件对应的uri
   */
  public static async saveToSandbox(buffer: ArrayBuffer): Promise<string> {
    let file: fs.File | null = null;
    if (!WindowUtil.globalContext) {
      return '';
    }
    try {
      const savePath = `${WindowUtil.globalContext.cacheDir}/${new Date().getTime()}.png`;
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
          fs.closeSync(file);
        } catch (err) {
          UtilLog.error(TAG, 'close file failed. error: ' + JSON.stringify(err));
        }
      }
    }
  }

  public static readFileToPixelMap(uri: string): Promise<image.PixelMap | undefined> {
    return new Promise((resolve, reject) => {
      let file: fs.File | undefined = undefined;
      try {
        file = fs.openSync(uri, fs.OpenMode.READ_ONLY);
        const imageSource: image.ImageSource = image.createImageSource(file.fd);
        imageSource.createPixelMap().then((pixelMap: image.PixelMap) => {
          resolve(pixelMap);
        }).catch((e: Error) => {
          reject(e);
        });
      } catch (e) {
        reject(e);
      } finally {
        if (file) {
          fs.closeSync(file);
        }
      }
    });
  }
}