/**
 * 图片选择工具类 - 统一处理相机拍照和相册选择
 */
import { cameraPicker } from '@kit.CameraKit';
import { camera } from '@kit.CameraKit';
import { fileIo, fileUri } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { promptAction } from '@kit.ArkUI';

export type ImageSource = 'camera' | 'album';

export interface ImagePickResult {
  uri: string;
  source: ImageSource;
}

//图片选择工具类
export class ImagePickerUtil {
  //拍照
  static async takePicture(context: common.UIAbilityContext): Promise<string | null> {
    try {
      const cacheDir = context.cacheDir;
      const fileName = `IMG_${new Date().getTime()}.jpg`;
      const filePath = `${cacheDir}/${fileName}`;
      const fileUriPath = fileUri.getUriFromPath(filePath);

      // 创建空文件，确保文件存在
      let file: fileIo.File | undefined;
      try {
        file = fileIo.openSync(filePath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
      } catch (e) {
        // File creation failed
      } finally {
        if (file) {
          fileIo.closeSync(file);
        }
      }

      const pickerProfile: cameraPicker.PickerProfile = {
        cameraPosition: camera.CameraPosition.CAMERA_POSITION_BACK,
        saveUri: fileUriPath
      };

      const pickerResult: cameraPicker.PickerResult =
        await cameraPicker.pick(context, [cameraPicker.PickerMediaType.PHOTO], pickerProfile);

      // 如果resultUri为空，尝试使用我们预设的filePath
      let finalUri = (pickerResult && pickerResult.resultUri) ? pickerResult.resultUri : filePath;

      // 如果是URI格式，尝试转换为路径
      if (finalUri.startsWith('file://')) {
        try {
          new fileUri.FileUri(finalUri);
        } catch (e) {
          // Failed to parse URI
        }
      } else {
        // 如果是空字符串，且resultCode为0，意味着使用了saveUri但没有返回URI
        if (pickerResult.resultCode === 0 && !pickerResult.resultUri) {
          finalUri = filePath;
        }
      }

      if (pickerResult && pickerResult.resultCode === 0) {
        return finalUri;
      }

      return null;
    } catch (error) {
      promptAction.showToast({
        message: '拍照失败: ' + ((error as Error).message || '未知错误')
      });
      return null;
    }
  }

  //从相册选择图片
  static async selectFromAlbum(context: common.UIAbilityContext): Promise<string | null> {
    try {
      const photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
      photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
      photoSelectOptions.maxSelectNumber = 1;

      const photoViewPicker = new photoAccessHelper.PhotoViewPicker();
      const photoSelectResult: photoAccessHelper.PhotoSelectResult =
        await photoViewPicker.select(photoSelectOptions);

      if (photoSelectResult && photoSelectResult.photoUris && photoSelectResult.photoUris.length > 0) {
        const selectedUri = photoSelectResult.photoUris[0];

        // 将选中的图片复制到缓存目录，以确保有权限处理
        const cacheDir = context.cacheDir;
        const fileName = `ALBUM_${new Date().getTime()}.jpg`;
        const filePath = `${cacheDir}/${fileName}`;

        let file: fileIo.File | undefined;
        try {
          file = fileIo.openSync(selectedUri, fileIo.OpenMode.READ_ONLY);
          fileIo.copyFileSync(file.fd, filePath);

          const finalUri = fileUri.getUriFromPath(filePath);
          return finalUri;
        } catch (e) {
          // 如果复制失败，尝试直接使用URI
          return selectedUri;
        } finally {
          if (file) {
            fileIo.closeSync(file);
          }
        }
      }

      return null;
    } catch (error) {
      promptAction.showToast({
        message: '选择图片失败: ' + ((error as Error).message || '未知错误')
      });
      return null;
    }
  }

  //显示选择对话框（拍照或相册）
  static showImageSourceDialog(
    _context: common.UIAbilityContext,
    _callback: (result: ImagePickResult | null) => void
  ): void {
    // 这里可以使用系统对话框或自定义弹窗
    // 暂时保留原有的组件方式，后续可以优化为统一的对话框
  }
}
