import { pushService } from '@kit.PushKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { identifier } from '@kit.AdsKit';
import { abilityAccessCtrl, common, PermissionRequestResult } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { fileIo, storageStatistics } from '@kit.CoreFileKit';
import fs from '@ohos.file.fs';

/**
 * 获取push推送token
 **/
export async function getTokenSyn(): Promise<string> {
  try {
    const pushToken = await pushService.getToken();
    return pushToken;
  } catch (err) {
    let e: BusinessError = err as BusinessError;
    hilog.error(0x0000, 'testTag', 'Get push token catch error: %{public}d %{public}s', e.code, e.message);
    return '';
  }
}

/**
 * 进入页面时，向用户请求授权广告跨应用关联访问权限
 **/

export async function requestOAIDTrackingConsentPermissions(context: common.Context) {
  // 进入页面时，向用户请求授权广告跨应用关联访问权限
  const atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
  let result = await atManager.requestPermissionsFromUser(context, ['ohos.permission.APP_TRACKING_CONSENT'])
  if (result.authResults[0] === 0) {
    const oaid = await identifier.getOAID()
    return oaid
  }
  return ''
}

/*
 * 相册picker
 * */

export async function getPictureFromAlbum() {
  // 拉起相册，选择图片
  let photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
  photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
  photoSelectOptions.maxSelectNumber = 1;
  let photoPicker = new photoAccessHelper.PhotoViewPicker();
  let photoSelectResult: photoAccessHelper.PhotoSelectResult = await photoPicker.select(photoSelectOptions);
  return photoSelectResult.photoUris[0]
}

// 获取应用数据空间大小
export async function getCache(): Promise<number> {
  return new Promise((resolve, reject) => {
    storageStatistics.getCurrentBundleStats().then((BundleStats: storageStatistics.BundleStats) => {
      resolve(BundleStats.cacheSize)
    }).catch((err: BusinessError) => {
      reject('error')
      console.error('getCurrentBundleStats failed with error:' + JSON.stringify(err));
    });
  })
}

// 清理缓存
export async function clearCache(context: Context): Promise<string> {
  let cacheDir = context.cacheDir;
  console.info(cacheDir);

  return new Promise((resolve, reject) => {
    fileIo.listFile(cacheDir).then((filenames) => {
      for (let i = 0; i < filenames.length; i++) {
        let dirPath = cacheDir + '/' + filenames[i];
        console.log(dirPath);
        // 判断是否为文件夹
        let isDirectory: boolean = false;
        try {
          isDirectory = fileIo.statSync(dirPath).isDirectory();
        } catch (e) {
          console.error(JSON.stringify(e));
        }

        if (isDirectory) {
          fileIo.rmdirSync(dirPath);
        } else {
          fileIo.unlink(dirPath).then(() => {
            resolve('success')
          }).catch((err: Error) => {
            reject('error')
            console.error('remove file failed with error message: ' + err.message);
          });
        }
      }

    })
  })
}

export async function choosePhoto() {
  // 设置图片选择器选项
  const photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
  // 限制只能选择一张图片
  photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
  photoSelectOptions.maxSelectNumber = 1;
  // 创建并实例化图片选择器
  const photoViewPicker = new photoAccessHelper.PhotoViewPicker();
  // 选择图片并获取图片URI
  let uris: photoAccessHelper.PhotoSelectResult = await photoViewPicker.select(photoSelectOptions);
  if (!uris || uris.photoUris.length === 0) {
    return '';
  }
  return uris.photoUris[0]
}