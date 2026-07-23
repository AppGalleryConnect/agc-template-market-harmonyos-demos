import { camera } from '@kit.CameraKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { abilityAccessCtrl, Permissions } from '@kit.AbilityKit';
import { display } from '@kit.ArkUI';
import { LivePage } from './LivePage'

import { LiveMsgModel } from '../models/LiveModel'
import { MockAudienceFactory, AudienceRes } from '@agctemplate/server/src/main/ets/api/mock/mockAudienceFactory'
import { DetailPageComponent } from './DetailPageComponent'
// import { media } from '@kit.MediaKit';
import { common } from '@kit.AbilityKit';
// import { camera } from '@kit.CameraKit';
import { media } from '@kit.MediaKit';
import { fileUri } from '@kit.CoreFileKit';
import { router } from '@kit.ArkUI';
// import { BusinessError } from '@kit.BasicServicesKit';
import { FileUtil } from '../utils/FileUtil';
import { CommonConstants } from '../common/CommonConstants';
import { RouterParams } from '../utils/RouterParams';
import Logger from '../utils/Logger';

const TAG: string = 'Record';
const uiContext: UIContext | undefined = AppStorage.get('uiContext');
let context = uiContext?.getHostContext() as common.UIAbilityContext;

interface RecordingMetadata {
  title: string;
  startTime: number;
  duration: number;
}

@ComponentV2
struct CameraPage {
  private xComponentCtl: XComponentController = new XComponentController();
  private xComponentSurfaceId: string = '';
  @Local imageWidth: number = 1920;
  @Local imageHeight: number = 1080;
  // private cameraManager: camera.CameraManager | undefined = undefined;
  @Provider('mCameraPosition') mCameraPosition: camera.CameraPosition = camera.CameraPosition.CAMERA_POSITION_BACK;
  private cameras: Array<camera.CameraDevice> | Array<camera.CameraDevice> = [];
  // private cameraInput: camera.CameraInput | undefined = undefined;
  // private previewOutput: camera.PreviewOutput | undefined = undefined;
  private session: camera.VideoSession | undefined = undefined;
  private uiContext: UIContext = this.getUIContext();
  private context: Context | undefined = this.uiContext.getHostContext();
  private cameraPermission: Permissions = 'ohos.permission.CAMERA'; // 申请权限相关问题可参考本篇开头的申请相关权限文档
  @Local isShow: boolean = false;
  @Provider('isLive') isLive: boolean = false;
  @Local liveStreamer: LiveMsgModel = LiveMsgModel.instance
  @Local audienceList: Array<AudienceRes> = new MockAudienceFactory().getAllAudience()
  @Local xComponentWidth: number = 0;
  @Local xComponentHeight: number = 0;
  @Local videoUri: string = '';
  @Local recording: boolean = false;
  @Local path: string = '';
  @Local recordStartTime: number = 0;
  @Local recordDuration: number = 0;
  @Local cameraManager: camera.CameraManager | undefined = undefined;
  @Local videoOutput: camera.VideoOutput | undefined = undefined;
  @Local captureSession: camera.Session | undefined = undefined;
  @Local cameraInput: camera.CameraInput | undefined = undefined;
  @Local previewOutput: camera.PreviewOutput | undefined = undefined;
  @Local avRecorder: media.AVRecorder | undefined = undefined;
  @Local recordNameExo: number = 0;
  // private mXComponentController: XComponentController = new XComponentController;
  // private surfaceId: string = '';
  url: string = '';

  @Monitor('mCameraPosition')
  async onCameraChange() {
    await this.initCamera(this.getUIContext().getHostContext()!, this.xComponentSurfaceId);
  }

  async requestPermissionsFn(): Promise<void> {
    let atManager = abilityAccessCtrl.createAtManager();
    if (this.context) {
      try {
        let res = await atManager.requestPermissionsFromUser(this.context, [this.cameraPermission]);
        for (let i = 0; i < res.permissions.length; i++) {
          if (this.cameraPermission.toString() === res.permissions[i] && res.authResults[i] === 0) {
            this.isShow = true;
          }
        }
      } catch (e) {
      }
    }
  }

