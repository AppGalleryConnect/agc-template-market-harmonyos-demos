// model/PipManager.ets
import { PiPWindow, typeNode } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { MediaSource } from 'video_swiper';
import { TextNodeController } from './CustomNodeController';
import { PipVideoController } from './PipVideoController';

const TAG = 'Pip_Manager';

export class PipVideoConfig {
  index: number = 0;
  mediaSource: MediaSource[] = []
  pipListener?: PipListener
}

export class SurfaceListener {
  onSurfaceCreated: (surfaceId: string) => void = () => {
  }
  onSurfaceDestroyed: (surfaceId: string) => void = () => {
  }
}

export class CustomXComponentController extends XComponentController {
  onSurfaceCreated(surfaceId: string): void {
    console.log(TAG, `onSurfaceCreated surfaceId: ${surfaceId}`);
    PipManager.getInstance().onSurfaceCreated(surfaceId)
  }

  onSurfaceDestroyed(surfaceId: string): void {
    console.log(TAG, `onSurfaceDestroyed surfaceId: ${surfaceId}`);
    PipManager.getInstance().onSurfaceDestroyed(surfaceId)
  }
}

export class PipListener {
  onEnterPip?: () => PipVideoConfig
  onExitPip?: () => void
}

export class PipManager {
  private static instance: PipManager = new PipManager();
  private pipVideoController: PipVideoController = new PipVideoController
  private pipController?: PiPWindow.PiPController = undefined;
  private mXComponentController: XComponentController;
  private xComponent: typeNode.XComponent | null = null; // typeNode节点
  private nodeController: TextNodeController = new TextNodeController('');
  private pipVideoConfig?: PipVideoConfig

  public static getInstance(): PipManager {
    return PipManager.instance;
  }

  constructor() {
    this.mXComponentController = new CustomXComponentController();
  }

  public getIndex() {
    return this.pipVideoController.index
  }

  onActionEvent(control: PiPWindow.ControlEventParam) {
    switch (control.controlType) {
      case PiPWindow.PiPControlType.VIDEO_PLAY_PAUSE:
        if (control.status === PiPWindow.PiPControlStatus.PAUSE) {
          //停止视频
          this.pipVideoController.pause()
        } else if (control.status === PiPWindow.PiPControlStatus.PLAY) {
          //播放视频
          this.pipVideoController.play()
        }
        break;
      case PiPWindow.PiPControlType.VIDEO_NEXT:
        // 切换到下一个视频
        break;
      case PiPWindow.PiPControlType.VIDEO_PREVIOUS:
        // 切换到上一个视频
        break;
      case PiPWindow.PiPControlType.FAST_FORWARD:
        // 视频进度快进
        break;
      case PiPWindow.PiPControlType.FAST_BACKWARD:
        // 视频进度后退
        break;
      default:
        break;
    }
    console.info('onActionEvent, controlType:' + control.controlType + ', status' + control.status);
  }

  // 监听画中画生命周期
  onStateChange(state: PiPWindow.PiPState, reason: string) {
    console.info(TAG, 'onStateChange begin')
    let curState: string = '';
    if (this.lifeCycleCallback !== null) {
      console.info(TAG, 'onStateChange, lifeCycleCallback size:' + this.lifeCycleCallback.size);
      this.lifeCycleCallback.forEach((fun) => {
        fun(state);
      });
    }
    switch (state) {
      case PiPWindow.PiPState.ABOUT_TO_START:
        curState = 'ABOUT_TO_START';
        break;
      case PiPWindow.PiPState.STARTED:
        curState = 'STARTED';
        break;
      case PiPWindow.PiPState.ABOUT_TO_STOP:
        curState = 'ABOUT_TO_STOP';
        break;
      case PiPWindow.PiPState.STOPPED:
        curState = 'STOPPED';
        break;
      case PiPWindow.PiPState.ABOUT_TO_RESTORE:
        curState = 'ABOUT_TO_RESTORE';
        break;
      case PiPWindow.PiPState.ERROR:
        curState = 'ERROR';
        break;
      default:
        break;
    }
    console.info(`[${TAG}] onStateChange: ${curState}, reason: ${reason}`);
  }

  registerPipStateChangeListener() {
    console.info(TAG, 'registerPipStateChangeListener');
    // 通过画中画控制器实例的on('stateChange')接口注册生命周期事件回调
    try {
      this.pipController?.on('stateChange', (state: PiPWindow.PiPState, reason: string) => {
        this.onStateChange(state, reason);
      });
      // 通过画中画控制器实例的on('controlEvent')接口注册控制事件回调
      this.pipController?.on('controlEvent', (control: PiPWindow.ControlEventParam) => {
        this.onActionEvent(control);
      });
    } catch (e) {
      console.error(TAG, `registerPipStateChangeListener failed: ${e}`);
    }
  }

