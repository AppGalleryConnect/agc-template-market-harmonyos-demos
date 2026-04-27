/*
 *  Copyright (c) 2025 Huawei Device Co., Ltd.
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */
import { UtilLog } from '@hw-agconnect/util-log';
import { camera } from '@kit.CameraKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { JSON } from '@kit.ArkTS';
import { image } from '@kit.ImageKit';
import { textRecognition } from '@kit.CoreVisionKit';
import { getInstance, RouterMap } from '../util/Route';
import { GlobalContext } from './GlobalContext';
import { MyLog } from './MyLogUtil';

const TAG: string = 'CameraService';

export class CameraService {
  private cameraManager: camera.CameraManager | undefined = undefined;
  private cameras: Array<camera.CameraDevice> | Array<camera.CameraDevice> = [];
  private cameraInput: camera.CameraInput | undefined = undefined;
  private previewOutput: camera.PreviewOutput | undefined = undefined;
  private photoOutput: camera.PhotoOutput | undefined = undefined;
  private session: camera.PhotoSession | camera.VideoSession | undefined = undefined;
  private curCameraDevice: camera.CameraDevice | undefined = undefined;
  private defaultCameraDeviceIndex = 0;
  // 默认的预览分辨率.
  private previewProfileObj: camera.Profile = {
    format: 1003,
    size: {
      width: 1920,
      height: 1080,
    },
  };
  private curSceneMode: camera.SceneMode = camera.SceneMode.NORMAL_PHOTO;

  // 设置模式
  setSceneMode(sceneMode: camera.SceneMode): void {
    this.curSceneMode = sceneMode;
  }

  // 获取当前模式
  getSceneMode(): camera.SceneMode {
    return this.curSceneMode;
  }

  // 获取预览配置
  getPreviewProfile(cameraOutputCapability: camera.CameraOutputCapability): camera.Profile | undefined {
    const previewProfiles = cameraOutputCapability.previewProfiles;
    if (previewProfiles.length < 1) {
      return undefined;
    }
    const index = previewProfiles.findIndex((previewProfile: camera.Profile) => {
      return previewProfile.size.width === this.previewProfileObj.size.width &&
        previewProfile.size.height === this.previewProfileObj.size.height &&
        previewProfile.format === this.previewProfileObj.format;
    });
    if (index === -1) {
      return previewProfiles[0];
    }
    return previewProfiles[index];
  }

  // 获取拍照配置
  getPhotoProfile(cameraOutputCapability: camera.CameraOutputCapability): camera.Profile | undefined {
    const photoProfiles = cameraOutputCapability.photoProfiles;
    if (photoProfiles.length < 1) {
      return undefined;
    }
    const index = photoProfiles.findIndex((photoProfile: camera.Profile) => {
      return photoProfile.size.width === this.previewProfileObj.size.width &&
        photoProfile.size.height === this.previewProfileObj.size.height;
    });
    if (index === -1) {
      return photoProfiles[0];
    }
    return photoProfiles[index];
  }

  // 判断是否支持该模式
  isSupportedSceneMode(cameraManager: camera.CameraManager, cameraDevice: camera.CameraDevice): boolean {
    let sceneModes = cameraManager.getSupportedSceneModes(cameraDevice);
    if (sceneModes === undefined) {
      return false;
    }
    let index = sceneModes.findIndex((sceneMode: camera.SceneMode) => {
      return sceneMode === this.curSceneMode;
    });
    if (index === -1) {
      return false;
    }
    return true;
  }

