import { BusinessError } from '@kit.BasicServicesKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { camera, cameraPicker } from '@kit.CameraKit';
import { faceDetector, subjectSegmentation } from '@kit.CoreVisionKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { image } from '@kit.ImageKit';
import { UtilLog } from '@hw-agconnect/util-log';
import { Logger } from '../util/MyLog';
import { toastUtil } from '../util/ToastUtil';
import { getInstance, RouterMap } from '../util/Route';
import { PhotoTypeItem, PickerItem, EditParms } from '../model/Index';


@ObservedV2
export class CredentialsPageVM {
  @Trace img: image.PixelMap | undefined = undefined;
  @Trace photoTypeIndex: number = 0;
  @Trace pickerList: PickerItem[] = [
    {
      icon: $r('app.media.ic_credentials_picture'),
      text: '本地相册',
    },
    {
      icon: $r('app.media.ic_credentials_camera'),
      text: '相机拍摄',
    },
  ];
  @Trace photoTypeList: PhotoTypeItem[] = [
    {
      label: '一寸照片',
      size: {
        width: 25,
        height: 35,
      },
    },
    {
      label: '二寸照片',
      size: {
        width: 35,
        height: 49,
      },
    },
    {
      label: '学生证',
      size: {
        width: 33,
        height: 48,
      },
    },
    {
      label: '简历照片',
      size: {
        width: 25,
        height: 35,
      },
    },
    {
      label: '四六级',
      size: {
        width: 26,
        height: 32,
      },
    },
    {
      label: '护照',
      size: {
        width: 33,
        height: 48,
      },
    },
    {
      label: '司法考试',
      size: {
        width: 26,
        height: 32,
      },
    },
    {
      label: '驾驶证',
      size: {
        width: 22,
        height: 32,
      },
    },
    {
      label: '健康证',
      size: {
        width: 25,
        height: 35,
      },
    },
    {
      label: '美国签证',
      size: {
        width: 51,
        height: 51,
      },
    },
  ];
  private static _instance: CredentialsPageVM;

  public static get instance() {
    if (!CredentialsPageVM._instance) {
      CredentialsPageVM._instance = new CredentialsPageVM();
    }
    return CredentialsPageVM._instance;
  }

  showLoading: () => void = () => {

  };
  closeLoading: () => void = () => {

  };

  async selectPhoto() {
    try {
      let photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
      photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
      photoSelectOptions.maxSelectNumber = 1;
      let photoPicker = new photoAccessHelper.PhotoViewPicker();
      photoPicker.select(photoSelectOptions).then((photoSelectResult: photoAccessHelper.PhotoSelectResult) => {
        this.subjectSegmentation(photoSelectResult.photoUris[0]);
      }).catch((err: BusinessError) => {
        Logger.error(`PhotoViewPicker.select failed with err: ${err.code}, ${err.message}`);
      });
    } catch (error) {
      let err: BusinessError = error as BusinessError;
      Logger.error(`PhotoViewPicker failed with err: ${err.code}, ${err.message}`);
    }
  }


  async takePhoto(context: Context) {
    try {
      let pickerProfile: cameraPicker.PickerProfile = {
        cameraPosition: camera.CameraPosition.CAMERA_POSITION_BACK,
      };
      let pickerResult: cameraPicker.PickerResult = await cameraPicker.pick(context,
        [cameraPicker.PickerMediaType.PHOTO], pickerProfile);
      if (pickerResult.resultCode !== -1) {
        this.subjectSegmentation(pickerResult.resultUri);
      }
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(`the call failed. error code: ${err.code}`);
    }
  }

