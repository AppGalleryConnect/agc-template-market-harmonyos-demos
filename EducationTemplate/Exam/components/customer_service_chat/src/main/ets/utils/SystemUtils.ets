import { abilityAccessCtrl, common, Permissions } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { camera, cameraPicker } from '@kit.CameraKit';
import { fileUri, fileIo as fs } from '@kit.CoreFileKit';
import { petalMaps, sceneMap } from '@kit.MapKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { LocationInfo } from '../models/MessageModel';

const TAG = '[SystemUtils]';

/**
 * 拉起图库选择器
 *
 * @param maxSelectNumber - 最大选择数量
 * @returns 返回所选图片 URI 列表
 */
export async function pickPhoto(maxSelectNumber: number): Promise<string[]> {
  try {
    let photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
    photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
    photoSelectOptions.isEditSupported = true;
    photoSelectOptions.isOriginalSupported = true;
    photoSelectOptions.completeButtonText = photoAccessHelper.CompleteButtonText.TEXT_DONE;
    photoSelectOptions.maxSelectNumber = maxSelectNumber;

    const picker: photoAccessHelper.PhotoViewPicker = new photoAccessHelper.PhotoViewPicker();
    const result: photoAccessHelper.PhotoSelectResult = await picker.select(photoSelectOptions);
    hilog.info(0x0000, TAG, 'PhotoViewPicker.select succeed, uri: ' + JSON.stringify(result));
    return result.photoUris;
  } catch (err) {
    hilog.error(0x0000, TAG, `PhotoViewPicker failed, error: ${err.code}, ${err.message}`);
    return [];
  }
}

/**
 * 拉起系统相机
 *
 * @param context - 上下文
 * @returns
 */
export async function takePhoto(context: common.UIAbilityContext): Promise<cameraPicker.PickerResult> {
  let pathDir = context.cacheDir;
  let fileName = `${Date.now()}`;
  let filePath = pathDir + `/${fileName}.png`;
  try {
    fs.createRandomAccessFileSync(filePath, fs.OpenMode.CREATE);
  } catch (err) {
    hilog.error(0x0000, TAG, `create picker profile failed, error: ${err.code}, ${err.message}`);
  }

  let uri = fileUri.getUriFromPath(filePath);
  let pickerProfile: cameraPicker.PickerProfile = {
    cameraPosition: camera.CameraPosition.CAMERA_POSITION_BACK,
    saveUri: uri,
  };

  let result: cameraPicker.PickerResult =
    await cameraPicker.pick(context, [cameraPicker.PickerMediaType.PHOTO], pickerProfile);
  hilog.info(0x0000, TAG,
    `picker resultCode: ${result.resultCode},resultUri: ${result.resultUri},mediaType: ${result.mediaType}`);
  return result;
}

/**
 * 请求位置或麦克风权限
 *
 * @param context - 上下文
 * @returns
 */
export async function requestPermissionsFromUser(requestType: string,
  context: common.UIAbilityContext): Promise<boolean> {
  try {
    let atManager = abilityAccessCtrl.createAtManager();
    const permissions: Array<Permissions> =
      requestType === 'Location' ? ['ohos.permission.LOCATION', 'ohos.permission.APPROXIMATELY_LOCATION'] :
        ['ohos.permission.MICROPHONE'];
    const data = await atManager.requestPermissionsFromUser(context, permissions);
    if (data.authResults.every(result => result === 0)) {
      hilog.info(0x0000, TAG, '%{public}s', 'permission authorized');
      return true;
    } else {
      hilog.error(0x0000, TAG, '%{public}s', 'user refuse');
      return false;
    }
  } catch (err) {
    hilog.error(0x0000, TAG, '%{public}s', 'request fail err: ' + JSON.stringify(err));
    return false;
  }
}

/**
 * 选择位置
 *
 * @param context - 上下文
 * @returns
 */
export async function chooseLocation(context: common.UIAbilityContext): Promise<sceneMap.LocationChoosingResult> {
  const requestResult = await requestPermissionsFromUser('Location', context);
  return new Promise((resolve, reject) => {
    if (requestResult) {
      try {
        const locationChoosingOptions: sceneMap.LocationChoosingOptions = {
          language: 'zh',
          // 展示搜索控件
          searchEnabled: true,
          // 展示附近POI
          showNearbyPoi: true,
          // 返回映射快照
          snapshotEnabled: true,
        };
        // 拉起地点选取页
        sceneMap.chooseLocation(context, locationChoosingOptions).then((data) => {
          hilog.info(0x0000, TAG, '%{public}s',
            'chooseLocation Succeeded in choosing location. ' + JSON.stringify(data));
          resolve(data);
        }).catch((err: BusinessError) => {
          hilog.info(0x0000, TAG, '%{public}s', 'chooseLocation Failed to choose location. ' + JSON.stringify(err));
          reject(err);
        });
      } catch (err) {
        hilog.info(0x0000, TAG, '%{public}s', 'chooseLocation err. ' + JSON.stringify(err));
        reject(err);
      }
    } else {
      hilog.error(0x0000, TAG, '%{public}s', 'request fail');
      reject();
    }
  })
}

/**
 * 打开地图应用查看地点详情
 *
 * @param locationInfo - 位置信息
 * @param context - 上下文
 * @returns
 */
export async function displayLocation(locationInfo: LocationInfo, context: Context) {
  try {
    let params: petalMaps.PoiDetailParams = {
      destinationPosition: {
        latitude: locationInfo.locationLatitude,
        longitude: locationInfo.locationLongitude
      },
      destinationPoiId: locationInfo.siteId,
      destinationName: locationInfo.name,
    };
    await petalMaps.openMapPoiDetail(context, params);
  } catch (e) {
    hilog.error(0x0000, 'TAG', `code:${e.code}, message:${e.message}`);
  }
}