  aboutToDisappear() {
    this.releaseCamera()
  }

  aboutToAppear(): void {
    this.requestPermissionsFn();
    this.recordNameExo = Date.now();
    this.path = this.getUIContext().getHostContext()!.filesDir + '/live_' + this.recordNameExo + '.mp4';
    Logger.info(TAG, `Video path: ${this.path}`);
    let file = FileUtil.createOrOpen(this.path);
    if (file) {
      this.url = 'fd://' + file.fd;
      this.videoUri = fileUri.getUriFromPath(this.path);
    } else {
      Logger.error(TAG, 'open file failed.');
    }
  }

  async onPageShow(): Promise<void> {
    console.info('onPageShow');
    if (this.xComponentSurfaceId !== '') {
      await this.initCamera(this.getUIContext().getHostContext()!, this.xComponentSurfaceId);
    }
  }

  onPageHide(): void {
    console.info('onPageHide');
    this.releaseCamera();
  }

  build() {
    NavDestination() {
      Stack() {
        Column() {
          if (this.isShow) {
            XComponent({
              id: 'componentId',
              type: XComponentType.SURFACE,
              controller: this.xComponentCtl
            })
              .onLoad(async () => {
                console.info('onLoad is called');
                this.xComponentSurfaceId = this.xComponentCtl.getXComponentSurfaceId(); // 获取组件surfaceId。
                // 初始化相机，组件实时渲染每帧预览流数据。
                this.xComponentCtl.setXComponentSurfaceRotation({ lock: true })
                let displayInfo = display.getDefaultDisplaySync();
                this.xComponentCtl.setXComponentSurfaceRect({
                  surfaceWidth: displayInfo.width,
                  surfaceHeight: displayInfo.height
                })
                await this.initCamera(this.getUIContext().getHostContext()!, this.xComponentSurfaceId);
              })
              .renderFit(RenderFit.RESIZE_COVER)
          }
        }
        .height('100%')
        .width('100%')

        if (this.isLive) {
          DetailPageComponent({
            audienceList: this.audienceList,
            stopRecord: () => { this.stopRecord() }
          })

        } else {
          LivePage({
            startRecord: () => {
              this.startRecord()
            }
          })
        }

      }
    }
    .hideTitleBar(true)
    .hideToolBar(true)
    .onWillShow(() => {
      this.isLive = false
    })
    .onShown(async () => {
      await this.initCamera(this.getUIContext().getHostContext()!, this.xComponentSurfaceId);
    })
    .onBackPressed(() => {
      if (this.isLive) {
        return true
      }
      return false
    })
  }

