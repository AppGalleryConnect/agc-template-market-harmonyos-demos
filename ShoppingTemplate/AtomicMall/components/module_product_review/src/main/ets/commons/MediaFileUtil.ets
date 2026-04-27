import { common } from '@kit.AbilityKit';
import { dataSharePredicates } from '@kit.ArkData';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { Logger, SafeJson } from 'module_ui_base';
import { Constants } from './Constants';
import { ReviewMediaType } from './Enums';
import { SkuReviewModel } from './Models';

const TAG: string = '[MediaFileUtil]';

export class MediaFileUtil {
  private static _context: Context;

  public static getMediaFromAlbum(model: SkuReviewModel, uiContext: UIContext) {
    MediaFileUtil._context = uiContext.getHostContext() as Context;
    let photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
    photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
    photoSelectOptions.maxSelectNumber = Constants.MAX_MEDIA_LENGTH - model.mediaList.length;
    let photoPicker = new photoAccessHelper.PhotoViewPicker();
    return photoPicker.select(photoSelectOptions).then((photoSelectResult) => {
      if (photoSelectResult !== null && photoSelectResult !== undefined) {
        photoSelectResult.photoUris.forEach(async (uri) => {
          await MediaFileUtil.handlePhotoSource(model, uri);
        });
      }
      Logger.info(TAG, 'PhotoViewPicker.select successfully, PhotoSelectResult uri: ' +
      JSON.stringify(model.mediaList));
    }).catch((err: BusinessError) => {
      Logger.error(TAG, `PhotoViewPicker select failed, code is ${err.code}, message is ${err.message}.`);
    });
  }

  public static async handlePhotoSource(model: SkuReviewModel, uri: string) {
    // requestMovingPhoto (DeliveryMode) not supported in atomic service — use regular image
    model.mediaList.push({
      type: ReviewMediaType.IMAGE,
      uri,
    });
  }
}