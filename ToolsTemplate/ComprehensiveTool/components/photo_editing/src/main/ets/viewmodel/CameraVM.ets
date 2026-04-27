import { BusinessError } from '@kit.BasicServicesKit';
import { PersistenceV2 } from '@kit.ArkUI';
import { image } from '@kit.ImageKit';
import { camera } from '@kit.CameraKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { UtilLog } from '@hw-agconnect/util-log';
import { fileIo } from '@kit.CoreFileKit';
import { UserInfoModel } from 'module_base';
import { CustomFilter } from '../model/CustomFilter';
import { formatToPixelMapFormatMap, pixelMapFormatToSizeMap } from '../constant/Constants';
import { PRESETS } from '../constant/Presets';
import { ImageProcessingUtil } from '../util/ImageProcessingUtil';
import { getInstance } from '../util/RouteModule';

@ObservedV2
export class CameraVM {
  @Trace filter: CustomFilter = PRESETS[0];
  @Trace pixelMap: PixelMap | undefined = undefined;
  @Trace capturePixelmap: PixelMap | undefined = undefined;
  @Trace imageReceiver: image.ImageReceiver | undefined = undefined;
  @Trace imageWidth: number = 1280;
  @Trace imageHeight: number = 720;
  @Trace isBusy: boolean = false;
  @Trace selectedFilterIndex: number = 0;
  filters: CustomFilter[] = PRESETS;
  private imageReceiverSurfaceId: string = '';
  @Trace context: Context | undefined = undefined;
  userInfoModel: UserInfoModel = PersistenceV2.connect(UserInfoModel, () => new UserInfoModel())!;
  @Trace isMember: boolean = false;
  private session: camera.PhotoSession | undefined = undefined;
  private previewOutput: camera.PreviewOutput | undefined = undefined;
  private cameraInput: camera.CameraInput | undefined = undefined;
  private photoOutput: camera.PhotoOutput | undefined = undefined;
  private cameraManager: camera.CameraManager | undefined = undefined;
  private imageObj: image.Image | undefined = undefined;
  private mCameraPosition: camera.CameraPosition = camera.CameraPosition.CAMERA_POSITION_BACK;
  private static _instance: CameraVM;

  public static get instance() {
    if (!CameraVM._instance) {
      CameraVM._instance = new CameraVM();
    }
    return CameraVM._instance;
  }

  setFilter(index: number) {
    this.filter = PRESETS[index];
  }

  /**
   * 获取ImageReceiver的SurfaceId
   * @param receiver
   * @returns
   */
  async initImageReceiver(): Promise<void> {
    if (!this.imageReceiver) {
      try {
        // 创建ImageReceiver。
        let size: image.Size = { width: this.imageWidth, height: this.imageHeight };
        this.imageReceiver = image.createImageReceiver(size, image.ImageFormat.JPEG, 8);
        // 获取第一路流SurfaceId。
        this.imageReceiverSurfaceId = await this.imageReceiver.getReceivingSurfaceId();
        console.info(`initImageReceiver imageReceiverSurfaceId:${this.imageReceiverSurfaceId}`);
        // 注册监听处理预览流每帧图像数据。
        this.onImageArrival(this.imageReceiver);
      } catch (e) {
        UtilLog.error(`initImageReceiver failed: ${JSON.stringify(e)}`);
      }
    }
  }

  /**
   * 注册ImageReceiver图像监听
   * @param receiver
   */
  onImageArrival(receiver: image.ImageReceiver): void {
    // 注册imageArrival监听。
    receiver.on('imageArrival', () => {
      console.info('image arrival');
      // 获取图像。
      receiver.readNextImage((err: BusinessError, nextImage: image.Image) => {
        if (err || nextImage === undefined) {
          console.error('readNextImage failed');
          return;
        }
        // 解析图像内容。
        nextImage.getComponent(image.ComponentType.JPEG, async (err: BusinessError, imgComponent: image.Component) => {
          if (err || imgComponent === undefined) {
            console.error('getComponent failed');
          }
          if (imgComponent.byteBuffer) {
            // 请参考步骤7解析buffer数据，本示例以方式一为例。
            let width = nextImage.size.width; // 获取图片的宽。
            let height = nextImage.size.height; // 获取图片的高。
            let stride = imgComponent.rowStride; // 获取图片的stride。
            let imageFormat = nextImage.format; // 获取图片的format。
            let pixelMapFormat = formatToPixelMapFormatMap.get(imageFormat) ?? image.PixelMapFormat.NV21;
            let mSize = pixelMapFormatToSizeMap.get(pixelMapFormat) ?? 1.5;
            console.info(`getComponent with width:${width} height:${height} stride:${stride}`);
            // oriPixelMap创建时使用的size、srcPixelFormat需要与相机预览输出流previewProfile中的size、format保持一致。此处format以NV21格式为例。
            // stride与width一致。
            let oriPixelMap: PixelMap| undefined = undefined;
            if (stride === width) {
              try {
                oriPixelMap = await image.createPixelMap(imgComponent.byteBuffer, {
                  size: { height: height, width: width },
                  srcPixelFormat: pixelMapFormat,
                });
              } catch (e) {
                UtilLog.error(`createPixelMap failed with error ${JSON.stringify(e)}`);
              }
            } else {
              // stride与width不一致。
              const dstBufferSize = width * height * mSize; // 以NV21为例（YUV_420_SP格式的图片）YUV_420_SP内存计算公式：长x宽+(长x宽)/2。
              const dstArr = new Uint8Array(dstBufferSize);
              for (let j = 0; j < height * mSize; j++) {
                const srcBuf = new Uint8Array(imgComponent.byteBuffer, j * stride, width);
                dstArr.set(srcBuf, j * width);
              }
              try {
                oriPixelMap = await image.createPixelMap(dstArr.buffer, {
                  size: { height: height, width: width },
                  srcPixelFormat: pixelMapFormat,
                });
              } catch (e) {
                UtilLog.error(`createPixelMap failed with error ${JSON.stringify(e)}`);
              }
            }
            // 因为pixelmap和相机流的宽高相反，所以需要旋转90度
            if (this.mCameraPosition === camera.CameraPosition.CAMERA_POSITION_BACK) {
              await oriPixelMap?.rotate(90);
            } else {
              await oriPixelMap?.rotate(-90);
            }
            this.pixelMap = await ImageProcessingUtil.filterImage(this.filter, oriPixelMap);
            oriPixelMap?.release();
          } else {
            console.error('byteBuffer is null');
          }
          // 确保当前buffer没有在使用的情况下，可进行资源释放。
          // 如果对buffer进行异步操作，需要在异步操作结束后再释放该资源（nextImage.release()）。
          nextImage.release();
          console.info('image process done');
        });
      });
    });
  }

