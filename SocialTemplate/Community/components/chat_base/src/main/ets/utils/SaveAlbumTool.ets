import { BusinessError } from '@kit.BasicServicesKit';
import common from '@ohos.app.ability.common';
import { picker } from '@kit.CoreFileKit';
import fs from '@ohos.file.fs';
import { buffer } from '@kit.ArkTS';
import { UIContext } from '@kit.ArkUI';

const TAG = 'SaveAlbumTool';

export class SaveAlbumTool {
  //保存视频到文本文件
  async saveHttpVideo(videoFilePath: string, context: UIContext) {
    const abilityContext = context.getHostContext() as common.UIAbilityContext
    try {
      // 在UIAbilityContext中调用
      const documentViewPicker = new picker.DocumentViewPicker(abilityContext);
      let videoName = videoFilePath.split('/').pop()
      videoName = videoName?.split('?').toString() ?? `${Date.now().toString()}.mp4`
      const documentSaveOptions = new picker.DocumentSaveOptions();
      documentSaveOptions.newFileNames = [videoName]; // 指定文件名
      documentSaveOptions.fileSuffixChoices = ['.mp4']; // 设置文件后缀

      documentViewPicker.save(documentSaveOptions).then((uris: Array<string>) => {
        if (uris.length > 0) {
          this.writeFileToPath(videoFilePath, uris[0], context)
        }
      }).catch((err: BusinessError) => {
      })
    } catch (error) {
    }
  }

  //保存到相册
  async saveAlbum(filePath: string, context: UIContext) {
    const abilityContext = context.getHostContext() as common.UIAbilityContext
    try {
      // 在UIAbilityContext中调用
      const documentViewPicker = new picker.DocumentViewPicker(abilityContext);

      let fileName = filePath.split('/').pop()
      fileName = fileName?.split('?')[0] ?? `${Date.now().toString()}.jpg`
      const documentSaveOptions = new picker.DocumentSaveOptions();
      documentSaveOptions.newFileNames = [fileName]; // 自定义文件名
      documentSaveOptions.fileSuffixChoices = ['.jpg', '.png']; // 限制可保存的格式

      documentViewPicker.save(documentSaveOptions).then((uris: Array<string>) => {
        if (uris.length > 0) {
          this.writeFileToPath(filePath, uris[0], context)
        }
      }).catch((err: BusinessError) => {
      })
    } catch (error) {
    }
  }

  private async writeFileToPath(filePath: string, desto: string, context: UIContext) {
    // 将沙箱视频内容写入buffer
    let oriFile: fs.File | undefined = undefined
    let fileInAlbum: fs.File | undefined = undefined
    try {
      oriFile = await fs.open(filePath, fs.OpenMode.READ_ONLY);
      const imgSize: number = (await fs.stat(oriFile.fd)).size;
      let arrayBuffer: ArrayBuffer = new ArrayBuffer(imgSize);
      let readLength: number = await fs.read(oriFile.fd, arrayBuffer);
      let imageBuffer: ArrayBuffer = buffer.from(arrayBuffer, 0, readLength).buffer;
      fileInAlbum = await fs.open(desto, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE)
      // 写入图库
      await fs.write(fileInAlbum.fd, imageBuffer);
      context.getPromptAction().showToast({
        message: '操作成功'
      })
    } catch (error) {
      context.getPromptAction().showToast({
        message: '操作失败'
      })
    } finally {
      // 关闭文件
      if (oriFile) {
        await fs.close(oriFile.fd);
      }

      if (fileInAlbum) {
        await fs.close(fileInAlbum.fd);
      }
    }
  }
}

export const saveAlbumTool = new SaveAlbumTool()
