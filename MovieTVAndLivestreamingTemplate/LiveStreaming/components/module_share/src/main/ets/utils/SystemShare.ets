import { systemShare } from '@kit.ShareKit';
import { uniformTypeDescriptor as utd } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { fileUri, fileIo as fs } from '@kit.CoreFileKit';
import { BusinessError, pasteboard } from '@kit.BasicServicesKit';
import { image } from '@kit.ImageKit';
import { SheetShowVM } from '../viewModel/SheetShowVM';
import { promptAction } from '@kit.ArkUI';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { buffer } from '@kit.ArkTS';


export class PosterShare {
  private context: common.Context | undefined;
  private static _instance: PosterShare
  shareShowVM: SheetShowVM = SheetShowVM.instance

  public static get instance() {
    if (!PosterShare._instance) {
      PosterShare._instance = new PosterShare()
    }
    return PosterShare._instance
  }

  public setContext(context: Context) {
    this.context = context
  }

  public async share(context: UIContext) {
    let shareData: systemShare.SharedData = new systemShare.SharedData({
      utd: utd.UniformDataType.TEXT,
      content: 'www.vmall.com/index.html?cid=128688',
      title: this.shareShowVM.title,
      description: `${this.shareShowVM.articleFrom}  ${this.shareShowVM.createTime}`,
    });

    let controller: systemShare.ShareController = new systemShare.ShareController(shareData);
    controller.show(context.getHostContext() as common.UIAbilityContext, {
      selectionMode: systemShare.SelectionMode.SINGLE,
      previewMode: systemShare.SharePreviewMode.DETAIL,
    }).then(() => {
      console.info('ShareController show success.');
    }).catch((error: BusinessError) => {
      console.error(`ShareController show error. code: ${error.code}, message: ${error.message}`);
    });
  }

  public copy(context: UIContext) {
    try {
      const pasteboardData =
        pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, 'www.vmall.com/index.html?cid=128688')
      const systemPasteboard = pasteboard.getSystemPasteboard()
      systemPasteboard.setData(pasteboardData)
      systemPasteboard.getData().then((data) => {
        if (data) {
          context.getPromptAction().showToast({ message: '复制成功' })
        } else {
          context.getPromptAction().showToast({ message: '复制失败' })
        }
      })
    } catch (e) {
    }
  }

  public async saveImage(context: UIContext) {
    const imagePacker = image.createImagePacker();
    const options: image.PackingOption = {
      format: 'image/jpeg',
      quality: 100,
    };
    const filesDir = (context.getHostContext() as common.UIAbilityContext).filesDir;
    const savePath = `${filesDir}/${new Date().getTime()}.png`;
    let file: fs.File = null!;
    let file1: fs.File = null!;
    let file2: fs.File = null!;
    try {
      file = await fs.open(savePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      const packOutput = await imagePacker.packToData(this.shareShowVM.posterImage as image.PixelMap, options);
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
          title: '直播模板',
          fileNameExtension: 'jpg',
          photoType: photoAccessHelper.PhotoType.IMAGE,
        },
      ];
      let desFileUris: Array<string> = await phAccessHelper.showAssetsCreationDialog(srcFileUris, photoCreationConfigs);
      file1 = fs.openSync(savePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      let arrayBuffer = new ArrayBuffer(4096000);
      let readLen = fs.readSync(file1.fd, arrayBuffer);
      let buf = buffer.from(arrayBuffer, 0, readLen);
      file2 = fs.openSync(desFileUris[0], fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      fs.writeSync(file2.fd, arrayBuffer);
      context.getPromptAction().showToast({ message: '保存成功' })
      this.shareShowVM.sharePopShow = false
    } catch (err) {
      context.getPromptAction().showToast({ message: '保存失败' })
    } finally {
      fs.closeSync(file2);
      fs.closeSync(file1);
    }
  }
}