  // // 初始化相机。
  // async initCamera(mCameraPosition: camera.CameraPosition): Promise<void> {
  //   console.info(`initCamera previewOutput xComponentSurfaceId:${this.xComponentSurfaceId}`);
  //   try {
  //     await this.releaseCamera()
  //     // 获取相机管理器实例。
  //     this.cameraManager = camera.getCameraManager(this.context);
  //     if (!this.cameraManager) {
  //       console.error('initCamera getCameraManager');
  //       return;
  //     }
  //     // 获取当前设备支持的相机device列表。
  //     this.cameras = this.cameraManager.getSupportedCameras();
  //     if (!this.cameras) {
  //       console.error('initCamera getSupportedCameras');
  //     }
  //
  //     let deviceIndex = this.cameras.findIndex((cameraDevice: camera.CameraDevice) => {
  //       return cameraDevice.cameraPosition === mCameraPosition
  //     })
  //     // 没有找到对应位置的摄像头，可选择其他摄像头，具体场景具体对待。
  //     if (deviceIndex === -1) {
  //       deviceIndex = 0;
  //     }
  //     console.info(`${deviceIndex}`)
  //     // 选择一个相机device，创建cameraInput输出对象。
  //     this.cameraInput = this.cameraManager.createCameraInput(this.cameras[deviceIndex]);
  //     if (!this.cameraInput) {
  //       console.error('initCamera createCameraInput');
  //       return;
  //     }
  //
  //     // 打开相机。
  //     await this.cameraInput.open();
  //
  //     // 获取相机device支持的profile。
  //     let capability: camera.CameraOutputCapability =
  //       this.cameraManager.getSupportedOutputCapability(this.cameras[deviceIndex], camera.SceneMode.NORMAL_VIDEO);
  //     if (!capability || capability.previewProfiles.length === 0) {
  //       console.error('capability is null || []');
  //       this.releaseCamera();
  //       return;
  //     }
  //     let minRatioDiff: number = 0.1;
  //     let surfaceRatio: number = this.imageWidth / this.imageHeight; // 最接近16:9宽高比。
  //     let previewProfile: camera.Profile = capability.previewProfiles[0];
  //     let maxResolution: number = 0;
  //     for (let index = 0; index < capability.previewProfiles.length; index++) {
  //       const tempProfile = capability.previewProfiles[index];
  //       let tempRatio = tempProfile.size.width >= tempProfile.size.height ?
  //         tempProfile.size.width / tempProfile.size.height : tempProfile.size.height / tempProfile.size.width;
  //       let currentRatio = Math.abs(tempRatio - surfaceRatio);
  //       let resolution: number = tempProfile.size.width * tempProfile.size.height;
  //       if (currentRatio <= minRatioDiff && tempProfile.format === camera.CameraFormat.CAMERA_FORMAT_YUV_420_SP) {
  //         if (resolution > maxResolution) {
  //           maxResolution = resolution;
  //           previewProfile = tempProfile;
  //         }
  //       }
  //     }
  //     this.imageWidth = previewProfile.size.width; // 更新xComponent组件的宽。
  //     this.imageHeight = previewProfile.size.height; // 更新xComponent组件的高。
  //     console.info(`initCamera imageWidth:${this.imageWidth} imageHeight:${this.imageHeight}`);
  //
  //     // 使用xComponentSurfaceId创建预览。
  //     this.previewOutput = this.cameraManager.createPreviewOutput(previewProfile, this.xComponentSurfaceId);
  //     if (!this.previewOutput) {
  //       console.error('initCamera createPreviewOutput');
  //       this.releaseCamera();
  //       return;
  //     }
  //
  //     // 创建录像模式相机会话。
  //     let session = this.cameraManager.createSession(camera.SceneMode.NORMAL_VIDEO);
  //     if (!session) {
  //       console.error('session is null');
  //       this.releaseCamera();
  //       return;
  //     }
  //     this.session = session as camera.VideoSession;
  //     // 开始配置会话。
  //     this.session.beginConfig();
  //     // 添加相机设备输入。
  //     this.session.addInput(this.cameraInput);
  //     // 添加预览流输出。
  //     this.session.addOutput(this.previewOutput);
  //     // 提交会话配置。
  //     await this.session.commitConfig();
  //     // 开始启动已配置的输入输出流。
  //     await this.session.start();
  //   } catch (error) {
  //     console.error(`initCamera fail: ${JSON.stringify(error)}`);
  //     this.releaseCamera();
  //   }
  // }

  // // 释放相机。
  // async releaseCamera(): Promise<void> {
  //   console.info('releaseCamera');
  //   // 停止当前会话。
  //   await this.session?.stop().catch((e: BusinessError) => {
  //     console.error('Failed to stop session: ', e)
  //   });
  //   // 释放相机输入流。
  //   await this.cameraInput?.close().catch((e: BusinessError) => {
  //     console.error('Failed to close the camera: ', e)
  //   });
  //   // 释放预览输出流。
  //   await this.previewOutput?.release().catch((e: BusinessError) => {
  //     console.error('Failed to stop the preview stream: ', e)
  //   });
  //   // 释放会话。
  //   await this.session?.release().catch((e: BusinessError) => {
  //     console.error('Failed to release session: ', e)
  //   });
  // }

