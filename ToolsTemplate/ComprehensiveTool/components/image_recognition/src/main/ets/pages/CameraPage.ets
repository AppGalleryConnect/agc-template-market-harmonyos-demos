import { LoadingDialog } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { CameraService } from '../util/CameraUtil';
import { GlobalContext } from '../util/GlobalContext';
import { NavTitle } from '../components/NavTitle';


@Builder
export function CameraPageBuilder() {
  CameraPage();
}


@ComponentV2
struct CameraPage {
  loadingController: CustomDialogController = new CustomDialogController({
    builder: LoadingDialog({
      content: '图片处理中...',
    }),
    autoCancel: false,
  });
  private xComponentCtl: XComponentController = new XComponentController();
  private xComponentSurfaceId: string = '';
  private cameraManager: CameraService = new CameraService();
  private isProgress: boolean = false;

  aboutToAppear(): void {
    const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    // 注册回调
    this.cameraManager.setPhotoCallBack(this.startLoading);
    this.cameraManager.setRecognizeCallBack(this.offLoading);
    // 保存context
    GlobalContext.get().setCameraSettingContext(context);
  }

  aboutToDisappear(): void {
    this.xComponentSurfaceId = '';
    this.cameraManager.releaseCamera();
  }

  build() {
    NavDestination() {
      NavTitle({
        isDark: true,
      });
      Stack() {
        XComponent({
          id: 'componentId',
          type: XComponentType.SURFACE,
          controller: this.xComponentCtl,
        })
          .onLoad(async () => {
            this.xComponentSurfaceId = this.xComponentCtl.getXComponentSurfaceId(); // 获取组件surfaceId
            // 初始化相机，组件实时渲染每帧预览流数据
            this.cameraManager.initCamera(this.xComponentSurfaceId);
          })
          .width('100%')
          .height('100%');
      }
      .layoutWeight(1)
      .width('100%');

      Column() {
        Image($r('app.media.camera_button')).width(60).height(60).margin({ top: 38, bottom: 38 })
          .onClick(() => {
            if (!this.isProgress) {
              this.cameraManager.capture();
            }
          });
      }.width('100%');
    }
    .backgroundColor($r('sys.color.black'))
    .hideTitleBar(true)
    .systemBarStyle({ statusBarContentColor: '#FFFFFF' })
    .onHidden(() => {
      this.cameraManager.releaseCamera();
    })
    .onShown(() => {
      if (this.xComponentSurfaceId) {
        this.cameraManager.initCamera(this.xComponentSurfaceId);
      }
    });
  }

  private startLoading: () => void = () => {
    this.loadingController.open();
    this.isProgress = true
  };
  private offLoading: () => void = () => {
    this.loadingController.close();
    this.isProgress = false
  };
}