  // 初始化相机
  async initCamera(surfaceId: string): Promise<void> {
    MyLog.info(TAG, `initCamera.`);
    try {
      await this.releaseCamera();
      // 获取相机管理实例.
      this.cameraManager = this.getCameraManagerFn();
      if (this.cameraManager === undefined) {
        MyLog.error(TAG, 'cameraManager is undefined');
        return;
      }
      // 获取指定相机设备对象的支持信息.
      this.cameras = this.getSupportedCamerasFn(this.cameraManager);
      if (this.cameras.length < 1 || this.cameras.length < this.defaultCameraDeviceIndex + 1) {
        return;
      }
      this.curCameraDevice = this.cameras[this.defaultCameraDeviceIndex];
      let isSupported = this.isSupportedSceneMode(this.cameraManager, this.curCameraDevice);
      if (!isSupported) {
        MyLog.error(TAG, 'The current scene mode is not supported.');
        return;
      }
      let cameraOutputCapability =
        this.cameraManager.getSupportedOutputCapability(this.curCameraDevice, this.curSceneMode);
      let previewProfile = this.getPreviewProfile(cameraOutputCapability);
      if (previewProfile === undefined) {
        MyLog.error(TAG, 'The resolution of the current preview stream is not supported.');
        return;
      }
      this.previewProfileObj = previewProfile;
      // 创建预览输出对象.
      this.previewOutput = this.createPreviewOutputFn(this.cameraManager, this.previewProfileObj, surfaceId);
      if (this.previewOutput === undefined) {
        MyLog.error(TAG, 'Failed to create the preview stream.');
        return;
      }
      // 监听预览事件回调.
      this.previewOutputCallBack(this.previewOutput);

      let outPhotoProfile = this.getPhotoProfile(cameraOutputCapability);
      if (outPhotoProfile === undefined) {
        return;
      }
      // 创建拍照输出对象
      this.photoOutput = this.createPhotoOutput(this.cameraManager, outPhotoProfile);
      if (this.photoOutput === undefined) {
        return;
      }


      // 创建相机输入对象.
      this.cameraInput = this.createCameraInputFn(this.cameraManager, this.curCameraDevice);
      if (this.cameraInput === undefined) {
        MyLog.error(TAG, 'Failed to create the camera input.');
        return;
      }
      // 打开相机.
      let isOpenSuccess = await this.cameraInputOpenFn(this.cameraInput);
      if (!isOpenSuccess) {
        MyLog.error(TAG, 'Failed to open the camera.');
        return;
      }
      // 相机状态回调.
      this.onCameraStatusChange(this.cameraManager);
      // 监控来自CameraInput的错误事件.
      this.onCameraInputChange(this.cameraInput, this.curCameraDevice);

      this.setPhotoOutputCbSingle(this.photoOutput);
      // 会话进程
      await this.sessionFlowFn(this.cameraManager, this.cameraInput, this.previewOutput, this.photoOutput);
    } catch (error) {
      UtilLog.error(`initCamera fail: ${error}`)
    }
  }

  // 释放相机
  async releaseCamera(): Promise<void> {
    MyLog.info(TAG, 'releaseCamera is called');
    try {
      await this.previewOutput?.release();
    } catch (error) {
      UtilLog.error(`previewOutput release fail: error: ${error}`);
    } finally {
      this.previewOutput = undefined;
    }
    try {
      await this.photoOutput?.release();
    } catch (error) {
      UtilLog.error(`photoOutput release fail: error: ${error}`);
    } finally {
      this.photoOutput = undefined;
    }
    try {
      await this.session?.release();
    } catch (error) {
      UtilLog.error(`session close failed: ${error}`);
    } finally {
      this.session = undefined;
    }
    try {
      await this.cameraInput?.close();
    } catch (error) {
      UtilLog.error(`cameraInput close failed: ${error}`);
    } finally {
      this.cameraInput = undefined;
    }
    this.offCameraStatusChange();
    MyLog.info(TAG, 'releaseCamera success');
  }

  // 获取相机管理实例
  getCameraManagerFn(): camera.CameraManager | undefined {
    if (this.cameraManager) {
      return this.cameraManager;
    }
    let cameraManager: camera.CameraManager | undefined = undefined;
    try {
      cameraManager = camera.getCameraManager(GlobalContext.get().getCameraSettingContext());
      MyLog.info(TAG, `getCameraManager success: ${cameraManager}`);
    } catch (error) {
      let err = error as BusinessError;
      MyLog.error(TAG, `getCameraManager failed: ${err}`);
    }
    return cameraManager;
  }

  // 获取指定相机设备对象的支持信息
  getSupportedCamerasFn(cameraManager: camera.CameraManager): Array<camera.CameraDevice> {
    let supportedCameras: Array<camera.CameraDevice> = [];
    try {
      supportedCameras = cameraManager.getSupportedCameras();
      MyLog.info(TAG, `getSupportedCameras success: ${this.cameras}, length: ${this.cameras?.length}`);
    } catch (error) {
      UtilLog.error(`getSupportedCameras failed: ${error}`);
    }
    return supportedCameras;
  }