  async initCamera(context: common.Context, surfaceId: string) {
    try {
      this.cameraManager = camera.getCameraManager(context);
    } catch (error) {
      Logger.error(TAG, `camera.getCameraManager failed. error is: ${JSON.stringify(error)}`);
    }

    if (!this.cameraManager) {
      Logger.error(TAG, 'camera.getCameraManager error');
      return;
    }

    this.cameraManager.on('cameraStatus', (err: BusinessError, cameraStatusInfo: camera.CameraStatusInfo) => {
      if (err) {
        Logger.error(TAG, `cameraStatus call failed. error code: ${err.code}`);
      }
      Logger.info(TAG, `camera : ${cameraStatusInfo.camera.cameraId}`);
      Logger.info(TAG, `status:  ${cameraStatusInfo.status}`);
    });

    let cameraArray: Array<camera.CameraDevice> = [];
    try {
      cameraArray = this.cameraManager.getSupportedCameras();
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `getSupportedCameras call failed. error code: ${err.code}`);
    }

    if (cameraArray.length <= 0) {
      Logger.error(TAG, 'cameraManager.getSupportedCameras error');
      return;
    }

    let cameraIndex: number = this.mCameraPosition === camera.CameraPosition.CAMERA_POSITION_BACK ? 0 : 1;
    if (cameraIndex >= cameraArray.length) {
      cameraIndex = 0;
    }
    let targetCamera: camera.CameraDevice = cameraArray[cameraIndex];
    Logger.info(TAG, `Target camera position: ${this.mCameraPosition}, cameraId: ${targetCamera.cameraId}, index: ${cameraIndex}`);

    let cameraOutputCap: camera.CameraOutputCapability =
      this.cameraManager.getSupportedOutputCapability(targetCamera, camera.SceneMode.NORMAL_VIDEO);
    if (!cameraOutputCap) {
      Logger.error(TAG, 'cameraManager.getSupportedOutputCapability error');
      return;
    }
    Logger.info(TAG, 'outputCapability: ' + JSON.stringify(cameraOutputCap));

    let previewProfilesArray: Array<camera.Profile> = cameraOutputCap.previewProfiles;
    if (!previewProfilesArray) {
      Logger.error(TAG, 'createOutput previewProfilesArray === null || undefined');
    }

    let photoProfilesArray: Array<camera.Profile> = cameraOutputCap.photoProfiles;
    if (!photoProfilesArray) {
      Logger.error(TAG, 'createOutput photoProfilesArray === null || undefined');
    }

    // [Start recording_parameters]
    let videoProfilesArray: Array<camera.VideoProfile> = cameraOutputCap.videoProfiles;
    if (!videoProfilesArray) {
      Logger.error(TAG, 'createOutput videoProfilesArray === null || undefined');
    }
    // [StartExclude recording_parameters]
    // [Start set_profile]
    let videoSize: camera.Size = {
      width: 1920,
      height: 1080
    }

    // [Start create_video_output]
    let videoProfile: undefined | camera.VideoProfile = videoProfilesArray.find((profile: camera.VideoProfile) => {
      return profile.size.width === videoSize.width && profile.size.height === videoSize.height;
    });
    // [StartExclude create_video_output]
    if (!videoProfile) {
      Logger.error(TAG, 'videoProfile is not found');
      return;
    }
    // [EndExclude create_video_output]
    // [EndExclude recording_parameters]

