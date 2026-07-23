import { image } from '@kit.ImageKit';
import { camera } from '@kit.CameraKit';
import { display } from '@kit.ArkUI';
import { effectKit } from '@kit.ArkGraphics2D';
import { BusinessError } from '@kit.BasicServicesKit';
import { RouterMap, RouterModule, Logger, BaseViewModel, PRESETS, CustomFilter, ToastLoading } from 'commonlib';
import { formatToPixelMapFormatMap, pixelMapFormatToSizeMap } from '../model/CameraModel';

const TAG = '[LutCameraPageVM]'

@ObservedV2
export class LutCameraPageVM extends BaseViewModel {
  @Trace markId: string = 'watermarkFlag';
  // 外层容器宽高
  @Trace containerWidth: number = 0;
  @Trace containerHeight: number = 0;
  // 预览容器宽高
  @Trace preWidth: number = 360;
  @Trace preHeight: number = 640;
  // 默认宽高比
  @Trace ratio: number = 9 / 16;
  // 是否展示水印
  @Trace isShowWatermark: boolean = false;
  // 是否展示滤镜
  @Trace showFilterBar: boolean = false;
  // 水印图片
  @Trace markPixelMap: image.PixelMap | undefined = undefined;
  // 照片
  @Trace currentPixelMap: image.PixelMap | undefined = undefined;
  // 滤镜资源
  @Trace filterList: CustomFilter[] = PRESETS;
  @Trace filter: CustomFilter = PRESETS[0];
  @Trace selectedFilterIndex: number = 0;
  @Trace isShow: boolean = false;
  @Trace isFont: boolean = false;
  @Trace pixelMap: PixelMap | undefined = undefined;
  @Trace imageReceiver: image.ImageReceiver | undefined = undefined;
  @Trace imageWidth: number = 1280;
  @Trace imageHeight: number = 720;
  private imageReceiverSurfaceId: string = '';
  @Trace context: Context | undefined = undefined;
  @Trace uiContext: UIContext | undefined = undefined;
  private session: camera.PhotoSession | undefined = undefined;
  private previewOutput: camera.PreviewOutput | undefined = undefined;
  private cameraInput: camera.CameraInput | undefined = undefined;
  private photoOutput: camera.PhotoOutput | undefined = undefined;
  private cameraManager: camera.CameraManager | undefined = undefined;
  private imageObj: image.Image | undefined = undefined;
  private mCameraPosition: camera.CameraPosition = camera.CameraPosition.CAMERA_POSITION_BACK;
  private static _instance: LutCameraPageVM;

  public static get instance() {
    if (!LutCameraPageVM._instance) {
      LutCameraPageVM._instance = new LutCameraPageVM();
    }
    return LutCameraPageVM._instance;
  }

  public static set instance(_instance: LutCameraPageVM) {
    LutCameraPageVM._instance = _instance;
  }

  // 处理预览容器宽高
  handlePreSize() {
    let targetWidth = this.containerWidth;
    if (this.containerWidth <= this.containerHeight) {
      this.preWidth = targetWidth;
      this.preHeight = this.containerHeight;
    } else {
      this.preHeight = this.containerHeight;
      this.preWidth = this.preHeight * this.ratio;
    }
  }

