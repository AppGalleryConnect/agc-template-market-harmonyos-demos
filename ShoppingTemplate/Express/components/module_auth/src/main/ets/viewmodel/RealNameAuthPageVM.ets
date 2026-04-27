import { camera, cameraPicker as picker } from '@kit.CameraKit';
import { fileIo } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';
import { IdCardInfo } from '../types';
import { PickerUtil } from '../common/PickerUtil';

@ObservedV2
export class RealNameAuthPageVM {
  stack: NavPathStack = new NavPathStack();
  @Trace showIdCardSheet: boolean = false;
  @Trace currentIdx: number = 0;
  @Trace idCardList: IdCardInfo[] = [
    new IdCardInfo(0, '头像面', $r('app.media.id_card_pic_1')),
    new IdCardInfo(1, '国徽面', $r('app.media.id_card_pic_2')),
    new IdCardInfo(2, '手持 身份证 照片', $r('app.media.id_card_pic_3')),
  ]

  // 拍照
  async takePhoto(context: common.UIAbilityContext) {
    let pathDir = context.filesDir;
    let fileName = `${new Date().getTime()}`
    let filePath = pathDir + `/${fileName}.tmp`
    fileIo.open(filePath, fileIo.OpenMode.CREATE);
    let pickerProfile: picker.PickerProfile = {
      cameraPosition: camera.CameraPosition.CAMERA_POSITION_FRONT,
    };
    let result: picker.PickerResult =
      await picker.pick(context, [picker.PickerMediaType.PHOTO], pickerProfile);
    if (result.resultCode === 0) {
      if (result.mediaType === picker.PickerMediaType.PHOTO) {
        const imgUri = result.resultUri
        this.setResult(imgUri);
      }
    }
  }

  // 从相册中选择
  pickerImage() {
    PickerUtil.selectPhoto({ maxSelectNumber: 1 }).then((uris) => {
      if (uris.length > 0) {
        this.setResult(uris[0])
      }
    });
  }

  setResult(imgUri: string) {
    const currentIdCard = this.idCardList.find((item) => item.id === this.currentIdx);
    if (currentIdCard) {
      currentIdCard.cardImg = imgUri;
    }
  }
}