    let aVRecorderProfile: media.AVRecorderProfile = {
      // [StartExclude set_profile]
      // [StartExclude recording_parameters]
      audioBitrate: 48000,
      audioChannels: 2,
      audioCodec: media.CodecMimeType.AUDIO_AAC,
      audioSampleRate: 48000,
      // [EndExclude recording_parameters]
      fileFormat: media.ContainerFormatType.CFT_MPEG_4,
      videoBitrate: 2000000,
      // [EndExclude set_profile]
      videoCodec: media.CodecMimeType.VIDEO_HEVC,
      // [StartExclude set_profile]
      videoFrameWidth: videoSize.width,
      videoFrameHeight: videoSize.height,
      videoFrameRate: 30
      // [EndExclude set_profile]
    };
    // [End set_profile]

    // [StartExclude create_video_output]
    let aVRecorderConfig: media.AVRecorderConfig = {
      // [StartExclude recording_parameters]
      audioSourceType: media.AudioSourceType.AUDIO_SOURCE_TYPE_MIC,
      // [EndExclude recording_parameters]
      videoSourceType: media.VideoSourceType.VIDEO_SOURCE_TYPE_SURFACE_YUV,
      profile: aVRecorderProfile,
      url: this.url,
      rotation: 90,
      // [StartExclude recording_parameters]
      location: {
        latitude: 30,
        longitude: 130
      }
      // [EndExclude recording_parameters]
    };
    // [End recording_parameters]