  // 初始化相机
  async initCamera(): Promise<void> {
    try {
      // 获取相机管理器实例
      this.cameraManager = camera.getCameraManager(this.context);
      if (!this.cameraManager) {
        Logger.error(TAG, 'initCamera getCameraManager');
      }
      // 获取当前设备支持的相机device列表
      let cameras = this.cameraManager.getSupportedCameras();
      if (!cameras) {
        Logger.error(TAG, 'initCamera getSupportedCameras');
        return;
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
        Logger.error(TAG, 'initCamera createCameraInput');
        return
      }
      // 打开相机。
      await this.cameraInput.open().catch((err: BusinessError) => {
        Logger.error(TAG, `initCamera open fail: ${err}`);
      });
      // 获取相机device支持的profile。
      let capability: camera.CameraOutputCapability =
        this.cameraManager.getSupportedOutputCapability(cameras[deviceIndex], camera.SceneMode.NORMAL_PHOTO);
      if (!capability) {
        Logger.error(TAG, 'initCamera getSupportedOutputCapability');
      }
      let minRatioDiff: number = 0.1;
      let surfaceRatio: number = this.imageWidth / this.imageHeight;
      let previewProfile: camera.Profile = capability.previewProfiles[0];
      let photoIndex = capability.photoProfiles.length > 1 ? capability.photoProfiles.length / 2 : 0;
      // 应用开发者根据实际业务需求选择一个支持的预览流previewProfile。
      for (let index = 0; index < capability.previewProfiles.length; index++) {
        const tempProfile = capability.previewProfiles[index];
        let tempRatio = tempProfile.size.width >= tempProfile.size.height ?
          tempProfile.size.width / tempProfile.size.height : tempProfile.size.height / tempProfile.size.width;
        let currentRatio = Math.abs(tempRatio - surfaceRatio);
        if (currentRatio <= minRatioDiff && tempProfile.format === camera.CameraFormat.CAMERA_FORMAT_YUV_420_SP) {
          if (Math.abs(tempProfile.size.width - this.imageWidth) <
          Math.abs(previewProfile.size.width - this.imageWidth)) {
            previewProfile = tempProfile;
            photoIndex = index;
          }
        }
      }
      // 拍照配置信息
      let photoProfile: camera.Profile = capability.photoProfiles[photoIndex];
      this.imageWidth = previewProfile.size.width;
      this.imageHeight = previewProfile.size.height;
      // 使用imageReceiverSurfaceId创建第一路预览。
      this.previewOutput = this.cameraManager.createPreviewOutput(previewProfile, this.imageReceiverSurfaceId);
      if (!this.previewOutput) {
        Logger.error(TAG, 'initCamera createPreviewOutput');
      }
      // 创建拍照输出流。
      try {
        this.photoOutput = this.cameraManager.createPhotoOutput(photoProfile);
      } catch (error) {
        Logger.error(TAG, `Failed to createPhotoOutput. error: ${JSON.stringify(error)}`);
      }
      if (this.photoOutput) {
        this.photoOutput.on('photoAvailable', (errCode: BusinessError, photo: camera.Photo): void => {
          if (errCode || photo === undefined) {
            Logger.error(TAG, 'getPhoto failed');
            return;
          }
          // 拍照时固定当前帧
          this.imageReceiver?.off('imageArrival');
          this.imageReceiver = undefined;

          this.imageObj = photo.main;
          this.captureCallback();
        });
      }

      this.session = this.cameraManager.createSession(camera.SceneMode.NORMAL_PHOTO) as camera.PhotoSession;
      if (!this.session) {
        Logger.error(TAG, 'initCamera createSession');
      }
      // 开始配置会话。
      try {
        this.session.beginConfig();
      } catch (error) {
        Logger.error(TAG, `Failed to beginConfig. error: ${JSON.stringify(error)}`);
      }
      // 向会话中添加相机输入流。
      try {
        this.session.addInput(this.cameraInput);
      } catch (error) {
        Logger.error(TAG, `Failed to addInput. error: ${JSON.stringify(error)}`);
      }

      // 向会话中添加预览输出流。
      try {
        this.session.addOutput(this.previewOutput);
      } catch (error) {
        Logger.error(TAG, `Failed to addOutput(previewOutput). error: ${JSON.stringify(error)}`);
      }

      // 向会话中添加拍照输出流。
      try {
        this.session.addOutput(this.photoOutput);
      } catch (error) {
        Logger.error(TAG, `Failed to addOutput(photoOutput). error: ${JSON.stringify(error)}`);
      }
      // 提交会话配置。
      await this.session.commitConfig();
      // 开始启动已配置的输入输出流。
      await this.session.start().catch((error: BusinessError) => {
        Logger.error(TAG, `session start failed. error: ${JSON.stringify(error)}`);
      })
    } catch (error) {
      Logger.error(TAG, `initCamera fail: ${JSON.stringify(error)}`);
    }
  }

