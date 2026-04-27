/*
Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
*/

import { Context } from '@kit.AbilityKit';
import { camera } from '@kit.CameraKit';
import { cameraPicker } from '@kit.CameraKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { Logger } from '../logger/AppLogger';

const TAG = 'CameraUtil'

export class CameraUtil {
  public static async takePicture(context: Context): Promise<string | undefined> {
    let cameraPosition: camera.CameraPosition = camera.CameraPosition.CAMERA_POSITION_BACK;
    let mediaType: cameraPicker.PickerMediaType = cameraPicker.PickerMediaType.PHOTO;
    try {
      let pickerProfile: cameraPicker.PickerProfile = { cameraPosition: cameraPosition };
      let pickerResult: cameraPicker.PickerResult = await cameraPicker.pick(context, [mediaType], pickerProfile);
      if (!pickerResult.resultUri) {
        return '';
      }
      return pickerResult.resultUri
    } catch (error) {
      let err = error as BusinessError;
      Logger.info(TAG, JSON.stringify(err))
      return '';
    }
  }

  public static async pickPicture(maxSelectNumber: number, isPhotoTakingSupported: boolean = true): Promise<string[]> {
    let uris: string[] = []
    let photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
    photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
    photoSelectOptions.maxSelectNumber = maxSelectNumber;
    photoSelectOptions.isPhotoTakingSupported = isPhotoTakingSupported;
    photoSelectOptions.isPreviewForSingleSelectionSupported = false;
    photoSelectOptions.isOriginalSupported = true;
    let photoPicker = new photoAccessHelper.PhotoViewPicker();
    let res = await photoPicker.select(photoSelectOptions);
    if (res) {
      uris = res.photoUris;
    }
    return uris;
  }
}