  // 创建预览输出对象
  createPreviewOutputFn(cameraManager: camera.CameraManager, previewProfileObj: camera.Profile,
    surfaceId: string): camera.PreviewOutput | undefined {
    let previewOutput: camera.PreviewOutput | undefined = undefined;
    try {
      previewOutput = cameraManager.createPreviewOutput(previewProfileObj, surfaceId);
      MyLog.info(TAG, `createPreviewOutput success: ${previewOutput}`);
    } catch (error) {
      let err = error as BusinessError;
      MyLog.error(TAG, `createPreviewOutput failed: ${err}`);
    }
    return previewOutput;
  }

  // 创建相机输出
  public createPhotoOutput(cameraManager: camera.CameraManager | undefined,
    profile: camera.Profile) {
    let cameraPhotoOutput: camera.PhotoOutput | undefined = undefined;
    try {
      cameraPhotoOutput = cameraManager?.createPhotoOutput(profile);
    } catch (error) {
      UtilLog.error(`Failed to createPhotoOutput. error: ${error}`);
    }
    return cameraPhotoOutput;
  }

  // 设置相机拍照的回调
  setPhotoOutputCbSingle(photoOutput: camera.PhotoOutput) {
    photoOutput.on('photoAvailable', (errCode: BusinessError, photo: camera.Photo): void => {
      if (errCode || photo === undefined) {
        MyLog.error('getPhoto failed');
        getInstance().pop();
        return;
      }
      this.recognizeText(photo.main);
    });
  }

  // 拍照
  public async capture(isFront: boolean = false) {
    if (this.photoOutput) {
      let settings: camera.PhotoCaptureSetting = {
        quality: camera.QualityLevel.QUALITY_LEVEL_HIGH,
        rotation: camera.ImageRotation.ROTATION_0,
        mirror: isFront,
      };
      this.photoOutput.capture(settings);
      // 拍照成功
      this.photoCallBack();
    }
  }

  // 创建相机输入对象
  createCameraInputFn(cameraManager: camera.CameraManager,
    cameraDevice: camera.CameraDevice): camera.CameraInput | undefined {
    MyLog.info(TAG, 'createCameraInputFn is called.');
    let cameraInput: camera.CameraInput | undefined = undefined;
    try {
      cameraInput = cameraManager.createCameraInput(cameraDevice);
      MyLog.info(TAG, 'createCameraInputFn success');
    } catch (error) {
      let err = error as BusinessError;
      MyLog.error(TAG, `createCameraInputFn failed: ${err}`);
    }
    return cameraInput;
  }

  // 打开相机
  async cameraInputOpenFn(cameraInput: camera.CameraInput): Promise<boolean> {
    let isOpenSuccess = false;
    try {
      await cameraInput.open();
      isOpenSuccess = true;
      MyLog.info(TAG, 'cameraInput open success');
    } catch (error) {
      UtilLog.error(`createCameraInput failed : ${error}`)
    }
    return isOpenSuccess;
  }

  // 会话进程
  async sessionFlowFn(cameraManager: camera.CameraManager, cameraInput: camera.CameraInput,
    previewOutput: camera.PreviewOutput, imageReceiverOutput: camera.PhotoOutput): Promise<void> {
    try {
      if (this.curSceneMode === camera.SceneMode.NORMAL_PHOTO) {
        this.session = cameraManager.createSession(this.curSceneMode) as camera.PhotoSession;
      } else if (this.curSceneMode === camera.SceneMode.NORMAL_VIDEO) {
        this.session = cameraManager.createSession(this.curSceneMode) as camera.VideoSession;
      }
      if (this.session === undefined) {
        return;
      }
      this.onSessionErrorChange(this.session);
      this.session.beginConfig();
      this.session.addInput(cameraInput);
      this.session.addOutput(previewOutput);
      this.session.addOutput(imageReceiverOutput);
      await this.session.commitConfig();
      this.setFocusMode(camera.FocusMode.FOCUS_MODE_CONTINUOUS_AUTO);
      await this.session.start();
      MyLog.info(TAG, 'sessionFlowFn success');
    } catch (error) {
      UtilLog.error(TAG, `sessionFlowFn fail : ${error}`);
    }
  }

