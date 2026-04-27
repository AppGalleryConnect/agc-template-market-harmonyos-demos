import { MessageEvents, ThreadWorkerGlobalScope, worker } from '@kit.ArkTS';
import { FileBasic, FileType, MainFile, WorkerMessageType } from '../common/Constant';
import { FileSaveVo } from '../model/FileSaveVo';
import { FileUtil, saveImageToAlbum, saveVideoToAlbum } from '../utils/FileUtil';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { common } from '@kit.AbilityKit';
import { dataSharePredicates } from '@kit.ArkData';
import { CloneFile, WorkerMessage } from '../model/WorkerMessage';

const workerPort: ThreadWorkerGlobalScope = worker.workerPort;

workerPort.onmessage = (event: MessageEvents) => {
  let data = event.data as WorkerMessage;
  switch (data.type) {
    case WorkerMessageType.SAVE_FILE:
      saveFile(data.context as common.UIAbilityContext, data.data as FileSaveVo);
      break;
    case WorkerMessageType.GET_CLONE_FILE:
      getCloneFiles(data.context as common.UIAbilityContext)
      break
  }
  const fileSaveVo: FileSaveVo = event.data.data
  if (fileSaveVo.type === FileType.IMAGE) {
    saveImageToAlbum(event.data.context, fileSaveVo.data)
  } else {
    saveVideoToAlbum(event.data.context, fileSaveVo.data)
  }
};

function saveFile(context: common.UIAbilityContext, fileSaveVo: FileSaveVo) {
  if (fileSaveVo.type === FileType.IMAGE) {
    saveImageToAlbum(context, fileSaveVo.data)
  } else {
    saveVideoToAlbum(context, fileSaveVo.data)
  }
}

async function getCloneFiles(context: common.UIAbilityContext) {
  const image = new MainFile()
  const video = new MainFile()
  // 图片和视频
  try {
    let phAccessHelper = photoAccessHelper.getPhotoAccessHelper(context);
    let predicates: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    let fetchOption: photoAccessHelper.FetchOptions = {
      fetchColumns: [],
      predicates: predicates,
    };
    let fetchResult: photoAccessHelper.FetchResult<photoAccessHelper.PhotoAsset> =
      await phAccessHelper.getAssets(fetchOption);
    fetchResult.getAllObjects( async (err, photoAssetList) => {
      if (photoAssetList !== undefined) {
        photoAssetList.forEach((data) => {
          if (data.photoType === 1) {
            image.list.push({
              uri: data.uri,
              size: 0,
            })
            image.size += 1
          } else {
            video.list.push({
              uri: data.uri,
              size: 0,
            })
            video.size += 1
          }
        })
        if (image.size > 0) {
          for (let index = 0; index < image.list.length; index++) {
            const data = image.list[index];
            const fileInfo = await FileUtil.getFileInfo(data.uri, FileType.IMAGE)
            if (fileInfo) {
              data.size = fileInfo.size
            }
          }
          image.fileSize = getAllSize(image.list)
        }
        if (video.size > 0) {
          for (let index = 0; index < video.list.length; index++) {
            const data = video.list[index];
            const fileInfo = await FileUtil.getFileInfo(data.uri, FileType.VIDEO)
            if (fileInfo) {
              data.size = fileInfo.size
            }
          }
          video.fileSize = getAllSize(video.list)
        }
        workerPort.postMessage({
          type: WorkerMessageType.SEND_CLONE_FILE,
          data: { image, video } as CloneFile,
        } as WorkerMessage);
      } else {
        console.error(`photoAsset failed with err:${err.code}, ${err.message}`);
      }
    });
  } catch (e) {
    console.log(JSON.stringify(e))
  }
}

function getAllSize(fileList: FileBasic[]) {
  let size = 0
  fileList.forEach((data) => {
    size = size + data.size
  })
  return size
}