  // 初始化相机
  async initCamera(): Promise<void> {
    console.info(`initCamera imageReceiverSurfaceId:${this.imageReceiverSurfaceId}`);
    try {
      // 获取相机管理器实例
      this.cameraManager = camera.getCameraManager(this.context);
      if (!this.cameraManager) {
        console.error('initCamera getCameraManager');
      }
      // 获取当前设备支持的相机device列表
      let cameras = this.cameraManager.getSupportedCameras();
      if (!cameras) {
        console.error('initCamera getSupportedCameras');
      }
      let deviceIndex = cameras.findIndex((cameraDevice: camera.CameraDevice) => {
        return cameraDevice.cameraPosition === this.mCameraPosition;
      });
      // 没有找到对应位置的摄像头，可选择其他摄像头，具体场景具体对待
      if (deviceIndex === -1) {
        deviceIndex = 0;
      }
      // 选择一个相机device，创建cameraInput输出对象。
      this.cameraInput = this.cameraManager.createCameraInput(cameras[deviceIndex]);
      if (!this.cameraInput) {
        console.error('initCamera createCameraInput');
      }
      // 打开相机。
      await this.cameraInput.open().catch((err: BusinessError) => {
        console.error(`initCamera open fail: ${err}`);
      });
      // 获取相机device支持的profile。
      let capability: camera.CameraOutputCapability =
        this.cameraManager.getSupportedOutputCapability(cameras[deviceIndex], camera.SceneMode.NORMAL_PHOTO);
      if (!capability) {
        console.error('initCamera getSupportedOutputCapability');
      }
      let minRatioDiff: number = 0.1;
      let surfaceRatio: number = this.imageWidth / this.imageHeight; // 最接近16:9宽高比。
      let previewProfile: camera.Profile = capability.previewProfiles[0];
      // 取最后一个，分辨率最高
      let photoProfile: camera.Profile = capability.photoProfiles[capability.photoProfiles.length - 1];
      // 应用开发者根据实际业务需求选择一个支持的预览流previewProfile。
      // 此处以选择CAMERA_FORMAT_YUV_420_SP（NV21）格式、满足限定条件分辨率的预览流previewProfile为例。
      for (let index = 0; index < capability.previewProfiles.length; index++) {
        const tempProfile = capability.previewProfiles[index];
        let tempRatio = tempProfile.size.width >= tempProfile.size.height ?
          tempProfile.size.width / tempProfile.size.height : tempProfile.size.height / tempProfile.size.width;
        let currentRatio = Math.abs(tempRatio - surfaceRatio);
        if (currentRatio <= minRatioDiff && tempProfile.format === camera.CameraFormat.CAMERA_FORMAT_YUV_420_SP) {
          if (Math.abs(tempProfile.size.width - this.imageWidth) <
          Math.abs(previewProfile.size.width - this.imageWidth)) {
            previewProfile = tempProfile;
          }
        }
      }

      this.imageWidth = previewProfile.size.width; // 更新xComponent组件的宽。
      this.imageHeight = previewProfile.size.height; // 更新xComponent组件的高。
      console.info(`initCamera imageWidth:${this.imageWidth} imageHeight:${this.imageHeight}`);
      // 使用imageReceiverSurfaceId创建第一路预览。
      this.previewOutput = this.cameraManager.createPreviewOutput(previewProfile, this.imageReceiverSurfaceId);
      if (!this.previewOutput) {
        console.error('initCamera createPreviewOutput');
      }

      // 创建拍照输出流。
      try {
        this.photoOutput = this.cameraManager.createPhotoOutput(photoProfile);
      } catch (error) {
        let err = error as BusinessError;
        console.error('Failed to createPhotoOutput errorCode = ' + err.code);
      }
      if (this.photoOutput) {
        this.photoOutput.on('photoAvailable', (errCode: BusinessError, photo: camera.Photo): void => {
          if (errCode || photo === undefined) {
            console.error('getPhoto failed');
            return;
          }
          this.imageObj = photo.main;
          this.captureCallback();
        });
      }

      this.session = this.cameraManager.createSession(camera.SceneMode.NORMAL_PHOTO) as camera.PhotoSession;
      if (!this.session) {
        console.error('initCamera createSession');
      }
      // 开始配置会话。
      try {
        this.session.beginConfig();
      } catch (error) {
        let err = error as BusinessError;
        console.error('Failed to beginConfig. errorCode = ' + err.code);
      }

      // 向会话中添加相机输入流。
      try {
        this.session.addInput(this.cameraInput);
      } catch (error) {
        let err = error as BusinessError;
        console.error('Failed to addInput. errorCode = ' + err.code);
      }

      // 向会话中添加预览输出流。
      try {
        this.session.addOutput(this.previewOutput);
      } catch (error) {
        let err = error as BusinessError;
        console.error('Failed to addOutput(previewOutput). errorCode = ' + err.code);
      }

      // 向会话中添加拍照输出流。
      try {
        this.session.addOutput(this.photoOutput);
      } catch (error) {
        let err = error as BusinessError;
        console.error('Failed to addOutput(photoOutput). errorCode = ' + err.code);
      }
      // 提交会话配置。
      await this.session.commitConfig();
      // 开始启动已配置的输入输出流。
      await this.session.start().then(() => {
        console.info('Promise returned to indicate the session start success.');
      });
    } catch (error) {
      console.error(`initCamera fail: ${error}`);
    }
  }

