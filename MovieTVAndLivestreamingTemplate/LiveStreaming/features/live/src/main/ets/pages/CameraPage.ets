import { camera } from '@kit.CameraKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { abilityAccessCtrl, Permissions } from '@kit.AbilityKit';
import { LivePage } from './LivePage'

import { LiveMsgModel } from '../models/LiveModel'
import { MockAudienceFactory, AudienceRes } from '@agctemplate/server/src/main/ets/api/mock/mockAudienceFactory'
import { DetailPageComponent } from './DetailPageComponent'

@ComponentV2
struct CameraPage {
  private xComponentCtl: XComponentController = new XComponentController();
  private xComponentSurfaceId: string = '';
  @Local imageWidth: number = 1920;
  @Local imageHeight: number = 1080;
  private cameraManager: camera.CameraManager | undefined = undefined;
  @Provider('mCameraPosition') mCameraPosition: camera.CameraPosition = camera.CameraPosition.CAMERA_POSITION_BACK;
  private cameras: Array<camera.CameraDevice> | Array<camera.CameraDevice> = [];
  private cameraInput: camera.CameraInput | undefined = undefined;
  private previewOutput: camera.PreviewOutput | undefined = undefined;
  private session: camera.VideoSession | undefined = undefined;
  private uiContext: UIContext = this.getUIContext();
  private context: Context | undefined = this.uiContext.getHostContext();
  private cameraPermission: Permissions = 'ohos.permission.CAMERA'; // 申请权限相关问题可参考本篇开头的申请相关权限文档
  @Local isShow: boolean = false;
  @Provider('isLive') isLive: boolean = false;
  @Local liveStreamer: LiveMsgModel = LiveMsgModel.instance
  @Local audienceList: Array<AudienceRes> = new MockAudienceFactory().getAllAudience()

  @Monitor('mCameraPosition')
  onCameraChange() {
    this.initCamera(this.mCameraPosition)
  }

  async requestPermissionsFn(): Promise<void> {
    let atManager = abilityAccessCtrl.createAtManager();
    if (this.context) {
      let res = await atManager.requestPermissionsFromUser(this.context, [this.cameraPermission]);
      for (let i = 0; i < res.permissions.length; i++) {
        if (this.cameraPermission.toString() === res.permissions[i] && res.authResults[i] === 0) {
          this.isShow = true;
        }
      }
    }
  }

  async aboutToDisappear() {
    await this.releaseCamera()
  }

  aboutToAppear(): void {
    this.requestPermissionsFn();
  }

