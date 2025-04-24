
import { BusinessError } from '@kit.BasicServicesKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { Logger } from './Logger';

/**
 * 数量
 */
const PHOTO_DEFAULT_SELECT_NUMBER: number = 9;
export class PickerUtil {


  /**
   * 通过选择模式拉起photoPicker界面，用户可以选择一个或多个图片/视频。
   * @param options
   * @returns
   */
  static async selectPhoto(options?: photoAccessHelper.PhotoSelectOptions): Promise<Array<string>> {
    try {
      if (!options) {
        options =  new photoAccessHelper.PhotoSelectOptions();
      }
      //可选择的媒体文件类型，若无此参数，则默认为图片和视频类型。
      if (!options.MIMEType) {
        options.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
      }
      //选择媒体文件数量的最大值,默认9
      if (!options.maxSelectNumber) {
        options.maxSelectNumber = 9;
      }
      if (options.isPhotoTakingSupported === undefined) {
        //支持拍照
        options.isPhotoTakingSupported = true;
      }
      if (options.isEditSupported === undefined) {
        //支持编辑照片
        options.isEditSupported = true;
      }
      if (options.isSearchSupported === undefined) {
        //支持搜索照片
        options.isSearchSupported = true;
      }

      let photoPicker = new photoAccessHelper.PhotoViewPicker();
      let photoSelectResult: photoAccessHelper.PhotoSelectResult = await photoPicker.select(options)
      if (photoSelectResult && photoSelectResult.photoUris && photoSelectResult.photoUris.length > 0) {
        return photoSelectResult.photoUris
      } else {
        return [];
      }
    } catch (err) {
      let error = err as BusinessError;
      Logger.error(`PickerUtil-selectPhoto-异常 ~ code: ${error.code} -·- message: ${error.message}`);
      return [];
    }
  }
}

/**
 * 相册选择参数类
 */
class PhotoSelectOptions {
  /**
   * 可选择的媒体文件类型，若无此参数，则默认为图片和视频类型。
   */
  mimeType?: photoAccessHelper.PhotoViewMIMETypes = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
  maxSelectNumber?: number = PHOTO_DEFAULT_SELECT_NUMBER;
  /**
   * 支持拍照
   */
  isPhotoTakingSupported?: boolean = true;
  /**
   * 支持编辑照片
   */
  isEditSupported?: boolean = true;
  /**
   * 支持搜索
   */
  isSearchSupported?: boolean = true;
  /**
   * 支持照片推荐
   */
  recommendationOptions?: photoAccessHelper.RecommendationOptions;
  /**
   * 预选择图片的uri数据
   */
  preselectedUris?: Array<string>;
}