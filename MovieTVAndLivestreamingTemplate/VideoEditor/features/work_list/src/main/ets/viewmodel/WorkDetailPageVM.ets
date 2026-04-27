import { fileIo, fileUri } from '@kit.CoreFileKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { promptAction } from '@kit.ArkUI';
import { phoneRouterControl } from 'oh_router';
import { WorkViewModel } from 'video_common';
import { WorkListPageVM } from '../viewmodel/WorkListPageVM';

@ObservedV2
export class WorkDetailPageVM {
  private static _instance: WorkDetailPageVM;
  @Trace isShowDetail: boolean = false;
  @Trace videoWork: WorkViewModel = new WorkViewModel()
  workListPageVM: WorkListPageVM = WorkListPageVM.instance;

  public static get instance() {
    if (!WorkDetailPageVM._instance) {
      WorkDetailPageVM._instance = new WorkDetailPageVM();
    }
    return WorkDetailPageVM._instance;
  }

  // 初始化数据
  initData() {
    // 根据路由传参的id,查询该条数据信息
    this.videoWork =
      this.workListPageVM.workList.lists.find(item => item.id === this.workListPageVM.deleteId) as WorkViewModel;
  }

  // 将视频保存到相册
  async saveToAlbum(mContext: UIContext) {
    try {
      let phAccessHelper = photoAccessHelper.getPhotoAccessHelper(mContext.getHostContext());
      let videoSrc = this.videoWork.videoUrl
      let srcFileUri = videoSrc.startsWith('file://') ? videoSrc : fileUri.getUriFromPath(videoSrc)
      let srcFileUris: Array<string> = [
        srcFileUri
      ];
      // 指定待保存视频的创建选项，包括文件后缀和类型，标题和子类型可选
      let photoCreationConfigs: Array<photoAccessHelper.PhotoCreationConfig> = [
        {
          title: this.videoWork.title,
          fileNameExtension: this.videoWork.fileFormat,
          photoType: photoAccessHelper.PhotoType.VIDEO,
          subtype: photoAccessHelper.PhotoSubtype.DEFAULT,
        }
      ];
      let desFile: fileIo.File | undefined = undefined;
      let srcFile: fileIo.File | undefined = undefined;
      // 基于弹窗授权的方式获取媒体库的目标uri
      let desFileUris: Array<string> =
        await phAccessHelper.showAssetsCreationDialog(srcFileUris, photoCreationConfigs);
      try {
        // 将来源于应用沙箱的视频内容写入媒体库的目标uri
        desFile = await fileIo.open(desFileUris[0], fileIo.OpenMode.WRITE_ONLY);
        srcFile = await fileIo.open(srcFileUri, fileIo.OpenMode.READ_ONLY);
        await fileIo.copyFile(srcFile.fd, desFile.fd);
        promptAction.showToast({ message: '保存到相册成功' });
      } finally {
        fileIo.closeSync(srcFile);
        fileIo.closeSync(desFile);
      }
    } catch (err) {
    }
  }

  // 返回上一层页面
  backPage() {
    phoneRouterControl.popPage();
  }
}
