import { systemShare } from '@kit.ShareKit';
import { uniformTypeDescriptor as utd } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { fileUri, fileIo as fs } from '@kit.CoreFileKit';
import { BusinessError, pasteboard } from '@kit.BasicServicesKit';
import { image } from '@kit.ImageKit';
import { promptAction } from '@kit.ArkUI';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { buffer } from '@kit.ArkTS';
import { ShareEventDispatcher } from './EventDispatcher';
import { ShareOptions } from '../model/Model';


export class PosterShare {
  context: Context = getContext(this)
  private static _instance: PosterShare

  public static get instance() {
    if (!PosterShare._instance) {
      PosterShare._instance = new PosterShare()
    }
    return PosterShare._instance
  }

  public setContext(context: Context) {
    this.context = context
  }

  public async share(qrCodeInfo: ShareOptions) {
    let shareData: systemShare.SharedData = new systemShare.SharedData({
      utd: utd.UniformDataType.TEXT,
      content: qrCodeInfo.coverUrl ?? '',
      title: qrCodeInfo.title,
      description: `${qrCodeInfo.createTime}`,
    });

    let controller: systemShare.ShareController = new systemShare.ShareController(shareData);
    let context = getContext(this) as common.UIAbilityContext;
    controller.show(context, {
      selectionMode: systemShare.SelectionMode.SINGLE,
      previewMode: systemShare.SharePreviewMode.DETAIL,
    }).then(() => {
      console.info('ShareController show success.');
    }).catch((error: BusinessError) => {
      console.error(`ShareController show error. code: ${error.code}, message: ${error.message}`);
    });
    controller.on('dismiss', () => {
      ShareEventDispatcher.dispatchToClose()
    })
  }

  public copy(qrCodeInfo: ShareOptions) {
    try {
      const pasteboardData =
        pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN,
          qrCodeInfo.coverUrl ?? 'www.vmall.com/index.html?cid=128688')
      const systemPasteboard = pasteboard.getSystemPasteboard()
      systemPasteboard.setData(pasteboardData)
      promptAction.showToast({ message: '复制成功' })
    } catch (e) {
    }
  }

  public async saveImage(cover: PixelMap, popClose: (isClose: boolean) => void) {
    const imagePacker = image.createImagePacker();
    const options: image.PackingOption = {
      format: 'image/jpeg',
      quality: 100,
    };
    const filesDir = this.context.cacheDir;
    const savePath = `${filesDir}/${new Date().getTime()}.png`;
    let file: fs.File = null!;
    let file1: fs.File = null!;
    let file2: fs.File = null!;
    try {
      file = await fs.open(savePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      const packOutput = await imagePacker.packing(cover, options);
      await fs.write(file.fd, packOutput);
    } finally {
      await fs.close(file);
    }
    let uri = fileUri.getUriFromPath(savePath)
    let phAccessHelper = photoAccessHelper.getPhotoAccessHelper(this.context);
    try {
      let srcFileUris: Array<string> = [
        uri,
      ];
      let photoCreationConfigs: Array<photoAccessHelper.PhotoCreationConfig> = [
        {
          fileNameExtension: 'jpg',
          photoType: photoAccessHelper.PhotoType.IMAGE,
        },
      ];
      /*
       * 调用此接口时请确保module.json5文件中的abilities标签中配置了label和icon项。
       * */
      let desFileUris: Array<string> = await phAccessHelper.showAssetsCreationDialog(srcFileUris, photoCreationConfigs);
      file1 = fs.openSync(savePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      let arrayBuffer = new ArrayBuffer(4096000);
      let readLen = fs.readSync(file1.fd, arrayBuffer);
      let buf = buffer.from(arrayBuffer, 0, readLen);
      file2 = fs.openSync(desFileUris[0], fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      fs.writeSync(file2.fd, arrayBuffer);
      promptAction.showToast({ message: '保存成功' })
      popClose(false)
    } catch (err) {
      promptAction.showToast({ message: '保存失败' })
    } finally {
      fs.closeSync(file2);
      fs.closeSync(file1);
    }
  }
}