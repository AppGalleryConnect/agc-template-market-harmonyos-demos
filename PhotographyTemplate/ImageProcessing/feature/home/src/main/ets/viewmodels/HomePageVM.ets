import { deviceInfo } from '@kit.BasicServicesKit';
import { ToastDialog } from '@hw-agconnect/ui-toast';
import { BaseViewModel, OperateType, RouterMap, RouterModule } from 'commonlib';
import { PhotoOperateParam, PhotoType } from '../common/Constants';

const TAG = '[HomePageVM]'

@ObservedV2
export class HomePageVM extends BaseViewModel {

  @Computed
  get imgAspectRatio() {
    return this.breakPointModel.isMoreMD ? 1.63 : 0.75;
  }

  // 图片选择
  photoPicker(operateType: OperateType, filterName?: string) {
    const param = {
      photoType: PhotoType.Beautification,
      operateType,
      filterName
    } as PhotoOperateParam
    RouterModule.push({ url: RouterMap.PHOTO_PICKER_PAGE, param: param });
  }

  // 相机
  takePhoto() {
    if (deviceInfo.productModel === 'emulator') {
      ToastDialog.showToast({
        message: '本功能不支持模拟器！',
      })
    } else {
      RouterModule.push({ url: RouterMap.LUT_CAMERA_PAGE });
    }
  }

  // 拼图
  collage() {
    const param = {
      photoType: PhotoType.Collage,
      operateType: OperateType.NONE,
    } as PhotoOperateParam
    RouterModule.push({ url: RouterMap.PHOTO_PICKER_PAGE, param: param });
  }
}