  // 添加水印
  async addWaterMark(originalPixelmap: image.PixelMap, markPixelmap: image.PixelMap, containerWidth: number,
    uiContext: UIContext) {
    // 获取图片信息
    const originalInfo = await originalPixelmap.getImageInfo();
    const markInfo = await markPixelmap.getImageInfo();
    // 记录原图和水印图片大小
    const originWidth: number = uiContext.px2vp(originalInfo.size.width);
    const originHeight: number = uiContext.px2vp(originalInfo.size.height);
    const markWidth: number = uiContext.px2vp(markInfo.size.width);
    const markHeight: number = uiContext.px2vp(markInfo.size.height);
    // 计算预览容器和图片宽度之间的比例
    const ratio = originWidth / containerWidth;
    // 离屏绘制原图片
    const offscreenCanvas = new OffscreenCanvas(originWidth, originHeight);
    const ctx = offscreenCanvas.getContext('2d');
    ctx.drawImage(originalPixelmap, 0, 0, originWidth, originHeight);
    // 计算水印的绘制位置
    const DEFAULT_PADDING = this.breakPointModel.pagePadding;
    const x = DEFAULT_PADDING * ratio;
    const y = originHeight - (markHeight * ratio + DEFAULT_PADDING * ratio);
    // 绘制水印
    ctx.drawImage(markPixelmap, x, y, markWidth * ratio, markHeight * ratio);

    return ctx.getPixelMap(0, 0, originWidth, originHeight);
  }

  async initImageReceiver(): Promise<void> {
    if (!this.imageReceiver) {
      try {
        // 创建ImageReceiver。
        let size: image.Size = { width: this.imageWidth, height: this.imageHeight };
        this.imageReceiver = image.createImageReceiver(size, image.ImageFormat.JPEG, 8);
        // 获取第一路流SurfaceId。
        this.imageReceiverSurfaceId = await this.imageReceiver.getReceivingSurfaceId();
        // 注册监听处理预览流每帧图像数据。
        this.onImageArrival(this.imageReceiver);
      } catch (e) {
        Logger.error(TAG, `initImageReceiver failed: ${JSON.stringify(e)}`);
      }
    }
  }

