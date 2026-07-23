import {
  PickerController,
  PickerOptions,
  ItemInfo,
  ClickType,
  ItemType,
  ReminderMode,
  SelectMode,
} from '@kit.MediaLibraryKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { image } from '@kit.ImageKit';
import { BaseViewModel, BeautyParam, Logger, OperateType, RouterMap, RouterModule } from 'commonlib';
import { PhotoOperateParam, PhotoType } from '../common/Constants';


const TAG = '[PhotoPickerPageVM]'

@ObservedV2
export class PhotoPickerPageVM extends BaseViewModel {
  // 配置选择选项
  pickerOptions: PickerOptions = new PickerOptions();
  // 控制器，用于组件初始化后控制部分行为
  @Trace pickerController: PickerController = new PickerController();
  // 已选择的图片URI列表
  @Trace selectUris: string[] = [];
  // 图片类型： 美化和拼图
  @Trace photoType: PhotoType = PhotoType.Beautification;
  // 图片美化类型
  @Trace operateType: OperateType = OperateType.NONE;
  // 滤镜名称
  @Trace filterName?: string

  // 初始化
  initOptions() {
    // 获取页面参数
    let param = RouterModule.getNavParam({ url: RouterMap.PHOTO_PICKER_PAGE }) as PhotoOperateParam;
    if (param) {
      this.photoType = param.photoType;
      this.operateType = param.operateType;
      this.filterName = param.filterName
    }
    // 设置数据类型为图片
    this.pickerOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
    // 最大选择数量
    this.pickerOptions.maxSelectNumber = this.photoType === PhotoType.Collage ? 5 : 1;
    // 选择模式: 多选和单选
    this.pickerOptions.selectMode =
      this.photoType === PhotoType.Collage ? SelectMode.MULTI_SELECT : SelectMode.SINGLE_SELECT;
    // 单选模式下是否需要进大图预览
    this.pickerOptions.isPreviewForSingleSelectionSupported = false;
    // 超出最大选择数量时的提醒方式
    this.pickerOptions.maxSelectedReminderMode = ReminderMode.TOAST;
    // 是否展示搜索框
    this.pickerOptions.isSearchSupported = false;
    // 是否支持拍照
    this.pickerOptions.isPhotoTakingSupported = true;
  }

  // 资源选中回调
  onItemClicked(itemInfo: ItemInfo, clickType: ClickType): boolean {
    if (!itemInfo) {
      return false;
    }
    let type: ItemType | undefined = itemInfo.itemType;
    let uri: string | undefined = itemInfo.uri;
    if (type === ItemType.CAMERA) {
      // 点击相机item，返回true拉起系统相机
      return true;
    } else {
      if (clickType === ClickType.SELECTED) {
        // 选中操作
        if (uri && this.photoType === PhotoType.Beautification) {
          this.handlePhotoBeauty(uri);
          return false;
        }
        return true;
      } else {
        return true;
      }
    }
  }

  // 选择回调
  onSelect(uri: string): void {
    this.selectUris.push(uri);
    this.pickerOptions.preselectedUris = [...this.selectUris];
  }

  // 取消选择回调
  onDeselect(uri: string): void {
    this.selectUris = this.selectUris.filter((item: string) => item !== uri);
    this.pickerOptions.preselectedUris = [...this.selectUris];
  }

  // 处理图像美化
  handlePhotoBeauty(uri: string) {
    if (uri) {
      let resFile: fs.File = fs.openSync(uri, fs.OpenMode.READ_ONLY);
      try {
        const imageSource: image.ImageSource = image.createImageSource(resFile.fd);
        imageSource.createPixelMap().then((result: PixelMap) => {
          let param: BeautyParam = {
            pixelMap: result,
            uris: [],
            operateType: this.operateType,
            filterName: this.filterName,
          };
          RouterModule.push({ url: RouterMap.PICTURE_BEAUTIFICATION, param: param });
        });
      } catch (err) {
        Logger.error(TAG, `createImageSource failed, err: ${JSON.stringify(err)}`);
      } finally {
        fs.closeSync(resFile);
      }
    }
  }

  // 拼图
  handleCollage() {
    RouterModule.push({ url: RouterMap.COLLAGE_PAGE, param: this.selectUris });
  }
}