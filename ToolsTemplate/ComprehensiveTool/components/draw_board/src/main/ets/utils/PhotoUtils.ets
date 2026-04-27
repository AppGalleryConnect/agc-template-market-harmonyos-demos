import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { BusinessError } from '@kit.BasicServicesKit';

export class PhotoUtils {
  /**
   * 用系统picker，拉起相册或者相机
   * @param params
   * @returns
   */
  public static selectPhoto(): Promise<string[]> {
    const photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
    photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;

    let uris: string[] = [];
    const photoViewPicker = new photoAccessHelper.PhotoViewPicker();
    return photoViewPicker.select(photoSelectOptions).then((photoSelectResult: photoAccessHelper.PhotoSelectResult) => {
      uris = photoSelectResult.photoUris;
      console.info('photoViewPicker.select to file succeed and uris are:' + uris);
      return uris;
    }).catch((err: BusinessError) => {
      console.error(
        `Invoke photoViewPicker.select failed, code is ${err.code}, message is ${err.message}`);
      return uris;
    })
  }
}