  // 监控预览事件
  previewOutputCallBack(previewOutput: camera.PreviewOutput): void {
    MyLog.info(TAG, 'previewOutputCallBack is called');
    try {
      previewOutput.on('frameStart', (): void => {
        MyLog.info(TAG, 'Preview frame started');
      });
      previewOutput.on('frameEnd', (): void => {
        MyLog.info(TAG, 'Preview frame ended');
      });
      previewOutput.on('error', (previewOutputError: BusinessError): void => {
        MyLog.info(TAG, `Preview output previewOutputError: ${previewOutputError}`);
      });
    } catch (err) {
      MyLog.error(TAG, 'previewOutputCallBack error');
    }
  }

  // 注册相机状态变化的回调函数
  registerCameraStatusChange(err: BusinessError, cameraStatusInfo: camera.CameraStatusInfo): void {
    MyLog.info(TAG, `cameraId: ${cameraStatusInfo.camera.cameraId},status: ${cameraStatusInfo.status}`);
  }

  // 监听相机状态改变
  onCameraStatusChange(cameraManager: camera.CameraManager): void {
    MyLog.info(TAG, 'onCameraStatusChange is called');
    try {
      cameraManager.on('cameraStatus', this.registerCameraStatusChange);
    } catch (error) {
      MyLog.error(TAG, 'onCameraStatusChange error');
    }
  }

  // 关闭相机状态改变监听
  offCameraStatusChange(): void {
    MyLog.info(TAG, 'offCameraStatusChange is called');
    this.cameraManager?.off('cameraStatus', this.registerCameraStatusChange);
  }

  // 监听输入改变
  onCameraInputChange(cameraInput: camera.CameraInput, cameraDevice: camera.CameraDevice): void {
    MyLog.info(TAG, `onCameraInputChange is called`);
    try {
      cameraInput.on('error', cameraDevice, (cameraInputError: BusinessError): void => {
        MyLog.info(TAG, `onCameraInputChange cameraInput error code: ${cameraInputError.code}`);
      });
    } catch (error) {
      MyLog.error(TAG, 'onCameraInputChange error');
    }
  }

  onSessionErrorChange(session: camera.PhotoSession | camera.VideoSession): void {
    try {
      session.on('error', (captureSessionError: BusinessError): void => {
        MyLog.info(TAG,
          'onCaptureSessionErrorChange captureSession fail: ' + JSON.stringify(captureSessionError.code));
      });
    } catch (error) {
      MyLog.error(TAG, 'onCaptureSessionErrorChange error');
    }
  }

  setFocusMode(focusMode: camera.FocusMode): void {
    MyLog.info(TAG, `setFocusMode is called`);
    let isSupported = this.session?.isFocusModeSupported(focusMode);
    MyLog.info(TAG, `setFocusMode isSupported: ${isSupported}`);
    if (!isSupported) {
      return;
    }
    this.session?.setFocusMode(focusMode);
  }

  recognizeText(curImage: image.Image) {
    try {
      curImage.getComponent(image.ComponentType.JPEG, async (err, imgComponent: image.Component) => {
        if (err || imgComponent === undefined) {
          MyLog.error(TAG, `getComponent error, error is ${err} or curImage is undefined`);
          return;
        }
        if (imgComponent.byteBuffer as ArrayBuffer) {
          let imageSource: image.ImageSource = image.createImageSource(imgComponent.byteBuffer);
          let pixelMap = imageSource.createPixelMapSync();
          await imageSource.release();
          let visionInfo: textRecognition.VisionInfo = {
            pixelMap: pixelMap,
          };
          let textConfiguration: textRecognition.TextRecognitionConfiguration = {
            isDirectionDetectionSupported: true,
          };
          textRecognition.recognizeText(visionInfo, textConfiguration)
            .then((data: textRecognition.TextRecognitionResult) => {
              // 文字识别成功
              this.recognizeCallBack();
              getInstance().pushPathByName(RouterMap.TEXT_RESULT, data.value);
            }).catch((error: BusinessError) => {
            MyLog.error(TAG, `Failed to recognize text. Code: ${error.code}, message: ${error.message}`);
          });
        } else {
          return;
        }
        curImage.release();
      });
    } catch (e) {
      UtilLog.error(`recognizeText failed with error ${e}`);
    }
  }

  setPhotoCallBack(callBack: Function) {
    this.photoCallBack = callBack;
  }

  setRecognizeCallBack(callBack: Function) {
    this.recognizeCallBack = callBack;
  }

  // 开始拍照回调
  private photoCallBack: Function = () => {

  };
  // 识别完成
  private recognizeCallBack: Function = () => {

  };
}

