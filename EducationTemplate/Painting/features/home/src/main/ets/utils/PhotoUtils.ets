import { photoAccessHelper } from '@kit.MediaLibraryKit';
import fs from '@ohos.file.fs';
import { BusinessError } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';
import { buffer } from '@kit.ArkTS';
import { GlobalContext } from 'common';
import { image } from '@kit.ImageKit';

export class PhotoUtils {
  /**
   * 用系统picker，拉起相册或者相机
   * @param params
   * @returns
   */
  public static selectPhoto(): Promise<string[]> {
    const photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
    photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
    photoSelectOptions.maxSelectNumber = 1; // 最大选择数量为1
    let uris: string[] = [];
    const photoViewPicker = new photoAccessHelper.PhotoViewPicker();
    return photoViewPicker.select(photoSelectOptions).then((photoSelectResult: photoAccessHelper.PhotoSelectResult) => {
      uris = photoSelectResult.photoUris;
      return uris;
    }).catch((err: BusinessError) => {
      return uris;
    })
  }

  /**
   * 保存图片到沙箱
   * @param uris
   * @returns
   */
  static async saveAlbumToBox(uri: string) {
    const context = GlobalContext.getUIContext().getHostContext()
    let file: fs.File = fs.openSync(uri, fs.OpenMode.READ_ONLY)
    const newPath: string = context?.tempDir! + Date.now() + '.png';
    try {
      fs.copyFileSync(file.fd, newPath);
      return 'file://' + newPath
    } catch (err) {
      return ''
    } finally {
      fs.closeSync(file.fd);
    }
  }

  //保存PixelMap到沙箱
  static async savePixelMapToBox(pixelMap: image.PixelMap, region?: image.Region) {
    const imagePackerApi = image.createImagePacker();
    const packOpts: image.PackingOption = { format: 'image/jpeg', quality: 95 };
    const filePath = GlobalContext.getUIContext().getHostContext()?.tempDir! + Date.now() + '.jpg';
    const file = fs.openSync(filePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE)
    try {
      //图片裁剪
      if (region) {
        await pixelMap.crop(region)
      }
      const arrayBuffer = await imagePackerApi.packToData(pixelMap, packOpts);
      fs.writeSync(file.fd, arrayBuffer);
      return 'file://' + filePath
    } catch (error) {
      return ''
    } finally {
      fs.closeSync(file.fd)
    }
  }

  /**
   * 保存绘画内容到沙箱
   * @param context
   */
  static async saveDrawingToBox(dataUrl: string) {
    const imgPath = GlobalContext.getUIContext().getHostContext()?.tempDir! + Date.now() + '.jpg'
    const file = fs.openSync(imgPath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE)
    const reg = new RegExp('data:image/\\w+;base64,')
    try {
      const base64 = dataUrl.replace(reg, '');
      const dataBuffer = buffer.from(base64, 'base64')
      fs.writeSync(file.fd, dataBuffer.buffer);
      return 'file://' + imgPath
    } catch (err) {
      return ''
    } finally {
      fs.closeSync(file.fd);
    }
  }

  /**
   * 从沙箱保存到相册
   * @param context
   */
  static async saveImageToAlbum(imgPath: string) {
    let context: common.UIAbilityContext = GlobalContext.getUIAbilityContext()
    let phAccessHelper = photoAccessHelper.getPhotoAccessHelper(context);
    let albumUri = await phAccessHelper.createAsset(photoAccessHelper.PhotoType.IMAGE, 'jpg');
    const srcFile = fs.openSync(imgPath, fs.OpenMode.READ_ONLY);
    const baseFile = fs.openSync(albumUri, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
    try {
      await fs.copyFile(srcFile.fd, baseFile.fd);
      GlobalContext.getUIContext()
        .getPromptAction()
        .showToast({ message: '图片已保存至' + albumUri, duration: 1000, alignment: Alignment.Bottom })
    } catch (err) {
      GlobalContext.getUIContext()
        .getPromptAction()
        .showToast({ message: '图片保存失败' + err.message, duration: 1000, alignment: Alignment.Bottom })
    } finally {
      fs.closeSync(srcFile.fd);
      fs.closeSync(baseFile.fd);
    }
    return albumUri
  }
}