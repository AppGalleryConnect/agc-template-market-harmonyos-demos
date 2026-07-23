import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { util } from '@kit.ArkTS';
import { hilog } from '@kit.PerformanceAnalysisKit';
import fs from '@ohos.file.fs';
import { GlobalContext } from 'lib_common';

const DOMAIN = 0x0000;
const TAG = '[MediaUtils]';

export class MediaUtils {
  /**
   * 用系统picker，拉起相册或者相机
   * @param params
   * @returns
   */
  public static selectMedia(maxSelectNumber: number): Promise<string[]> {
    const photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
    photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
    photoSelectOptions.maxSelectNumber = maxSelectNumber;

    let uris: string[] = [];
    const photoViewPicker = new photoAccessHelper.PhotoViewPicker();
    return photoViewPicker.select(photoSelectOptions)
      .then((photoSelectResult: photoAccessHelper.PhotoSelectResult) => {
        uris = photoSelectResult.photoUris;
        hilog.info(DOMAIN, TAG, 'photoViewPicker.select to file succeed and uris are:' + uris);
        return uris;
      }).catch((err: BusinessError) => {
        hilog.error(DOMAIN, TAG,
          `Invoke photoViewPicker.select failed, code is ${err.code}, message is ${err.message}`);
        return uris;
      })
  }

  /**
   * uri对应文件复制到沙箱
   * @param uri
   * @param suffix
   * @returns
   */
  public static handleUri(uri: string, suffix: string = 'png'): string {
    if (!uri) {
      return '';
    }
    let tempFile: fs.File | null = null;
    try {
      tempFile = fs.openSync(uri, fs.OpenMode.READ_ONLY);
      let newPath: string = GlobalContext.getContext().cacheDir + `/${util.generateRandomUUID(false)}.${suffix}`;
      fs.copyFileSync(tempFile.fd, newPath);
      hilog.info(DOMAIN, TAG, 'handleUri copyFileSync success, cache path: ' + newPath);
      return 'file://' + newPath;
    } finally {
      if (tempFile) {
        fs.closeSync(tempFile);
      }
    }
  }
}