  async subjectSegmentation(uri: string) {
    // 置空上次保存图片
    this.img = undefined;
    let chooseImage: image.PixelMap | undefined = undefined;
    //将选择的图片转换为PixelMap
    let fileSource: fs.File | undefined = undefined;
    try {
      fileSource = await fs.open(uri, fs.OpenMode.READ_ONLY);
      let imageSource = image.createImageSource(fileSource.fd);
      chooseImage = await imageSource.createPixelMap();
      imageSource.release();
    } catch (error) {
      const err = error as BusinessError;
      Logger.error(`convert failed. error code: ${err.code}`);
    } finally {
      if (fileSource) {
        fs.closeSync(fileSource);
      }
    }

    if (!chooseImage) {
      Logger.info('chooseImage is undefined');
      return;
    }
    this.showLoading();
    // 初始化主体分割
    let initRes = false;
    // 兼容模拟器异常处理
    try {
      initRes = await subjectSegmentation.init();
    } catch (e) {
      this.closeLoading();
      toastUtil.showToast('本设备不支持人像处理！');
    }

    if (!initRes) {
      this.closeLoading();
      toastUtil.showToast('本设备不支持人像处理！');
      return;
    }

    // 调用主体分割接口
    const visionInfo: subjectSegmentation.VisionInfo = {
      pixelMap: chooseImage,
    };
    const config: subjectSegmentation.SegmentationConfig = {
      maxCount: 2,
      enableSubjectDetails: false,
      enableSubjectForegroundImage: true,
    };
    try {
      let data: subjectSegmentation.SegmentationResult = await subjectSegmentation.doSegmentation(visionInfo, config);
      this.img = data.fullSubject.foregroundImage;
    } catch (e) {
      this.closeLoading();
      toastUtil.showToast('图片处理失败！');
    }


    subjectSegmentation.release();
    if (chooseImage) {
      chooseImage.release();
    }
    if (this.img) {
      const faceList = await this.detectFace(this.img);
      if (faceList.length < 1) {
        this.closeLoading();
        toastUtil.showToast('未识别到人脸信息！');
        return;
      }
      const face = faceList[0];
      // 判断是否为人脸
      if (face.probability > 0.999) {
        const size = this.img.getImageInfoSync().size;
        // 当前照片对应比例
        const typeSize = this.photoTypeList[this.photoTypeIndex].size;
        const ratio = typeSize.height / typeSize.width;
        let region: image.Region = this.handleFaceImage(face.rect, size, ratio);
        // 裁剪图片,仅用于调整头像位置
        this.img.crop(region)
          .then(() => {
            Logger.info('Succeeded in cropping pixelmap.');
          })
          .catch((err: BusinessError) => {
            Logger.error(`Failed to crop pixelmap. code is ${err.code}, message is ${err.message}`);
          })
          .finally(() => {
            this.closeLoading();
            this.toEdit();
          });
      } else {
        this.closeLoading();
        toastUtil.showToast('需要清晰人像！');
      }
    } else {
      this.closeLoading();
      toastUtil.showToast('图片处理失败！');
    }


  }

  async detectFace(pixelMap: PixelMap): Promise<faceDetector.Face[]> {
    let res: faceDetector.Face[] = [];
    try {
      if (await faceDetector.init()) { // 初始化faceDetector
        let visionInfo: faceDetector.VisionInfo = { pixelMap: pixelMap };
        res = await faceDetector.detect(visionInfo); // 检测人脸
        await faceDetector.release(); // 完成后释放faceDetector
      }
    } catch (e) {
      UtilLog.error(`createCameraInput failed : ${JSON.stringify(e)}`)
    }

    return res;
  }


  // 脸部裁剪
  handleFaceImage(rect: faceDetector.FaceRectangle, size: image.Size, ratio: number) {
    // 照片宽度与脸部宽度比例
    let faceRatio = 2.2;
    if (ratio <= 1.3) {
      faceRatio = 3.0;
    }
    // 左侧留白占比
    const spaceRatio = (faceRatio - 1) / (2 * faceRatio);
    // 证件照中脸部占比
    let imgWidth = Math.min(rect.width * faceRatio, size.width);
    // 证件照高度
    let imgHeight = Math.min(imgWidth * ratio, size.height);
    // 左侧留白
    const left = Math.max((rect.left - (imgWidth * spaceRatio)), 0);
    // 头顶留白
    const top = Math.max((rect.top - imgHeight * 0.23), 0);

    if (rect.top - imgHeight * 0.23 < 0) {
      imgHeight = imgHeight + rect.top - imgHeight * 0.23;
    }
    const region: image.Region = { x: left, y: top, size: { width: imgWidth, height: imgHeight } };
    return region;
  }


  // 跳转编辑
  toEdit() {
    const photoType = this.photoTypeList[this.photoTypeIndex];
    if (this.img) {
      const params: EditParms = {
        label: photoType.label,
        size: photoType.size,
        img: this.img,
      };
      getInstance().pushPathByName(RouterMap.EDIT, params);
    }
  }
}