  // 拍照的回调函数
  captureCallback() {
    this.imageObj!.getComponent(image.ComponentType.JPEG,
      async (errCode: BusinessError, component: image.Component) => {
        const buffer: ArrayBuffer = component.byteBuffer;
        if (!buffer) {
          return;
        }
        try {
          let pixelMap = image.createImageSource(buffer).createPixelMapSync();
          this.capturePixelmap = await ImageProcessingUtil.filterImage(this.filter, pixelMap);
          // 跳转到下载页面
          getInstance().pushPathByName('ImageDownload', this.capturePixelmap);
          this.imageObj!.release();
          this.isBusy = false;
        } catch (e) {
          UtilLog.error(`captureCallback failed: ${JSON.stringify(e)}`);
        }
      });
  }

  async handleSaveButtonClick(uiContext: UIContext) {
    let file: fileIo.File | undefined = undefined;
    try {
      const phAccessHelper = photoAccessHelper.getPhotoAccessHelper(uiContext.getHostContext());
      const filePath = await phAccessHelper.createAsset(photoAccessHelper.PhotoType.IMAGE, 'jpeg');
      const imagePacker = image.createImagePacker();
      const imageBuffer = await imagePacker.packToData(this.capturePixelmap, { format: 'image/jpeg', quality: 100 });
      const mode = fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE;
      file = fileIo.openSync(filePath, mode);
      fileIo.writeSync(file.fd, imageBuffer);
      uiContext.getPromptAction().showToast({ message: '保存图片到相册成功~' });
    } catch (err) {
      UtilLog.error('save to album error', JSON.stringify(err));
    } finally {
      if (file) {
        fileIo.close(file);
      }
    }
  }

  // 切换摄像头
  async changeCameraPosition() {
    await this.releaseCamera();
    this.mCameraPosition = this.mCameraPosition === camera.CameraPosition.CAMERA_POSITION_BACK ?
      camera.CameraPosition.CAMERA_POSITION_FRONT : camera.CameraPosition.CAMERA_POSITION_BACK;
    await this.initCamera();
  }

  // 拍照
  async capture() {
    this.isBusy = true;
    let settings: camera.PhotoCaptureSetting = {
      quality: camera.QualityLevel.QUALITY_LEVEL_HIGH, // 设置图片质量高。
      rotation: camera.ImageRotation.ROTATION_0,
      mirror: false, // 设置镜像使能开关(默认关)。
    };

    this.photoOutput!.capture(settings, (err: BusinessError) => {
      if (err) {
        this.isBusy = false;
        console.error(`Failed to capture the photo. error: ${err}`);
        return;
      }
      console.info('Callback invoked to indicate the photo capture request success.');
    });
  }

  // 释放相机。
  async releaseCamera(): Promise<void> {
    console.info('releaseCamera E');
    try {
      // 释放相机输入流。
      await this.cameraInput?.close();
      // 释放预览输出流。
      await this.previewOutput?.release();
      await this.photoOutput?.release();
      // 停止当前会话。
      await this.session?.stop();
      // 释放会话。
      await this.session?.release();
    } catch (error) {
      console.error(`initCamera fail: ${error}`);
    }
  }
}