  // 注册imageArrival监听。
  onImageArrival(receiver: image.ImageReceiver): void {
    receiver.on('imageArrival', () => {
      // 获取图像。
      receiver.readNextImage((err: BusinessError, nextImage: image.Image) => {
        if (err || nextImage === undefined) {
          Logger.error(TAG, 'readNextImage failed');
          return;
        }
        // 解析图像内容。
        nextImage.getComponent(image.ComponentType.JPEG, async (err: BusinessError, imgComponent: image.Component) => {
          if (err || imgComponent === undefined) {
            Logger.error(TAG, 'getComponent failed');
          }
          if (imgComponent.byteBuffer) {
            let width = nextImage.size.width; // 获取图片的宽。
            let height = nextImage.size.height; // 获取图片的高。
            let stride = imgComponent.rowStride; // 获取图片的stride。
            let imageFormat = nextImage.format; // 获取图片的format。
            let pixelMapFormat = formatToPixelMapFormatMap.get(imageFormat) ?? image.PixelMapFormat.NV21;
            let mSize = pixelMapFormatToSizeMap.get(pixelMapFormat) ?? 1.5;
            let oriPixelMap: PixelMap | undefined = undefined;
            if (stride === width) {
              try {
                oriPixelMap = await image.createPixelMap(imgComponent.byteBuffer, {
                  size: { height: height, width: width },
                  srcPixelFormat: pixelMapFormat,
                });
              } catch (e) {
                Logger.error(TAG, `createPixelMap failed with error ${JSON.stringify(e)}`);
              }
            } else {
              const dstBufferSize = width * height * mSize;
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
                Logger.error(TAG, `createPixelMap failed with error ${JSON.stringify(e)}`);
              }
            }

            let displayDefault: display.Display | null = null;
            try {
              displayDefault = display.getDefaultDisplaySync();
              const displayRotation = (displayDefault?.rotation ?? 0) * camera.ImageRotation.ROTATION_90;
              const rotation = this.previewOutput?.getPreviewRotation(displayRotation) || 0;
              if (this.mCameraPosition === camera.CameraPosition.CAMERA_POSITION_FRONT) {
                if (displayRotation === 90 || displayRotation === 270) {
                  await oriPixelMap?.rotate((rotation + 180) % 360);
                } else {
                  await oriPixelMap?.rotate(rotation);
                }
                await oriPixelMap?.flip(true, false);
              } else {
                await oriPixelMap?.rotate(rotation);
              }
            } catch (error) {
              Logger.error(TAG, `getDefaultDisplaySync failed, code is ${JSON.stringify(error)}`);
            }
            this.pixelMap = await this.filterImage(this.filter, oriPixelMap);
            oriPixelMap?.release();
          } else {
            Logger.error(TAG, 'byteBuffer is null');
          }
          nextImage.release().catch((error: BusinessError) => {
            Logger.error('Failed to release. error is: ' + JSON.stringify(error));
          });
          Logger.info('image process done');
        });
      });
    });
  }

  //图片加滤镜
  filterImage(item: CustomFilter, pixelMap?: PixelMap): Promise<PixelMap> {
    let filter = effectKit.createEffect(pixelMap);
    filter.blur(item.blur);
    if (item.grayscale) {
      filter.grayscale();
    }
    if (item.invert) {
      filter.invert();
    }
    filter.setColorMatrix(item.colorMatrix);
    filter.brightness(item.brightness);
    if (item.grayscale) {
      filter.grayscale();
    }
    return filter.getEffectPixelMap();
  }

  // 拍照的回调函数
  captureCallback() {
    this.imageObj!.getComponent(image.ComponentType.JPEG, async (err: BusinessError, component: image.Component) => {
      const buffer: ArrayBuffer = component.byteBuffer;
      if (!buffer) {
        return;
      }
      try {
        let pixelMap = image.createImageSource(buffer).createPixelMapSync();
        const capturePixelmap = await this.filterImage(this.filter, pixelMap);
        // 判断是否有水印
        if (this.isShowWatermark && this.markPixelMap) {
          this.currentPixelMap =
            await this.addWaterMark(capturePixelmap, this.markPixelMap, this.containerWidth, this.uiContext!);
        } else {
          this.currentPixelMap = capturePixelmap;
        }
        await this.imageObj!.release();
        await this.markPixelMap?.release();
        // 跳转到下载页面
        RouterModule.push({ url: RouterMap.IMAGE_DOWNLOAD, param: this.currentPixelMap });
      } catch (e) {
        Logger.error(TAG, `captureCallback failed: ${JSON.stringify(e)}`);
      }

      ToastLoading.close();
    });
  }

  // 切换摄像头
  async changeCameraPosition() {
    this.isFont = !this.isFont;
    await this.releaseCamera();
    this.mCameraPosition = this.isFont ? camera.CameraPosition.CAMERA_POSITION_FRONT :
      camera.CameraPosition.CAMERA_POSITION_BACK;
    await this.initCamera();
  }

  // 拍照
  async capture() {
    ToastLoading.open();
    this.showFilterBar = false;
    // 如果有水印，先处理水印
    if (this.isShowWatermark) {
      try {
        this.markPixelMap = this.uiContext!.getComponentSnapshot().getSync(this.markId, {
          scale: 1, waitUntilRenderFinished: true,
        });
      } catch (error) {
        Logger.error(TAG, `getSync failed. error: ${JSON.stringify(error)}`)
      }
    }

    let settings: camera.PhotoCaptureSetting = {
      quality: camera.QualityLevel.QUALITY_LEVEL_HIGH, // 设置图片质量高。
      rotation: camera.ImageRotation.ROTATION_0,
      mirror: this.isFont,
    };
    try {
      this.photoOutput!.capture(settings, (err: BusinessError) => {
        if (err) {
          ToastLoading.close();
          Logger.error(TAG, `Failed to capture the photo. error: ${err}`);
          return;
        }
      });
    } catch (e) {
      ToastLoading.close();
      Logger.error(TAG, `Failed to capture the photo. error: ${e}`);
    }
  }

  // 释放相机。
  async releaseCamera(): Promise<void> {
    try {
      // 停止当前会话。
      await this.session?.stop();
      // 释放会话。
      await this.session?.release();
      this.photoOutput?.off('photoAvailable');
      // 释放相机输入流。
      await this.cameraInput?.close();
      // 释放预览输出流。
      await this.previewOutput?.release();
      await this.photoOutput?.release();

      this.session = undefined;
      this.cameraInput = undefined;
      this.photoOutput = undefined;
      this.previewOutput = undefined;
    } catch (error) {
      Logger.error(TAG, `initCamera fail: ${JSON.stringify(error)}`);
    }
  }

  // 选择滤镜
  selectedFilter(ri: RepeatItem<CustomFilter>) {
    this.selectedFilterIndex = ri.index;
    this.filter = PRESETS[ri.index];
  }
}
