import { UtilLog } from '@hw-agconnect/util-log';
import { image } from '@kit.ImageKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { getInstance, RouterMap } from '../util/Route';
import { EditParms } from '../model/Index';
import { toastUtil } from '../util/ToastUtil';


@ObservedV2
export class SavePhotoPageVM {
  @Trace img: image.PixelMap | undefined = undefined;
  @Trace ratio: number = 1;
  private static _instance: SavePhotoPageVM;

  public static get instance() {
    if (!SavePhotoPageVM._instance) {
      SavePhotoPageVM._instance = new SavePhotoPageVM();
    }
    return SavePhotoPageVM._instance;
  }

  showLoading: () => void = () => {

  };
  closeLoading: () => void = () => {

  };

  public getRouteParam() {
    const res: EditParms = getInstance().getParamByName(RouterMap.SAVE)[0] as EditParms;
    this.img = res.img;
    this.ratio = res.size.height / res.size.width;
  }


  // 保存图片
  async savePhoto(cxt: Context | undefined) {
    if (!cxt) {
      return;
    }
    this.showLoading();
    try {
      const imagePackerApi: image.ImagePacker = image.createImagePacker();
      let packOpts: image.PackingOption = { format: 'image/png', quality: 100 };
      let arrayBuffer = await imagePackerApi.packToData(this.img, packOpts);
      let helper = photoAccessHelper.getPhotoAccessHelper(cxt);
      // onClick触发后10秒内通过createAsset接口创建图片文件，10秒后createAsset权限收回
      let uri = await helper.createAsset(photoAccessHelper.PhotoType.IMAGE, 'png');
      let file: fs.File | undefined = undefined;
      try {
        // 使用uri打开文件，可以持续写入内容，写入过程不受时间限制
        file = await fs.open(uri, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
        // 写入文件
        await fs.write(file.fd, arrayBuffer);
        toastUtil.showToast('保存成功，请前往图库查看！');
      } catch (e) {
        toastUtil.showToast('保存失败！');
      } finally {
        if (file) {
          // 关闭文件
          fs.closeSync(file.fd);
        }
        this.closeLoading();
      }
    } catch (e) {
      UtilLog.error(`onKeyboardChange failed with error ${JSON.stringify(e)}`);
    }
  }
}