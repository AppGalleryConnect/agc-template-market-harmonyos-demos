import { image } from '@kit.ImageKit';
import { fileIo } from '@kit.CoreFileKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { ToastDialog as promptAction } from '@hw-agconnect/ui-toast';
import { RouterMap, RouterModule, Logger, BeautyParam, OperateType } from 'commonlib';

@ObservedV2
export class ImageDownloadPageVM {
  @Trace capturePixelmap: image.PixelMap | undefined = undefined;

  getRouteParm() {
    this.capturePixelmap = RouterModule.getNavParam({ url: RouterMap.IMAGE_DOWNLOAD });
  }

  // 保存到相册
  async handleSaveButtonClick(context: Context) {
    let file: fileIo.File | undefined = undefined;
    try {
      const phAccessHelper = photoAccessHelper.getPhotoAccessHelper(context);
      const filePath = await phAccessHelper.createAsset(photoAccessHelper.PhotoType.IMAGE, 'jpeg');
      const imagePacker = image.createImagePacker();
      let imageBuffer = await imagePacker.packToData(this.capturePixelmap, {
        format: 'image/jpeg',
        quality: 100,
        needsPackProperties: true,
      });
      const mode = fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE;
      file = fileIo.openSync(filePath, mode);
      fileIo.writeSync(file.fd, imageBuffer);
      promptAction.showToast({ message: '保存图片到相册成功~' });
    } catch (err) {
      Logger.error('save to album error', JSON.stringify(err));
    } finally {
      if (file) {
        fileIo.close(file);
      }
    }
  }

  // 编辑照片
  async handleEditButtonClick() {
    if (!this.capturePixelmap) {
      return
    }
    let param: BeautyParam = {
      uris: [],
      operateType: OperateType.NONE,
      filterName: '',
      pixelMap: this.capturePixelmap,
    };
    RouterModule.getStack().removeByName(RouterMap.IMAGE_DOWNLOAD)
    RouterModule.getStack().removeByName(RouterMap.LUT_CAMERA_PAGE)

    RouterModule.push({ url: RouterMap.PICTURE_BEAUTIFICATION, param: param });
  }
}