  onPageShow(): void {
    console.info('onPageShow');
    if (this.xComponentSurfaceId !== '') {
      this.initCamera(this.mCameraPosition);
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
              })
              .renderFit(RenderFit.RESIZE_COVER)
          }
        }
        .height('100%')
        .width('100%')

        if (this.isLive) {
          DetailPageComponent({
            audienceList: this.audienceList
          })

        } else {
          LivePage()
        }

      }
    }
    .hideTitleBar(true)
    .hideToolBar(true)
    .onWillShow(() => {
      this.isLive = false
    })
    .onShown(() => {
      this.initCamera(this.mCameraPosition)
    })
    .onBackPressed(() => {
      if (this.isLive) {
        return true
      }
      return false
    })
  }

  // 初始化相机。
  async initCamera(mCameraPosition: camera.CameraPosition): Promise<void> {
    console.info(`initCamera previewOutput xComponentSurfaceId:${this.xComponentSurfaceId}`);
    try {
      await this.releaseCamera()
      // 获取相机管理器实例。
      this.cameraManager = camera.getCameraManager(this.context);
      if (!this.cameraManager) {
        console.error('initCamera getCameraManager');
        return;
      }
      // 获取当前设备支持的相机device列表。
      this.cameras = this.cameraManager.getSupportedCameras();
      if (!this.cameras) {
        console.error('initCamera getSupportedCameras');
      }

      let deviceIndex = this.cameras.findIndex((cameraDevice: camera.CameraDevice) => {
        return cameraDevice.cameraPosition === mCameraPosition
      })
      // 没有找到对应位置的摄像头，可选择其他摄像头，具体场景具体对待。
      if (deviceIndex === -1) {
        deviceIndex = 0;
      }
      console.info(`${deviceIndex}`)
      // 选择一个相机device，创建cameraInput输出对象。
      this.cameraInput = this.cameraManager.createCameraInput(this.cameras[deviceIndex]);
      if (!this.cameraInput) {
        console.error('initCamera createCameraInput');
        return;
      }

      // 打开相机。
      await this.cameraInput.open();

      // 获取相机device支持的profile。
      let capability: camera.CameraOutputCapability =
        this.cameraManager.getSupportedOutputCapability(this.cameras[deviceIndex], camera.SceneMode.NORMAL_VIDEO);
      if (!capability || capability.previewProfiles.length === 0) {
        console.error('capability is null || []');
        this.releaseCamera();
        return;
      }
      let minRatioDiff: number = 0.1;
      let surfaceRatio: number = this.imageWidth / this.imageHeight; // 最接近16:9宽高比。
      let previewProfile: camera.Profile = capability.previewProfiles[0];
      // 应用开发者根据实际业务需求选择一个支持的预览流previewProfile。
      // 此处以选择CAMERA_FORMAT_YUV_420_SP（NV21）格式、满足限定条件分辨率的预览流previewProfile为例。
      for (let index = 0; index < capability.previewProfiles.length; index++) {
        const tempProfile = capability.previewProfiles[index];
        let tempRatio = tempProfile.size.width >= tempProfile.size.height ?
          tempProfile.size.width / tempProfile.size.height : tempProfile.size.height / tempProfile.size.width;
        let currentRatio = Math.abs(tempRatio - surfaceRatio);
        if (currentRatio <= minRatioDiff && tempProfile.format === camera.CameraFormat.CAMERA_FORMAT_YUV_420_SP) {
          previewProfile = tempProfile;
          break;
        }
      }
      this.imageWidth = previewProfile.size.width; // 更新xComponent组件的宽。
      this.imageHeight = previewProfile.size.height; // 更新xComponent组件的高。
      console.info(`initCamera imageWidth:${this.imageWidth} imageHeight:${this.imageHeight}`);

      // 使用xComponentSurfaceId创建预览。
      this.previewOutput = this.cameraManager.createPreviewOutput(previewProfile, this.xComponentSurfaceId);
      if (!this.previewOutput) {
        console.error('initCamera createPreviewOutput');
        this.releaseCamera();
        return;
      }

      // 创建录像模式相机会话。
      let session = this.cameraManager.createSession(camera.SceneMode.NORMAL_VIDEO);
      if (!session) {
        console.error('session is null');
        this.releaseCamera();
        return;
      }
      this.session = session as camera.VideoSession;
      // 开始配置会话。
      this.session.beginConfig();
      // 添加相机设备输入。
      this.session.addInput(this.cameraInput);
      // 添加预览流输出。
      this.session.addOutput(this.previewOutput);
      // 提交会话配置。
      await this.session.commitConfig();
      // 开始启动已配置的输入输出流。
      await this.session.start();
    } catch (error) {
      console.error(`initCamera fail: ${JSON.stringify(error)}`);
      this.releaseCamera();
    }
  }

  // 释放相机。
  async releaseCamera(): Promise<void> {
    console.info('releaseCamera');
    // 停止当前会话。
    await this.session?.stop().catch((e: BusinessError) => {
      console.error('Failed to stop session: ', e)
    });
    // 释放相机输入流。
    await this.cameraInput?.close().catch((e: BusinessError) => {
      console.error('Failed to close the camera: ', e)
    });
    // 释放预览输出流。
    await this.previewOutput?.release().catch((e: BusinessError) => {
      console.error('Failed to stop the preview stream: ', e)
    });
    // 释放会话。
    await this.session?.release().catch((e: BusinessError) => {
      console.error('Failed to release session: ', e)
    });
  }
}

@Builder
export function CameraPageBuilder() {
  CameraPage()
}