    // [Start create_av_recorder]
    // Creating an AVRecorder Instance
    try {
      this.avRecorder = await media.createAVRecorder();
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `createAVRecorder call failed. error code: ${err.code}`);
    }
    // [End create_av_recorder]

    if (this.avRecorder === undefined) {
      return;
    }
    // [EndExclude create_video_output]

    try {
      await this.avRecorder.prepare(aVRecorderConfig);
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `prepare call failed. error code: ${err.code}`);
    }

    let videoSurfaceId: string | undefined = undefined;
    try {
      videoSurfaceId = await this.avRecorder.getInputSurface();
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `getInputSurface call failed. error code: ${err.code}`);
    }
    if (videoSurfaceId === undefined) {
      return;
    }

    try {
      this.videoOutput = this.cameraManager.createVideoOutput(videoProfile, videoSurfaceId);
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `Failed to create the videoOutput instance. error: ${JSON.stringify(err)}`);
    }
    // [End create_video_output]

    if (this.videoOutput === undefined) {
      return;
    }
    this.videoOutput.on('frameStart', () => {
      Logger.info(TAG, 'Video frame started');
    });

    this.videoOutput.on('error', (error: BusinessError) => {
      Logger.info(TAG, `Preview output error code: ${error.code}`);
    });

    // [Start set_session]
    // Create and configure a camera session
    try {
      this.captureSession = this.cameraManager.createSession(camera.SceneMode.NORMAL_VIDEO) as camera.VideoSession;
      ;
    } catch (error) {
      // [StartExclude set_session]
      let err = error as BusinessError;
      Logger.error(TAG, 'Failed to create the CaptureSession instance. errorCode = ' + err.code);
      // [EndExclude set_session]
    }
    // [StartExclude set_session]
    if (this.captureSession === undefined) {
      return;
    }
    // [EndExclude set_session]

    try {
      this.captureSession.beginConfig();
    } catch (error) {
      // [StartExclude set_session]
      let err = error as BusinessError;
      Logger.error(TAG, 'Failed to beginConfig. errorCode = ' + err.code);
      // [EndExclude set_session]
    }

    // [StartExclude set_session]
    let cameraInput: camera.CameraInput | undefined = undefined;
    try {
      cameraInput = this.cameraManager.createCameraInput(targetCamera);
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `Failed to createCameraInput. error: ${JSON.stringify(err)}`);
    }
    if (cameraInput === undefined) {
      return;
    }

    let cameraDevice: camera.CameraDevice = targetCamera;
    cameraInput.on('error', cameraDevice, (error: BusinessError) => {
      Logger.info(TAG, `Camera input error code: ${error.code}`);
    });

    try {
      await cameraInput.open();
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `Failed to open cameraInput. error: ${JSON.stringify(err)}`);
    }

    try {
      this.captureSession.addInput(cameraInput);
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `Failed to add cameraInput. error: ${JSON.stringify(err)}`);
    }

    let previewOutput: camera.PreviewOutput | undefined = undefined;
    try {
      previewOutput = this.cameraManager.createPreviewOutput(videoProfile, surfaceId);
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `Failed to create the PreviewOutput instance. error: ${JSON.stringify(err)}`);
    }

    if (previewOutput === undefined) {
      return;
    }

    try {
      this.captureSession.addOutput(previewOutput);
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `Failed to add previewOutput. error: ${JSON.stringify(err)}`);
    }

    try {
      this.captureSession.addOutput(this.videoOutput);
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `Failed to add videoOutput. error: ${JSON.stringify(err)}`);
    }
    // [EndExclude set_session]

    try {
      await this.captureSession.commitConfig();
    } catch (error) {
      // [StartExclude set_session]
      let err = error as BusinessError;
      Logger.error(TAG, `captureSession commitConfig error: ${JSON.stringify(err)}`);
      // [EndExclude set_session]
    }

    try {
      await this.captureSession.start();
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `captureSession start error: ${JSON.stringify(err)}`);
    }
    // [End set_session]

    // [Start start_fn]
    try {
      this.videoOutput.start((err: BusinessError) => {
        if (err) {
          Logger.error(TAG, `Failed to start the video output. error: ${JSON.stringify(err)}`);
          return;
        }
        Logger.info(TAG, 'Callback invoked to indicate the video output start success.');
      });
    } catch (e) {
    }
    // [End start_fn]
  }

  // [Start start_record]
  async startRecord() {
    if (this.avRecorder) {
      try {
        this.recordStartTime = Date.now();
        await this.avRecorder.start();
      } catch (error) {
        let err = error as BusinessError;
        Logger.error(TAG, `avRecorder start error: ${JSON.stringify(err)}`);
      }
    }
  }

  // [End start_record]

  async stopRecord() {
    if (this.avRecorder) {
      try {
        if (this.videoOutput) {
          this.videoOutput.stop((err: BusinessError) => {
            if (err) {
              Logger.error(TAG, `Failed to stop the video output. error: ${JSON.stringify(err)}`);
              return;
            }
            Logger.info(TAG, `Callback invoked to indicate the video output stop success.${this.path}`);
          });
        }
        try {
          await this.avRecorder.stop();
          await this.avRecorder.release();
        } catch (error) {
          let err = error as BusinessError;
          Logger.error(TAG, `avRecorder stop error: ${JSON.stringify(err)}`);
        }
      } catch (error) {
        let err = error as BusinessError;
        Logger.error(TAG, `avRecorder stop error: ${JSON.stringify(err)}`);
      }
      this.recordDuration = Date.now() - this.recordStartTime;
      let metadata: RecordingMetadata = {
        title: this.liveStreamer.title,
        startTime: this.recordStartTime,
        duration: this.recordDuration
      };
      let metadataPath = this.getUIContext().getHostContext()!.filesDir + '/live_info_' + this.recordNameExo + '.json';
      FileUtil.writeStrToFile(metadataPath, JSON.stringify(metadata));
      Logger.info(TAG, `Metadata saved: ${metadataPath}`);
      Logger.info(TAG, `Video file: ${this.path}`);
      this.releaseCamera();
    }
  }

  releaseCamera() {
    try {
      if (this.captureSession) {
        this.captureSession.stop();
      }
      if (this.cameraInput) {
        this.cameraInput.close();
      }
      if (this.previewOutput) {
        this.previewOutput.release();
      }
      if (this.videoOutput) {
        this.videoOutput.release();
      }
      if (this.captureSession) {
        this.captureSession.release();
      }
      if (this.captureSession) {
        this.captureSession = undefined;
      }
      if (this.avRecorder) {
        this.avRecorder.release();
      }
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `avRecorder stop error: ${JSON.stringify(err)}`);
    }
  }
}

@Builder
export function CameraPageBuilder() {
  CameraPage()
}
