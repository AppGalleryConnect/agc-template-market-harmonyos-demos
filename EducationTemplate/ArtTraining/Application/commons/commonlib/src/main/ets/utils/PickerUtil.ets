import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';
import { picker } from '@kit.CoreFileKit';
import { Logger } from './Logger';

const TAG: string = '[PickerUtil]';

const MAX_RESOURCE_NUMBER = 9;

export enum PickerResourceType {
  IMAGE,
  VIDEO,
  AUDIO,
}

export interface PickerPreviewItem {
  type: PickerResourceType;
  uri: ResourceStr;
  fileName?: string;
}

@ObservedV2
export class PickerUtil {
  @Trace public static mediaPreviewList: PickerPreviewItem[] = [];
  public static selectedNum: number = 0;

  @Computed
  public static get maxSelectNumber() {
    return MAX_RESOURCE_NUMBER - PickerUtil.mediaPreviewList.length;
  }

  public static async selectResource(type: PickerResourceType) {
    switch (type) {
      case PickerResourceType.IMAGE:
        await PickerUtil._getMediaFromAlbum(photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE);
        break;
      case PickerResourceType.VIDEO:
        await PickerUtil._getMediaFromAlbum(photoAccessHelper.PhotoViewMIMETypes.VIDEO_TYPE);
        break;
      case PickerResourceType.AUDIO:
        await PickerUtil._getAudioFromFile();
        break;
      default:
        break;
    }
  }

  public static clearResource() {
    PickerUtil.mediaPreviewList = [];
    PickerUtil.selectedNum = 0;
  }

  private static async _getAudioFromFile() {
    const audioSelectOptions = new picker.AudioSelectOptions();
    const context = getContext() as common.Context;
    const audioViewPicker = new picker.AudioViewPicker(context);
    audioViewPicker.select(audioSelectOptions).then((audioSelectResult: string[]) => {
      const uri = audioSelectResult[0];
      const fileName = '音频文件';
      const item: PickerPreviewItem = {
        type: PickerResourceType.AUDIO,
        uri,
        fileName,
      };
      PickerUtil.mediaPreviewList.push(item);
      Logger.info(TAG, 'audioViewPicker select successfully, audioSelectResult uri is:' + audioSelectResult[0]);
    }).catch((err: BusinessError) => {
      Logger.error(TAG, `AudioViewPicker select failed, code is ${err.code}, message is ${err.message}`);
    });
  }

  public static deleteItem(index: number) {
    PickerUtil.mediaPreviewList.splice(index, 1);
  }

  private static _getMediaFromAlbum(resourceType: photoAccessHelper.PhotoViewMIMETypes) {
    let photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
    photoSelectOptions.MIMEType = resourceType;
    photoSelectOptions.maxSelectNumber = PickerUtil.maxSelectNumber;
    let photoPicker = new photoAccessHelper.PhotoViewPicker();
    return photoPicker.select(photoSelectOptions).then((photoSelectResult) => {
      if (photoSelectResult !== null && photoSelectResult !== undefined) {
        photoSelectResult.photoUris.forEach((uri) => {
          const item: PickerPreviewItem = {
            uri,
            type: resourceType === photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE ? PickerResourceType.IMAGE :
            PickerResourceType.VIDEO,
          };
          PickerUtil.mediaPreviewList.push(item);
        });
      }
      Logger.info(TAG, 'PhotoViewPicker.select successfully, PhotoSelectResult uri: ' +
      JSON.stringify(PickerUtil.mediaPreviewList));
    }).catch((err: BusinessError) => {
      Logger.error(TAG, `PhotoViewPicker select failed, code is ${err.code}, message is ${err.message}.`);
    });
  }
}