  // 解注册监听
  unregisterPipStateChangeListener() {
    console.info(TAG, 'unregisterPipStateChangeListener');
    this.pipController?.off('stateChange');
    this.pipController?.off('controlEvent');
  }

  getXComponentController(): CustomXComponentController {
    return this.mXComponentController;
  }

  // 步骤1：创建画中画控制器，注册生命周期事件以及控制事件回调
  init(ctx: Context) {
    if (this.pipController !== null && this.pipController !== undefined) {
      return;
    }
    console.info(TAG, 'onPageShow');
    if (!PiPWindow.isPiPEnabled()) {
      console.error(TAG, `picture in picture disabled for current OS`);
      return;
    }

    let config: PiPWindow.PiPConfiguration = {
      context: ctx,
      componentController: this.getXComponentController(),
      templateType: PiPWindow.PiPTemplateType.VIDEO_PLAY,
      contentWidth: 1080, // 使用typeNode启动画中画时，contentWidth需设置为大于0的值，否则将设置为16:9默认比例
      contentHeight: 1920, // 使用typeNode启动画中画时，contentHeight需设置为大于0的值，否则将设置为16:9默认比例
      customUIController: this.nodeController
    };
    // 通过create接口创建画中画控制器实例

    PiPWindow.create(config, this.xComponent).then((controller: PiPWindow.PiPController) => {
      this.pipController = controller;
      // 通过画中画控制器实例的setAutoStartEnabled接口设置是否需要在应用返回桌面时自动启动画中画
      this.pipController.setAutoStartEnabled(true);
      // this.registerPipStateChangeListener()
      this.pipVideoController.setCustomUIController(this.nodeController)
    }).catch((err: BusinessError) => {
      console.error(TAG, `Failed to create pip controller. Cause:${err.code}, message:${err.message}`);
    });
  }

  // 步骤2：创建画中画控制器实例后，通过startPiP接口启动画中画
  startPip(pipVideoConfig: PipVideoConfig) {
    console.info(TAG, `startPip.`);
    this.nodeController.update('')
    this.pipVideoConfig = pipVideoConfig
    this.pipVideoController.setPlayList(pipVideoConfig.mediaSource)
  }

  // 步骤3：更新媒体源尺寸信息
  updateContentSize(width: number, height: number) {
    if (this.pipController) {
      this.pipController.updateContentSize(width, height);
    }
  }

  // 步骤4：关闭画中画
  stopPip() {
    if (this.pipController === null || this.pipController === undefined) {
      return;
    }
    let promise: Promise<void> = this.pipController.stopPiP();
    promise.then(() => {
      console.info(TAG, `Succeeded in stopping pip.`);
    }).catch((err: BusinessError) => {
      console.error(TAG, `Failed to stop pip. Cause:${err.code}, message:${err.message}`);
    });
  }

  setAutoStart(autoStart: boolean): void {
    this.pipController?.setAutoStartEnabled(autoStart);
  }

  // 创建typeNode节点
  makeTypeNode(ctx: UIContext) {
    if (this.xComponent === null || this.xComponent === undefined) {
      // 创建XComponent类型的typeNode
      try {
        this.xComponent = typeNode.createNode(ctx, 'XComponent', {
          type: XComponentType.SURFACE, // 类型设置为SURFACE
          controller: PipManager.getInstance().getXComponentController(), // 设置XComponentController
        });
      } catch (e) {
      }
    }
  }

  onSurfaceCreated(surfaceId: string): void {
    console.log(TAG, `onSurfaceCreated surfaceId: ${surfaceId}`);
    this.pipVideoController.pipSurfaceId = surfaceId
    if (this.pipVideoConfig) {
      console.log(TAG, `onSurfaceCreated playIndex: ${this.pipVideoConfig.index}`);
      this.pipVideoController.playIndex(this.pipVideoConfig.index)
    }

  }

  onPlaybackStatus(isPlay: boolean) {
    let status: PiPWindow.PiPControlStatus =
      isPlay ? PiPWindow.PiPControlStatus.PLAY : PiPWindow.PiPControlStatus.PAUSE;
    this.pipController?.updatePiPControlStatus(PiPWindow.PiPControlType.VIDEO_PLAY_PAUSE, status)
  }

  onSurfaceDestroyed(surfaceId: string): void {
    console.log(TAG, `onSurfaceDestroyed surfaceId: ${surfaceId}`);
    this.pipVideoController.pipSurfaceId = undefined
    this.pipVideoConfig?.pipListener?.onExitPip?.()
  }

  private lifeCycleCallback: Set<Function> = new Set();

  public registerLifecycleCallback(callBack: Function) {
    console.info(TAG, `registerLifecycleCallback.`);
    this.lifeCycleCallback.add(callBack);
  }

  public unRegisterLifecycleCallback(callBack: Function): void {
    console.info(TAG, `unRegisterLifecycleCallback.`);
    this.lifeCycleCallback.delete(callBack);
  }
}